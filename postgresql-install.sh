#!/bin/bash

PGUSER=osm
PGDB=osm

apt-get update
apt-get install -y postgresql postgresql-contrib

sudo -u postgres bash << EOF
createuser -P ${PGUSER}
createdb -O ${PGUSER} ${PGDB}
EOF

apt-get install -y postgis postgresql-9.3-postgis-2.1
sudo -u postgres bash << EOF
psql -c "CREATE EXTENSION postgis; CREATE EXTENSION postgis_topology;" ${PGDB}
EOF

echo "Success!"
