#!/bin/bash
TMPFILE=$(mktemp --suffix=.png)
flameshot gui -r > "$TMPFILE"
if [ -s "$TMPFILE" ]; then

    RESULT=$(zbarimg "$TMPFILE" | grep -oP 'QR-Code:\K.*')

    if [ -n "$RESULT" ]; then
        echo "QR-код найден: $RESULT"

        echo -n "$RESULT" | xclip -selection clipboard
        echo "Результат скопирован в буфер обмена!"
    else
        echo "QR-код не найден."
    fi
else
    echo "Скриншот не был сделан."
fi
rm -f "$TMPFILE"
