export CROSS_COMPILE=arm-linux-gnueabihf-
export ARCH=arm

DIR="linux-xlnx"

make -C ${DIR} menuconfig

