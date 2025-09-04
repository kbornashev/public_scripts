#!/bin/bash
URL="https://tasksboard.com/app"
BROWSER="google-chrome"
function check_window() {
  local title_pattern="$1"
  xdotool search --onlyvisible --name "$title_pattern" | while read -r win_id; do
    if [ -n "$win_id" ]; then
      echo "$win_id"
      return
    fi
  done
}
WIN_ID=$(check_window "$URL")
if [ -z "$WIN_ID" ]; then

  $BROWSER --new-window "$URL" &
else

  xdotool windowactivate "$WIN_ID"
fi
