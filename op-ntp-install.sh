#!/bin/bash

apt-get update

if [ ! -f "/etc/ntp.conf" ]; then
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
fi

service ntp restart

if [ ! -f "/etc/apt/sources.list.d/cloudarchive-juno.list" ]; then
  apt-get install ubuntu-cloud-keyring
  echo "deb http://ubuntu-cloud.archive.canonical.com/ubuntu" \
  "trusty-updates/juno main" > /etc/apt/sources.list.d/cloudarchive-juno.list
  apt-get update && apt-get dist-upgrade
fi
