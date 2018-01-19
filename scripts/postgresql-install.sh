#!/bin/bash

PGUSER=osm
PGDB=osm

apt-get update
apt-get install -y postgresql postgresql-contrib

cd /etc/postgresql/9.3/main
sed -i "/^[^#]/s/peer$/trust/" /etc/postgresql/9.3/main/pg_hba.conf
sed -i "/^[^#]/s/md5$/trust/" /etc/postgresql/9.3/main/pg_hba.conf
/etc/init.d/postgresql restart

sudo -u postgres bash << EOF
createuser -P ${PGUSER}
createdb -O ${PGUSER} ${PGDB}
EOF

apt-get install -y postgis postgresql-9.3-postgis-2.1
sudo -u postgres bash << EOF
psql -c "CREATE EXTENSION postgis; CREATE EXTENSION postgis_topology;" ${PGDB}
EOF

echo "Success!"
