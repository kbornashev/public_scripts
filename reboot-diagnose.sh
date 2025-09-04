#!/usr/bin/env bash
set -euo pipefail
BOOT_INDEX="-1"   # предыдущая загрузка по умолчанию
LINES=400         # сколько последних строк смотреть для триггеров
ERR_WINDOW_MIN=30 # минут ошибок до завершения работы для сжатого окна
usage() {
  cat <<EOF
Usage: $0 [-i BOOT_IDX] [-l LINES]
  -i BOOT_IDX   journalctl boot index (например: -1, -2, 0). По умолчанию: -1
  -l LINES      сколько последних строк анализировать для триггеров. По умолчанию: $LINES
Примеры:
  $0                 # анализ предыдущей загрузки
  $0 -i -2           # анализ загрузки перед предыдущей
  $0 -i 0            # анализ текущей загрузки (если нужен факт последнего shutdown)
EOF
}
while getopts ":i:l:h" opt; do
  case $opt in
    i) BOOT_INDEX="$OPTARG" ;;
    l) LINES="$OPTARG" ;;
    h) usage; exit 0 ;;
    \?) echo "Invalid option: -$OPTARG" >&2; usage; exit 1 ;;
  esac
done
j() { journalctl -o short-iso "$@"; }
echo "=== REBOOT DIAGNOSIS ==="
echo "Host: $(hostname)"
echo "Now:  $(date -Is)"
echo
echo "== Boots =="
j --list-boots || true
echo
BOOT_START="$(j -b "$BOOT_INDEX" | head -n1 | cut -d' ' -f1 | sed -e 's/\..*//')"
BOOT_END="$(j -b "$BOOT_INDEX" | tail -n1 | cut -d' ' -f1 | sed -e 's/\..*//')"
echo "== Analyzing boot index: $BOOT_INDEX =="
echo "Boot window: ${BOOT_START:-unknown} .. ${BOOT_END:-unknown}"
echo
if [[ -n "${BOOT_END:-}" ]]; then
  ERR_SINCE="$(date -Is -d "${BOOT_END} - ${ERR_WINDOW_MIN} min" 2>/dev/null || echo "")"
fi
echo "== Potential trigger
