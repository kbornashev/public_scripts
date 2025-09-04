#!/bin/bash
SESSION="ssh-multi"
HOSTS_FILE="$1"
tmux new-session -d -s $SESSION
i=0
while IFS= read -r host; do
    if [ "$i" -eq 0 ]; then
        tmux send-keys "ssh $host" C-m
    else
        tmux split-window -v
        tmux select-pane -t $i
        tmux send-keys "ssh $host" C-m
    fi
    ((i++))
done < "$HOSTS_FILE"
tmux select-layout tiled
tmux set-window-option synchronize-panes on
tmux attach -t $SESSION
