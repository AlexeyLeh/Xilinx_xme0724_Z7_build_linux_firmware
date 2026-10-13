#!/bin/bash
#
# Формирование загрузочного пакета файлов
#

echo ""

dir="$(cd ../.. ; pwd)"
TARGET="${dir}/BOOT"

dir="$(cd .. ; pwd)"
SCRDIR="${dir}/boot_scripts/xme0724-20"

BOOTBIN="${dir}/boot_bin"

rm -rf ${TARGET}
mkdir ${TARGET}

RC=0

# 2.
echo ""
echo "--- QSPI FLASH ---"
mkdir -p ${TARGET}/qspi/ || RC=1
cp -fv ${BOOTBIN}/boot_qspi.bin ${TARGET}/qspi/ || RC=1
cp -fv ${BOOTBIN}/fsbl.elf ${TARGET}/qspi/ || RC=1

# 2.
echo ""
echo "--- SD ---"
mkdir -p ${TARGET}/sd/
cp -fv ${BOOTBIN}/boot_sd.bin         ${TARGET}/sd/boot.bin || RC=1
cp -fv ${dir}/linux/uImage.bin        ${TARGET}/sd/ || RC=1
cp -fv ${dir}/rootfs/uRootfs.image.gz ${TARGET}/sd/ || RC=1

# 3.
echo ""
echo "--- TFTP ---"
mkdir -p ${TARGET}/tftp/
cp -fvr ${SCRDIR} ${TARGET}/tftp/ || RC=1

ZIPNAME="xme072420-$(date +%Y%m%d-%H%M).zip"
EXT="zip"
if which zip; then
    pack_cmd="zip -r -9 -q ${TARGET}/${ZIPNAME} ${TARGET}/tftp/*"
elif which 7z; then
    pack_cmd="7z a -mx9 -tzip ${TARGET}/${ZIPNAME} ${TARGET}/tftp/*"
fi
if [ ! -z "$pack_cmd" ]; then
    echo "$pack_cmd"
    eval "$pack_cmd"
fi

# 4.
echo ""
echo "--- All ---"
mkdir -p ${TARGET}/all/
cp -fv ${SCRDIR}/* ${TARGET}/all/              || RC=1
cp -fv ${BOOTBIN}/boot_qspi.bin ${TARGET}/all/ || RC=1
cp -fv ${BOOTBIN}/boot_sd.bin ${TARGET}/all/   || RC=1
cp -fv ${BOOTBIN}/fsbl.elf ${TARGET}/all/      || RC=1
cp -fv ${BOOTBIN}/bitstream.bit ${TARGET}/all/ || RC=1
cp -fv ${BOOTBIN}/u-boot.elf ${TARGET}/all/    || RC=1

cp -fv ${BOOTBIN}/boot_image_qspi.bif ${TARGET}/all/ || RC=1
cp -fv ${BOOTBIN}/boot_image_sd.bif ${TARGET}/all/   || RC=1

# 5.
echo ""
echo "--- flash script ---"
cp -fv ./flash.bat ${TARGET}
cp -fv ./flash.sh  ${TARGET}
chmod +x ${TARGET}/flash.sh

# LAST.
DIR=$(cd ${TARGET}; pwd)
if [ $RC -eq 0 ]; then
    cat << EOF

Комплект загрузочных файлов готов.
см: ${DIR}
Порядок использования смотрим в документации (и в lnx/boot/README.md)
EOF

else
    cat << EOF







ВНИМАНИЕ! Возможна ОШИБКА!








При подготовке комплекта загрузочных файлов в
${DIR}
произошла ошибка копирования.
Комплект может быть не полным - проверьте ошибки...
EOF

exit 1
fi

echo ""
