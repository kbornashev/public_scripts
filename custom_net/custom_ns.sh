#!/bin/bash
NS_NAME="custom_ns"
sudo ip netns add $NS_NAME
sudo ip link add veth0 type veth peer name veth1
sudo ip link set veth1 netns $NS_NAME
sudo ip addr add 192.168.100.1/24 dev veth0
sudo ip link set veth0 up
sudo ip netns exec $NS_NAME ip addr add 192.168.100.2/24 dev veth1
sudo ip netns exec $NS_NAME ip link set veth1 up
sudo ip netns exec $NS_NAME ip link set lo up
sudo iptables -t nat -A POSTROUTING -s 192.168.100.0/24 ! -o veth0 -j MASQUERADE
sudo ip netns exec $NS_NAME ip route add default via 192.168.100.1
sudo mkdir -p /etc/netns/$NS_NAME
echo "nameserver 8.8.8.8" | sudo tee /etc/netns/$NS_NAME/resolv.conf
sudo ip netns exec $NS_NAME bash
