#!/bin/bash
set -euo pipefail
ZSHRC="$HOME/.zshrc"
BACKUP="$HOME/.zshrc.bak"
cp "$ZSHRC" "$BACKUP"
FUNCTIONS=$(grep -nE '^\s*(function\s+)?[a-zA-Z_][a-zA-Z0-9_]*\s*\(\)' "$ZSHRC")
[ -z "$FUNCTIONS" ] && echo "No functions found in $ZSHRC" && exit 1
MAPFILE=()
while IFS= read -r line; do
  LINE_NUM=$(echo "$line" | cut -d: -f1)
  CODE=$(echo "$line" | cut -d: -f2-)
  NAME=$(echo "$CODE" | sed -E 's/^\s*(function\s+)?([a-zA-Z0-9_]+)\s*\(\).*/\2/')
  MAPFILE+=("$NAME:$LINE_NUM")
done <<< "$FUNCTIONS"
CHOICE=$(printf "%s\n" "${MAPFILE[@]}" | fzf --prompt="Select function > ")
[ -z "$CHOICE" ] && echo "Cancelled." && exit 0
FUNC_NAME=$(echo "$CHOICE" | cut -d: -f1)
LINE_NUM=$(echo "$CHOICE" | cut -d: -f2)
"${EDITOR:-vim}" +${LINE_NUM} "$ZSHRC"
if [ -n "${ZSH_VERSION:-}" ]; then
  echo "Reloading .zshrc"
  source "$ZSHRC"
else
  echo "Updated ~/.zshrc"
  echo "Not in zsh — run 'exec zsh' to apply changes."
fi
