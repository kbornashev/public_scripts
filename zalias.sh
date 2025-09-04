#!/bin/bash
set -euo pipefail
ZSHRC="$HOME/.zshrc"
BACKUP="$HOME/.zshrc.bak"
[ -f "$ZSHRC" ] || { echo "~/.zshrc not found"; exit 1; }
cp "$ZSHRC" "$BACKUP"
ALIASES=$(grep -E '^\s*(#\s*)?alias ' "$ZSHRC" || true)
SELECTION=$(printf "Create new alias\n%s" "$ALIASES" | fzf --prompt="Select or create alias > ")
[ -z "$SELECTION" ] && echo "No selection." && exit 0
TMP=$(mktemp)
cp "$ZSHRC" "$TMP"
insert_after_aliases_marker() {
    local new_line="$1"
    local marker_line
    marker_line=$(grep -n -i "^# *aliases" "$TMP" | cut -d: -f1 | head -n1)
    if [[ -n "$marker_line" ]]; then
        ((marker_line++))
        sed -i "${marker_line}i$new_line" "$TMP"
    else
        echo "$new_line" >> "$TMP"
    fi
}
if [[ "$SELECTION" == "➕ Create new alias" ]]; then
    read -p "Alias name: " NEW_NAME
    NEW_NAME=$(echo "$NEW_NAME" | tr -d '\r')
    [ -z "$NEW_NAME" ] && echo "Cancelled." && exit 0
    read -p "Command for '$NEW_NAME': " NEW_CMD
    NEW_CMD=$(echo "$NEW_CMD" | tr -d '\r')
    [ -z "$NEW_CMD" ] && echo "Cancelled." && exit 0
    NEW_LINE="alias $NEW_NAME=\"$NEW_CMD\""
    insert_after_aliases_marker "$NEW_LINE"
    echo "Added: $NEW_LINE"
else

    ALIAS_NAME=$(echo "$SELECTION" | sed -E 's/^[# ]*alias +([^=]+)=.*/\1/' | tr -d '"')
    ACTION=$(printf "Edit alias\nComment\nUncomment\nDelete" | fzf --prompt="Action for $ALIAS_NAME > ")
    [ -z "$ACTION" ] && echo "No action." && exit 0
    case "$ACTION" in
      "Edit alias")
        read -p "New command for alias $ALIAS_NAME: " NEW_CMD
        NEW_CMD=$(echo "$NEW_CMD" | tr -d '\r')
        [ -z "$NEW_CMD" ] && echo "Cancelled." && exit 0
        NEW_LINE="alias $ALIAS_NAME=\"$NEW_CMD\""
        sed -i "s|.*alias *$ALIAS_NAME=.*|$NEW_LINE|" "$TMP"
        ;;
      "Comment")
        sed -i "s|^\s*\(alias *$ALIAS_NAME=.*\)|# \1|" "$TMP"
        ;;
      "Uncomment")
        sed -i "s|^# *\(alias *$ALIAS_NAME=.*\)|\1|" "$TMP"
        ;;
      "Delete")
        sed -i "/alias *$ALIAS_NAME=/d" "$TMP"
        ;;
    esac
fi
cp "$TMP" "$ZSHRC"
rm "$TMP"
if [ -n "${ZSH_VERSION:-}" ]; then
  echo "Reloading .zshrc"
  source "$ZSHRC"
else
  echo "Updated ~/.zshrc"
  echo "Not in zsh shell — run 'exec zsh' to apply changes."
fi
