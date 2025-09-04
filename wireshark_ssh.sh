#!/bin/bash
hostname=$1
ssh $hostname "sudo tcpdump -i eth0 -U -s 0 -w -" | sudo wireshark -k -i -
