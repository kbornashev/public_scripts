#!/bin/bash
if [ $# -ne 1 ]; then
  echo "Usage: $0 <total_memory_in_gib>"
  exit 1
fi
totalMemory=$(( $1 * 1024 * 1024 * 1024 ))
maxSysMem=$(( 16 * 1024 * 1024 * 1024 ))
sysMem=$(( totalMemory / 4 ))
if (( sysMem > maxSysMem )); then
  sysMem=$maxSysMem
fi
workspaceSize=$(( (totalMemory - sysMem) / 2 ))
echo "Рабочее пространство: $((workspaceSize / 1024 / 1024 / 1024)) GiB ($workspaceSize байт)"
