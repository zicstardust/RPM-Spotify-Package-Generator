#!/bin/bash
while :
do
    python3 /build/download_deb.py
    python3 /build/build_rpm.py


    #copy RPM
    echo "copy RPM to /data"
    cp -Rf /root/rpmbuild/RPMS/x86_64/* /data/


    #cleanup
    echo "cleanup..."
    rm -f /build/spotify.info
    rm -Rf /build/spotify*.deb
    rm -f /build/data.tar.gz
    rm -f /build/control.tar.gz
    rm -f /build/debian-binary
    rm -Rf /build/usr

    rm -Rf /root/rpmbuild


    #Start interval
    echo "Start INTERVAL: ${INTERVAL}"
    sleep ${INTERVAL}
done
