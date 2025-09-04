#!/bin/bash
WINDOW_TITLE=$1
WIDTH=$2
HEIGHT=$3
X_POS=$4
Y_POS=$5
gnome-terminal --title "$WINDOW_TITLE" --window &
sleep 2
WINDOW_ID=$(wmctrl -l | grep "$WINDOW_TITLE" | awk '{print $1}')
wmctrl -i -r $WINDOW_ID -e 0,$X_POS,$Y_POS,$WIDTH,$HEIGHT
