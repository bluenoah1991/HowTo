#!/bin/bash

RockMongo_URL='https://github.com/iwind/rockmongo/archive/1.1.7.tar.gz'

echo 'start install mongodb...'

apt-get install mongodb -y

echo 'start install apache2...'

apt-get install apache2 -y

echo "ServerName localhost:80" >> /etc/apache2/apache2.conf

/etc/init.d/apache2 restart

echo 'start install php5...'

apt-get install php5 libapache2-mod-php5 -y

apt-get install php5-dev -y

echo 'start install mongo php driver...'

printf '\n' | pecl install mongo

echo 'extension=mongo.so' >> /etc/php5/apache2/php.ini

/etc/init.d/apache2 restart

wget ${RockMongo_URL} --output-document=/tmp/rockmongo.tar.gz

tar -zxvf /tmp/rockmongo.tar.gz -C /var/www/html

rockmongodir=`ls -l /var/www/html | grep rockmongo | rev | cut -d ' ' -f1 | rev`

ln -s /var/www/html/$rockmongodir /var/www/html/rockmongo

echo 'success'
