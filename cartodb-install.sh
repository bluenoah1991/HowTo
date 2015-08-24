#!/bin/bash

apt-get update
apt-get install make gcc g++ git -y

cd /usr/local/src
git clone --recursive https://github.com/CartoDB/cartodb.git
apt-get install python-software-properties -y
add-apt-repository ppa:cartodb/base -y
add-apt-repository ppa:cartodb/gis -y
add-apt-repository ppa:cartodb/mapnik -y
add-apt-repository ppa:cartodb/nodejs -y
add-apt-repository ppa:cartodb/redis -y
add-apt-repository ppa:cartodb/postgresql-9.3 -y
apt-get update # 404 Not Found

echo -e 'LANG=en_US.UTF-8\nLC_ALL=en_US.UTF-8' | sudo tee /etc/default/locale
source /etc/default/locale
apt-get install build-essential checkinstall -y
apt-get install unp -y
apt-get install zip -y
apt-get install libgeos-c1 libgeos-dev -y
apt-get install gdal-bin libgdal1-dev -y
apt-get install libjson0 python-simplejson libjson0-dev -y
apt-get install proj-bin proj-data libproj-dev -y
apt-get install postgresql-9.3 postgresql-client-9.3 postgresql-contrib-9.3 postgresql-server-dev-9.3 -y
apt-get install postgresql-plpython-9.3 -y

cd /etc/postgresql/9.3/main
sed -i "/^[^#]/s/peer$/trust/" /etc/postgresql/9.3/main/pg_hba.conf
sed -i "/^[^#]/s/md5$/trust/" /etc/postgresql/9.3/main/pg_hba.conf

/etc/init.d/postgresql restart
cd /usr/local/src
wget http://download.osgeo.org/postgis/source/postgis-2.1.7.tar.gz
tar -xvzf postgis-2.1.7.tar.gz
cd postgis-2.1.7
./configure --with-raster --with-topology
make
make install

sudo -u postgres bash << EOF
POSTGIS_SQL_PATH=`pg_config --sharedir`/contrib/postgis-2.1
createdb -E UTF8 template_postgis
createlang -d template_postgis plpgsql
psql -d postgres -c "UPDATE pg_database SET datistemplate='true' WHERE datname='template_postgis'"
psql -d template_postgis -c "CREATE EXTENSION postgis"
psql -d template_postgis -c "CREATE EXTENSION postgis_topology"
psql -d template_postgis -c "GRANT ALL ON geometry_columns TO PUBLIC;"
psql -d template_postgis -c "GRANT ALL ON spatial_ref_sys TO PUBLIC;"
EOF

cd /tmp
git clone https://github.com/CartoDB/pg_schema_triggers.git
cd pg_schema_triggers
make all install PGUSER=postgres
make installcheck PGUSER=postgres

echo "shared_preload_libraries = 'schema_triggers.so'" >> /etc/postgresql/9.3/main/postgresql.conf
service postgresql restart

cd /tmp
git clone https://github.com/CartoDB/cartodb-postgresql.git
cd cartodb-postgresql
git checkout cdb
make all install
make installcheck PGUSER=postgres

apt-get install ruby -y
gem install bundler

apt-get install nodejs -y
apt-get install npm -y
apt-get install redis-server -y
apt-get install python2.7-dev -y
apt-get install build-essential -y

sudo -u root bash << EOF
apt-get install python-setuptools -y
easy_install pip
export CPLUS_INCLUDE_PATH=/usr/include/gdal
export C_INCLUDE_PATH=/usr/include/gdal
cd /usr/local/src/cartodb
pip install --no-use-wheel -r python_requirements.txt
EOF

apt-get install libmapnik-dev python-mapnik mapnik-utils -y
apt-get install nodejs-legacy -y

npm config set registry https://registry.npm.taobao.org # CHANGE NPM SOURCE

cd /usr/local/src
git clone git://github.com/CartoDB/CartoDB-SQL-API.git
cd CartoDB-SQL-API
git checkout master
#npm install pg
npm config set ca ""
npm install
cp config/environments/development.js.example config/environments/development.js
setsid node app.js development &

cd /usr/local/src
git clone git://github.com/CartoDB/Windshaft-cartodb.git
cd Windshaft-cartodb
git checkout master
npm config set ca ""
npm install
cp config/environments/development.js.example config/environments/development.js
setsid node app.js development &

apt-get install imagemagick -y

# Running CartoDB

cd /usr/local/src/cartodb
export SUBDOMAIN=development
setsid redis-server &
apt-get install ruby-dev -y
sed -i "/compass/s/0.12.3/~> 1.0.3/" Gemfile
bundle install
cp config/app_config.yml.sample config/app_config.yml
cp config/database.yml.sample config/database.yml
sed -i "/app_assets/s/^/#/" config/app_config.yml
sed -i "/asset_host/s/^/#/" config/app_config.yml

echo "127.0.0.1 ${SUBDOMAIN}.localhost.lan" | sudo tee -a /etc/hosts
git submodule update && make -C lib/sql install
sh script/create_dev_user ${SUBDOMAIN}

setsid bundle exec script/resque > /dev/null 2>&1 &

npm install
npm install -g grunt-cli
grunt

setsid bundle exec rails s -p 3000 > /dev/null 2>&1 &





