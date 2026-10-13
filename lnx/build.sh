#!/bin/bash
#
# Сборка загрузочных образов
#

DIRS="device_tree u-boot linux rootfs boot_scripts boot_bin boot"

echo ""

# 1.
VIVADO_FILES="$1"
ARTIFACTS_DIR="$2"

if [ -z "${ARTIFACTS_DIR}" ]; then
    echo "Не указан каталог с файлами описаний от Vivado"
    echo ""
    exit 1
fi

if [ -z "${VIVADO_FILES}" ]; then
    echo "Не указан тип артефактов от Vivado"
    echo ""
    exit 1
fi

echo "XILINXBIN:   ${XILINXBIN}"
echo "BOOTGEN:     ${BOOTGEN}"
echo "BOOTGEN_BAT: ${BOOTGEN_BAT}"
echo "ARTIFACTS:   ${ARTIFACTS_DIR}"

# 2. - проверим наличие скрипта и сделаем его запускаемым
BUILDSCRIPT="build.sh"
echo -e "\nChecking for scripts (${BUILDSCRIPT})"
RC=0
for dir in $DIRS; do
    if [ ! -d ${dir} ]; then
        printf "  %-20s - directory not found \n" "${dir}"
        RC=1
    fi
    if [ ! -f ${dir}/${BUILDSCRIPT} ]; then
        printf "  %-20s - not found \n" "${dir}/${BUILDSCRIPT}"
        RC=1
    fi
    chmod +x ${dir}/${BUILDSCRIPT}
    printf "  %-25s ... OK \n" "${dir}/${BUILDSCRIPT}"
done
[ $RC -ne 0 ] && exit 1

# 3. запустим все сборки по каталогам
idx=1
for dir in $DIRS; do
    echo ""
    echo "+++ ----------------------------------------"
    echo "+++ ${idx}. ${dir} "
    idx=$((idx + 1))

    pushd $dir &> /dev/null

    ./${BUILDSCRIPT} ${VIVADO_FILES} ${ARTIFACTS_DIR} ${BOOTGEN}
    RC=$? ; [ $RC -ne 0 ] && exit $RC

    popd &> /dev/null
done

echo "done."
