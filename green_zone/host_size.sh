#!/bin/bash
if [ $# -ne 1 ]; then
    echo "Usage: $0 <memory_in_gib>"
    exit 1
fi
memory=$(( $1 * 1024 * 1024 * 1024 ))
workspaceSize=$(( (3 * memory) / 8 ))
echo "workspaceSize: $((workspaceSize / 1024 / 1024 / 1024)) GiB ($workspaceSize bytes)"
