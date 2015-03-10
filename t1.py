#!/usr/bin/python

import time

f = open('bdmusic.log', 'rb')

print 't1 begin'

time.sleep(1000 * 60 * 3)

f.close()

print 't1 over'
