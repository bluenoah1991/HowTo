#!/bin/bash

NOVA_DBPASS=123456
CTL_IPADDR=controller
ADMIN_PASS=123456 # from identity service
NOVA_PASS=123456 

echo 'Please tell me your MariaDB password:'
read MARIADBPWD

sql1="
  GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'localhost' 
  IDENTIFIED BY '${NOVA_DBPASS}'
"
sql2="
  GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'%' 
  IDENTIFIED BY '${NOVA_DBPASS}'
"

mysql -uroot -p${MARIADBPWD} << EOF

CREATE DATABASE nova;

${sql1};
${sql2};

EOF

export OS_TENANT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=${ADMIN_PASS}
export OS_AUTH_URL=http://${CTL_IPADDR}:35357/v2.0

keystone user-create --name nova --pass ${NOVA_PASS}
keystone user-role-add --user nova --tenant service --role admin
keystone service-create --name nova --type compute \
  --description "OpenStack Compute"
keystone endpoint-create \
  --service-id $(keystone service-list | awk '/ compute / {print $2}') \
  --publicurl http://${CTL_IPADDR}:8774/v2/%\(tenant_id\)s \
  --internalurl http://${CTL_IPADDR}:8774/v2/%\(tenant_id\)s \
  --adminurl http://${CTL_IPADDR}:8774/v2/%\(tenant_id\)s \
  --region regionOne

apt-get install nova-api nova-cert nova-conductor nova-consoleauth \
  nova-novncproxy nova-scheduler python-novaclient -y


