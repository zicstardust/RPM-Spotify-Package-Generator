#!/usr/bin/env bash

SPOTIFY_BRANCH=$1


if [ "$SPOTIFY_BRANCH" = "stable" ]; then
    SNAP_BRANCH="stable"
else
    SNAP_BRANCH="edge"
fi

SPOTIFY_VERSION="$(curl -s -H 'Snap-Device-Series: 16' https://api.snapcraft.io/v2/snaps/info/spotify | jq -r ".\"channel-map\"[] | select(.channel.architecture == \"amd64\" and .channel.name == \"$SNAP_BRANCH\") | .version")"


echo $SPOTIFY_VERSION > /tmp/spotify-client.${SPOTIFY_BRANCH}.Version