#!/bin/bash
if [ $# -ne 1 ]; then
    echo "Использование: $0 <адрес_удаленного_хоста>"
    exit 1
fi
LOCAL_PORT=9090
REMOTE_HOST=$1
close_tunnel() {
    echo "Закрываем SSH туннель..."
    pkill -f "ssh -N -D $LOCAL_PORT $REMOTE_HOST"
    echo "SSH туннель закрыт."
}
echo "Создаем SSH туннель..."
ssh -N -D $LOCAL_PORT $REMOTE_HOST &
sleep 2
if ! ps -ef | grep -v grep | grep "ssh -N -D $LOCAL_PORT $REMOTE_HOST" > /dev/null; then
    echo "Ошибка: не удалось установить SSH туннель."
    exit 1
fi
echo "SSH туннель успешно создан. Запуск браузера..."
xterm -e "google-chrome --incognito --proxy-server=\"socks5://localhost:$LOCAL_PORT\" --host-resolver-rules=\"MAP * ~NOTFOUND , EXCLUDE localhost\" --proxy-bypass-list=\"<local>\" --disable-plugins --disable-extensions" &
trap close_tunnel EXIT
wait
#
