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



export STABLE_BUILDS
export TESTING_BUILDS
export SRPMS_BUILDS
export BUILTIN_FFMPEG
export BUILD
export LOG_LEVEL
export ENTERPRISE_LINUX_BACKEND

export BUILD_DIR="/home/spotify/rpmbuild"
export SOURCES_DIR="${BUILD_DIR}/SOURCES"

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
    local distros=$1
    local SPOTIFY_BRANCH=$2
    local SPOTIFY_VERSION=$3
    
    for item in "${distros[@]}"; do

        release="${item:2}"

        if ! [ "$(ls /data/${release}/x86_64/${SPOTIFY_BRANCH}/Packages/spotify-client-${SPOTIFY_VERSION}*.x86_64.rpm 2> /dev/null)" ]; then
            echo "false"
            return
        fi

        if [[ "$SRPMS_BUILDS" =~ ^(1|true|True|y|Y)$ ]]; then
            if ! [ "$(ls /data/${release}/source/${SPOTIFY_BRANCH}/Packages/spotify-client-${SPOTIFY_VERSION}*.src.rpm 2> /dev/null)" ]; then
                echo "false"
                return
            fi
        fi
    done
    echo "true"
    return
}


build_RPM(){

    local SPOTIFY_BRANCH=$1

    parser_debian_control_file.py $SPOTIFY_BRANCH spotify-client Version
    SPOTIFY_VERSION=$(cat /tmp/spotify-client.${SPOTIFY_BRANCH}.Version)
    IFS="," read -ra distros <<< "$BUILD"

    check_builds=$(check_if_all_builds_exist $distros $SPOTIFY_BRANCH $SPOTIFY_VERSION) 

    if [ "$check_builds" = "true" ]; then
        echo "$(getdate) - Not Found new .deb ${SPOTIFY_BRANCH} version, skip"
        return
    fi
    
    echo "$(getdate) - New .deb ${SPOTIFY_BRANCH} version found!"
    download_deb.sh $SPOTIFY_BRANCH $SPOTIFY_VERSION
    build_SRPM.sh $SPOTIFY_BRANCH $SPOTIFY_VERSION    

    for item in "${distros[@]}"; do
        build_RPM.sh $(ls ${BUILD_DIR}/SRPMS/spotify-client-${SPOTIFY_VERSION}*.src.rpm) $SPOTIFY_VERSION $SPOTIFY_BRANCH $item
    done

    cleanup.sh
}


#GPG Key
if [ "$GPG_NAME" ] && [ "$GPG_EMAIL" ]; then
    export GPG_TTY=$(tty)

    gpg --import /gpg-key/private.pgp 2>&1 | logs "$(getdate "log").rpm.gpg.import.log" 
    gpg --import /gpg-key/public.pgp 2>&1 | logs "$(getdate "log").rpm.gpg.import.log" 

    gpg --export -a "${GPG_EMAIL}" > /data/gpg

    set_rpmmacros.sh
fi

#.Repo File
if [ "$REPO_FILE_URL" ]; then
    echo "$(getdate) - Generating repo file..." | logs "$(getdate "log").generate.repofile.log" "all"
    generate_repofile.sh
fi


while :
do
    if [[ "$STABLE_BUILDS" =~ ^(1|true|True|y|Y)$ ]]; then
        build_RPM stable
    else
        echo "$(getdate) - Skip build stable RPM"
    fi

    if [[ "$TESTING_BUILDS" =~ ^(1|true|True|y|Y)$ ]]; then
        build_RPM testing
    else
        echo "$(getdate) - Skip build testing RPM"
    fi

    #Start interval
    if [[ "$INTERVAL" =~ ^(false|False|n|N)$ ]]; then
        echo "$(getdate) - Interval disable, exit"
        exit 0
    else
        echo "$(getdate) - Start INTERVAL: ${INTERVAL}"
        sleep ${INTERVAL}
    fi
done
