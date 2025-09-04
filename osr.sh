#!/bin/bash
IMAGE="$1"
if [[ -z "$IMAGE" ]]; then
  echo "Укажи путь к изображению как аргумент."
  echo "Пример: $0 ~/Pictures/screenshot.png"
  exit 1
fi
if ! command -v tesseract &>/dev/null; then
  echo "Установи tesseract-ocr: sudo apt install tesseract-ocr"
  exit 1
fi
if ! command -v xclip &>/dev/null; then
  echo "Установи xclip: sudo apt install xclip"
  exit 1
fi
TMPFILE=$(mktemp)
tesseract "$IMAGE" "$TMPFILE" --oem 3 --psm 3
cat "$TMPFILE.txt" | xclip -selection clipboard
rm "$TMPFILE.txt"
echo "Текст скопирован в буфер обмена."
