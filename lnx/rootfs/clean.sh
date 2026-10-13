#!/bin/bash

rm -fv rootfs.image
rm -fv rootfs.image.gz
rm -fv uRootfs.image.gz
rm -fv rootfs.tar.bz2

chmod +x ./creation/clean.sh
(cd ./creation && ./clean.sh)

exit 0
