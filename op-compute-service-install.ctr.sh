#!/bin/bash

NOVA_DBPASS=123456
CTL_HOST=controller
CTL_IPADDR=10.0.0.11
ADMIN_PASS=123456 # from identity service
NOVA_PASS=123456 
RABBIT_PASS=123456 # from common settings

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
export OS_AUTH_URL=http://${CTL_HOST}:35357/v2.0

keystone user-create --name nova --pass ${NOVA_PASS}
keystone user-role-add --user nova --tenant service --role admin
keystone service-create --name nova --type compute \
  --description "OpenStack Compute"
keystone endpoint-create \
  --service-id $(keystone service-list | awk '/ compute / {print $2}') \
  --publicurl http://${CTL_HOST}:8774/v2/%\(tenant_id\)s \
  --internalurl http://${CTL_HOST}:8774/v2/%\(tenant_id\)s \
  --adminurl http://${CTL_HOST}:8774/v2/%\(tenant_id\)s \
  --region regionOne

apt-get install nova-api nova-cert nova-conductor nova-consoleauth \
  nova-novncproxy nova-scheduler python-novaclient -y

echo "#rpc_backend = rabbit" >> /etc/nova/nova.conf
echo "rabbit_host = ${CTL_HOST}" >> /etc/nova/nova.conf
echo "rabbit_password = ${RABBIT_PASS}" >> /etc/nova/nova.conf
echo "auth_strategy = keystone" >> /etc/nova/nova.conf
echo "my_ip = ${CTL_IPADDR}" >> /etc/nova/nova.conf
echo "vncserver_listen = ${CTL_IPADDR}" >> /etc/nova/nova.conf
echo "vncserver_proxyclient_address = ${CTL_IPADDR}" >> /etc/nova/nova.conf
echo "verbose = True" >> /etc/nova/nova.conf

echo "[database]" >> /etc/nova/nova.conf
echo "connection = mysql://nova:${NOVA_DBPASS}@${CTL_HOST}/nova" >> /etc/nova/nova.conf

echo "[keystone_authtoken]" >> /etc/nova/nova.conf
echo "auth_uri = http://${CTL_HOST}:5000/v2.0" >> /etc/nova/nova.conf
echo "identity_uri = http://${CTL_HOST}:35357" >> /etc/nova/nova.conf
echo "admin_tenant_name = service" >> /etc/nova/nova.conf
echo "admin_user = nova" >> /etc/nova/nova.conf
echo "admin_password = ${NOVA_PASS}" >> /etc/nova/nova.conf

echo "[glance]" >> /etc/nova/nova.conf
echo "host = ${CTL_HOST}" >> /etc/nova/nova.conf

su -s /bin/sh -c "nova-manage db sync" nova

service nova-api restart
service nova-cert restart
service nova-consoleauth restart
service nova-scheduler restart
service nova-conductor restart
service nova-novncproxy restart

rm -f /var/lib/nova/nova.sqlite








