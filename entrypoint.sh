#!/bin/bash
set -e

: "${PUID:=1000}"
: "${PGID:=1000}"

if ! getent group spotify >/dev/null; then
    groupadd -g "$PGID" spotify
fi

if ! id -u spotify >/dev/null 2>&1; then
    useradd -m -u "$PUID" -g "$PGID" -s /sbin/nologin spotify
fi

mkdir -p /data /home/spotify

chown -R spotify:spotify /build /data /home/spotify

if [ "$DISABLE_WEB_SERVER" != "1" ]; then
    httpd 1> /dev/null
fi

exec runuser -u spotify -- "$@"