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

#sudo cp 

