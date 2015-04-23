#!/bin/bash

GLANCE_DBPASS=123456 
GLANCE_PASS=123456 
CTL_HOST=controller
ADMIN_PASS=123456 # from identity service

echo 'Please tell me your MariaDB password:'
read MARIADBPWD

sql1="
  GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'localhost' 
  IDENTIFIED BY '${GLANCE_DBPASS}'
"
sql2="
  GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%' 
  IDENTIFIED BY '${GLANCE_DBPASS}'
"

mysql -uroot -p${MARIADBPWD} << EOF

CREATE DATABASE glance;

${sql1};
${sql2};

EOF

export OS_TENANT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=${ADMIN_PASS}
export OS_AUTH_URL=http://${CTL_HOST}:35357/v2.0

keystone user-create --name glance --pass ${GLANCE_PASS}
keystone user-role-add --user glance --tenant service --role admin
keystone service-create --name glance --type image \
  --description "OpenStack Image Service"
keystone endpoint-create \
  --service-id $(keystone service-list | awk '/ image / {print $2}') \
  --publicurl http://${CTL_HOST}:9292 \
  --internalurl http://${CTL_HOST}:9292 \
  --adminurl http://${CTL_HOST}:9292 \
  --region regionOne

apt-get install glance python-glanceclient -y

sed -i "/#connection = <None>/cconnection = mysql://glance:${GLANCE_DBPASS}@${CTL_HOST}/glance" \
/etc/glance/glance-api.conf
ln_keystone_authtoken=`grep -n '\^[keystone_authtoken\]' /etc/glance/glance-api.conf | head -1 | cut -d : -f 1`
sed -i "${ln_keystone_authtoken}aauth_uri = http://${CTL_HOST}:5000/v2.0" /etc/glance/glance-api.conf
sed -i "/^identity_uri/cidentity_uri = http://${CTL_HOST}:35357" /etc/glance/glance-api.conf
sed -i "/^admin_tenant_name/cadmin_tenant_name = service" /etc/glance/glance-api.conf
sed -i "/^admin_user/cadmin_user = glance" /etc/glance/glance-api.conf
sed -i "/^admin_password/cadmin_password = ${GLANCE_PASS}" /etc/glance/glance-api.conf
sed -i "/^#flavor=/cflavor = keystone" /etc/glance/glance-api.conf
sed -i "/^# notification_driver = noop/s/#//" /etc/glance/glance-api.conf
sed -i "/^#verbose/cverbose = True" /etc/glance/glance-api.conf
sed -i "/^#connection = <None>/cconnection = mysql://glance:${GLANCE_DBPASS}@${CTL_HOST}/glance" /etc/glance/glance-registry.conf
ln_keystone_authtoken=`grep -n '\^[keystone_authtoken\]' /etc/glance/glance-registry.conf | head -1 | cut -d : -f 1`
sed -i "${ln_keystone_authtoken}aauth_uri = http://${CTL_HOST}:5000/v2.0" /etc/glance/glance-registry.conf
sed -i "/^identity_uri/cidentity_uri = http://${CTL_HOST}:35357" /etc/glance/glance-registry.conf
sed -i "/^admin_tenant_name/cadmin_tenant_name = service" /etc/glance/glance-registry.conf
sed -i "/^admin_user/cadmin_user = glance" /etc/glance/glance-registry.conf
sed -i "/^admin_password/cadmin_password = ${GLANCE_PASS}" /etc/glance/glance-registry.conf
sed -i "/^#flavor=/cflavor = keystone" /etc/glance/glance-registry.conf
sed -i "/^# notification_driver = noop/s/#//" /etc/glance/glance-registry.conf
sed -i "/^#verbose/cverbose = True" /etc/glance/glance-registry.conf

su -s /bin/sh -c "glance-manage db_sync" glance
service glance-registry restart
service glance-api restart
rm -f /var/lib/glance/glance.sqlite







