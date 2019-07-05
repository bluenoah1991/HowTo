#!/bin/bash

# export LC_ALL="en_US.UTF-8"
# export LC_CTYPE="en_US.UTF-8"
# sudo dpkg-reconfigure locales

IPADDRESS=0.0.0.0
PASSWORD=123456

# install shadowsocks server
if [ ! -e /usr/local/bin/ssserver ]; then
apt-get update
apt-get install python-pip -y
pip install shadowsocks
fi

# create shadowsocks config file
if [ ! -e /etc/shadowsocks.json ]; then
echo -e "{
    \"server\":\"${IPADDRESS}\",
    \"server_port\":8388,
    \"local_address\": \"127.0.0.1\",
    \"local_port\":1080,
    \"password\":\"${PASSWORD}\",
    \"timeout\":300,
    \"method\":\"aes-256-gcm\",
    \"fast_open\": false
}" > /etc/shadowsocks.json
fi

# configure to automatically start up at boot
if ! grep -q ssserver /etc/rc.local; then
sed -i '/^exit\ 0/i\/usr/local/bin/ssserver -c /etc/shadowsocks.json -d start\n' /etc/rc.local
fi

# start server
/usr/local/bin/ssserver -c /etc/shadowsocks.json -d start

echo "installation succeeded!"
