# Подготовка linux-файловой системы

(оно-же rootfs initrd initramdisk initramfs)

## Исходники

- Файловая система делается на основе
    - busybox - **https://busybox.net/about.html**
    - dosfstools - **https://github.com/dosfstools/dosfstools**
    - e2fsprogs - **http://e2fsprogs.sourceforge.net**

- Busybox
    - В данном проекте использована версия 1.36.1 - 
[busybox-1.36.1.tar.bz2](https://busybox.net/downloads/busybox-1.36.1.tar.bz2) \
      Упакованный комплект находится в фйале - **lnx\rootfs\busybox-1.36.1.tar.bz2**  

    - **Upd:**  Используется версия 1.37.0 - [busybox-1_37_0.tar.bz2](https://git.busybox.net/busybox/snapshot/busybox-1_37_0.tar.bz2) \
      Упакованный комплект находится в фйале - **lnx\rootfs\busybox-1.37.0.tar.bz2**

      К версии 1.37.0 применены"заплатки" **lnx\rootfs\busybox-1.37.0.patched.tar.bz2**:
      - [fixes non i386 and x86 builds](https://lists.busybox.net/pipermail/busybox/2024-October/090953.html)

      - *networking/tc.c:236:27: 'TCA_CBQ_MAX’ undeclared*
        - [This bug was submitted to the official BusyBox](https://bugs.busybox.net/show_bug.cgi?id=15931)
        - [здесь заплатка](https://bugs.busybox.net/attachment.cgi?id=9751)  

      - исправлены предупреждения с "ляпами" в C-коде

    - Busybox предоставляет набор linux-утилит (/bin, /usr/bin,...), 
но для создания полноценной файловой системы необходим некоторый, минимальный, 
набор файлов и каталогов. \
Такой набор сформирован и упакованный находится в файле **rootfs.tar.bz2**,
который генерится скриптом **build.sh**

- dosfstools
    - Содержит пограммы mkfs.fat, fsck.fat и fatlabel для создания,
проверки и установки имени файловой системы на семействе FAT.

- e2fsprogs
    - Утилиты файловой системы Ext2/Ext3/Ext4 содержат все стандартные утилиты для создания,
конфигурирования и отладки ext2, ext3, и ext4 файловых систем.

## Сборка rootfs
Распаковка и использование готовых комплектов выполняется скриптом сборки - **build.sh**
```
$ ./build.sh
```

# Скрипты сборки

- **build.sh** - основной скрипт, выполняющий последовательно необходимые действия
- **build-busybox.sh** - скрипт сборки *Busybox*
- **build-dosfstools.sh** - скрипт сборки *dosfstools*
- **build-e2fsprogs.sh** - скрипт сборки *e2fsprogs*
- **build-rootfs.sh** - скрипт подготовки полного комплекта *rootfs*

### Ожидаемый результат сборки
```
uRootfs.image.gz
```
*Примечание*: **uRootfs.image.gz* это *упакованный* для процедуры UBoot-загрузки файл **rootfs.image.gz**

# Модифицирование rootfs
Для изменения комплекта необходимо распаковать комплект, выполнить модификацию, запаковать обратно.
```
$ ### распаковать
$ mkdir tmp
$ tar -C tmp -xjf rootfs-template.tar.bz2
$ cd tmp/rootfs

$ ### выполнить модификацию комплекта

$ ### запаковать
$ cd ..
$ tar cjf rootfs-template.tar.bz2 rootfs
$ cd ..
$ rm -rf ./tmp
```

