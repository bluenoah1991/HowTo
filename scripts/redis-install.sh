#!/bin/bash

PORT=6379
REDIS_URL=http://download.redis.io/redis-stable.tar.gz
REDIS_FILENAME=redis-stable.tar.gz

apt-get update
apt-get install make gcc -y

wget ${REDIS_URL} --output-document=/tmp/${REDIS_FILENAME}
cd /tmp
tar xvzf ${REDIS_FILENAME}

extdir=${REDIS_FILENAME%.tar.gz*}
cd ${extdir}

make && make install

mkdir /etc/redis
mkdir /var/redis
cp utils/redis_init_script /etc/init.d/redis_${PORT}

ln=`grep -n "REDISPORT=" /etc/init.d/redis_${PORT} | head -1 | cut -d : -f 1`
sed -i "${ln}c REDISPORT=${PORT}" /etc/init.d/redis_${PORT}

cp redis.conf /etc/redis/${PORT}.conf
mkdir /var/redis/${PORT}

ln=`grep -n "daemonize no" /etc/redis/${PORT}.conf | head -1 | cut -d : -f 1`
sed -i "${ln}c daemonize yes" /etc/redis/${PORT}.conf

ln=`grep -n "pidfile /var/run/redis.pid" /etc/redis/${PORT}.conf | head -1 | cut -d : -f 1`
sed -i "${ln}c pidfile /var/run/redis_${PORT}.pid" /etc/redis/${PORT}.conf

ln=`grep -n "port 6379" /etc/redis/${PORT}.conf | head -1 | cut -d : -f 1`
sed -i "${ln}c port ${PORT}" /etc/redis/${PORT}.conf

ln=`grep -n "logfile \"\"" /etc/redis/${PORT}.conf | head -1 | cut -d : -f 1`
sed -i "${ln}c logfile \"/var/log/redis_${PORT}.log\"" /etc/redis/${PORT}.conf

ln=`grep -n "dir ./" /etc/redis/${PORT}.conf | head -1 | cut -d : -f 1`
sed -i "${ln}c dir /var/redis/${PORT}" /etc/redis/${PORT}.conf

update-rc.d redis_${PORT} defaults

sed -i 's/^save/#&/' /etc/redis/${PORT}.conf

/etc/init.d/redis_${PORT} start

redis-cli ping

echo "success!"


