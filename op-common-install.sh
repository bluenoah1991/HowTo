#!/bin/bash

CTL_MGR_IPADDR=10.0.0.11

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
  apt-get install ubuntu-cloud-keyring -y
  echo "deb http://ubuntu-cloud.archive.canonical.com/ubuntu" \
  "trusty-updates/juno main" > /etc/apt/sources.list.d/cloudarchive-juno.list
  apt-get update && apt-get dist-upgrade
fi

if [ $# -eq 0 ]; then
  apt-get install mariadb-server python-mysqldb -y
  #echo 'Please tell me your MariaDB password:'
  #read MARIADBPWD
  cp /etc/mysql/my.cnf /etc/mysql/my.cnf.bak
  sed -i "/^bind-address/s/127.0.0.1/${CTL_MGR_IPADDR}/" /etc/mysql/my.cnf
  ln_mysqld=`grep -n '\[mysqld\]' /etc/mysql/my.cnf | head -1 | cut -d : -f 1`
  sed -i "${ln_mysqld}a\\
default-storage-engine = innodb\\
innodb_file_per_table\\
collation-server = utf8_general_ci\\
init-connect = 'SET NAMES utf8'\\
character-set-server = utf8" /etc/mysql/my.cnf
  service mysql restart
  mysql_secure_installation
fi
