#!/bin/bash
if [ $# -lt 2 ]; then
    echo "Usage: $0 <hosts_file> <command>"
    exit 1
fi
HOSTS_FILE=$1
shift
COMMAND="$@"
while IFS= read -r HOST; do
    if [ -n "$HOST" ]; then
        echo "Executing command on $HOST..."
        ssh "$HOST" "$COMMAND"
        if [ $? -ne 0 ]; then
            echo "Failed to execute command on $HOST"
        else
            echo "Command executed successfully on $HOST"
        fi
    fi
done < "$HOSTS_FILE"
