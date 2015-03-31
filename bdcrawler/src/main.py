#!/usr/bin/python
# -*- coding: utf-8 -*-

import sys
reload(sys)
sys.setdefaultencoding('utf8')

import os, time, math, pdb, threading

import common, db, job_artist, job_song, job_hotnum

#just once
db_ = db.db('mongodb://192.168.20.66:27017/', 'local')

rs = job_artist.Start(db_)

artist_list = db_.mode()
count = len(artist_list)

t = int(common.get_argv('-t', 1))

print 'Thread : ' + str(t)

b = int(math.ceil(count / t))

threads = []

if '--debug' in sys.argv:
    job_hotnum.Start(db_, artist_list)
else:
    print 't is %d, b is %d' % (t, b)
    for i in range(0, t):
        begin = b * i
        end = b * (i + 1)
        if end >= count:
            end = count - 1
        t = threading.Thread(target=job_hotnum.Start, args=(db_, artist_list[begin:end]))
        threads.append(t)
        t.start()
        #list_ = job_hotnum.Start(artist_list[begin:end])
        #artist_list_.extend(list_)
    
    for t in threads:
        t.join()

artist_list = db_.mode2()

count = len(artist_list)

print 'Artist : ' + str(count)

if '--debug' in sys.argv:
    job_song.Start(db_, artist_list)
    print 'debug mode'
    sys.exit(0)

p = int(common.get_argv('-p', 1))

print 'Process : ' + str(p)

b = int(math.ceil(count / p))

print '%d Artist per Process' % b

cursor = 0
p_ = p 
pid = os.getpid()

while pid != 0 and p_ > 0:
    #global pid
    pid = os.fork()
    c_ = cursor
    #cursor = (cursor + b) if (cursor + b) < count else (count - 1)
    if (cursor + b) < count:
        cursor = cursor + b
    else:
        cursor = count - 1
    p_ = p_ - 1
    if pid == 0:
        #pdb.set_trace()
        pid_ = os.getpid()
        print '[%d] Working...' % pid_
        job_song.Start(db_, artist_list[c_:cursor])
        break

print 'go go fighting!!!' 


    
