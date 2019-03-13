#!/bin/bash

# export LC_ALL="en_US.UTF-8"
# export LC_CTYPE="en_US.UTF-8"
# sudo dpkg-reconfigure locales

ADDRESS=0.0.0.0
PASSWORD=123456

# install shadowsocks server
if [ ! -e /usr/local/bin/ssserver ]; then
apt-get update
apt-get install python-pip -y

# install 2.8.2
# pip install shadowsocks

# install latest version
pip install git+https://github.com/shadowsocks/shadowsocks.git@master
fi

# create shadowsocks config file
if [ ! -e /etc/shadowsocks.json ]; then
echo -e "{
    \"server\":\"${ADDRESS}\",
    \"server_port\":8388,
    \"local_address\": \"127.0.0.1\",
    \"local_port\":1080,
    \"password\":\"${PASSWORD}\",
    \"timeout\":300,
    \"method\":\"aes-256-cfb\",
    \"fast_open\": false
}" > /etc/shadowsocks.json
fi

# configure to automatically start up at boot
if [ -e /etc/rc.local ]; then
if ! grep -q ssserver /etc/rc.local; then
sed -i '/^exit\ 0/i\/usr/local/bin/ssserver -c /etc/shadowsocks.json -d start\n' /etc/rc.local
# start server
/usr/local/bin/ssserver -c /etc/shadowsocks.json -d start
fi
else
# Systemd mode
cp ./shadowsocks.service /etc/systemd/system/shadowsocks.service
chmod 664 /etc/systemd/system/shadowsocks.service
# register and enable service
/bin/systemctl enable shadowsocks.service
/bin/systemctl enable --now shadowsocks.service
fi

echo "installation succeeded!"
