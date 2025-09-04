#!/bin/bash
if [ $# -ne 1 ]; then
    echo "Usage: $0 <workspace_size_in_gib>"
    exit 1
fi
workspaceSize=$(( $1 * 1024 * 1024 * 1024 ))
memory=$(echo "$workspaceSize * 8 / 3" | bc)
memory=$(echo "$memory / 1" | bc)
while true; do
    calculated_workspace_size=$(echo "$memory * 3 / 8" | bc)
    remainder=$(echo "$calculated_workspace_size % 1" | bc)
    if [ "$remainder" == "0" ]; then
        break
    fi
    memory=$((memory + 1))
done
echo "memory: $((memory / 1024 / 1024 / 1024)) GiB ($memory bytes)"
