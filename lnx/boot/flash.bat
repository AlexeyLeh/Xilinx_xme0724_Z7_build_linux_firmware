@echo off
echo .
echo . Set the load mode switch to "JTAG mode"
echo .  ON   o---  2
echo .       o---  1
echo .


@set BOOT_FILES=.\qspi
@set FSBL=%BOOT_FILES%\fsbl.elf
@set BOOTBIN=%BOOT_FILES%\boot_qspi.bin

@if not exist "%FSBL%" (
    @echo ERROR: file not found - %FSBL%
    @pause
    @exit /b 1
)

@if not exist "%BOOTBIN%" (
    @echo ERROR: file not found - "%BOOTBIN%"
    @pause
    @exit /b 2
)

which program_flash.bat

@echo:
@echo flashing %BOOTBIN%
@echo:

call program_flash.bat ^
-fsbl %FSBL% ^
-f "%BOOTBIN%" -offset 0 ^
-flash_type qspi-x4-single ^
-url TCP:127.0.0.1:3121

