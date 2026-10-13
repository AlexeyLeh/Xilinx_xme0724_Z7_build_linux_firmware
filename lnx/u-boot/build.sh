#!/bin/bash

#
# git-репозиторий варианта U-boot, который любезно предоставляет компания Xilinx:
# git clone https://github.com/Xilinx/u-boot-xlnx.git
#

echo ""

UBOOT_ARC="u-boot-xlnx-v2025.1.tar.bz2"
UBOOT_UNP="u-boot-xlnx-v2025.1"
DEFCONFIG="xilinx_zynq_xme0724_uboot_xlnx_v2025_defconfig"

UBOOT_DIR="u-boot-xlnx"
DEVICE="zynq_xme0724"

#-------------------------------------------------
if [ ! -d ${UBOOT_DIR} ]; then
    if [ ! -f ${UBOOT_ARC} ]; then
        echo "ERROR: ${UBOOT_ARC} NOT FOUND"
        exit 1
    fi

    [ -d ${UBOOT_DIR} ] && rm -rf ${UBOOT_DIR}

    echo "unpacking:"
    cmd="tar xfj ${UBOOT_ARC}"
    echo "  $ $cmd"
    eval $cmd || exit 1

    if [ ! -d ${UBOOT_UNP} ]; then
        echo "ERROR: ${UBOOT_UNP} NOT FOUND"
        echo "(perhaps the archive does not contain the expected version)"
        exit 1
    fi

    mv -v ${UBOOT_UNP} ${UBOOT_DIR} || exit 1
fi

if [ ! -d "${UBOOT_DIR}" ]; then
    echo "ERROR: Не найден каталог \"${UBOOT_DIR}\""
    exit 1
fi
find "${UBOOT_DIR}" -name "*.sh" -exec chmod +x {} \;

#-------------------------------------------------
rm -f u-boot.elf 2>/dev/null
rm -f u-boot.dtb 2>/dev/null

#-------------------------------------------------
export CROSS_COMPILE=arm-linux-gnueabihf-
export ARCH=arm

[ ! -f ${UBOOT_DIR}/.scmversion ] && touch ${UBOOT_DIR}/.scmversion

#-------------------------------------------------
# нужен файл описания устройств (.dtb)
DTB_DIR=$(cd ../device_tree ; pwd) 
if [ ! -f ${DTB_DIR}/system.dtb ]; then
    echo -e "\nERROR: Не найден system.dtb"
    echo "Проверьте сборку в папке ${DTB_DIR}"
    exit 1
fi

#-------------------------------------------------
# (optional)
# make -C ${UBOOT_DIR} clean
# make -C ${UBOOT_DIR} distclean

#-------------------------------------------------
echo ""
echo "-- установка конфигурации сборки для xilinx_zynq_xme0724"
if [ ! -f ${DEFCONFIG} ]; then
    echo ""
    echo "ERROR: не найдена конфигурация сборки ${DEFCONFIG}"
    exit 1
fi
cp -fv ${DEFCONFIG} ${UBOOT_DIR}/configs/xilinx_zynq_xme0724_defconfig
cmd="make -C ${UBOOT_DIR} xilinx_zynq_xme0724_defconfig"
echo "\$ $cmd"
eval $cmd || exit 1

#-------------------------------------------------
# подкладывание файла описания устройств на SoC-е
echo ""
echo "-- используется ${DTB_DIR}/system.dtb"
DTS_DIR=$(cd ${UBOOT_DIR}/arch/arm/dts/ ; pwd)
ls -l ${DTS_DIR}/zynq-xme0724.dtb 2>/dev/null
cp -fv ${DTB_DIR}/system.dtb ${DTS_DIR}/zynq-xme0724.dtb || exit 1
ls -l ${DTS_DIR}/zynq-xme0724.dtb
echo ""

#-------------------------------------------------
# правка конфигурации сборки .config
# (make -C ${LINUX} ARCH=arm menuconfig)

CFGFILE="u-boot-xlnx/.config"

# эти конфиг-опции будут удалены
sed 's/^.*CONFIG_LOCALVERSION_AUTO=[ym].*$/# CONFIG_LOCALVERSION_AUTO is not set/' -i ${CFGFILE}


#-------------------------------------------------
# сборка
cmd="make -C ${UBOOT_DIR}"
echo "\$ $cmd"
eval $cmd || exit 1

#-------------------------------------------------
# информация о готовых файлах
ls -lh ${UBOOT_DIR}/u-boot.img \
       ${UBOOT_DIR}/u-boot.dtb \
       ${UBOOT_DIR}/u-boot-dtb.img \
       ${UBOOT_DIR}/u-boot-elf.lds \
       ${UBOOT_DIR}/u-boot.elf \
       ${UBOOT_DIR}/u-boot.cfg

echo ""
cp -fv ${UBOOT_DIR}/u-boot.elf ./
chmod -x u-boot.*

echo ""

