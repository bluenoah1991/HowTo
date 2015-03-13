#!/usr/bin/python

from riak import RiakClient, RiakNode
from riak.riak_object import RiakObject

client = RiakClient(protocal='http', host='127.0.0.1', http_port=8098)

res = client.ping()

bucket = client.bucket('xxx')

#res = client.get_keys(res[0])

#obj = RiakObject(client, res, 'xxx')

obj = bucket.new('a', 'hello', 'text/plain')

obj.store()

res = bucket.get('a')

n = 0
