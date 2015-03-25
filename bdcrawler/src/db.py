#!/usr/bin/python
# -*- coding: utf-8 -*-

artist_ = 'artist9'
song_ = 'song9'
artist_log_ = 'artist_log9'

import threading

import common
import pymongo

hot = int(common.get_argv('-hot', 10000))

class db(object):

    def mode(self):
        artist_list = []
        for (k_, v_) in self.__artist_map.items():
            if k_ and k_ not in self.__artist_log_map and v_ and v_ == -1:
                artist_list.append(k_)
        return artist_list

    def mode2(self):
        artist_list = []
        for (k_, v_) in self.__artist_map.items():
            if k_ and k_ not in self.__artist_log_map and v_ and v_ > hot:
                artist_list.append(k_)
        return artist_list

    def __init__(self, uri = 'mongodb://localhost:27017/', db = 'local'):
        try:
            self.__client = pymongo.MongoClient(uri)
            self.__db = self.__client[db]
            self.__artist_map = {}
            artist_full_docs = self.__db[artist_].find()
            for d_ in artist_full_docs:
                self.__artist_map[d_['artist_id']] = d_['hot']
            self.__artist_log_map = set([])
            artist_log_full_docs = self.__db[artist_log_].find()
            for d_ in artist_log_full_docs:
                self.__artist_log_map.add(d_['artist_id'])
            self.hot_lock = threading.Lock()
            self.hot_map_lock = threading.Lock()
        except Exception, e:
            common.log(e)

    def __del__(self):
        try:
            if self.__client:
                self.__client.close()
        except Exception, e:
            common.log(e)

    def add_artist(self, artist_id, artist_name):
        if not artist_id:
            common.log('add_artist: artist_id is null')
            return None
        if artist_id in self.__artist_map:
            return None
        else:
            self.__artist_map[artist_id] = -1
        if not artist_name:
            common.log('add_artist: artist_name is null, artist_id is [%s]' % artist_id)
        post = {'artist_id': artist_id,
                'artist_name': artist_name,
                'hot': -1}
        try:
            global artist_
            artist_db = self.__db[artist_]
            artist_db.insert(post)
        except Exception, e:
            common.log(e)

    def set_artist_hot(self, artist_id, hot):
        if not artist_id:
            common.log('set_artist_hot: artist_id is null')
            return None
        if artist_id in self.__artist_map and self.__artist_map[artist_id] == -1:
            self.hot_map_lock.acquire()
            self.__artist_map[artist_id] = hot
            self.hot_map_lock.release()
            try:
                global artist_
                self.hot_lock.acquire()
                artist_db = self.__db[artist_]
                post = {'artist_id': artist_id}
                post_ = {'$set': {'hot': hot}}
                artist_db.update(post, post_)
                self.hot_lock.release()
            except Exception, e:
                common.log(e)

    def get_song_cursor(self):
        try:
            global song_
            song_db = self.__db[song_]
            return song_db.find()
        except Exception, e:
            common.log(e)

    def add_song(self, song_id, song_name, lrclink, songlink, rate, size, artist_id, order):
        if not song_id:
            common.log('add_song: song_id is null')
            return None
        if not song_name:
            common.log('add_song[%d]: song_name is null' % song_id)
        if not songlink:
            common.log('add_song[%d]: songlink is null' % song_id)
        post = {'song_id': song_id,
                'song_name': song_name,
                'lrclink': lrclink,
                'songlink': songlink,
                'rate': rate,
                'size': size,
                'artist_id': artist_id,
                'order': order}
        try:
            global song_
            song_db = self.__db[song_]
            song_db.insert(post)
        except Exception, e:
            common.log('add_song: ' + str(e))
       
    def del_artist(self, artist_id):
        if not artist_id:
            common.log('del_artist: artist_id is null')
            return None
        try:
            global song_
            song_db = self.__db[song_]
            post = {'artist_id': artist_id}
            song_db.remove(post)
        except Exception, e:
            common.log(e)

    def add_artist_log(self, artist_id):
        if not artist_id:
            common.log('add_artist_log: artist_id is null')
            return None
        if artist_id in self.__artist_log_map:
            return None
        else:
            self.__artist_log_map.add(artist_id)
        try:
            global artist_log_
            artist_log_db = self.__db[artist_log_]
            post = {'artist_id': artist_id}
            artist_log_db.insert(post)
        except Exception, e:
            common.log(e)

    def exist_artist_log(self, artist_id):
        if not artist_id:
            common.log('exist_artist_log: artist_id is null')
            return True
        return artist_id in self.__artist_log_map




