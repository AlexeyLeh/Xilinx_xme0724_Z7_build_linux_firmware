#!/bin/bash

DIRS="device_tree linux u-boot rootfs boot_scripts boot boot_bin"

echo -e "\nудаление рабочих данных в каталогах: "
for dir in $DIRS; do
    pushd ${dir} &> /dev/null
    if [ -f clean.sh ]; then
        echo "-- ${dir} "
        chmod +x clean.sh
        #./clean.sh && echo "OK" || echo "FAILED"
        ./clean.sh
    fi
    popd &> /dev/null
done

echo ""