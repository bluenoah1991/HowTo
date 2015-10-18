#!/bin/bash

locale-gen en_US.UTF-8
update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

apt-get install autoconf binutils-doc bison build-essential flex -y
apt-get install git -y
apt-get install python-software-properties -y
apt-get install libpq5 \
                     libpq-dev \
                     postgresql-client-9.3 \
                     postgresql-client-common -y
apt-get install postgresql-9.3 \
                     postgresql-contrib-9.3 \
                     postgresql-server-dev-9.3 \
                     postgresql-plpython-9.3 -y

sed -i "/^[^#]/s/peer$/trust/" /etc/postgresql/9.3/main/pg_hba.conf
sed -i "/^[^#]/s/md5$/trust/" /etc/postgresql/9.3/main/pg_hba.conf
/etc/init.d/postgresql restart

createuser publicuser --no-createrole --no-createdb --no-superuser -U postgres
createuser tileuser --no-createrole --no-createdb --no-superuser -U postgres

apt-get install libxml2-dev -y
apt-get install liblwgeom-2.1.2 postgis postgresql-9.3-postgis-2.1 postgresql-9.3-postgis-2.1-scripts -y

createdb -T template0 -O postgres -U postgres -E UTF8 template_postgis
createlang plpgsql -U postgres -d template_postgis
psql -U postgres template_postgis -c 'CREATE EXTENSION postgis;CREATE EXTENSION postgis_topology;'
ldconfig

cd /usr/local/src

git clone https://github.com/CartoDB/pg_schema_triggers.git
pushd pg_schema_triggers
make
make install
PGUSER=postgres make installcheck
echo "shared_preload_libraries = 'schema_triggers.so'" >> /etc/postgresql/9.3/main/postgresql.conf
service postgresql restart
popd

git clone https://github.com/CartoDB/cartodb-postgresql.git
pushd cartodb-postgresql
git checkout cdb
make all install
PGUSER=postgres make installcheck
popd

/etc/init.d/postgresql restart

apt-get install libproj0 proj-bin proj-data libproj-dev -y
apt-get install libjson0 libjson0-dev python-simplejson -y
apt-get install libgeos-c1 libgeos-dev -y
apt-get install gdal-bin libgdal1-dev -y

apt-get install redis-server -y
apt-get install nodejs npm -y
apt-get install python2.7-dev -y
apt-get install build-essential -y
apt-get install libmapnik-dev python-mapnik mapnik-utils -y
apt-get install nodejs-legacy -y
apt-get install libcairo2-dev libpango1.0-dev libjpeg-dev -y

git clone git://github.com/CartoDB/CartoDB-SQL-API.git
pushd CartoDB-SQL-API
git checkout master
npm config set ca ""
npm install
cp config/environments/development.js.example config/environments/development.js
setsid node app.js development &
popd

git clone git://github.com/CartoDB/Windshaft-cartodb.git
pushd Windshaft-cartodb
git checkout master
npm config set ca ""
npm install
cp config/environments/development.js.example config/environments/development.js
setsid node app.js development &
popd

echo "success"
exit 0

wget -O ruby-install-0.5.0.tar.gz https://github.com/postmodern/ruby-install/archive/v0.5.0.tar.gz
tar -xzvf ruby-install-0.5.0.tar.gz
pushd ruby-install-0.5.0
make install
apt-get install libreadline6-dev openssl -y
ruby-install ruby 1.9.3
gem install bundler
popd

git clone --recursive https://github.com/CartoDB/cartodb.git
pushd cartodb
apt-get install imagemagick unp zip -y
apt-get install ruby-dev -y
RAILS_ENV=development bundle install
npm install
sudo -u root bash << EOF
apt-get install python-setuptools -y
easy_install pip
export CPLUS_INCLUDE_PATH=/usr/include/gdal
export C_INCLUDE_PATH=/usr/include/gdal
pip install --no-use-wheel -r python_requirements.txt
EOF
bundle exec ./node_modules/grunt-cli/bin/grunt --environment development

cp config/app_config.yml.sample config/app_config.yml
cp config/database.yml.sample config/database.yml

RAILS_ENV=development bundle exec rake db:setup
RAILS_ENV=development bundle exec rake db:migrate

echo "127.0.0.1 development.localhost.lan" | sudo tee -a /etc/hosts
sh script/create_dev_user development
bundle exec rake cartodb:db:create_new_organization_with_owner ORGANIZATION_NAME="cartodb" ORGANIZATION_DISPLAY_NAME="CartoDB Inc." ORGANIZATION_SEATS="5" ORGANIZATION_QUOTA="1073741824" USERNAME="development"

setsid bundle exec script/resque > /dev/null 2>&1 &
setsid bundle exec rails s -p 3000 > /dev/null 2>&1 &


