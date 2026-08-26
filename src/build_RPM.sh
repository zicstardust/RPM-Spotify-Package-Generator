#!/usr/bin/env bash

srpms_file=$1
SPOTIFY_VERSION=$2
SPOTIFY_BRANCH=$3
item=$4

logfile="$(getdate "log").build.${item}.${SPOTIFY_VERSION}"
logfile_createrepo="$(getdate "log").${MAIN_LOG_NAME}"

distro="${item:0:2}"
release="${item:2}"

if [ "$distro" == "fc" ]; then
    mock_file="fedora-${release}-x86_64"
elif [ "$distro" == "el" ]; then
    mock_file="${ENTERPRISE_LINUX_BACKEND}+epel-${release}-x86_64"
fi


if [ ! -e "/etc/mock/${mock_file}.cfg" ]; then
    echo "$(getdate) - BUILD: ${item} invalid!" 2>&1 | logs $logfile "all"
    exit 0
fi


if [ -e "$(ls /data/${release}/x86_64/${SPOTIFY_BRANCH}/Packages/spotify-client-${SPOTIFY_VERSION}*.x86_64.rpm 2> /dev/null)" ]; then
    echo "$(getdate) - spotify-client:${SPOTIFY_VERSION} RPM to ${mock_file} exists, skip" 2>&1 | logs  $logfile "all"
    if [[ "$SRPMS_BUILDS" =~ ^(1|true|True|y|Y)$ ]]; then
        if [ -e "$(ls /data/${release}source/${SPOTIFY_BRANCH}/Packages/spotify-client-${SPOTIFY_VERSION}*.src.rpm 2> /dev/null)" ]; then
            echo "$(getdate) - spotify-client:${SPOTIFY_VERSION} SRPM to ${mock_file} exists, skip" 2>&1 | logs  $logfile "all"
            exit 0
        fi
    else 
        exit 0
    fi
fi

echo "$(getdate) - Building spotify-client:${SPOTIFY_VERSION} branch:${SPOTIFY_BRANCH} to ${item}..." 2>&1 | logs  $logfile "all"
mock -r ${mock_file} --rebuild $srpms_file 2>&1 | logs  $logfile



if [ "$GPG_NAME" ] && [ "$GPG_EMAIL" ]; then
    echo "$(getdate) - Signing RPMs spotify-client:${SPOTIFY_VERSION} to ${item}..." 2>&1 | logs  $logfile "all"
    rpm --addsign /var/lib/mock/${mock_file}/result/spotify-client-${SPOTIFY_VERSION}*.x86_64.rpm 2>&1 | logs $logfile
    rpm --addsign /var/lib/mock/${mock_file}/result/spotify-client-${SPOTIFY_VERSION}*.src.rpm 2>&1 | logs $logfile
fi


mkdir -p /data/${release}/x86_64/${SPOTIFY_BRANCH}/Packages/
cp /var/lib/mock/${mock_file}/result/spotify-client-${SPOTIFY_VERSION}*.x86_64.rpm /data/${release}/x86_64/${SPOTIFY_BRANCH}/Packages/
remove_old_rpms.sh /data/${release}/x86_64/${SPOTIFY_BRANCH}/Packages
createrepo /data/${release}/x86_64/${SPOTIFY_BRANCH}/ 2>&1 | logs $logfile_createrepo


if [[ "$SRPMS_BUILDS" =~ ^(1|true|True|y|Y)$ ]]; then
    mkdir -p /data/${release}/source/${SPOTIFY_BRANCH}/Packages/
    cp /var/lib/mock/${mock_file}/result/spotify-client-${SPOTIFY_VERSION}*.src.rpm /data/${release}/source/${SPOTIFY_BRANCH}/Packages/
    remove_old_rpms.sh /data/${release}/source/${SPOTIFY_BRANCH}/Packages
    createrepo /data/${release}/source/${SPOTIFY_BRANCH}/ 2>&1 | logs $logfile_createrepo
fi
mock -r ${mock_file} --clean 2>&1 | logs $logfile
echo "$(getdate) - Finish: spotify-client, branch=${SPOTIFY_BRANCH}, version=${SPOTIFY_VERSION} to ${mock_file}!" 2>&1 | logs  $logfile "all"

