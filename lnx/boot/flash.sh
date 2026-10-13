#!/bin/bash
echo "."
echo ". Установите переключатель режима загрузки в \"JTAG mode\" "
echo ".   ON  o--- 2 "
echo ".       o--- 1 "
echo "."

BOOT_FILES="./qspi"
FSBL="${BOOT_FILES}/fsbl.elf"
BOOTBIN="${BOOT_FILES}/boot_qspi.bin"

##################################################
# Проверка, что скрипт запускается из под WSL (Windows).
# Так как в Xilinx под Windows не будет файла lin64.o (а только win64.o),
# то бинарники линуксовые не запустятся - будем запускать Windows-ные...
#
XILINXBIN=$(echo $PATH | tr ":" "\n" | grep Xilinx | grep -e "bin$" -e "bin/$" | uniq)
FLASHBIN="${XILINXBIN:-.}/program_flash"

if [ ${FLASHBIN:0:5} == "/mnt/" ]; then
    echo "detected WSL command: ${FLASHBIN}"
    CMD="$(echo ${FLASHBIN:5} | sed 's|\/|:\/|1')"
    FLASHBIN="cmd.exe /C ${CMD}"
fi
#echo "Flashing command: ${FLASHBIN}"

##################################################
for FN in "${FSBL}" "${BOOTBIN}" ; do
    if [ ! -f "${FN}" ]; then
        echo "ERROR: file not found - ${FN}"
        read -p "Press any key key to continue"
        exit 1
    fi
done

##################################################
cmd="${FLASHBIN} -fsbl ${FSBL} -f ${BOOTBIN} -offset 0 \
-flash_type qspi-x4-single -url TCP:127.0.0.1:3121"

echo "$ $cmd" ; eval $cmd || exit 1
