#!/bin/bash

# IP address instead of domain
REMOTE_SERVER_IP=123.123.123.123
REMOTE_SERVER_PASSWORD=123456
CONFIG_PATH=/etc/shadowsocks-libev/config.json
LAN_INTERFACE_NAME=wlan0

apt-get update
apt-get install ipset shadowsocks-libev -y

# Fix https://github.com/shadowsocks/shadowsocks-libev/pull/1620 
SS_NAT_URI=https://github.com/shadowsocks/shadowsocks-libev/raw/master/src/ss-nat
wget ${SS_NAT_URI} --output-document=/usr/bin/ss-nat
chmod 755 /usr/bin/ss-nat

# Load kmod xt_TPROXY
modprobe xt_TPROXY

# Enable IPv4 forward
sed -i '/^#net.ipv4.ip_forward=1/s/^#//' /etc/sysctl.conf
sysctl -p /etc/sysctl.conf

# Disable ss-server service
systemctl disable shadowsocks-libev.service

echo -e "
{
    \"server\": \"${REMOTE_SERVER_IP}\",
    \"server_port\": 8388,
    \"local_address\": \"0.0.0.0\",
    \"local_port\": 1080,
    \"password\": \"${REMOTE_SERVER_PASSWORD}\",
    \"timeout\": 300,
    \"method\": \"aes-256-cfb\",
    \"fast_open\": false
}
" > ${CONFIG_PATH}

# Enable ss-redir service
if [ ! -e /var/run/ss-redir.pid ]; then
	CMD="/usr/bin/ss-redir -u -c ${CONFIG_PATH} -f /var/run/ss-redir.pid"
	if ! grep -q ss-redir /etc/rc.local; then
		sed -i "/^exit\ 0/i\\${CMD}\n" /etc/rc.local
	fi
	eval ${CMD}
fi

# Disable and flush all NAT rules for shadowsocks
/usr/bin/ss-nat -f
# Enable NAT rules for shadowsocks
# https://github.com/shadowsocks/shadowsocks-libev/blob/master/doc/ss-nat.asciidoc
/usr/bin/ss-nat -s ${REMOTE_SERVER_IP} -l 1080 -I ${LAN_INTERFACE_NAME} -u -o
