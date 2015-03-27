#!/usr/bin/python

import sys
reload(sys)
sys.setdefaultencoding('utf8')

import time, urllib, inspect
import httplib
from urlparse import urlparse

import pdb

def log(obj):
    fname = time.strftime('%Y%m%d.log', time.localtime())
    f = open(fname, 'a')
    ltime = time.strftime('[%H:%M:%S] ', time.localtime())
    f.write(ltime + str(obj) + '\r\n')
    f.close()

def http_read(url):
    try:
        time.sleep(1)
        handle = urllib.urlopen(url)
        raw_content = handle.read()
        handle.close()
        return raw_content
    except Exception, e:
        #pdb.set_trace()#TODO
        log('http_read: ' + str(e))
        return None

def get_argv(tag, default):
    t = default
    try:
        if tag in sys.argv:
            i = sys.argv.index(tag)
            if i and i > 0 and len(sys.argv) > i + 1:
                t = sys.argv[i + 1]
    except Exception, e:
        log('get_argv: ' + str(e))
    return t


class Downloader(object):

    def __init__(self, dest_hostname, dest_template, expire):
        try:
            self.dconn_ = httplib.HTTPConnection(dest_hostname)
            self.cpool_ = {}
            self.dt_ = dest_template
            self.expire_ = expire
        except Exception, e:
            log('Downloader.__init__: ' + str(e))

    def transfer(self, uri, id_, mimeType):
        self.expire_ = self.expire_ - 1
        if(self.expire_ <= 0 and self.evtExpire is not None):
            self.evtExpire(self)
        try:
            o = urlparse(uri)
            conn = None
            if(o.hostname not in self.cpool_):
                conn = httplib.HTTPConnection(o.hostname)
                self.cpool_[o.hostname] = conn
            else:
                conn = self.cpool_[o.hostname]
            path = uri[(uri.find(o.hostname) + len(o.hostname)):]
            conn.request('GET', path)
            res = conn.getresponse()
            body = res.read()
            self.dconn_.request('PUT', self.dt_ % id_, body, {'Content-Type': mimeType})
            res = self.dconn_.getresponse()
            res.read()
            return True
        except Exception, e:
            log('[%s]Downloader.transfer: ' % str(id_) + str(e))
            return False

    def close(self):
        self.dconn_.close()
        for (k, v) in self.cpool_.items():
            if v is not None:
                v.close()


