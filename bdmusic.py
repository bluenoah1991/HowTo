#!/usr/bin/python
# -*- coding: utf-8 -*-

import sys
reload(sys)
sys.setdefaultencoding('utf8')

from HTMLParser import HTMLParser
import urllib, json

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

#Artist_URL_Template_ = 'http://music.baidu.com/artist/%s'
GetSongs_URL_Template_ = 'http://music.baidu.com/data/user/getsongs?start=%s&ting_uid=%s'
Song_List_ = set([])

c_switch_ = False

def Find_Song_Link(tag, attrs):
    global c_switch_
    if tag == 'a':
        for k, v in attrs:
            if(k and k == 'href' and v and v.find('/song/') != -1):
                href_ = v[v.find('/song/') + len('/song/'):]
                if href_.find('/') != -1:
                    href_ = href_[:href_.find('/')]
                Song_List_.add(href_)
                c_switch_ = True

parser = HTMLParser()
parser.handle_starttag = Find_Song_Link

for k_ in Artist_List_:
    s_ = 0
    c_switch_ = True
    while(c_switch_):
        c_switch_ = False
        handle = urllib.urlopen(GetSongs_URL_Template_ % (s_, k_))
        raw_content = handle.read()
        handle.close()
        raw_object = json.loads(raw_content)
        raw_content = raw_object['data']['html']
        raw_content = raw_content.decode('unicode_escape')
        parser.feed(raw_content)
        s_ = s_ + 25

for s in Song_List_:
    print s

print 'Summary : ' + str(len(Song_List_))

####

SongLink_URL_Template_ = 'http://play.baidu.com/data/music/songlink?songIds=%s'

SongLink_List_ = set([])

f = open('bdmusic.log', 'w')

for k_ in Song_List_:
    handle = urllib.urlopen(SongLink_URL_Template_ % k_)
    raw_content = handle.read()
    handle.close()
    raw_object = json.loads(raw_content)
    try:
        songName = raw_object['data']['songList'][0]['songName']
        songLink = raw_object['data']['songList'][0]['songLink']
        print songName + ' : ' + songLink
        f.write(songName + ' : ' + songLink + '\r\n')
    except Exception, e:
        print e

f.close()





