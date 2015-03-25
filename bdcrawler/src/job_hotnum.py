#!/usr/bin/python
# -*- coding: utf-8 -*-

import sys
reload(sys)
sys.setdefaultencoding('utf8')

from HTMLParser import HTMLParser
import urllib

import common, db

class HotNumParser(HTMLParser):
    def __init__(self):
        self.processing = None
        self.hotnum = 0
        HTMLParser.__init__(self)
    def handle_starttag(self, tag, attrs):
        try:
            if(tag and tag == 'span'):
                for k, v in attrs:
                    if(k and k == 'class' and v and v == 'num'):
                        self.processing = tag
        except Exception, e:
            common.log('HotNumParser.handle_starttag: ' + str(e))
    def handle_data(self, data):
        try:
            if self.processing:
                data_ = data.replace(',', '')
                self.hotnum = int(data_)
        except Exception, e:
            common.log('HotNumParser.handle_data: ' + str(e))
    def handle_endtag(self, tag):
        self.processing = None 

def Start(db_, list_):

    ARITIST_URL_TEMPLATE_ = 'http://music.baidu.com/artist/%s'

    parser = HotNumParser()
    
    for l_ in list_:
        raw_content = common.http_read(ARITIST_URL_TEMPLATE_ % l_)
        try:
            parser.feed(raw_content)
            db_.set_artist_hot(l_, parser.hotnum)
            print 'artist %s hot num is %s' % (l_, parser.hotnum)
        except Exception, e:
            common.log('HotNumParser.feed: ' + str(e))


 
 
