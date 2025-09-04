#!/bin/bash
CHEATSHEET_FILE="/home/bo/bookmarks/cheatsheet_python3.md"
MAX_LENGTH=$(awk '{ if (length > max) max = length } END { print max }' "$CHEATSHEET_FILE")
WIDTH=$((MAX_LENGTH * 10 / $(tput cols)))
[ $WIDTH -gt 100 ] && WIDTH=100
rofi -dmenu -i -p "Python Cheat Sheet" -theme-str "window { width: 50%;}" < "$CHEATSHEET_FILE"
