#!/bin/bash

IpAddress=0.0.0.0
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

ssserver -c /etc/shadowsocks.json -d start

echo "Success!"
