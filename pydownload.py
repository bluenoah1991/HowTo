#!/usr/bin/python

URL_ = '/data2/music/67598946/67598946.mp3?xcode=ad59de9d87ea3fb39a555cd036251632ffba1b9a023dbc6d&src="http%3A%2F%2Fpan.baidu.com%2Fshare%2Flink%3Fshareid%3D874874759%26uk%3D4283194947"'
URL = 'http://file.qianqian.com/data2/music/67598946/67598946.mp3?xcode=ad59de9d87ea3fb39a555cd036251632ffba1b9a023dbc6d&src="http%3A%2F%2Fpan.baidu.com%2Fshare%2Flink%3Fshareid%3D874874759%26uk%3D4283194947"'

import httplib

conn = httplib.HTTPConnection()
conn.request("GET", URL)
res = conn.getresponse()
f = open('777.mp3', 'w')
f.write(res.read())
f.close()
conn.close()

