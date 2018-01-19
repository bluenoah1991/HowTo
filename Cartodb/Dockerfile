FROM ubuntu:14.04.3

MAINTAINER codemeow codemeow@yahoo.com

RUN cp /etc/apt/sources.list /etc/apt/sources.list.raw
ADD https://github.com/codemeow5/software/raw/master/ubt_sources_list_aliyun.txt /etc/apt/sources.list
RUN apt-get update && apt-get install wget -y

## System requirements

# System locales

RUN locale-gen en_US.UTF-8
RUN update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# Build essentials

RUN apt-get install autoconf binutils-doc bison build-essential python-dev flex -y

# Git

RUN apt-get install git -y

# APT tools

RUN apt-get install python-software-properties -y

## PostgreSQL

RUN apt-get install libpq5 \
                     libpq-dev \
                     postgresql-client-9.3 \
                     postgresql-client-common -y
RUN apt-get install postgresql-9.3 \
                     postgresql-contrib-9.3 \
                     postgresql-server-dev-9.3 \
                     postgresql-plpython-9.3 -y
RUN sed -i "/^[^#]/s/peer$/trust/" /etc/postgresql/9.3/main/pg_hba.conf
RUN sed -i "/^[^#]/s/md5$/trust/" /etc/postgresql/9.3/main/pg_hba.conf
RUN /etc/init.d/postgresql restart &&\
	createuser publicuser --no-createrole --no-createdb --no-superuser -U postgres &&\
	createuser tileuser --no-createrole --no-createdb --no-superuser -U postgres
RUN apt-get install libproj0 proj-bin proj-data libproj-dev -y
RUN apt-get install libjson0 libjson0-dev python-simplejson -y
RUN apt-get install libgeos-c1 libgeos-dev -y
RUN apt-get install gdal-bin libgdal1-dev -y
RUN apt-get install libxml2-dev -y
RUN apt-get install liblwgeom-2.1.2 postgis postgresql-9.3-postgis-2.1 postgresql-9.3-postgis-2.1-scripts -y
RUN /etc/init.d/postgresql restart &&\
	createdb -T template0 -O postgres -U postgres -E UTF8 template_postgis &&\
	#createlang plpgsql -U postgres -d template_postgis &&\
	psql -U postgres template_postgis -c 'CREATE EXTENSION postgis;CREATE EXTENSION postgis_topology;'
RUN ldconfig

# pg_schema_triggers

WORKDIR /usr/local/src
RUN git clone https://github.com/codemeow5/pg_schema_triggers.git
WORKDIR /usr/local/src/pg_schema_triggers
RUN make
RUN make install
RUN /etc/init.d/postgresql restart &&\
	PGUSER=postgres make installcheck
RUN echo "shared_preload_libraries = 'schema_triggers.so'" >> /etc/postgresql/9.3/main/postgresql.conf
RUN /etc/init.d/postgresql restart

# cartodb-postgresql

WORKDIR /usr/local/src
RUN git clone https://github.com/codemeow5/cartodb-postgresql.git
WORKDIR /usr/local/src/cartodb-postgresql
RUN git checkout master
RUN make all install
RUN /etc/init.d/postgresql restart &&\
	PGUSER=postgres make installcheck; exit 0

RUN /etc/init.d/postgresql restart

## Redis

RUN apt-get install redis-server -y

## NodeJS (Pass)

RUN apt-get install nodejs npm -y
RUN apt-get install nodejs-legacy -y

## Ruby

RUN apt-get install ruby2.0 -y
RUN gem install bundler

## Editor

WORKDIR /usr/local/src
RUN git clone --recursive https://github.com/codemeow5/cartodb.git
WORKDIR /usr/local/src/cartodb
RUN apt-get install imagemagick unp zip -y
RUN apt-get install ruby-dev -y
RUN sed -i "/compass/s/0.12.3/~> 1.0.3/" Gemfile
RUN sed -i "/^source/csource 'https://ruby.taobao.org'" Gemfile
ENV RAILS_ENV development
RUN bundle install
RUN npm config set registry http://registry.npm.taobao.org
RUN npm install -g grunt
RUN npm install -g grunt-cli
RUN npm install # proxychains
RUN apt-get install python-pip -y
ENV CPLUS_INCLUDE_PATH /usr/include/gdal
ENV C_INCLUDE_PATH /usr/include/gdal
RUN pip install --no-use-wheel -r python_requirements.txt
RUN bundle exec ./node_modules/grunt-cli/bin/grunt --environment development
RUN cp config/app_config.yml.sample config/app_config.yml
RUN cp config/database.yml.sample config/database.yml
ENV RAILS_ENV development
RUN /etc/init.d/redis-server restart &&\
	/etc/init.d/postgresql restart &&\
	bundle exec rake db:setup; exit 0
RUN /etc/init.d/redis-server restart &&\
	/etc/init.d/postgresql restart &&\
	bundle exec rake db:migrate
RUN echo "127.0.0.1 cartodb.localhost.lan" | tee -a /etc/hosts
RUN /etc/init.d/redis-server restart &&\
	/etc/init.d/postgresql restart &&\
	sh script/create_dev_user cartodb 123456 123456 codemeow@yahoo.com
RUN /etc/init.d/redis-server restart &&\
	/etc/init.d/postgresql restart &&\
	bundle exec rake cartodb:db:create_new_organization_with_owner ORGANIZATION_NAME="cartodb-group" ORGANIZATION_DISPLAY_NAME="CartoDB Inc." ORGANIZATION_SEATS="5" ORGANIZATION_QUOTA="1073741824" USERNAME="cartodb"

#RUN echo 'Execute the following command:'
#RUN echo '#> bundle exec script/resque'
#RUN echo '#> bundle exec rails s -p 3000'

# Update Github

RUN echo 'wtf'
WORKDIR /usr/local/src/cartodb
RUN git checkout .
RUN git pull
RUN bundle install
RUN npm install
RUN bundle exec ./node_modules/grunt-cli/bin/grunt --environment development

EXPOSE 3000

COPY supervisord.sh /usr/local/src/cartodb/supervisord.sh
RUN chmod u+x /usr/local/src/cartodb/supervisord.sh

CMD /usr/local/src/cartodb/supervisord.sh

