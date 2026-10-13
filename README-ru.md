# Сборка необходимых материалов для формирования загрузочных файлов для XME0724-20

Проект рассчитан на сборку под Windows с использованием подсистемы WSL2  
*(WSL версии 1 - не подходит - не поддерживает /dev/loop)*  
Активацию WSL и доп. ее настройки смотри ниже [WSL Installation](#wsl-installation)

Сборка отлажена под Linux и адаптирована под WSL2.

Дополнительная информация и описания - в README-ru.md в соответстующих подкаталогах.

*Примечание:*  
**Описание сборки приведено из расчета использования Linux под WSL.  
Способ с использованием `wsl.exe <команда>` не рекомендуется из-за
крайне низкой скорости работы WSL на файловой системе отличной от \\\\wsl$\\  
(это системное ограничение WSL)**

## Работа с проектом
Сборку проекта необходимо выполнять в среде WSL-Linux  

- Запускаем CMD (Win+r cmd)  
    - лучше Terminal (Win+x i) (Windows-11) - довольно удобен, напоминает bash
    - Можно и PowerShell (Win+x i) для тех *кто знает как*, но там команды чудные, например удаление каталога (очередное тупиковое развитие Windows :()...
    - *напоминалка:* в CMD вставка (Paste) ранее запомненного текста (Copy) делается правой кнопкой мыши

- Клонируем проект из репозитария (далее примеры для диска D:)
```
> git clone http://192.168.1.29/lav/xme0724-20-ver0.git D:\xme0724
> rmdir /S /Q D:\xme0724\.git
```

- Запускаем WSL и копируем проект
```
> wsl
$ cd 
$ cp -r /mnt/d/xme0724/ ./ 
$ ls -l
$ cd xme0724
```
**Примечание:** /mnt/d - это диск D:

- Запуск сборки
```
$ chmod +x clean.sh build.sh
$ ./clean.sh
$ ./build.sh
$ ls -l BOOT
```
Результат сборки проекта - папка **BOOT** - загрузочные файлы для прошивки.  
Смотрим главу [Прошивка](#прошивка).

## Прошивка

Для прошивки используются скрипты из папки boot

Детали в [lnx/boot/README-ru.md](lnx/boot/README-ru.md)

Коротко - порядок запуска:  
Windows: 
```
> cd flash
> flash.bat
```

WSL:
```
$ cd flash
$ ./flash.sh
```

## Установка WSL
1. Установка WSL
```
> wsl --install Debian
> wsl --list -v
  NAME      STATE           VERSION
* Debian    Stopped         2
```

2. DisableUNCCheck - отключить проверку UNC (Universal Naming Convention) 

_TODO: актуальность для Windows 11 не проверялась_

```
# powershell.exe (Win+x i)
reg add "HKCU\Software\Microsoft\Command Processor" /v DisableUNCCheck /t REG_DWORD /d 1
```

3. Дополнительные пакеты, которые необходимо установить в Linux,  
перечислены в файле [lnx/misc/linux-inst-pkg.sh](lnx/misc/linux-inst-pkg.sh)

Порядок запуска:  
```
# cmd.exe (Win+r cmd)  (Win+x i) 
> copy D:\xme0724\lnx\misc\linux-inst-pkg.sh \\wsl$\Debian\home\user
> wsl
$ cd 
$ chmod +x linux-inst-pkg.sh
$ ./linux-inst-pkg.sh
```

## Ограничения WSL

_TODO: актуальность для Windows 11 не проверялась_

### Медленные файловые операции
Работа с wsl.exe в Windows-каталогах приводит к существенному замедлению файловых операций

### бит exec (+x)
Бит exec у запускаемыз файлов может отсутствовать - нужна настройка в wsl.conf

### Разрешение установки бита exec (chmod +x)
В WSL обычно изначально отключена возможность установки бита exec.  
Т.е. команда `chmod +x build.sh` не будет иметь эффекта.

Для устранения такого поведения необходимо отредактировать файл /etc/wsl.conf (или создать)
и вставить параметры, указанные в файле lnx/misc/wsl.conf

**Примечание:** Можно просто скопировать весь файл, как показано ниже:
```
# cmd.exe (Win+r cmd)
> copy C:\prj\xme0724-20\lnx\misc\wsl.conf \\wsl$\Debian\etc\
> wsl --shutdown
```


### Полезные заметки

- задание ip адреса в аргументах kernel
```
ip=<client-IP-number>:[<server-id>]:<gateway-IP-number>:<netmask>:<client-hostname>:<interface>:{dhcp|dhcp6|auto6|on|any|none|off}
```
например DHCP: `ip=192.168.1.81:::::eth0:dhcp`

```
bootargs = "console=ttyPS0,115200 root=/dev/ram rw ip=192.168.1.81:::::eth0:dhcp earlyprintk earlycon";
```

- Полное удаление содержимого EMMC (XME072420)
```
# mmc dev 1
# mmc read 0 0x7fffffff 1
ERROR: ... exceeds max(0x748000)
# mmc erase 0 0x748000
```
