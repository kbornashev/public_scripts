#!/bin/bash

if [ "$#" -lt 2 ]; then
    echo "Usage: $0 nickname target (e.g., alice 192.168.0.10 or alice bo@192.168.0.10)"
    exit 1
fi

nickname="$1"
target="$2"

if [[ "$target" == *@* ]]; then
    remote_user="${target%@*}"
    remote_host="${target#*@}"
else
    remote_user="$nickname"
    remote_host="$target"
fi

keys_file="/home/bo/om/ssh_keys.txt"

if [ ! -f "$keys_file" ]; then
    echo "Файл с ключами $keys_file не найден"
    exit 1
fi

run_ssh_command() {
    local command="$1"

    if grep -q "^Host $remote_host$" ~/.ssh/config; then
        ssh_command="ssh -o StrictHostKeyChecking=no $remote_host \"$command\""
    else
        ssh_command="ssh -o StrictHostKeyChecking=no $remote_user@$remote_host \"$command\""
    fi

    eval "$ssh_command"
}

comment_line=""
ssh_key_line=""
while IFS= read -r line; do
    if [[ "$line" =~ ^\#\ $nickname ]]; then
        comment_line="$line"
        read -r ssh_key_line
        break
    fi
done < "$keys_file"

if [ -z "$ssh_key_line" ]; then
    echo "КЛЮЧ $nickname НЕ НАЙДЕН ($keys_file)"
    exit 1
fi

check_command="grep -Fxq '$ssh_key_line' ~/.ssh/authorized_keys"
if run_ssh_command "$check_command"; then
    echo "КЛЮЧ УЖЕ СУЩЕСТВУЕТ на $remote_user@$remote_host"
    exit 0
fi

add_command="echo -e '$comment_line\n$ssh_key_line' >> ~/.ssh/authorized_keys"
if run_ssh_command "$add_command"; then
    echo "$nickname ДОБАВЛЕН на $remote_user@$remote_host"
    echo "---"
    grep "$remote_host" -A1 $HOME/.ssh/config
else
    echo "ОШИБКА ( $nickname хост $target )"
fi

