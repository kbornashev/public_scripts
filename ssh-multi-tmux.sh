#!/bin/bash
SESSION="ssh-multi"
HOSTS_FILE="$1"
MAX_PANES=6  # максимум сплитов в одном окне
if [[ -z "$HOSTS_FILE" || ! -f "$HOSTS_FILE" ]]; then
    echo "Usage: $0 hosts.txt"
    exit 1
fi
tmux new-session -d -s "$SESSION" -n "ssh-0"
i=0
win=0
while IFS= read -r host || [ -n "$host" ]; do
    pane=$((i % MAX_PANES))
    if [ "$pane" -eq 0 ] && [ "$i" -ne 0 ]; then
        ((win++))
        tmux new-window -t "$SESSION:$win" -n "ssh-$win"
    fi
    if [ "$pane" -eq 0 ]; then
        tmux send-keys -t "$SESSION:$win" "ssh $host" C-m
    else
        tmux split-window -t "$SESSION:$win" -v "ssh $host"
        tmux select-layout -t "$SESSION:$win" tiled
    fi
    ((i++))
done < "$HOSTS_FILE"
for w in $(seq 0 "$win"); do
    tmux set-window-option -t "$SESSION:$w" synchronize-panes on > /dev/null
done
tmux attach-session -t "$SESSION"
