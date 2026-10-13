#!/bin/bash

echo ""

echo "ARTIFACTS:  ${ARTIFACTS_DIR}"
echo "BOOTGEN:    ${BOOTGEN}"

if [ -z "${ARTIFACTS_DIR}" ]; then
    echo ""
    echo "The artifacts directory is not specified - see \$ARTIFACTS_DIR"
    echo ""
    exit 1
fi

if [ ! -d "${ARTIFACTS_DIR}" ]; then
    echo ""
    echo "The artifacts directory is not found"
    echo ""
    exit 1
fi

if [ -z "${BOOTGEN}" ]; then
    echo ""
    echo "The path to 'bootgen' script is not specified - see \$BOOTGEN"
    echo ""
    exit 1
fi

#-------------------------------------------------

# проверка, что запускаемся из под WSL (Windows) - 
# так как в Xilinx под Windows не будет файла lin64.o (а только win64.o),
# то бинарники линуксовые не запустятся - будем запускать Windows-ные...

if [ ${BOOTGEN:0:5} == "/mnt/" ]; then
    echo "Warning! Скрипт запущен под WSL (Windows), поэтому..."
    STR=$(echo ${BOOTGEN:5})
    CMD="$(echo ${STR} | sed 's|\/|:\/|1').bat"
    echo "Bootgen script:   ${CMD}"
    BOOTGEN="cmd.exe /C ${CMD}"
fi
echo "Bootgen command:  ${BOOTGEN}"
echo ""

#-------------------------------------------------

FILE_FSBL="${ARTIFACTS_DIR}/fsbl.elf"
FILE_BITS="${ARTIFACTS_DIR}/bitstream.bit"

if [ ! -f ${FILE_FSBL} -o ! -f ${FILE_BITS} ]; then
    echo "-- Проверка наличия файлов от Vivado в ${ARTIFACTS_DIR}"

    for fn in ${FILE_FSBL} ${FILE_BITS}; do
        [ ! -f "${fn}" ] && echo " - ${fn} - file not found"
    done

    echo -e "\n-- Будут использоваться локальные файлы\n"
    FILE_FSBL="./fsbl.elf"
    FILE_BITS="./bitstream.bit"
fi

ERR=0
for fn in ${FILE_FSBL} ${FILE_BITS}; do
    if [ ! -f "${fn}" ]; then
        echo " - ${fn} - file not found"
        ERR=1
    fi
done

if [ $ERR -ne 0 ]; then
    echo -e "\n-- Требуемые файлы не найдены"
    echo -e "Необходимо обеспечить наличие файлов Xilinx Vivado в \n${ARTIFACTS_DIR}\n"
    exit 1
fi

#-------------------------------------------------

rm -f u-boot.elf
rm -f boot.bin

dir="$(cd ../u-boot ; pwd)"
UBOOTELF="${dir}/u-boot.elf"

dir="$(cd ../boot_scripts/xme0724-20 ; pwd)"
SCRIPT_QSPI="${dir}/boot.scr.qspi.bin"

dir="$(cd ../boot_scripts/xme0724-20 ; pwd)"
SCRIPT_SD="${dir}/boot.scr.sd.bin"

echo "Требуемые файлы (FSBL/Bitstream/Uboot):"
echo "   FSBL:        ${FILE_FSBL}"
echo "   BIT:         ${FILE_BITS}"
echo "   UBOOT:       ${UBOOTELF}"
echo "   QSPI SCRIPT: ${SCRIPT_QSPI}"
echo "   SD SCRIPT:   ${SCRIPT_SD}"
echo ""

[ ! -f ${UBOOTELF}    ] && echo "ERROR: not found ${UBOOTELF}"    && exit 1
[ ! -f ${VIVADOFSBL}  ] && echo "ERROR: not found ${VIVADOFSBL}"  && exit 1
[ ! -f ${VIVADOBIT}   ] && echo "ERROR: not found ${VIVADOBIT}"   && exit 1
[ ! -f ${SCRIPT_QSPI} ] && echo "ERROR: not found ${SCRIPT_QSPI}" && exit 1
[ ! -f ${SCRIPT_SD}   ] && echo "ERROR: not found ${SCRIPT_SD}"   && exit 1

cp -fv ${UBOOTELF}    ./ || exit 1
cp -fv ${FILE_FSBL}   ./ || exit 1
cp -fv ${FILE_BITS}   ./ || exit 1
cp -fv ${SCRIPT_QSPI} ./ || exit 1
cp -fv ${SCRIPT_SD}   ./ || exit 1

#-------------------------------------------------

TARGETDIR=$(pwd)
cmd="${BOOTGEN} -w -image ${TARGETDIR}/boot_image_qspi.bif -arch zynq -o ${TARGETDIR}/boot_qspi.bin"
echo "" ; echo "$ $cmd"
eval $cmd
if [ $? -ne 0 ]; then 
    echo "FAILED"
    exit 1
fi

#-------------------------------------------------

cmd="${BOOTGEN} -w -image ${TARGETDIR}/boot_image_sd.bif -arch zynq -o ${TARGETDIR}/boot_sd.bin"
echo "" ; echo "$ $cmd"
eval $cmd
if [ $? -ne 0 ]; then 
    echo "FAILED"
    exit 1
fi

exit $RC
