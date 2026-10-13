#!/bin/bash

TFTPSERVER=192.168.1.32
TFTPUSER=user

echo ""

YESNO="y"
#read -p "Скопировать комплект загрузочных файлов на tftp-сервер (${TFTPSERVER})? [y/N] " YESNO



if [ "${YESNO}" != "y" -a "${YESNO}" != "Y" ]; then
    echo "[отменено]"
    exit 1
fi

echo -n "Поиск каталога ./BOOT/tftp ... "
if [ ! -d ./BOOT -o ! -d ./BOOT/tftp ]; then
    echo "не найден"
    echo -e "\nERROR: Комплект загрузочных файлов в каталоге BOOT не найден\n"
    read -p "Press any key to continue"
    exit 2
else
    echo "OK"
fi

XME0724_DIR="/srv/tftp/xme0724-20"
BACKUPS_DIR="${XME0724_DIR}-backups"

cmd="rm -rf ${XME0724_DIR}"
echo "${TFTPSERVER}\$ ${cmd}"
ssh ${TFTPUSER}@${TFTPSERVER} "${cmd}"

cmd="mkdir -p -v ${XME0724_DIR} ; mkdir -p ${BACKUPS_DIR}"
echo "${TFTPSERVER}\$ ${cmd}"
ssh ${TFTPUSER}@${TFTPSERVER} "${cmd}"

echo ""
echo "-- download new files to ${XME0724_DIR} ..."

# 1. Закачать всё
scp -r BOOT ${TFTPUSER}@${TFTPSERVER}:${XME0724_DIR} || exit 1

# 2. Выложить для удаленной загрузки по tftp (для настройки модуля esz7)
cp_cmd="cp -rf ${XME0724_DIR}/BOOT/tftp/xme0724-20/* ${XME0724_DIR}/"
cmd="[ -d \"${XME0724_DIR}\" ] && eval $cp_cmd"
echo "${TFTPSERVER}\$ ${cp_cmd}"
ssh ${TFTPUSER}@${TFTPSERVER} "${cmd}"

# 3. Права поправить "как-надо".
ssh ${TFTPUSER}@${TFTPSERVER} "find ${XME0724_DIR} -type f -exec chmod 644 {} \;" || exit 1
ssh ${TFTPUSER}@${TFTPSERVER} "find ${XME0724_DIR} -type d -exec chmod 755 {} \;" || exit 1

# 4. Сделать копию
BACKUP_NAME="xme072420-$(date +%Y%m%d-%H%M%S)"
BACKUP_PATH="${BACKUPS_DIR}/${BACKUP_NAME}"

cp_cmd="cp -rf ${XME0724_DIR} ${BACKUP_PATH}"
cmd="[ -d \"${XME0724_DIR}\" ] && eval $cp_cmd"
echo "${TFTPSERVER}\$ ${cp_cmd}"
ssh ${TFTPUSER}@${TFTPSERVER} "${cmd}"

# 5. Сжать копию
EXT="zip"
if which zip; then
    pack_cmd="zip -r -9 -q ${BACKUP_NAME}.${EXT} ${BACKUP_NAME}"
elif which 7z; then
    pack_cmd="7z a -mx5 -tzip ${BACKUP_NAME}.${EXT} ${BACKUP_NAME}"
fi
if [ ! -z "$pack_cmd" ]; then
    cmd="[ -d \"${BACKUP_PATH}\" ] && (cd ${BACKUP_PATH}/.. && eval $pack_cmd)"
    echo "${TFTPSERVER}\$ ${pack_cmd}"
    ssh ${TFTPUSER}@${TFTPSERVER} "${cmd}"

    if [ $? -eq 0 ]; then
        # Удалить каталог с копией
        rm_cmd="rm -rf ${BACKUP_PATH}"
        cmd="[ ! -z "${BACKUP_PATH}" -a -f "${BACKUP_PATH}.${EXT}" ] && eval $rm_cmd"
        #echo "${TFTPSERVER}\$ ${cmd}"
        ssh ${TFTPUSER}@${TFTPSERVER} "${cmd}"
    fi
fi

# done.
if [ $? -ne 0 ]; then
    echo FAILED
    read -p "Press any key to continue"
fi

echo ""
read -p "Press any key to continue"
