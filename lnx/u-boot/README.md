# Сборка U-Boot для XME0724 (Universal Boot loader)

## Исходники

Официальный образ U-Boot из репозитория Xilinx здесь - **https://github.com/Xilinx/u-boot-xlnx.git**

- Если используем из репозитория:
```
$ git clone https://github.com/Xilinx/u-boot-xlnx.git
```

- Здесь, в комплекте, есть уже скачанный **lnx\u-boot\u-boot-xlnx-v2023.2.tar.bz2 **

Распаковка и необходимые правки в конфигцрации выполняются скриптом сборки.

Для сборки используется скрипт **build.sh**
```
$ ./build.sh
```

При необходимости есть инструментарий по конфигурированию - скрипт **make-menuconfig.sh**
````
$ ./make-menuconfig.sh
$ ./build.sh
````

### Ожидаемый результат сборки - файлы:
```
u-boot.elf
```
