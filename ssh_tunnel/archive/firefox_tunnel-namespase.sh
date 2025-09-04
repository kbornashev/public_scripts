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
ssh -N -D $LOCAL_PORT $REMOTE_HOST &
sleep 2
export DISPLAY=:0
export XAUTHORITY=/run/user/$(id -u)/gdm/Xauthority
firefox --new-instance --private-window --proxy-server="socks5://localhost:$LOCAL_PORT" &
trap close_tunnel EXIT
exit 0
