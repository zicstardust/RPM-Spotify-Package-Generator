#!/usr/bin/env bash

logfile="$(getdate "log").${MAIN_LOG_NAME}"

echo "$(getdate) - cleanup..." 2>&1 | logs $logfile "all"

rm -Rfv /tmp/* 2>&1 | logs $logfile

rm -Rfv /home/spotify/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}/* 2>&1 | logs $logfile
