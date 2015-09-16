#!/bin/bash

IpAddress=127.0.0.1
Password=123456

apt-get install python-pip -y
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

apt-get install proxychains -y

sed -i "/^socks5/csocks5 127.0.0.1 1080" /etc/proxychains.conf

mkdir /root/.proxychains
echo -e "
strict_chain
proxy_dns 
remote_dns_subnet 224
tcp_read_time_out 15000
tcp_connect_time_out 8000
localnet 127.0.0.0/255.0.0.0
quiet_mode

[ProxyList]
socks5  127.0.0.1 1080
" > /root/.proxychains/proxychains.conf

mkdir ~/.proxychains
echo -e "
strict_chain
proxy_dns 
remote_dns_subnet 224
tcp_read_time_out 15000
tcp_connect_time_out 8000
localnet 127.0.0.0/255.0.0.0
quiet_mode

[ProxyList]
socks5  127.0.0.1 1080
" > ~/.proxychains/proxychains.conf

echo "Help: proxychains [ your command ]"

