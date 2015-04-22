#!/bin/bash

KEYSTONEPWD=123456 

echo 'Please tell me your MariaDB password:'
read MARIADBPWD

sql1="
  GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' 
  IDENTIFIED BY '${KEYSTONEPWD}'
"
sql2="
  GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' 
  IDENTIFIED BY '${KEYSTONEPWD}'
"

mysql -uroot -p${MARIADBPWD} << EOF

CREATE DATABASE keystone;

${sql1};
${sql2};

EOF

RANDPWD=`openssl rand -hex 10`

apt-get install keystone python-keystoneclient -y


