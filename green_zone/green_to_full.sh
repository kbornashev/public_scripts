#!/bin/bash
if [ $# -ne 1 ]; then
  echo "Usage: $0 <workspace_size_in_gib>"
  exit 1
fi
workspaceSize=$(( $1 * 1024 * 1024 * 1024 ))
maxSysMem=$(( 16 * 1024 * 1024 * 1024 ))
sysMem=$maxSysMem
memory=$(( sysMem + workspaceSize * 2 ))
if (( sysMem > memory / 4 )); then
  sysMem=$(( memory / 4 ))
  memory=$(( sysMem + workspaceSize * 2 ))
fi
memoryGib=$((memory / 1024 / 1024 / 1024))
echo "Общее количество памяти: $memoryGib GiB ($memory байт, $((memory / 1024 / 1024)))"
x=$(( memoryGib - 32 ))
y=$(( x / 10 ))
z=$(( y + 8 ));
echo "CPU: $z"
