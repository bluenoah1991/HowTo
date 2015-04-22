#!/bin/bash

apt-get update
apt-get install ntp -y

cp /etc/ntp.conf /etc/ntp.conf.bak

if [ $# -eq 0 ]; then
  sed -i "/^server/s/$/ iburst/" /etc/ntp.conf
  sed -i "/^restrict -4/s/nopeer noquery//" /etc/ntp.conf
  sed -i "/^restrict -6/s/nopeer noquery//" /etc/ntp.conf
else
  sed -i "/^server/s/^/#/" /etc/ntp.conf
  echo "server $1 iburst" >> /etc/ntp.conf
fi

service ntp restart

