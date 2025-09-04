#!/usr/bin/env bash
xhost +
sudo ip net add router
sudo tunctl -t tun101
sudo ip link set netns router dev tun101
sudo ip net exec router ip addr add 10.0.0.2/24 dev tun101
sudo ip net exec router ip link set up dev tun101
sudo ip net exec router ip route add default via 10.0.0.2
sudo ip net exec router login -f $USER
export DISPLAY=:0
