#!/bin/bash
while :
do
    python3 /build/download_deb.py
    python3 /build/build_rpm.py


    #copy RPM

    if [ "$ENABLE_SERVER_REPO" == "1" ]; then
        echo "copy RPM to repositoty"
        python3 /build/copy_rpm_to_repo.py
    else
        echo "copy RPM to /data"
        cp -Rf /home/spotify/rpmbuild/RPMS/x86_64/* /data/
    fi

    #cleanup
    echo "cleanup..."
    rm -f /build/spotify.info
    rm -Rf /build/spotify*.deb
    rm -f /build/data.tar.gz
    rm -f /build/control.tar.gz
    rm -f /build/debian-binary
    rm -Rf /build/usr

    rm -Rf /home/spotify/rpmbuild

    if [ "$ENABLE_SERVER_REPO" == "1" ]; then
        echo "update metadata repository..."
        rm -Rf /data/spotify-client-*.rpm
        for i in $(ls /data); do
            createrepo /data/$i/x86_64/stable
        done
    fi


    #Start interval
    echo "Start INTERVAL: ${INTERVAL}"
    sleep ${INTERVAL}
done
