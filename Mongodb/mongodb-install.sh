#!/bin/bash

ROCKMONGO_URL='https://github.com/iwind/rockmongo/archive/1.1.7.tar.gz'

apt-get install mongodb apache2 php5 libapache2-mod-php5 php5-dev -y
echo "ServerName localhost:80" >> /etc/apache2/apache2.conf
/etc/init.d/apache2 restart
printf '\n' | pecl install mongo
echo 'extension=mongo.so' >> /etc/php5/apache2/php.ini
/etc/init.d/apache2 restart
wget ${ROCKMONGO_URL} --output-document=/tmp/rockmongo.tar.gz
tar -zxvf /tmp/rockmongo.tar.gz -C /var/www/html
ROCKMONGO_DIRNAME=`ls -l /var/www/html | grep rockmongo | rev | cut -d ' ' -f1 | rev`
ln -s /var/www/html/$ROCKMONGO_DIRNAME /var/www/html/rockmongo

echo 'Success!'
