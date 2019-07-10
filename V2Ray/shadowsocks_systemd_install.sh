#!/bin/bash

# export LC_ALL="en_US.UTF-8"
# export LC_CTYPE="en_US.UTF-8"
# sudo dpkg-reconfigure locales

ADDRESS=0.0.0.0
PORT=443
PASSWORD=123456
DOMAIN=mydomain.me
V2RAYPLUGIN=/usr/bin/v2ray-plugin_linux_amd64
SUBJECT=/C=US/ST=Denial/L=Springfield/O=Dis/CN=${DOMAIN}

# install shadowsocks server
if [ ! -e /usr/bin/ss-server ]; then
apt-get install software-properties-common -y
add-apt-repository ppa:max-c-lv/shadowsocks-libev -y
apt-get update
apt install shadowsocks-libev -y
fi

# create shadowsocks config file
if [ ! -e /etc/shadowsocks.json ]; then
echo -e "{
    \"server\": \"${ADDRESS}\",
    \"server_port\": ${PORT},
    \"local_address\": \"0.0.0.0\",
    \"local_port\": 1080,
    \"password\": \"${PASSWORD}\",
    \"timeout\": 300,
    \"method\": \"aes-256-gcm\",
    \"fast_open\": false,
    \"plugin\": \"${V2RAYPLUGIN}\",
    \"plugin_opts\": \"server;tls;cert=/root/server.crt;key=/root/server.key\"
}" > /etc/shadowsocks.json

echo -e "{
    \"server\": \"${ADDRESS}\",
    \"server_port\": ${PORT},
    \"local_address\": \"0.0.0.0\",
    \"local_port\": 1080,
    \"password\": \"${PASSWORD}\",
    \"timeout\": 300,
    \"method\": \"aes-256-gcm\",
    \"fast_open\": false,
    \"plugin\": \"${V2RAYPLUGIN}\",
    \"plugin_opts\": \"tls;host=${DOMAIN};cert=/root/server.crt\"
}" > /etc/shadowsocks-client.json
fi

# generate certificate
if [ ! -e /root/server.crt ]; then
apt-get install openssl -y
openssl req -nodes -new -x509 -keyout /root/server.key -out /root/server.crt -subj "${SUBJECT}"
fi

# download v2ray plugin
if [ ! -e /usr/bin/v2ray-plugin_linux_amd64 ]; then
wget https://github.com/shadowsocks/v2ray-plugin/releases/download/v1.1.0/v2ray-plugin-linux-amd64-v1.1.0.tar.gz --output-document=./v2ray-plugin-linux-amd64.tar.gz
tar zxvf ./v2ray-plugin-linux-amd64.tar.gz
cp ./v2ray-plugin_linux_amd64 /usr/bin/v2ray-plugin_linux_amd64
fi

# configure to automatically start up at boot
if [ -e /etc/rc.local ]; then
if ! grep -q ssserver /etc/rc.local; then
COMMAND="/usr/bin/ss-server -c /etc/shadowsocks.json -f /var/run/shadowsocks-v2ray.pid"
sed -i "/^exit\\ 0/i\\${COMMAND}\\n" /etc/rc.local
# start server
${COMMAND}
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
