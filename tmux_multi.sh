#!/bin/bash
SESSION="ssh-multi"
HOSTS_FILE="$1"
DIRECTION="v"  # можно чередовать v/h
tmux new-session -d -s "$SESSION"
i=0
while IFS= read -r host; do
    if [ "$i" -eq 0 ]; then
        tmux send-keys "ssh $host" C-m
    else
        tmux split-window "-$DIRECTION" "ssh $host"
        tmux select-layout tiled
        DIRECTION=$([ "$DIRECTION" = "v" ] && echo "h" || echo "v")
    fi
    ((i++))
done < "$HOSTS_FILE"
tmux set-window-option synchronize-panes on
tmux attach -t "$SESSION"
