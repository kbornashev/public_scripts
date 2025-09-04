#!/bin/bash
if [ $# -eq 0 ]; then
    echo "Использование: $0 <удаленный_хост1> [<удаленный_хост2> ...]"
    exit 1
fi
LOCAL_PORT_BASE=9090
tmux new-session -d -s ssh_tunnels
close_tunnel() {
    local local_port=$1
    local remote_host=$2
    echo "Закрываем SSH туннель для $remote_host..."
    pkill -f "ssh -N -D $local_port $remote_host"
    echo "SSH туннель для $remote_host закрыт."
}
for (( i=1; i<=$#; i++ )); do
    remote_host="${!i}"
    local_port=$((LOCAL_PORT_BASE + i - 1))

    echo "Создаем SSH туннель для $remote_host на локальном порту $local_port..."
    ssh -N -D $local_port $remote_host &

    sleep 2

    if ! ps -ef | grep -v grep | grep "ssh -N -D $local_port $remote_host" > /dev/null; then
        echo "Ошибка: не удалось установить SSH туннель для $remote_host."
        exit 1
    fi
    echo "SSH туннель для $remote_host успешно создан на локальном порту $local_port."

    tmux send-keys -t ssh_tunnels "ssh -D $local_port localhost" Enter
done
wait
for (( i=1; i<=$#; i++ )); do
    remote_host="${!i}"
    local_port=$((LOCAL_PORT_BASE + i - 1))
    close_tunnel $local_port $remote_host
done
tmux kill-session -t ssh_tunnels
exit 0
