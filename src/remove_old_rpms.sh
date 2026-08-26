#!/usr/bin/env bash

package_dir=$1

set -e
: "${KEEP_VERSIONS:=2}"

if [ "${KEEP_VERSIONS}" ==  "0" ]; then
    exit 0
fi

list_RPMs=($(ls ${package_dir}/))

if [ ${#list_RPMs[@]} -gt $KEEP_VERSIONS ]; then
    delete_files_length=$((${#list_RPMs[@]}-$KEEP_VERSIONS))

    i=0
    for file in "${list_RPMs[@]}"; do
        rm -f ${package_dir}/${file}
        echo "$(getdate) - Deleted old RPM: $file" 2>&1 | logs "$(getdate "log").${MAIN_LOG_NAME}" "all"
        i=$(($i+1))
        if [ $i -eq $delete_files_length ]; then
            break
        fi
    done

fi
