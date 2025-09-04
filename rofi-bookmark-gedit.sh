#!/bin/bash
search_dir="/home/bo/bookmarks"
selected_file=$(find "$search_dir" -type f | rofi -dmenu -i -p "Select a file")
if [ -n "$selected_file" ]; then
    gedit "$selected_file" &
fi
