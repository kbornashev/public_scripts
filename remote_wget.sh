#!/bin/bash
if [ "$#" -ne 3 ]; then
    echo "Использование: $0 <удалённый_хост> <ссылка_на_скачивание> <директория>"
    exit 1
fi
REMOTE_HOST=$1
DOWNLOAD_URL=$2
TARGET_DIR=$3
if [ -n "$TERGET_DIR" ];
then 
  read -p "Введите логин для скачивания: " WGET_USER
else
  TARGET_DIR="kbornashev"
fi
read -s -p "Введите пароль для скачивания: " WGET_PASS
echo
ssh "$REMOTE_HOST" "exit"
if [ $? -ne 0 ]; then
    echo "Ошибка подключения к удалённому хосту: $REMOTE_HOST"
    exit 1
fi
ssh "$REMOTE_HOST" << EOF
    if sudo test -w "$TARGET_DIR"; then
        echo "Доступ к директории $TARGET_DIR есть."
    else
        echo "Нет доступа к директории $TARGET_DIR, попытка получения доступа через sudo."
        sudo mkdir -p "$TARGET_DIR"
        sudo chmod u+w "$TARGET_DIR"
    fi
    sudo wget --user="$WGET_USER" --password="$WGET_PASS" "$DOWNLOAD_URL" -P "$TARGET_DIR"
    if [ $? -eq 0 ]; then
        echo "Скачивание завершено успешно."
    else
        echo "Ошибка при скачивании файла."
        exit 1
    fi
EOF
