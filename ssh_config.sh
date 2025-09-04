#!/bin/bash
SSH_CONFIG_PATH="$HOME/.ssh/config"
COMMAND="ваша_команда"
UNREACHABLE_HOSTS_FILE="unreachable_hosts.txt"
HOSTS=$(grep -E "^\s*Host" $SSH_CONFIG_PATH | awk '{print $2}')
> $UNREACHABLE_HOSTS_FILE
execute_command() {
    host=$1
    echo "Executing command on $host..."
    ssh -o BatchMode=yes -o ConnectTimeout=5 $host "$COMMAND"

    if [ $? -ne 0 ]; then
        echo "$host is unreachable" >> $UNREACHABLE_HOSTS_FILE
        echo "Failed to connect to $host"
    fi
}
for host in $HOSTS; do
    execute_command $host
done
echo "Unreachable hosts:"
cat $UNREACHABLE_HOSTS_FILE
