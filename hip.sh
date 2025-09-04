#!/bin/bash
set -euo pipefail
HOSTS_FILE="/etc/hosts"
BACKUP_FILE="/etc/hosts.bak"
[ -f "$HOSTS_FILE" ] || { echo "❌ $HOSTS_FILE not found"; exit 1; }
sudo cp "$HOSTS_FILE" "$BACKUP_FILE"
CHOICE=$(printf "➕ Add new entry\n$(sudo grep -vE '^\s*$' $HOSTS_FILE)" | fzf --prompt="Select host entry > ")
[ -z "$CHOICE" ] && echo "Cancelled." && exit 0
TMP=$(mktemp)
sudo cp "$HOSTS_FILE" "$TMP"
if [[ "$CHOICE" == "➕ Add new entry" ]]; then
    read -p "Enter IP: " NEW_IP
    read -p "Enter hostname(s): " NEW_HOSTS
    NEW_LINE="$NEW_IP $NEW_HOSTS"
    echo "$NEW_LINE" >> "$TMP"
    echo "✔ Added: $NEW_LINE"
else
    CLEAN_LINE=$(echo "$CHOICE" | sed -E 's/^[# ]*//')
    IP=$(echo "$CLEAN_LINE" | awk '{print $1}')
    HOSTS=($(echo "$CLEAN_LINE" | cut -d' ' -f2-))

    SELECTED_HOST=$(printf "%s\n" "${HOSTS[@]}" | fzf --prompt="Select hostname > ")
    [ -z "$SELECTED_HOST" ] && echo "No host selected." && exit 0
    ACTION=$(printf "Edit IP\nRename Hostname\nComment Line\nUncomment Line\nDelete Hostname\nDelete Whole Line" | fzf --prompt="Action for $SELECTED_HOST > ")
    [ -z "$ACTION" ] && echo "No action selected." && exit 0
    case "$ACTION" in
      "Edit IP")
        read -p "New IP (was $IP): " NEW_IP
        NEW_IP=$(echo "$NEW_IP" | tr -d '\r')
        NEW_LINE="$NEW_IP ${HOSTS[*]}"
        sudo sed -i "s|^.*$SELECTED_HOST.*|$NEW_LINE|" "$TMP"
        echo "✔ Updated IP to $NEW_IP"
        ;;
      "Rename Hostname")
        read -p "Rename '$SELECTED_HOST' to: " NEW_NAME
        NEW_NAME=$(echo "$NEW_NAME" | tr -d '\r')
        sudo sed -i "s/\b$SELECTED_HOST\b/$NEW_NAME/" "$TMP"
        echo "✔ Renamed $SELECTED_HOST to $NEW_NAME"
        ;;
      "Comment Line")
        sudo sed -i "s|^.*$SELECTED_HOST.*|# $CLEAN_LINE|" "$TMP"
        echo "✔ Commented line"
        ;;
      "Uncomment Line")
        sudo sed -i "s|^# *$CLEAN_LINE|$CLEAN_LINE|" "$TMP"
        echo "✔ Uncommented line"
        ;;
      "Delete Hostname")
        NEW_LINE=$(echo "$CLEAN_LINE" | sed "s/\b$SELECTED_HOST\b//g" | tr -s ' ')
        sudo sed -i "s|^.*$SELECTED_HOST.*|$NEW_LINE|" "$TMP"
        echo "✔ Removed hostname $SELECTED_HOST"
        ;;
      "Delete Whole Line")
        sudo sed -i "/$SELECTED_HOST/d" "$TMP"
        echo "✔ Removed full line"
        ;;
    esac
fi
sudo cp "$TMP" "$HOSTS_FILE"
rm "$TMP"
echo "✔ /etc/hosts updated."
