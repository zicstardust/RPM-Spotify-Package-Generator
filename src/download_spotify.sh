#!/usr/bin/env bash

SPOTIFY_BRANCH=$1
SPOTIFY_VERSION=$2

logfile="$(getdate "log").${MAIN_LOG_NAME}"

source_file="/tmp/spotify-client_${SPOTIFY_VERSION}_amd64.${SOURCE}"


if [ "$SOURCE" = "deb" ]; then
    curl -fSL "https://repository.spotify.com/pool/non-free/s/spotify-client/spotify-client_${SPOTIFY_VERSION}_amd64.deb" -o "$source_file" 2>&1 | logs $logfile
else
    if [ "$SPOTIFY_BRANCH" = "stable" ]; then
        SNAP_BRANCH="stable"
    else
        SNAP_BRANCH="edge"
    fi

    snap_url="$(curl -s -H 'Snap-Device-Series: 16' https://api.snapcraft.io/v2/snaps/info/spotify | jq -r ".\"channel-map\"[] | select(.channel.architecture == \"amd64\" and .channel.name == \"$SNAP_BRANCH\") | .download.url")"

    curl -fSL ${snap_url} -o "$source_file" 2>&1 | logs $logfile

fi



