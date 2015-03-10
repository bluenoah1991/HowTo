#!/usr/bin/python
# -*- coding: utf-8 -*-

import sys
reload(sys)
sys.setdefaultencoding('utf8')

import os, time, math

import db

#just once
db_ = db.db()

rs = job_artist.Start(db_)

artist_list = db_.mode()
count = len(artist_list)

print 'Artist : ' + count

p = 1

p_index = sys.argv.index('-p')
if p_index and p_index > 0 and len(sys.argv) > p_index + 1:
    p = sys.argv[p_index + 1]

print 'Process : ' + p

b = math.ceil(count / p)

print '%d Artist per Process' % b

cursor = 0
p_ = p 
pid = os.getpid()

while pid != 0 and p_ > 0:
    #global pid
    pid = os.fork()
    c_ = cursor
    cursor = cursor + b if (cursor + b) < count else count - 1
    p_ = p_ - 1
    if pid == 0:
        pid_ = os.getpid()
        print '[%d] Working...' % pid_
        job_song.Start(db_, artist_list[c_:cursor])
        break

print 'go go fighting!!!' 

    
