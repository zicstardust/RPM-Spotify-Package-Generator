FROM almalinux:10.2-minimal


COPY src/*.sh /usr/local/bin/
COPY src/*.py /usr/local/bin/
COPY entrypoint.sh /entrypoint.sh

RUN chmod -R +x /usr/local/bin/*.sh /usr/local/bin/*.py /entrypoint.sh; \
    \
    microdnf install -y --setopt=install_weak_deps=0 --nodocs epel-release; \
    \
    microdnf -y update --setopt=install_weak_deps=0 --nodocs; \
    \
    microdnf -y install --enablerepo=crb --setopt=install_weak_deps=0 --nodocs \
        desktop-file-utils \
        python3 \
        make \
        rpm-build \
        rpmdevtools \
        binutils \
        gtk-update-icon-cache \
        util-linux \
        nginx \
        createrepo_c \
        gpg \
        rpm-sign \
        httpd-tools \
        mock \
        jq \
        squashfs-tools; \
    microdnf clean all; \
    rm -rf /var/cache/dnf; \
    \
    rm -f /etc/nginx/nginx.conf; \
    \
    groupadd -g 1000 spotify; \
    useradd -m -u 1000 -g 1000 -s /sbin/nologin spotify; \
    usermod -a -G mock spotify; \
    mkdir -p /home/spotify/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS};

COPY src/spotify-client.svg /home/spotify/
COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/*_server.conf /etc/nginx/conf.d/


VOLUME [ "/data" ]

ENTRYPOINT ["/entrypoint.sh"]

CMD ["run.sh"]
