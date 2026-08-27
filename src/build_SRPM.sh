#!/usr/bin/env bash

SPOTIFY_BRANCH=$1
SPOTIFY_VERSION=$2
logfile="$(getdate "log").build.SRPM.${SPOTIFY_VERSION}"

#https://github.com/zicstardust/spotify-debfixes/releases
if [ "$SPOTIFY_BRANCH" == "stable" ]; then
    ffmpeg_spotify_release="7.1.5"
elif [ "$SPOTIFY_BRANCH" == "testing" ]; then
    ffmpeg_spotify_release="7.1.5"
fi

current_dir=$(pwd)
cd /tmp
source_file="/tmp/spotify-client_${SPOTIFY_VERSION}_amd64.${SOURCE}"
mkdir -v spotify-client-${SPOTIFY_VERSION} 2>&1 | logs $logfile
echo "$(getdate) - Extracting .${SOURCE}..." 2>&1 | logs $logfile "all"


if [ "$SOURCE" = "deb" ]; then
    # Extract .deb
    ar x ${source_file} 2>&1 | logs $logfile
    tar -xvf data.tar.gz 2>&1 | logs $logfile
    mv -v usr spotify-client-${SPOTIFY_VERSION} 2>&1 | logs $logfile
else
    unsquashfs ${source_file} 2>&1 | logs $logfile
    mv -v /tmp/squashfs-root/usr spotify-client-${SPOTIFY_VERSION} 2>&1 | logs $logfile
fi


#Delete apt-keys folder
echo "$(getdate) - Remove from .${SOURCE}: apt-keys" 2>&1 | logs $logfile "all"
rm -Rfv spotify-client-${SPOTIFY_VERSION}/usr/share/spotify/apt-keys 2>&1 | logs $logfile

#Include FFMPEG libraries
if [[ "$BUILTIN_FFMPEG" =~ ^(1|true|True|y|Y)$ ]]; then
    echo "$(getdate) - Add to SRPM: FFMPEG ${ffmpeg_spotify_release} libraries" 2>&1 | logs $logfile "all"
    mkdir -pv spotify-client-${SPOTIFY_VERSION}/usr/share/spotify/ffmpeg 2>&1 | logs $logfile
    curl -fSL "https://github.com/zicstardust/spotify-ffmpeg-libs/releases/download/v${ffmpeg_spotify_release}/spotify-ffmpeg-${ffmpeg_spotify_release}-libs-linux-x86_64.tar.gz" -o "/tmp/ffmpeg_libs.tar.gz" 2>&1 | logs $logfile
    tar -xzvf /tmp/ffmpeg_libs.tar.gz  -C spotify-client-${SPOTIFY_VERSION}/usr/share/spotify/ffmpeg 2>&1 | logs $logfile
else
    echo "$(getdate) - Skip FFMPEG libraries." 2>&1 | logs $logfile "all"
fi

# Generate Desktop Entry
echo "$(getdate) - Add to SRPM: Desktop Entry" 2>&1 | logs $logfile "all"
generate_desktopentry.sh spotify-client-${SPOTIFY_VERSION}/usr/share/applications ${SPOTIFY_VERSION}
echo "$(getdate) - Remove from .${SOURCE}: Desktop Entry" 2>&1 | logs $logfile "all"
rm -fv spotify-client-${SPOTIFY_VERSION}/usr/share/spotify/spotify.desktop 2>&1 | logs $logfile

#Copy icons
echo "$(getdate) - Add to SRPM: Icons" 2>&1 | logs $logfile "all"
copy_icons.sh ${SPOTIFY_VERSION} 2>&1 | logs $logfile
echo "$(getdate) - Remove from .${SOURCE}: Icons" 2>&1 | logs $logfile "all"
rm -Rfv spotify-client-${SPOTIFY_VERSION}/usr/share/spotify/icons 2>&1 | logs $logfile

# Generate man page
echo "$(getdate) - Add to SRPM: Man" 2>&1 | logs $logfile "all"
generate_man.sh spotify-client-${SPOTIFY_VERSION}/usr/share/man/man1

# Generate appdata
echo "$(getdate) - Add to SRPM: Appdata" 2>&1 | logs $logfile "all"
generate_appdata.sh spotify-client-${SPOTIFY_VERSION}/usr/share/appdata ${SPOTIFY_VERSION}


# Genarate bin
echo "$(getdate) - Remove from .${SOURCE}: Bin" 2>&1 | logs $logfile "all"
rm -fv spotify-client-${SPOTIFY_VERSION}/usr/bin/spotify 2>&1 | logs $logfile
echo "$(getdate) - Add to SRPM: Bin" 2>&1 | logs $logfile "all"
generate_bin.sh spotify-client-${SPOTIFY_VERSION}/usr/bin $BUILTIN_FFMPEG
generate_generate_flags_file.sh spotify-client-${SPOTIFY_VERSION}/usr/share/spotify/
generate_generate_envs_file.sh spotify-client-${SPOTIFY_VERSION}/usr/share/spotify/


#Create and move spotify-client.tar.gz to SOURCES
echo "$(getdate) - Create tar file to spotify-client:${SPOTIFY_VERSION}..." 2>&1 | logs $logfile "all"
tar -czvf spotify-client-${SPOTIFY_VERSION}.tar.gz spotify-client-${SPOTIFY_VERSION} 2>&1 | logs $logfile
echo "$(getdate) - Move tar file Sources directory..." 2>&1 | logs $logfile "all"
cp -v spotify-client-${SPOTIFY_VERSION}.tar.gz ${SOURCES_DIR}/ 2>&1 | logs $logfile

# Generate spec file
echo "$(getdate) - Create spec file..." 2>&1 | logs $logfile "all"
generate_spec.sh ${BUILD_DIR}/SPECS/spotify.spec $SPOTIFY_VERSION


echo "$(getdate) - Building SRPMS spotify-client:${SPOTIFY_VERSION}..." 2>&1 | logs $logfile "all"
rpmbuild -bs --define "_topdir ${BUILD_DIR}" ${BUILD_DIR}/SPECS/spotify.spec 2>&1 | logs $logfile

cd $current_dir

