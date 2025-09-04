#!/bin/bash
SSH_PORT=22                   # Порт SSH
LOCAL_SOCKS_PORT=9060         # Порт локального SOCKS5 прокси
CHECK_INTERVAL=10             # Интервал проверки соединения (в секундах)
SSH_KEY="~/.ssh/id_rsa"       # Путь к SSH-ключу
LOCK_FILE="/tmp/ssh_tunnel.lock"
LOG_FILE="/tmp/ssh_tunnel.log"
if [ $# -lt 2 ]; then
    echo "Использование: $0 user@remote.host {start|stop|status|restart}"
    exit 1
fi
REMOTE_USER_HOST=$1
COMMAND=$2
start_tunnel() {
    echo "Запуск SSH-тоннеля через $REMOTE_USER_HOST..."
    ssh -D $LOCAL_SOCKS_PORT -C -N -f -M -S ~/.ssh/ssh_tunnel_socket \
        -o ServerAliveInterval=60 -o ExitOnForwardFailure=yes \
        -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
        -i "$SSH_KEY" -p $SSH_PORT "$REMOTE_USER_HOST" 2>&1 | tee "$LOG_FILE"
    if [ $? -eq 0 ]; then
        echo "Тоннель успешно установлен."
        setup_firewall
        echo $$ > "$LOCK_FILE"
    else
        echo "Ошибка при установке тоннеля. Подробности в $LOG_FILE"
        exit 1
    fi
}
check_tunnel() {
    while [ -f "$LOCK_FILE" ]; do
        if ! pgrep -f "ssh -D $LOCAL_SOCKS_PORT" > /dev/null; then
            echo "Тоннель потерян, перезапуск..."
            start_tunnel
        fi
        sleep $CHECK_INTERVAL
    done
}
setup_firewall() {
    echo "Настройка iptables..."

    sudo sysctl -w net.ipv4.conf.all.route_localnet=1
#
    echo "iptables настроены."
}
stop_tunnel() {
    echo "Остановка SSH-тоннеля..."
    pkill -f "ssh -D $LOCAL_SOCKS_PORT"
    rm -f ~/.ssh/ssh_tunnel_socket
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
        echo "Использование: $0 user@remote.host {start|stop|status|restart}"
        exit 1
        ;;
esac
