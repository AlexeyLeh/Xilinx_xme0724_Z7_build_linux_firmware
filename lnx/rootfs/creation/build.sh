#!/bin/bash

#
# Сборка busybox, dossfstools и rootfs (загружаемой файловой системы)
# 
# build.sh
# build-busybox.sh
# build-dosfstools.sh
# build-rootfs.sh
#

PACKAGES=(\
    "busybox-1_37_0.patched.tar.bz2"  \
    "dosfstools-4.2.tar.bz2"  \
    "e2fsprogs-1.47.1.tar.gz" \
)

SCRIPTS=(\
    build-busybox.sh    \
    build-dosfstools.sh \
    build-e2fsprogs.sh  \
)

function unpack_package()
{
    # expected format of archive name: <name>-<ver>.<ext>
    # where:
    #   <name> - any characters except dash '-'
    #   <ver>  - any characters - for examples "1.2.45"
    #   <ext>  - known types - 'tar.bz2' 'tar.gz' 'tgz' 'zip' '7z' 'rar'
    # example: busybox-1.36.1.tar.bz2

    ARCH_FILE=${1}

    PACKAGE_NAME=${ARCH_FILE%-*}
    if [ -d ${PACKAGE_NAME} ]; then
        return
    fi

    if [ ! -f ${ARCH_FILE} ]; then
        echo "ERROR: ${ARCH_FILE} NOT FOUND"
        exit 1
    fi

    TARGET_DIR=$(echo ${ARCH_FILE} | \
        sed 's/.tar.bz2$//' | \
        sed 's/.tar.gz$//'  | \
        sed 's/.tgz$//'     | \
        sed 's/.zip$//'     | \
        sed 's/.7z$//'      | \
        sed 's/.rar$//'     )

    case "${ARCH_FILE}" in 
      *.tar.bz2)
        cmd="tar xfj ${ARCH_FILE}"
        ;;
      *.tar.gz | *.tgz)
        cmd="tar xfz ${ARCH_FILE}"
        ;;
      *.zip)
        cmd="unzip -q ${ARCH_FILE}"
        ;;
      *.7z)
        cmd="7z x -bso0 -bsp0 ${ARCH_FILE}"
        ;;
      *.rar)
        cmd="rar x -idq ${ARCH_FILE}"
        ;;
      *)
        echo "Unregistered archive type - ${ARCH_FILE}"
        exit 1
      ;;
    esac

    echo "распаковка: $cmd"
    eval $cmd || exit 1

    if [ ! -d ${TARGET_DIR} ]; then
        echo "ERROR: ${TARGET_DIR} NOT FOUND"
        echo "(perhaps the archive does not contain the expected version)"
        exit 1
    fi

    mv -v ${TARGET_DIR} ${PACKAGE_NAME} || exit 1

    if [ ! -d "${PACKAGE_NAME}" ]; then
        echo "ERROR: Не найден каталог \"${PACKAGE_NAME}\""
        exit 1
    fi
    echo ""
}

### main() ###

rm -fv rootfs.tar.bz2

for idx in ${!PACKAGES[*]} ; do
    unpack_package ${PACKAGES[idx]}

    cmd=${SCRIPTS[idx]}
    [ ! -f "$cmd" ] && echo "ERROR: скрипт \"$cmd\" не найден" && exit 1

    chmod +x $cmd
    echo "\$ $cmd"
    eval ./$cmd || exit 1

    echo -e "========================================\n"
done

cmd="build-rootfs.sh"
if [ ! -f "$cmd" ]; then
    echo "ERROR: скрипт \"$cmd\" не найден"
    exit 1
fi
chmod +x $cmd

echo "\$ $cmd"
eval ./$cmd || exit 1

echo ""

ls -l rootfs.tar.bz2

echo ""
