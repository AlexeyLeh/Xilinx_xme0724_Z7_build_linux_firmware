#!/bin/bash

# downloaded from https://busybox.net/
# https://busybox.net/downloads/busybox-1.36.1.tar.bz2

BUSYBOX="busybox"
INSTDIR=$(pwd)/busybox-bin

if [ ! -d ${BUSYBOX} ]; then
    echo -e "\nERROR: Не найден каталог с исходниками - \"${BUSYBOX}\"\n"
    exit 1
fi

export ARCH=arm
export CROSS_COMPILE=arm-linux-gnueabihf-

echo "ARCH:          $ARCH"
echo "CROSS_COMPILE: $CROSS_COMPILE"

pushd ${BUSYBOX} &>/dev/null

echo ""
set -x

if [ ! -f .config ]; then
    make defconfig

    # these config options will be enabled.
    sed 's/^.*CONFIG_STATIC .*$/CONFIG_STATIC=y/' -i .config
    sed 's/^.*CONFIG_FLASH_ERASEALL .*$/CONFIG_FLASH_ERASEALL=y/' -i .config
    sed 's/^.*CONFIG_FLASH_LOCK .*$/CONFIG_FLASH_LOCK=y/' -i .config
    sed 's/^.*CONFIG_FLASH_UNLOCK .*$/CONFIG_FLASH_UNLOCK=y/' -i .config
    sed 's/^.*CONFIG_FLASHCP .*$/CONFIG_FLASHCP=y/' -i .config

    # these config options will be disabled.
    sed 's/^.*CONFIG_HDPARM=y.*$/# CONFIG_HDPARM is not set/' -i .config
    sed '/^.*CONFIG_FEATURE_HDPARM_.*$/d' -i .config

fi

make -j4 || exit 1

make CONFIG_PREFIX=${INSTDIR} install 1>/dev/null || exit 1

popd
