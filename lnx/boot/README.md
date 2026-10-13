# Boot file usage instructions

## BOOT/tftp/
Copy the `BOOT/tftp/` folder to the TFTP server (the standard directory is usually `/srv/tftp`).

## BOOT/qspi/
Flash the `BOOT/qspi/*` files to the device's QSPI flash memory.

- Refer to the [Flashing](../../README.md/#flashing) section for flashing instructions.
- For flashing, set the jumpers to position: `o--- 1`
`o--- 2`

- For booting, set the jumpers to position: `o--- 1`
`---o 2`

## BOOT/sd
Copy the `BOOT/sd/*` files to the SD card.
- For booting, set the jumpers to position: `---o 1`
`---o 2`

### Initial boot
When booting from QSPI flash for the first time, a TFTP server (containing the files from `BOOT/tftp`) is required.
Formatting and populating the MMC occurs automatically.

Subsequent boots will take place from the bootable partition on MMC 1 (`/mnt/uboot`).

To replace the boot files on the MMC, perform the following operations (on a running system):
```
$ mount /mnt/uboot
$ rm /mnt/uboot/*
$ reboot
```
If the boot partition is empty, the automatic MMC population procedure will run again.

Note:
Currently, the TFTP server address is hardcoded in the source files:
```
boot.script.tftp
boot.script.qspi
```