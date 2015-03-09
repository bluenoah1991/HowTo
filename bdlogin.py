#!/usr/bin/python
# -*- coding: utf-8 -*-

import httplib, urllib, pdb, time, json

bdid = None
bduss = None
headers = None

def login():

    httpClient = None

    try:
        httpClient = httplib.HTTPSConnection('passport.baidu.com', 443)
        httpClient.request('GET','/')
        response = httpClient.getresponse()
        cookie_header = response.getheader('Set-Cookie')
        bdid = cookie_header[:cookie_header.find(';')]
        print bdid

        headers = {'Accept': '*/*', 'Accept-Encoding': 'gzip, deflate, sdch', 'Accept-Language': 'zh-CN,zh;q=0.8', 
                   'Cache-Control': 'no-cache', 'Connection': 'keep-alive', 'Host': 'passport.baidu.com', 
                   'Pragma': 'no-cache', 'Referer': 'https://www.baidu.com/', 
                   'User-Agent': 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2272.76 Safari/537.36',
                   'Cookie': bdid}

        httpClient = httplib.HTTPSConnection('passport.baidu.com', 443)
        httpClient.request('GET', '/v2/api/?getapi&tpl=mn&apiver=v3&class=login&logintype=dialogLogin', None, headers)
        response = httpClient.getresponse()
    
        token_wrapper = response.read()
        token_wrapper = token_wrapper.replace("'", '"')
        token_wrapper_object = json.loads(token_wrapper)
        token = token_wrapper_object['data']['token'] 

        username = 'ev8sj3ff95@163.com'
        password = 'cOK1gvqMBEU2WUwjBxFNjwCPKJ6XVNgzQR1z77ULKuxdpR/ASxQPxjhz5ZL6P4pyF/Zmn6Ihk4yoKuigMfZCFpMyNZZTMCRoizDkOx0m06XfL17CsnGFtwMinjzHMUlUClhM9Yab+4k6dJZvHeYxbzHiBjHdVaF55C2HpIORZ7s='

        #password = 'shipfools'

        tt = str(int(time.time()) * 1000)
        print tt
        formData = {'tt': tt, 'tpl': 'mn', 'token': token, 'isPhone': '', 'username': username, 'password': password,
                    'verifycode': '', 'codestring': '', 'rsakey': 'aeMOwe7nnjWRC0x1q1cat8dtIf8qKToX',
                    'staticpage': 'https://www.baidu.com/cache/user/html/v3Jump.html',
                    'charset': 'UTF-8',
                    'apiver': 'v3',
                    'safeflg': '0',
                    'u': 'https://www.baidu.com/',
                    'quick_user': '0',
                    'logintype': 'dialogLogin',
                    'logLoginType': 'pc_loginDialog',
                    'loginmerge': 'true',
                    'splogin': 'newuser',
                    'mem_pass': 'on',
                    'crypttype': '12',
                    'ppui_logintime': '4063',
                    'callback': 'parent.bd_pcbs__6oisnl'}
        formData = urllib.urlencode(formData)
        print formData

        httpClient = httplib.HTTPSConnection('passport.baidu.com', 443)
        httpClient.request('POST', '/v2/api/?login', formData, headers)

        response = httpClient.getresponse()
        print response.reason
        print response.status
        print response.getheaders()
        print response.read()

    except Exception, e:
        pdb.set_trace()
    finally:
        if httpClient:
            httpClient.close()

