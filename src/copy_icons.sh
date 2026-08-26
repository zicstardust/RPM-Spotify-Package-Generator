#!/usr/bin/env bash

SPOTIFY_VERSION=$1

source_dir="spotify-client-${SPOTIFY_VERSION}/usr/share/spotify/icons"
destine_dir="spotify-client-${SPOTIFY_VERSION}/usr/share/icons"


for i in 8 16 22 24 32 36 44 48 64 72 96 128 144 150 192 256 310 512 1024; do
    if [ -f "${source_dir}/spotify-linux-${i}.png" ]; then
        mkdir -pv ${destine_dir}/hicolor/${i}x${i}/apps
        cp -v ${source_dir}/spotify-linux-${i}.png  ${destine_dir}/hicolor/${i}x${i}/apps/spotify-client.png
    fi
done

mkdir -pv ${destine_dir}/hicolor/scalable/apps
cp -arv /home/spotify/spotify-client.svg ${destine_dir}/hicolor/scalable/apps/
