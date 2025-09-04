#!/bin/bash
TMP_ROUTE_FILE="/tmp/vpn-pushed-routes.txt"
FINAL_ROUTE_FILE="$HOME/.config/pritunl/custom-routes.sh"
echo "[*] Подключись к VPN с route-pull (по умолчанию) и нажми Enter"
read -r
echo "[*] Сохранить маршруты, полученные от VPN..."
ip route | grep -Ev '(^default|linkdown)' | awk '/via/ && ($1 ~ /[0-9]/) { print "ip route add " $1 " via " $3 " dev " $5 }' > "$TMP_ROUTE_FILE"
echo "[*] Фильтруем только приватные подсети (10/8, 192.168/16, 172.16/12, 100.64/10)..."
grep -E '10\.|192\.168\.|172\.(1[6-9]|2[0-9]|3[0-1])\.|100\.' "$TMP_ROUTE_FILE" > "$FINAL_ROUTE_FILE"
echo "[+] Готово! Сохранённые маршруты:"
cat "$FINAL_ROUTE_FILE"
echo ""
echo "После включения route-nopull, добавляй маршруты вручную:"
echo "    bash $FINAL_ROUTE_FILE"
