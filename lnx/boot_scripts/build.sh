#!/bin/bash

FILES="boot.script.sd boot.script.tftp boot.script.mmc boot.script.qspi"

TARGET="xme0724-20"
rm -rf ${TARGET}
mkdir -p ${TARGET}

rm -f boot.scr.*

for fn in ${FILES}; do
    echo -e "\n--- обработка $fn"
    [ ! -f $fn ] && echo " - не найден '$fn'" && exit 1
    FOUT=$(echo $fn | sed 's/.script./.scr./')
    mkimage -v -A arm -T script -C none -d ${fn} ${TARGET}/${FOUT}.bin
done
echo ""

TFTP_FILES="../linux/uImage.bin ../device_tree/system.dtb ../rootfs/uRootfs.image.gz"
for fn in ${TFTP_FILES} ; do
    if [ -f ${fn} ]; then
        cp -fv ${fn} ${TARGET}
    else
        echo "NOT FOUND ${fn} - skip"
    fi
done
