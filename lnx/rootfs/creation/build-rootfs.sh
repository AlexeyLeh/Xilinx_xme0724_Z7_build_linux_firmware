#!/bin/bash

umask 022

ROOTFS="rootfs"
ROOTFS_ISSUE="${ROOTFS}/etc/rootfs.issue"
ROOTFS_TEMPLATE="rootfs-template.tar.bz2"

EXT2IMG=rootfs.image
EXT2IMG_GZ=${EXT2IMG}.gz
UROOTFS="uRootfs.image.gz"

TMPDIR=/tmp/rootfs-image

if [ ! -f "${ROOTFS_TEMPLATE}" ]; then
    echo "ERROR: Не найден архив root filesystem - \"${ROOTFS_TEMPLATE}\""
    echo "Проверьте установочный комплект..."
    echo ""
    exit 1
fi

PACKAGES=(busybox-bin dosfstools e2fsprogs)
ok=1
for dn in ${PACKAGES[*]} ; do
    if [ ! -d ${dn} ]; then
        echo "не найден ${dn}"
        ok=0
    fi
done
[ $ok -ne 1 ] && exit 1

set -x
rm -rf ${ROOTFS}
mkdir -p ${ROOTFS}

tar xjf ${ROOTFS_TEMPLATE} || exit 1

#---------------------------------------
# write changes list
if [ ! -f "${ROOTFS_ISSUE}" ]; then
    echo "Ver. 1.0.0 $(date '+%b %e %Y')" > "${ROOTFS_ISSUE}"
fi
VER=$(head -n 1 "${ROOTFS_ISSUE}")

NEWVER=$(echo "$VER" | awk '{
            split($2, v, "."); $2 = v[1]"."v[2]"."v[3]+1; print
         }')
echo -e "${NEWVER}\n" > "${ROOTFS_ISSUE}"

if which git; then
    FNLIST=$(git status | grep "modified:" | grep -v "../" | awk '{print $2}')
    for FN in $FNLIST ; do
        $(git diff "$FN"  >> "${ROOTFS_ISSUE}")
    done
fi

#---------------------------------------
cp -rf busybox-bin/* ${ROOTFS}

cp dosfstools-bin/sbin/fsck.fat ${ROOTFS}/sbin/
cp dosfstools-bin/sbin/mkfs.fat ${ROOTFS}/sbin/

#cp e2fsprogs-bin/sbin/mke2fs ${ROOTFS}/sbin/
#FILES="mkfs.ext2"
#for fn in ${FILES} ; do
#    (cd ${ROOTFS}/sbin ; ln -sf mke2fs ${fn})
#done

cp e2fsprogs-bin/sbin/e2fsck ${ROOTFS}/sbin/
FILES="fsck.ext2"
for fn in ${FILES} ; do
    (cd ${ROOTFS}/sbin ; ln -sf e2fsck ${fn})
done

if [ -d ../../linux/rootfs_modules ]; then
    cp -rfp ../../linux/rootfs_modules/lib/* ${ROOTFS}/lib
    find ${ROOTFS}/lib/modules -type l -name build -exec rm -v {} \;
    find ${ROOTFS}/lib/modules -type l -name source -exec rm -v {} \;
fi

tar --directory ${ROOTFS} -cjf rootfs.tar.bz2 .
### rm -rf ${ROOTFS} 
