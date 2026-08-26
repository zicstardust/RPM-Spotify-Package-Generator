#!/usr/bin/env bash
set -e

: "${PUID:=1000}"
: "${PGID:=1000}"
: "${DISABLE_WEB_SERVER:=false}"
: "${REPO_AUTHENTICATION_GPG_FILE:=false}"

if [ "$(id -g spotify)" != "${PGID}" ]; then
    groupmod -o -g "${PGID}" spotify
fi


if [ "$(id -u spotify)" != "${PUID}" ]; then
    usermod -o -u "${PUID}" spotify
fi


mkdir -p /data /gpg-key /logs
chown -R spotify:spotify /data /home/spotify /gpg-key /logs


if [ "$REPO_AUTHENTICATION_USER" ] && [ "$REPO_AUTHENTICATION_PASSWORD" ]; then
    sed -i "s|#auth_basic |auth_basic |g" /etc/nginx/conf.d/repo_server.conf
    sed -i "s|#auth_basic_user_file |auth_basic_user_file |g" /etc/nginx/conf.d/repo_server.conf
    htpasswd -bc /etc/nginx/.htpasswd "${REPO_AUTHENTICATION_USER}" "${REPO_AUTHENTICATION_PASSWORD}" >& /dev/null
    chmod 600 /etc/nginx/.htpasswd
    chown spotify:spotify /etc/nginx/.htpasswd
fi

if [ "$REPO_PORT" ]; then
    sed -i "s|80 default_server|${REPO_PORT} default_server|g" /etc/nginx/conf.d/{repo_server.conf,block_default_server.conf}
fi


if [ "$REPO_SERVER_NAME" ]; then
    sed -i "s|#include /etc/nginx/conf.d/block_default_server.conf;|include /etc/nginx/conf.d/block_default_server.conf;|" /etc/nginx/nginx.conf
    sed -i "s| default_server||g" /etc/nginx/conf.d/repo_server.conf
    sed -i "s|server_name _;|server_name ${REPO_SERVER_NAME};|g" /etc/nginx/conf.d/repo_server.conf
fi

if [[ "$DISABLE_WEB_SERVER" =~ ^(0|false|False|n|N)$ ]]; then
    nginx &> /dev/null
fi


if [[ "$REPO_AUTHENTICATION_GPG_FILE" =~ ^(1|true|True|y|Y)$ ]]; then
    sed -i "s|location = /gpg|#location = /gpg|" /etc/nginx/conf.d/repo_server.conf
fi


if [ "$GPG_NAME" ] && [ "$GPG_EMAIL" ]; then
    if [ ! -f /gpg-key/private.pgp ] && [ ! -f /gpg-key/public.pgp ]; then
        generate_gpg.sh
    fi
    rpm --import /gpg-key/public.pgp
fi


exec runuser -u spotify -- "$@"