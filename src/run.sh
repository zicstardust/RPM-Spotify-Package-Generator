#!/usr/bin/env bash

set -e
: "${INTERVAL:=1d}"
: "${STABLE_BUILDS:=true}"
: "${TESTING_BUILDS:=false}"
: "${SRPMS_BUILDS:=false}"
: "${BUILTIN_FFMPEG:=true}"
: "${BUILD:=el10}"
: "${LOG_LEVEL:=info}"
: "${ENTERPRISE_LINUX_BACKEND:=alma}"
: "${SOURCE:=deb}"

IFS="," read -ra distros <<< "$BUILD"

export STABLE_BUILDS
export TESTING_BUILDS
export SRPMS_BUILDS
export BUILTIN_FFMPEG
export BUILD
export LOG_LEVEL
export ENTERPRISE_LINUX_BACKEND
export SOURCE

export BUILD_DIR="/home/spotify/rpmbuild"
export SOURCES_DIR="${BUILD_DIR}/SOURCES"
export MAIN_LOG_NAME="spotify-rpm-packager"

getdate(){
    local dateformat=$1

    if [ "$dateformat" = "log" ]; then
        echo "$(date +%Y-%m-%d)"
    else
        echo "[$(date "+%m-%d-%Y %H:%M:%S")]"
    fi
}

logs() {
    local log_file=$1
    local loglevel="${2:-$LOG_LEVEL}"

    if [ "$loglevel" = "all" ]; then
        if [ "$LOG_LEVEL" = "info" ]; then
            tee -a /dev/null
        else
            stdbuf -oL tee -a "/logs/${log_file}.log"
        fi
    elif [ "$loglevel" = "file" ]; then
        cat >> "/logs/${log_file}.log"
    else
        cat >> /dev/null
    fi
}

export -f getdate
export -f logs




check_if_all_builds_exist(){
    local SPOTIFY_BRANCH=$1
    local SPOTIFY_VERSION=$2

    for item in "${distros[@]}"; do
        echo "$(getdate) - Checking if exists .rpm to spotify ${SPOTIFY_VERSION} - ${item}..." | logs "$(getdate "log").${MAIN_LOG_NAME}"


        release="${item:2}"

        if [ ! -e "$(ls /data/${release}/x86_64/${SPOTIFY_BRANCH}/Packages/spotify-client-${SPOTIFY_VERSION}*.x86_64.rpm 2> /dev/null)" ]; then
            echo "$(getdate) - Not found: data/${release}/x86_64/${SPOTIFY_BRANCH}/Packages/spotify-client-${SPOTIFY_VERSION}*.x86_64.rpm" | logs "$(getdate "log").${MAIN_LOG_NAME}"
            echo "false" > /tmp/all_builds_exists
            return
        else
            echo "$(getdate) - Found: data/${release}/x86_64/${SPOTIFY_BRANCH}/Packages/spotify-client-${SPOTIFY_VERSION}*.x86_64.rpm" | logs "$(getdate "log").${MAIN_LOG_NAME}"
        fi

        if [[ "$SRPMS_BUILDS" =~ ^(1|true|True|y|Y)$ ]]; then
            if [ ! -e  "$(ls /data/${release}/source/${SPOTIFY_BRANCH}/Packages/spotify-client-${SPOTIFY_VERSION}*.src.rpm 2> /dev/null)" ]; then
                echo "$(getdate) - Not found: data/${release}/source/${SPOTIFY_BRANCH}/Packages/spotify-client-${SPOTIFY_VERSION}*.x86_64.rpm" | logs "$(getdate "log").${MAIN_LOG_NAME}"
                echo "false" > /tmp/all_builds_exists
                return
            else
                echo "$(getdate) - Found: data/${release}/source/${SPOTIFY_BRANCH}/Packages/spotify-client-${SPOTIFY_VERSION}*.x86_64.rpm" | logs "$(getdate "log").${MAIN_LOG_NAME}"
            fi
        fi
    done
    echo "true" > /tmp/all_builds_exists
}


build_RPM(){

    local SPOTIFY_BRANCH=$1

    if [ "$SOURCE" = "deb" ]; then
        parser_debian_control_file.py $SPOTIFY_BRANCH spotify-client Version
    elif [ "$SOURCE" = "snap" ]; then
        get_snap_version.sh $SPOTIFY_BRANCH
    else
        echo "$(getdate) - SOURCE \"${SOURCE}\" invalid" 2>&1 | logs $logfile "all"
        exit 1
    fi

    SPOTIFY_VERSION=$(cat /tmp/spotify-client.${SPOTIFY_BRANCH}.Version)

    check_if_all_builds_exist $SPOTIFY_BRANCH $SPOTIFY_VERSION
    check_builds=$(cat /tmp/all_builds_exists) 

    if [ "$check_builds" = "true" ]; then
        echo "$(getdate) - Not Found new Spotify ${SPOTIFY_BRANCH} version, skip" | logs "$(getdate "log").${MAIN_LOG_NAME}" "all"
        return
    fi
    
    echo "$(getdate) - New .${SOURCE} ${SPOTIFY_BRANCH} version found!" | logs "$(getdate "log").${MAIN_LOG_NAME}" "all"
    echo "$(getdate) - Downloading .${SOURCE}, latest ${SPOTIFY_BRANCH} version: $SPOTIFY_VERSION" 2>&1 | logs $logfile "all"
    download_spotify.sh $SPOTIFY_BRANCH $SPOTIFY_VERSION

    build_SRPM.sh $SPOTIFY_BRANCH $SPOTIFY_VERSION    

    for item in "${distros[@]}"; do
        build_RPM.sh $(ls ${BUILD_DIR}/SRPMS/spotify-client-${SPOTIFY_VERSION}*.src.rpm) $SPOTIFY_VERSION $SPOTIFY_BRANCH $item
    done

    cleanup.sh
}


#GPG Key
if [ "$GPG_NAME" ] && [ "$GPG_EMAIL" ]; then
    export GPG_TTY=$(tty)

    gpg --import /gpg-key/private.pgp 2>&1 | logs "$(getdate "log").${MAIN_LOG_NAME}" 
    gpg --import /gpg-key/public.pgp 2>&1 | logs "$(getdate "log").${MAIN_LOG_NAME}" 

    gpg --export -a "${GPG_EMAIL}" > /data/gpg

    set_rpmmacros.sh
fi

#.Repo File
if [ "$REPO_FILE_URL" ]; then
    echo "$(getdate) - Generating repo file..." | logs "$(getdate "log").${MAIN_LOG_NAME}" "all"
    generate_repofile.sh
fi


while :
do
    if [[ "$STABLE_BUILDS" =~ ^(1|true|True|y|Y)$ ]]; then
        build_RPM stable
    else
        echo "$(getdate) - Skip build stable RPM" | logs "$(getdate "log").${MAIN_LOG_NAME}" "all"
    fi

    if [[ "$TESTING_BUILDS" =~ ^(1|true|True|y|Y)$ ]]; then
        build_RPM testing
    else
        echo "$(getdate) - Skip build testing RPM" | logs "$(getdate "log").${MAIN_LOG_NAME}" "all"
    fi

    #Start interval
    if [[ "$INTERVAL" =~ ^(false|False|n|N)$ ]]; then
        echo "$(getdate) - Interval disable, exit" | logs "$(getdate "log").${MAIN_LOG_NAME}" "all"
        exit 0
    else
        echo "$(getdate) - Start INTERVAL: ${INTERVAL}" | logs "$(getdate "log").${MAIN_LOG_NAME}" "all"
        sleep ${INTERVAL}
    fi
done
