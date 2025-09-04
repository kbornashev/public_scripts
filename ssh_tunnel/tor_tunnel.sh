#!/bin/bash
if [ $# -eq 0 ]; then
    echo "Использование: $0 <удаленный_хост>"
    exit 1
fi
LOCAL_PORT=9050  # Обычно используется порт 9050 для Tor
REMOTE_HOST=$1
close_tunnel() {
    echo "Закрываем SSH туннель..."
    pkill -f "ssh -N -D $LOCAL_PORT $REMOTE_HOST"
    echo "SSH туннель закрыт."
}
echo "Создаем SSH туннель на локальном порту $LOCAL_PORT для $REMOTE_HOST..."
ssh -N -D $LOCAL_PORT $REMOTE_HOST &
sleep 2
if ! ps -ef | grep -v grep | grep "ssh -N -D $LOCAL_PORT $REMOTE_HOST" > /dev/null; then
    echo "Ошибка: не удалось установить SSH туннель для $REMOTE_HOST."
    exit 1
fi
echo "SSH туннель успешно создан. Запуск Tor Browser..."
TOR_BROWSER_PATH="$HOME/tor-browser-linux/tor-browser/Browser/start-tor-browser"
"$TOR_BROWSER_PATH" --proxy-server="socks5://localhost:$LOCAL_PORT" &
trap close_tunnel EXIT
wait
exit 0
