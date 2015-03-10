#!/usr/bin/python

import time, urllib

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
    except Exception, e:
        log(e)
    return raw_content
