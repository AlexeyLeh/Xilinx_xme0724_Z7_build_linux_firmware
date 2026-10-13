# !/bin/bash

# downloaded from https://git.kernel.org/pub/scm/fs/ext2/e2fsprogs.git

E2FSPROGS="e2fsprogs"
E2FSPROGSINST="e2fsprogs-bin"
INSTDIR="$(pwd)/e2fsprogs-bin"

if [ ! -d ${E2FSPROGS} ]; then
    echo -e "\nERROR: Не найден каталог с исходниками - \"${E2FSPROGS}\" \n"
    exit 1
fi

export ARCH=arm
export CROSS_COMPILE=arm-linux-gnueabihf-

#export CFLAGS="-O2"
export LDFLAGS="-static"

echo "ARCH:          $ARCH"
echo "CROSS_COMPILE: $CROSS_COMPILE"
echo "CFLAGS:        $CFLAGS"
echo "LDFLAGS:       $LDFLAGS"

if [ ! -f ${E2FSPROGS}/configure ]; then
    echo -e "\nERROR: ${E2FSPROGS}/configure not found"
    echo -e "seems it is wrong package\n"
    exit 1
fi

opts="--host=arm-linux-gnueabihf"
opts="${opts} --disable-uuidd --disable-mmp --disable-tdb --disable-bmap-stats --disable-nls"
opts="${opts} --with-udev-rules-dir=${INSTDIR}"
opts="${opts} --with-crond-dir=${INSTDIR}"
opts="${opts} --with-systemd-unit-dir=${INSTDIR}"

mkdir -p -v ${E2FSPROGS}/build

pushd ${E2FSPROGS}/build &>/dev/null

echo ""
set -x

if [ ! -f config.status ]; then
    ../configure --prefix=${INSTDIR} ${opts} || exit 1
fi

make -j4 || exit 1

mkdir -p -v ${INSTDIR}
make install-strip 1>/dev/null || exit 1

popd

