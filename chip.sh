#!/bin/bash
ssh_config="$HOME/.ssh/config"
select_host=$(grep -E '^Host\s' "$ssh_config" | awk '{print $2}' | fzf --prompt="Выберите хост: ")
if [[ -z "$select_host" ]]; then
  echo "Хост не выбран. Выход."
  exit 1
fi
new_ip="$1"
if [[ -z "$new_ip" ]]; then
  read -rp "Введите новый IP-адрес для хоста '$select_host': " new_ip
fi
awk -v host="$select_host" -v new_ip="$new_ip" '
  $1=="Host" {found=($2==host)}
  found && $1=="HostName" {$2=new_ip; found=0}
  {print}
' "$ssh_config" > "${ssh_config}.tmp" && mv "${ssh_config}.tmp" "$ssh_config"
echo "IP для хоста '$select_host' успешно изменён на '$new_ip'."
