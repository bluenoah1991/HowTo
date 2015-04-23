#!/bin/bash

GLANCEPWD=123456 
GLANCE_PASS=123456 
CTL_IPADDR=controller
ADMIN_PASS=123456 # from identity service

echo 'Please tell me your MariaDB password:'
read MARIADBPWD

sql1="
  GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'localhost' 
  IDENTIFIED BY '${GLANCEPWD}'
"
sql2="
  GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%' 
  IDENTIFIED BY '${GLANCEPWD}'
"

mysql -uroot -p${MARIADBPWD} << EOF

CREATE DATABASE glance;

${sql1};
${sql2};

EOF

export OS_TENANT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=${ADMIN_PASS}
export OS_AUTH_URL=http://${CTL_IPADDR}:35357/v2.0

keystone user-create --name glance --pass ${GLANCE_PASS}
keystone user-role-add --user glance --tenant service --role admin
keystone service-create --name glance --type image \
  --description "OpenStack Image Service"
keystone endpoint-create \
  --service-id $(keystone service-list | awk '/ image / {print $2}') \
  --publicurl http://${CTL_IPADDR}:9292 \
  --internalurl http://${CTL_IPADDR}:9292 \
  --adminurl http://${CTL_IPADDR}:9292 \
  --region regionOne

apt-get install glance python-glanceclient -y

