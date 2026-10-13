#!/bin/bash

for fn in $(ls -d */ 2>/dev/null) ; do
    case ${fn} in
      busybox* | dosfstools* | e2fsprog* | rootfs* | tmp*)
        echo "remove $fn"
        rm -rf ${fn}
        ;;
    esac
done

rm -fv rootfs.tar.bz2
