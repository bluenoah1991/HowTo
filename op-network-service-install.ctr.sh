#!/bin/bash

NEUTRON_DBPASS=123456 
CTL_HOST=controller
ADMIN_PASS=123456
NEUTRON_PASS=123456 

echo 'Please tell me your MariaDB password:'
read MARIADBPWD

sql1="
  GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'localhost' 
  IDENTIFIED BY '${NEUTRON_DBPASS}'
"
sql2="
  GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'%' 
  IDENTIFIED BY '${NEUTRON_DBPASS}'
"

mysql -uroot -p${MARIADBPWD} << EOF

CREATE DATABASE neutron;

${sql1};
${sql2};

EOF

export OS_TENANT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=${ADMIN_PASS}
export OS_AUTH_URL=http://${CTL_HOST}:35357/v2.0

keystone user-create --name neutron --pass ${NEUTRON_PASS}
keystone user-role-add --user neutron --tenant service --role admin
keystone service-create --name neutron --type network \
  --description "OpenStack Networking"
keystone endpoint-create \
  --service-id $(keystone service-list | awk '/ network / {print $2}') \
  --publicurl http://${CTL_HOST}:9696 \
  --adminurl http://${CTL_HOST}:9696 \
  --internalurl http://${CTL_HOST}:9696 \
  --region regionOne

apt-get install neutron-server neutron-plugin-ml2 python-neutronclient -y


