#!/bin/bash

_now=$(date +"%m-%d-%Y")

df -h | grep -v -e 'tmpfs' -e 'boot'

lsblk | grep -v -e 'loop' -e 'boot' -e 'SWAP'

ssh test-ws -- /om/workspace-installer/current/install workspace --path /om/workspace1/manifest.json info

for i in $(systemctl --failed | awk '/service/{print$2}');do systemctl restart $i;done

for i in 101 102 103 104 105 106 107 108 109 110; do echo ws${i}; ssh corplan.ws${i} -- free -b | awk 'NR==2{print$2}'; done

