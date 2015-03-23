#!/usr/bin/python
# -*- coding: utf-8 -*-

import sys
reload(sys)
sys.setdefaultencoding('utf8')

from HTMLParser import HTMLParser
import urllib, json
import httplib
from urlparse import urlparse

import common, db

def Start(db_, artist_list):

    GetSongs_URL_Template_ = 'http://music.baidu.com/data/user/getsongs?start=%s&ting_uid=%s&order=hot'
    SongLink_URL_Template_ = 'http://play.baidu.com/data/music/songlink?songIds=%s'
    PRE_URL_ = 'http://play.baidu.com'

    Find_Song_Switch_ = [False]
    Artist_Id_ = ''
    Order_ = [0]

    h = '127.0.0.1:8098'
    if '-h' in sys.argv:
        h_index = sys.argv.index('-h')
        if h_index and h_index > 0 and len(sys.argv) > h_index + 1:
            h = sys.argv[h_index + 1]

    RIAK_HOSTNAME = h
    RIAK_URL_TEMPLATE = '/buckets/music/keys/%s'

    conn_pool = {}
    conn_riak = httplib.HTTPConnection(RIAK_HOSTNAME)	


    def Find_Song_Link(tag, attrs):
        try:
            if tag == 'a':
                for k, v in attrs:
                    if(k and k == 'href' and v and v.find('/song/') != -1):
                        href_ = v[v.find('/song/') + len('/song/'):]
                        if href_.find('/') != -1:
                            href_ = href_[:href_.find('/')]
                        #Song_List_.add(href_)
                        raw_content = common.http_read(SongLink_URL_Template_ % href_)
                        if not raw_content:
                            continue
                        raw_object = json.loads(raw_content)
                        songList = raw_object['data']['songList']
                        if len(songList) > 0:
                            song_ = songList[0]
                            songId = song_['songId']
                            songName = song_['songName']
                            lrclink = PRE_URL_ + song_['lrcLink']
                            songlink = song_['songLink']
                            rate = song_['rate']
                            size = song_['size']
                            artist_id = Artist_Id_
                            db_.add_song(songId, songName, lrclink, songlink, rate, size, artist_id, Order_[0])
                            if(songlink and songlink != ''):
                                o = urlparse(songlink)
                                conn = None
                                if(o.hostname not in conn_pool):
                                    conn = httplib.HTTPConnection(o.hostname)
                                    conn_pool[o.hostname] = conn
                                else:
                                    conn = conn_pool[o.hostname]
                                path = songlink[(songlink.find(o.hostname) + len(o.hostname)):]
                                conn.request("GET", path)
                                res = conn.getresponse()
                                body = res.read()
                                conn_riak.request("PUT", RIAK_URL_TEMPLATE % songId, body, {'Content-Type': 'audio/mpeg'})
                                res = conn_riak.getresponse()
                            Order_[0] = Order_[0] + 1
                            print 'song %d has been saved.' % songId
                        Find_Song_Switch_[0] = True
        except Exception, e:
            common.log('Find_Song_Link: ' + str(e))
    
    parser = HTMLParser()
    parser.handle_starttag = Find_Song_Link
    
    for k_ in artist_list:
        print 'start process artist %s ...' % k_
        Order_[0] = 0
        s_ = 0
        Find_Song_Switch_[0] = True
        while(Find_Song_Switch_[0]):
            Find_Song_Switch_[0] = False
            raw_content = common.http_read(GetSongs_URL_Template_ % (s_, k_))
            s_ = s_ + 25
            if not raw_content:
                continue
            try:
                raw_object = json.loads(raw_content)
            except Exception, e:
                common.log('json.loads: ' + str(e))
            try:
                raw_content = raw_object['data']['html']
            except Exception, e:
                common.log('extract html from json object: ' + str(e))
            try:
                raw_content = raw_content.decode('unicode_escape')
            except Exception, e:
                common.log('str.decode: ' + str(e)) 
            try:
                Artist_Id_ = k_
                parser.feed(raw_content)
                db_.add_artist_log(k_)
            except Exception, e:
                common.log('HTMLParser.feed: ' + str(e))
    
    return True    





