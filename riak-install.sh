#!/bin/bash

ERLANG_FILENAME=otp_src_R16B02-basho5.tar.gz
ERLANG_RUNTIME_URL=http://s3.amazonaws.com/downloads.basho.com/erlang/otp_src_R16B02-basho5.tar.gz

sudo apt-get install build-essential libncurses5-dev openssl libssl-dev fop xsltproc unixodbc-dev -y

wget ${ERLANG_RUNTIME_URL} --output-document=/tmp/${ERLANG_FILENAME}
cd /tmp
tar -xvf ${ERLANG_FILENAME}

ExtractDir=${ERLANG_FILENAME%.tar.gz*}
cd ${ExtractDir}

./configure && make && sudo make install

echo "Erlang has been installed."

sudo apt-get install build-essential libc6-dev-i386 git -y
sudo apt-get install libpam0g-dev -y

RIAK_URL=http://s3.amazonaws.com/downloads.basho.com/riak/2.0/2.0.5/riak-2.0.5.tar.gz
RIAK_FILENAME=riak-2.0.5.tar.gz
RIAK_HOME=/riak

sudo mkdir ${RIAK_HOME}

wget ${RIAK_URL} --output-document=${RIAK_HOME}/${RIAK_FILENAME}
cd ${RIAK_HOME}
tar zxvf ${RIAK_FILENAME}

ExtractDir=${RIAK_FILENAME%.tar.gz*}
cd ${ExtractDir}
make rel
make all

sudo mkdir ${RIAK_HOME}/local

sudo cp rel/riak ${RIAK_HOME}/local -rf
cd ${RIAK_HOME}/local/riak

bin/riak stop

ipaddr=`/sbin/ifconfig eth0 | grep inet | head -1 | cut -d : -f 2 | cut -d " " -f 1`

l1=`grep -n "listener.http.internal" etc/riak.conf | head -1 | cut -d : -f 1`
l2=`grep -n "listener.protobuf.internal" etc/riak.conf | head -1 | cur -d : -f 1`
l3=`grep -n "nodename" etc/riak.conf | head -1 | cur -d : -f 1`

sed -i "${l1}c listener.http.internal = ${ipaddr}:8098" etc/riak.conf
sed -i "${l2}c listener.protobuf.internal = ${ipaddr}:8087" etc/riak.conf
sed -i "${l3}c nodename = riak@${ipaddr}" etc/riak.conf

bin/riak-admin reip 'riak@127.0.0.1' "riak@${ipaddr}"

bin/riak start






