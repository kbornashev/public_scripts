#!/bin/bash
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <HOST> <PROGRAM>"
    exit 1
fi
HOST="$1"
PROGRAM="$2"
SOCKS_PORT=1080
ssh -D $SOCKS_PORT -C -N "$HOST" &
SSH_PID=$!
sleep 2
if ! ps -p $SSH_PID > /dev/null; then
    echo "Failed to establish SSH tunnel."
    exit 1
fi
echo "SSH tunnel established. Running $PROGRAM through proxychains..."
proxychains "$PROGRAM"
kill $SSH_PID
echo "SSH tunnel closed."
