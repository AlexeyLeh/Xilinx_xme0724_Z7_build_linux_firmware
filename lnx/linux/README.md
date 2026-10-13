# Сборка linux для XME0724-20

## Исходники

Официальный образ Linux из репозитория Xilinx взят здесь - **https://github.com/Xilinx/linux-xlnx**

- Если используем из репозитория:

```
$ git clone --branch xilinx-v2023.2 --single-branch --depth 1 https://github.com/Xilinx/linux-xlnx linux-xlnx-v2023.2
$ git co tags/xilinx-v2023.2 -b xilinx-v2023.2
```

- Здесь, в комплекте, есть уже скачанный **lnx\linux\linux-xlnx-branch-v2023.2.tar.bz2**

Распаковка и необходимые правки в конфигурации выполняются скриптом сборки.

Для сборки используется скрипт **build.sh**
```
$ ./build.sh
```

При необходимости есть инструментарий по конфигурированию - скрипт **make-menuconfig.sh**
````
$ ./make-menuconfig.sh
$ ./build.sh
````

### Ожидаемый результат сборки
- файл **uImage**
```
uImage
```
