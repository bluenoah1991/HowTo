#!/bin/bash

apt-get install nginx -y

ipaddr=`/sbin/ifconfig eth0 | grep inet | head -1 | cut -d : -f 2 | cut -d " " -f 1`

echo "Your ip is ${ipaddr}"

echo -n "Enter backend host address (e.g. 192.168.1.100:8080):"

read endip

ln=`grep -n 'http {' /etc/nginx/nginx.conf | head -1 | cut -d : -f 1`

sed -i "${ln}a \
server {\n\
  listen 80;\n\
  server_name ${ipaddr};\n\
  \n\
  location / {\n\
    limit_except GET {\n\
      deny all;\n\
    }\n\
    proxy_pass http://${endip};\n\
  }\n\
}" /etc/nginx/nginx.conf

if [ ! -f "/run/nginx.pid" ]; then
  /etc/init.d/nginx start
else
  nginx -s reload
fi

echo "success!"

