#!/usr/bin/python
# -*- coding: utf-8 -*-

import sys
reload(sys)
sys.setdefaultencoding('utf8')

from HTMLParser import HTMLParser
import urllib, json, re

import pdb

URL_ = 'http://music.baidu.com/artist'
PRE_URL_ = 'http://music.baidu.com'

Category_List_ = set([])
Category_List_Switch_ = True
Artist_List_ = {}

def Find_Artist_Link(tag, attrs):
    if(tag == 'a'):
        href_ = ''
        artid_ = ''
        title_ = ''
        for k, v in attrs:
            if(k and k == 'href' and v.find('/artist/') != -1):
                href_ = v
                artid_ = v[v.find('/artist/') + len('/artist/'):]
            if(k and k == 'title'):
                title_ = v
        if(artid_ != ''):
            if artid_.isdigit():
                Artist_List_[artid_] = title_
            elif Category_List_Switch_:
                Category_List_.add(PRE_URL_ + href_)

parser = HTMLParser()
parser.handle_starttag = Find_Artist_Link
handle = urllib.urlopen(URL_)
raw_content = handle.read()
handle.close()
parser.feed(raw_content)

print '"' + URL_ + '" has been processed.'

Category_List_Switch_ = False

for l_ in Category_List_:
    handle = urllib.urlopen(l_)
    raw_content = handle.read()
    handle.close()
    parser.feed(raw_content)
    print '"' + l_ + '" has been processed.'

parser.close()

#run

for k in Artist_List_:
    print k + ' : ' + Artist_List_.get(k, '')

print 'Summary : ' + str(len(Artist_List_))

for u in Category_List_:
    print u

print 'Summary : ' + str(len(Category_List_))

####

#### DEBUG

if('-d' in sys.argv):
    Artist_List_ = {'1098': 'xxx'}
    print 'Debug: Artist_List_ = 1098'

#### END_DEBUG

Artist_URL_Template_ = 'http://music.baidu.com/artist/%s'

N = 0

for k_ in Artist_List_:
    handle = urllib.urlopen(Artist_URL_Template_ % k_)
    raw_content = handle.read()
    #print raw_content
    m_ = re.search(r'歌曲\((\d{1,4})\)', raw_content)
    if m_:
        n_ = m_.group(1)
        if n_.isdigit():
            print n_
            N = N + int(n_)

print 'Summary : ' + str(N)

