#!/bin/bash
sudo ip link set down dev tun101
sudo ip netns del router
sudo tunctl -d tun101
