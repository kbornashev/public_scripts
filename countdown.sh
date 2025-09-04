#!/bin/bash
#
countdown() {
    local seconds=$1
    while [ $seconds -gt 0 ]; do
        echo -ne "Команда остановки Воркспейса будет запущена через $seconds секунд\033[0K\r"
        sleep 1
        : $((seconds--))
    done
    echo -ne "\033[0K\r"
}
countdown 5
echo "Запускаю команду..."
ls -la 
