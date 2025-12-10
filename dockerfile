FROM almalinux:10.1

RUN dnf -y update && \
    dnf -y install \
    #lsb_release \
    desktop-file-utils \
    python3 \
    make \
    rpm-build \
    rpmdevtools \
    #wget \
    #curl \
    binutils \
    gtk-update-icon-cache \
    && dnf clean all

#RUN rpmdev-setuptree

WORKDIR /build

COPY scripts/* .

RUN chmod +x /build/start.sh

CMD ["/build/start.sh"]