#!/bin/bash

# https://www.drupal.org/download
# https://localize.drupal.org/translate/languages/zh-hans

apt-get update
apt-get install apache2
apt-get install php5
apt-get install mysql-server mysql-client
apt-get install php5-mysql php5-curl php5-gd
apt-get install phpmyadmin
ln -s /usr/share/phpmyadmin/ /var/www/html/
php5enmod mcrypt
wget https://ftp.drupal.org/files/projects/drupal-8.0.2.tar.gz
tar -zxvf drupal-8.0.2.tar.gz -C /var/www/html/
ln -s /var/www/html/drupal-8.0.2/ /var/www/html/drupal
service apache2 restart

pushd /etc/apache2/mods-enabled
ln -s ../mods-available/rewrite.load .
popd

# Manual Operation
# Edit /etc/apache2/apache2/conf
# In Section <Directory /var/www/>
# Update `AllowOverride None` to `AllowOverride All`
