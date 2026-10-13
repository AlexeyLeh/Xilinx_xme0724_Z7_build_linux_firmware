# !/bin/bash

# downloaded from https://busybox.net/
# https://busybox.net/downloads/busybox-1.36.1.tar.bz2

DOSFSTOOLS="dosfstools"
INSTDIR=$(pwd)/dosfstools-bin

if [ ! -d ${DOSFSTOOLS} ]; then
    echo -e "\nERROR: Не найден каталог с исходниками - \"${DOSFSTOOLS}\" \n"
    exit 1
fi

export ARCH=arm
export CROSS_COMPILE=arm-linux-gnueabihf-

export CFLAGS="-O2"
export LDFLAGS="-static"

echo "ARCH:          $ARCH"
echo "CROSS_COMPILE: $CROSS_COMPILE"
echo "CFLAGS:        $CFLAGS"
echo "LDFLAGS:       $LDFLAGS"

if [ ! -f ${DOSFSTOOLS}/autogen.sh ]; then
    echo -e "\nERROR: ${DOSFSTOOLS}/autogen.sh not found"
    echo -e "seems it is wrong package\n"
    exit 1
fi

pushd ${DOSFSTOOLS} &>/dev/null

echo ""
set -x

if [ ! -f configure ]; then
    ./autogen.sh || exit 1
fi

if [ ! -f config.status ]; then
    ./configure --host=arm-linux-gnueabihf  --prefix=${INSTDIR} || exit 1
fi

make -j4 || exit 1

make install-strip 1>/dev/null || exit 1

popd

