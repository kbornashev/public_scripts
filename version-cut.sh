#!/bin/bash
echo "Введите JSON-данные (завершите ввод пустой строкой):"
json_data=""
while IFS= read -r line; do

    [[ -z "$line" ]] && break
    json_data+="$line"$'\n'
done
versions=$(echo "$json_data" | grep -oP '(?<=: ")[^"]*' | sed 's/"//g')
echo "$versions" | paste -sd ' ' - | xsel --clipboard
