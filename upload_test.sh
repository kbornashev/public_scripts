#!/bin/bash
URL="http://localhost/upload"  # Укажи свой URL
TMP_DIR="/tmp/nginx_upload_test"
mkdir -p "$TMP_DIR"
MIN=1        # Начнем с 1 МБ
MAX=100      # Максимум 100 МБ (можно изменить)
STEP=1       # Точность поиска в МБ
RESULT=0
generate_file() {
    SIZE_MB=$1
    fallocate -l "${SIZE_MB}M" "$TMP_DIR/test_${SIZE_MB}.dat"
}
while (( MIN <= MAX )); do
    MID=$(( (MIN + MAX) / 2 ))
    FILE="$TMP_DIR/test_${MID}.dat"

    [[ -f "$FILE" ]] || generate_file "$MID"
    echo "Пробуем загрузить файл размером ${MID} MB..."
    RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -F "file=@$FILE" "$URL")
    if [[ "$RESPONSE" == "413" ]]; then
        echo "→ ${MID} MB: слишком большой (413)"
        MAX=$(( MID - STEP ))
    elif [[ "$RESPONSE" == "2"* ]]; then
        echo "→ ${MID} MB: успешно (${RESPONSE})"
        RESULT=$MID
        MIN=$(( MID + STEP ))
    else
        echo "→ ${MID} MB: ошибка (код $RESPONSE)"
        break
    fi
done
echo
echo "🎯 Максимальный разрешённый размер файла: ${RESULT} MB"
rm -rf "$TMP_DIR"
