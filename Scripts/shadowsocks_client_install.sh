#!/bin/bash

IpAddress=your_host_ip
Password=123456

apt-get install python-pip make -y
pip install shadowsocks

echo -e "
{
    \"server\":\"${IpAddress}\",
    \"server_port\":8388,
    \"local_address\": \"127.0.0.1\",
    \"local_port\":1080,
    \"password\":\"${Password}\",
    \"timeout\":300,
    \"method\":\"aes-256-cfb\",
    \"fast_open\": false
}
" > /etc/shadowsocks.json

sslocal -c /etc/shadowsocks.json -d start

git clone https://github.com/rofl0r/proxychains-ng.git /usr/local/proxychains-ng
pushd /usr/local/proxychains-ng
sed -i "/^socks4/csocks5 127.0.0.1 1080" ./src/proxychains.conf
./configure –prefix=/usr –sysconfdir=/etc
make
make install
make install-config
popd

echo "Help: proxychains4 [ your command ]"
