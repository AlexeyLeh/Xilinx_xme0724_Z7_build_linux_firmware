# Assembling the necessary materials to create boot files for XME0724-20

The project is designed to be built on Windows using the WSL2 subsystem.
*(WSL version 1 is not suitable, as it does not support /dev/loop)*
For WSL activation and additional configuration, see [Installing WSL](#installing-wsl) below.

The build process is optimized for Linux and adapted for WSL2.

Additional information and descriptions can be found in the README.md files within the respective subdirectories.

*Note:*
**The build instructions assume the use of Linux via WSL.** The method using `wsl.exe <command>` is not recommended due to
the extremely slow performance of WSL on file systems other than `\\wsl$\`
(this is a system limitation of WSL)**

## Working with the project
The project must be built within the WSL-Linux environment.

- Launch CMD (Win+r, type `cmd`)
- Windows Terminal (Win+x, i) is preferable (Windows 11) — it is quite convenient and resembles bash. 
- PowerShell (Win+x, i) is also an option for those *who know how*, but the commands are peculiar—for instance, deleting a directory (yet another example of Windows' misguided evolution :()...
- *Reminder:* In CMD, pasting previously copied text is done using the right mouse button.

- Clone the project from the repository (the following examples use the D: drive)
```
> git clone http://192.168.1.29/lav/xme0724-20-ver0.git D:\xme0724
> rmdir /S /Q D:\xme0724\.git
```

- Launch WSL and copy the project
```
> wsl
$ cd
$ cp -r /mnt/d/xme0724/ ./
$ ls -l
$ cd xme0724
```
**Note:** `/mnt/d` corresponds to the D: drive.

- Start the build process
```
$ chmod +x clean.sh build.sh
$ ./clean.sh
$ ./build.sh
$ ls -l BOOT
```
The build result is the **BOOT** folder, containing the boot files for flashing.
See the [Flashing](#flashing) section.

## Flashing

Scripts from the `boot` folder are used for flashing.

Details in [boot/README.md](./boot/README.md)

In brief – startup procedure:
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

## WSL Installation
1. Install WSL
```
> wsl --install Debian
> wsl --list -v
NAME      STATE           VERSION
* Debian    Stopped         2
```

2. DisableUNCCheck – disable UNC (Universal Naming Convention) checking

_TODO: relevance for Windows 11 has not been verified_

```
# powershell.exe (Win+x i)
reg add "HKCU\Software\Microsoft\Command Processor" /v DisableUNCCheck /t REG_DWORD /d 1
```

3. Additional packages that need to be installed in Linux
are listed in the file [lnx/misc/linux-inst-pkg.sh](lnx/misc/linux-inst-pkg.sh)

Startup procedure:
```
# cmd.exe (Win+r cmd)  (Win+x i)
> copy D:\xme0724\lnx\misc\linux-inst-pkg.sh \\wsl$\Debian\home\user
> wsl
$ cd
$ chmod +x linux-inst-pkg.sh
$ ./linux-inst-pkg.sh
```

## WSL Limitations

_TODO: relevance for Windows 11 has not been verified_

### Slow file operations
Using wsl.exe within Windows directories results in significantly slower file operations.

### Executable bit (+x)
The executable bit on executable files may be missing – configuration in wsl.conf is required.

### Enabling the executable bit (chmod +x)
In WSL, the ability to set the executable bit is usually disabled by default.
I.e. the `chmod +x build.sh` command will have no effect.

To resolve this behavior, you need to edit (or create) the `/etc/wsl.conf` file
and insert the parameters specified in the `lnx/misc/wsl.conf` file.

**Note:** You can simply copy the entire file as shown below:
```
# cmd.exe (Win+r cmd)
> copy C:\prj\xme0724-20\lnx\misc\wsl.conf \\wsl$\Debian\etc\
> wsl --shutdown
```


### Useful notes

- Setting the IP address in kernel arguments
```
ip=<client-IP-number>:[<server-id>]:<gateway-IP-number>:<netmask>:<client-hostname>:<interface>:{dhcp|dhcp6|auto6|on|any|none|off}
```
e.g., DHCP: `ip=192.168.1.81:::::eth0:dhcp`

```
bootargs = "console=ttyPS0,115200 root=/dev/ram rw ip=192.168.1.81:::::eth0:dhcp earlyprintk earlycon";
```

- Completely erasing eMMC contents (XME072420)
```
# mmc dev 1
# mmc read 0 0x7fffffff 1
ERROR: ... exceeds max(0x748000)
# mmc erase 0 0x748000
```