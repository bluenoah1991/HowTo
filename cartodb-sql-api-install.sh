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

apt-get install postgresql-plpython-9.3 -y
apt-get install gdal-bin libgdal1-dev -y
apt-get install zip -y
apt-get install redis-server -y
apt-get install nodejs nodejs-legacy -y
apt-get install npm -y

apt-get install git -y

cd /usr/local/src
git clone https://github.com/CartoDB/CartoDB-SQL-API.git
cd CartoDB-SQL-API
git checkout master
npm config set registry https://registry.npm.taobao.org # CHANGE NPM SOURCE
npm config set ca ""
npm install
cp config/environments/development.js.example config/environments/development.js
setsid node app.js development &

echo "Success!"
