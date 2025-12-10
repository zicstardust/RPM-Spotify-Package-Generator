#!/bin/bash

python3 /build/download_deb.py
python3 build_rpm.py


#cleanup
rm -f /build/spotify.info
rm -Rf /build/spotify*.deb