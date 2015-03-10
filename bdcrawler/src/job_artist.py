#!/usr/bin/python
# -*- coding: utf-8 -*-

import sys
reload(sys)
sys.setdefaultencoding('utf8')

from HTMLParser import HTMLParser
import urllib

import common, db

#only once
def Start(db_):

    URL_ = 'http://music.baidu.com/artist'
    PRE_URL_ = 'http://music.baidu.com'
    
    Category_List_ = set([])
    Category_List_Switch_ = True
    #Artist_List_ = {}
    
    def Find_Artist_Link(tag, attrs):
        try:
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
                        #Artist_List_[artid_] = title_
                        db_.add_artist(artid_, title_)
                    elif Category_List_Switch_:
                        Category_List_.add(PRE_URL_ + href_)
        except Exception, e:
            common.log('Find_Artist_Link: ' + str(e))  
    
    parser = HTMLParser()
    parser.handle_starttag = Find_Artist_Link

    raw_content = common.http_read(URL_)
    
    try:
        parser.feed(raw_content)
    except Exception, e:
        common.log('HTMLParser.feed: ' + str(e))
    print '"' + URL_ + '" has been processed.'
    
    Category_List_Switch_ = False
    
    for l_ in Category_List_:
        raw_content = common.http_read(l_)
        try:
            parser.feed(raw_content)
        except Exception, e:
            common.log('HTMLParser.feed: ' + str(e))
        print '"' + l_ + '" has been processed.'
    
    parser.close()
    
    #run
    
    #for k in Artist_List_:
    #    print k + ' : ' + Artist_List_.get(k, '')
    #
    #print 'Summary : ' + str(len(Artist_List_))
    #
    #for u in Category_List_:
    #    print u
    #
    #print 'Summary : ' + str(len(Category_List_))

    return True




