#!/usr/bin/env bash
lines=( $@ )
echo "${lines[@]}"
for line in ${lines[@]};
do
  ssh $line -- sudo tee -a /home/optiroot/.ssh/authorized_keys > /dev/null << EOF
EOF
done
