#!/bin/bash
guake &  # Запускаем Guake
sleep 1  # Ждем, чтобы Guake успел запуститься
xdotool search --name 'Guake' windowactivate --sync type 'tail -f /var/log/syslog'  # Вводим команду
