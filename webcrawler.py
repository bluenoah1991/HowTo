#!/usr/bin/python

from HTMLParser import HTMLParser
import urllib

import pdb

url = "http://music.baidu.com/artist/4840"
artist_id = url[url.rfind('/') + 1:]

handle = urllib.urlopen(url)
raw_content = handle.read()
handle.close()
#print raw_content

downloadPage_list = []

def handle_starttag_(tag, attrs):
    if tag == 'a':
        for (key, value) in attrs:
            if(key and key == 'href' and value and value.find('/song/') != -1 and value.count('/') == 2):
                try:
                    downloadPage_list.append('http://music.baidu.com' + value + '/download?__o=%2Fartist%2F' + artist_id)
                except Exception, e:
                    pdb.set_trace()

parser = HTMLParser()
parser.handle_starttag = handle_starttag_
parser.feed(raw_content)

download_list = []

def handle_starttag_1(tag, attrs):
    if tag == 'a':
        for (key, value) in attrs:
            if(key and key == 'href' and value and value.find('/data/music/file?link=http://') != -1):
                try:
                    download_list.append(value[value.find('/data/music/file?link=') + 1:])
                except Exception, e:
                    pdb.set_trace()

parser.handle_starttag = handle_starttag_1

for page_ in downloadPage_list:
    handle = urllib.urlopen(page_)
    raw_content = handle.read()
    handle.close()
    parser.feed(raw_content)

for l_ in download_list:
    print l_ 

print 'The End'
