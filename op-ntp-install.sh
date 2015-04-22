#!/bin/bash

apt-get update
apt-get install ntp -y

cp /etc/ntp.conf /etc/ntp.conf.bak

sed -i "/^server/s/$/ iburst/" /etc/ntp.conf
sed -i "/^restrict -4/s/nopeer noquery//" /etc/ntp.conf
sed -i "/^restrict -6/s/nopeer noquery//" /etc/ntp.conf

service ntp restart

