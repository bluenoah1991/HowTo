#!/usr/bin/python
# -*- coding: utf-8 -*-

import sys
reload(sys)
sys.setdefaultencoding('utf8')

import httplib
from urlparse import urlparse
import common, db

RIAK_HOSTNAME = '192.168.20.67:8098'
RIAK_URL_TEMPLATE = '/buckets/music/key/%s'

db_ = db.db()

conn_pool = {}
conn_riak = httplib.HTTPConnection(RIAK_HOSTNAME)

cursor = db_.get_song_cursor()

for doc in cursor:
    id_ = doc['song_id']
    uri = doc['songlink']
    if(uri and uri != ''):
        o = urlparse(uri)
        conn = None
        if(o.hostname not in conn_pool):
            conn = httplib.HTTPConnection(o.hostname)
            conn_pool[o.hostname] = conn
        else:
            conn = conn_pool[o.hostname]
        conn.request("GET", uri)
        res = conn.getresponse()
        body = res.read()
        conn_riak.request("PUT", RIAK_URL_TEMPLATE % id_, body, {'Content-Type': 'audio/mpeg'})
        res = conn_riak.getresponse()
        print '%s has been uploaded' % uri
        
