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
if pgrep -x "qutebrowser" >/dev/null; then
    echo "Qutebrowser уже запущен."
else

    ssh -N -D $LOCAL_PORT $REMOTE_HOST &

    sleep 2

    export http_proxy="socks5://localhost:$LOCAL_PORT"

    qutebrowser &

    trap close_tunnel EXIT
fi
exit 0
