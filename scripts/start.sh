#!/bin/bash
while :
do
    python3 /build/download_deb.py
    python3 /build/build_rpm.py


    #copy RPM
    echo "copy RPM to /data"
    python3 /build/copy_rpm_to_repo.py
    

    #cleanup
    echo "cleanup..."
    rm -f /build/spotify.info
    rm -Rf /build/spotify*.deb
    rm -f /build/data.tar.gz
    rm -f /build/control.tar.gz
    rm -f /build/debian-binary
    rm -Rf /build/usr

    rm -Rf /home/spotify/rpmbuild

    if [ "$DISABLE_WEB_SERVER" != "1" ]; then
        echo "update metadata repository..."
        for i in $(ls /data); do
            createrepo /data/$i/x86_64/stable
        done
    fi


    #Start interval
    echo "Start INTERVAL: ${INTERVAL}"
    sleep ${INTERVAL}
done
