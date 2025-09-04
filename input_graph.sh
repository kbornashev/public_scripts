#!/bin/bash
VAULT_DIR="/home/bo/INPUT" 
NODES_DIR="$VAULT_DIR/nodes"
RAW_FILE="$VAULT_DIR/connections_raw.txt"
LOG_FILE="$VAULT_DIR/events_log.md"
mkdir -p "$NODES_DIR"
TEMP=$(mktemp)
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
}' > "$TEMP"
find "$NODES_DIR" -type f ! -name 'events_log.md' -delete
LOCALS=$(awk '{print $1}' "$TEMP" | sort -u)
for local_ip in $LOCALS; do
    local_file="$NODES_DIR/${local_ip}.md"
    if [ ! -f "$local_file" ]; then
        echo "# Локальный IP $local_ip" > "$local_file"
        echo "tags: #local" >> "$local_file"
        echo "$(timestamp) Добавлен локальный IP: $local_ip" >> "$LOG_FILE"
    fi
    grep "^$local_ip " "$TEMP" | while read lip lport rip; do
        port_file="$NODES_DIR/${lport}.md"
        remote_file="$NODES_DIR/${rip}.md"

        if [ ! -f "$port_file" ]; then
            service_name=$(getent services "$lport" | awk '{print $1}')
            if [ -z "$service_name" ]; then
                service_name="(неизвестный сервис)"
            fi
            echo "# Порт :$lport" > "$port_file"
            echo "**Имя сервиса:** $service_name" >> "$port_file"
            echo "" >> "$port_file"
            echo "tags: #port" >> "$port_file"
            echo "$(timestamp) Добавлен порт: $lport ($service_name)" >> "$LOG_FILE"
        fi

        if [ ! -f "$remote_file" ]; then
            host_name=$(dig -x "$rip" +short | sed 's/\.$//')
            if [ -z "$host_name" ]; then
                host_name="(имя не найдено)"
            fi
            echo "# Удалённый IP $rip" > "$remote_file"
            echo "" >> "$remote_file"
            echo "**Имя хоста:** $host_name" >> "$remote_file"
            echo "" >> "$remote_file"
            echo "tags: #remote" >> "$remote_file"
            echo "$(timestamp) Добавлен внешний IP: $rip ($host_name)" >> "$LOG_FILE"
        fi

        echo "- [[$lport]]" >> "$local_file"
        echo "- [[$rip]]" >> "$port_file"
    done
done
rm "$TEMP"
echo "[*] Vault успешно обновлён с журналом событий!"
