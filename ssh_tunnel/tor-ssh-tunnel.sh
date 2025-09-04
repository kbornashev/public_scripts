#!/bin/bash
LOCAL_SOCKS_PORT=9050         # Порт локального SOCKS5-прокси
CHECK_INTERVAL=10             # Интервал проверки соединения (в секундах)
TOR_SSH_CONFIG="$HOME/.ssh/tor_config"  # Конфиг SSH для Tor
LOCK_FILE="/tmp/tor_ssh_tunnel.lock"
LOG_FILE="/tmp/tor_ssh_tunnel.log"
if [ $# -lt 2 ]; then
    echo "Использование: $0 tor-server-name {start|stop|status|restart}"
    exit 1
fi
TOR_SERVER=$1
COMMAND=$2
start_tunnel() {
   echo "Запуск Tor SSH-туннеля через $TOR_SERVER..."
   ssh -F "$TOR_SSH_CONFIG" -D "$LOCAL_SOCKS_PORT" -C -N "$TOR_SERVER" -f </dev/null
   if [ $? -eq 0 ]; then
       echo "Тоннель успешно установлен. SOCKS5-прокси доступен на 127.0.0.1:$LOCAL_SOCKS_PORT"
       echo $$ > "$LOCK_FILE"
   else
       echo "Ошибка при установке тоннеля. Подробности в $LOG_FILE"
       exit 1
   fi
}
check_tunnel() {
    while [ -f "$LOCK_FILE" ]; do
        if ! pgrep -f "ssh -F $TOR_SSH_CONFIG -D $LOCAL_SOCKS_PORT" > /dev/null; then
            echo "Тоннель потерян, перезапуск..."
            start_tunnel
        fi
        sleep $CHECK_INTERVAL
    done
}
stop_tunnel() {
    echo "Остановка Tor SSH-туннеля..."
    pkill -f "ssh -F $TOR_SSH_CONFIG -D $LOCAL_SOCKS_PORT"
    rm -f "$LOCK_FILE"
    echo "Тоннель отключён."
}
case "$COMMAND" in
    start)
        if [ -f "$LOCK_FILE" ]; then
            echo "Тоннель уже запущен."
            exit 0
        fi
        start_tunnel
        check_tunnel &
        ;;
    stop)
        if [ ! -f "$LOCK_FILE" ]; then
            echo "Тоннель не запущен."
            exit 0
        fi
        stop_tunnel
        ;;
    status)
        if [ -f "$LOCK_FILE" ]; then
            echo "Тоннель запущен."
        else
            echo "Тоннель не работает."
        fi
        ;;
    restart)
        stop_tunnel
        start_tunnel
        check_tunnel &
        ;;
    *)
        echo "Использование: $0 tor-server-name {start|stop|status|restart}"
        exit 1
        ;;
esac
