#!/bin/bash
VAULT_DIR="/home/bo/INPUT_2"  
NODES_DIR="$VAULT_DIR/nodes"
RAW_FILE="$VAULT_DIR/connections_raw.txt"
LOG_FILE="$VAULT_DIR/events_log.md"
mkdir -p "$NODES_DIR"
tmp=$(mktemp)
lsof -i -nP > "$RAW_FILE"
timestamp() {
    date +"%Y-%m-%d %H:%M:%S"
}
lsof -i -nP | awk '
NR>1 {
    split($9, conn, "->")
    if (conn[2] != "") {
        split(conn[1], local, ":")
        split(conn[2], remote, ":")
        gsub(/\(.*\)/, "", remote[2])
        gsub(/\(.*\)/, "", local[2])
        printf "%s %s %s\n", local[1], local[2], remote[1]
    }
}' > "$tmp"
find "$NODES_DIR" -type f ! -name 'events_log.md' -delete
mapfile -t LOCALS < <(awk '{print $1}' "$tmp" | sort -u)
for local_ip in "${LOCALS[@]}"; do
    local_file="$NODES_DIR/${local_ip}.md"

    iface=$(ip -o addr | awk -v ip="$local_ip" '$0 ~ ip {print $2; exit}')
    [ -z "$iface" ] && iface="(неизвестный интерфейс)"
    if [ ! -f "$local_file" ]; then
        {
            echo "# Локальный IP $local_ip"
            echo "**Интерфейс:** $iface"
            echo "tags: #local"
        } > "$local_file"
        echo "$(timestamp) Добавлен локальный IP: $local_ip (iface: $iface)" >> "$LOG_FILE"
    fi
    grep -Fq "$local_ip " "$tmp" && {
        grep "^$local_ip " "$tmp" | while read -r lip lport rip; do
            port_file="$NODES_DIR/${lport}.md"
            remote_file="$NODES_DIR/${rip}.md"

            if [ ! -f "$port_file" ]; then
                service_name=$(getent services "$lport" | awk '{print $1}')
                [ -z "$service_name" ] && service_name="(неизвестный сервис)"
                {
                    echo "# Порт :$lport"
                    echo "**Имя сервиса:** $service_name"
                    echo "tags: #port"
                } > "$port_file"
                echo "$(timestamp) Добавлен порт: $lport ($service_name)" >> "$LOG_FILE"
            fi

            if [ ! -f "$remote_file" ]; then
                host_name=$(dig -x "$rip" +short | sed 's/\.$//')
                [ -z "$host_name" ] && host_name="(имя не найдено)"
                region=$(whois "$rip" | awk -F: '/Country|country/ {gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2; exit}')
                [ -z "$region" ] && region="(неизвестный регион)"
                {
                    echo "# Удалённый IP $rip"
                    echo "**Имя хоста:** $host_name"
                    echo "**Регион:** $region"
                    echo "tags: #remote"
                } > "$remote_file"
                echo "$(timestamp) Добавлен внешний IP: $rip ($host_name, $region)" >> "$LOG_FILE"
            fi

            if ! grep -Fx -- "- [[${lport}]]" "$local_file"; then
                echo "- [[${lport}]]" >> "$local_file"
            fi

            if ! grep -Fx -- "- [[${rip}]]" "$port_file"; then
                echo "- [[${rip}]]" >> "$port_file"
            fi
        done
    }
done
rm "$tmp"
echo "[*] Vault успешно обновлён с журналом событий!"
