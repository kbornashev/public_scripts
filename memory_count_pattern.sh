#!/bin/bash
total_memory=0
pattern=$@
for pid in $(pgrep $pattern); do

    memory_info=$(pmap -x $pid | grep "total kB")

    memory=$(echo $memory_info | awk '{print $3}')
    total_memory=$((total_memory + memory))
done
echo "Общая занимаемая память: ${total_memory} KB"
