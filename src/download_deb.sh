#!/usr/bin/env bash

SPOTIFY_BRANCH=$1
SPOTIFY_VERSION=$2

logfile="$(getdate "log").${MAIN_LOG_NAME}"

deb_file="/tmp/spotify-client_${SPOTIFY_VERSION}_amd64.deb"

echo "$(getdate) - Downloading .deb, latest ${SPOTIFY_BRANCH} version: $SPOTIFY_VERSION" 2>&1 | logs $logfile "all"
curl -fSL "https://repository.spotify.com/pool/non-free/s/spotify-client/spotify-client_${SPOTIFY_VERSION}_amd64.deb" -o "$deb_file" 2>&1 | logs $logfile
