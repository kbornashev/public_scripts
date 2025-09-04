#!/bin/bash
read -p "Введите значение в GiB: " gib
if ! [[ "$gib" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
    echo "Ошибка: Введенное значение не является числом."
    exit 1
fi
gib_to_bytes=$(echo "$gib * 1024^3" | bc)
echo "$gib GiB равно $gib_to_bytes байт."
echo "$gib_to_bytes" | xclip -selection clipboard
echo "Значение в байтах скопировано в буфер обмена."
