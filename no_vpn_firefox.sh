set -e
NAMESPACE=no-vpn
VETH_HOST=veth0
VETH_NS=veth1
BRIDGE_IP=10.200.1.1
NS_IP=10.200.1.2
IFACE=wlp0s20f3  # Интерфейс без VPN
BROWSER_USER=$USER  # Текущий пользователь
PROFILE_NAME=vpnless
echo "Создание namespace '$NAMESPACE'..."
sudo ip netns del $NAMESPACE 2>/dev/null || true
sudo ip netns add $NAMESPACE
sudo ip link add $VETH_HOST type veth peer name $VETH_NS
sudo ip link set $VETH_NS netns $NAMESPACE
sudo ip addr add $BRIDGE_IP/24 dev $VETH_HOST
sudo ip link set $VETH_HOST up
sudo ip netns exec $NAMESPACE ip addr add $NS_IP/24 dev $VETH_NS
sudo ip netns exec $NAMESPACE ip link set $VETH_NS up
sudo ip netns exec $NAMESPACE ip link set lo up
sudo ip netns exec $NAMESPACE ip route add default via $BRIDGE_IP
sudo ip netns exec $NAMESPACE bash -c "echo nameserver 8.8.8.8 > /etc/resolv.conf"
sudo iptables -t nat -A POSTROUTING -s ${NS_IP}/24 -o $IFACE -j MASQUERADE
echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward
xhost +SI:localuser:$BROWSER_USER
if ! firefox -P "$PROFILE_NAME" -no-remote -CreateProfile "$PROFILE_NAME" 2>/dev/null; then
  echo "Профиль $PROFILE_NAME уже существует или создан."
fi
echo "Запуск Firefox от пользователя '$BROWSER_USER' в namespace '$NAMESPACE' без VPN..."
sudo ip netns exec $NAMESPACE sudo -u $BROWSER_USER env DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY firefox -P "$PROFILE_NAME" --no-remote
