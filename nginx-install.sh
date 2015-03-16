#!/bin/bash

apt-get install nginx -y

ipaddr=`/sbin/ifconfig eth0 | grep inet | head -1 | cut -d : -f 2 | cut -d " " -f 1`

echo "Your ip is ${ipaddr}"

echo -n "Enter backend host address (e.g. 192.168.1.100:8080):"

read endip

ln=`grep -n 'http {' /etc/nginx/nginx.conf | head -1 | cut -d : -f 1`

sed -i "${ln}a \
server {\
  listen 80;\
  server_name ${ipaddr};\
  \
  location / {\
    limit_except GET {\
      deny all;\
    }\
    proxy_pass http://${endip};\
  }\
}" /etc/nginx/nginx.conf

echo "success!"

