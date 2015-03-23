#!/usr/bin/python
# -*- coding: utf-8 -*-

artist_ = 'artist9'
song_ = 'song9'
artist_log_ = 'artist_log9'

import common
import pymongo

class db(object):

    def mode(self):
        artist_list = []
        for k_ in self.__artist_map:
            if k_ not in self.__artist_log_map:
                artist_list.append(k_)
        return artist_list


    def __init__(self, uri = 'mongodb://localhost:27017/', db = 'local'):
        try:
            global artist_
            self.__client = pymongo.MongoClient(uri)
            self.__db = self.__client[db]
            self.__artist_map = set([])
            artist_full_docs = self.__db[artist_].find()
            for d_ in artist_full_docs:
                self.__artist_map.add(d_['artist_id'])
            self.__artist_log_map = set([])
            artist_log_full_docs = self.__db[artist_log_].find()
            for d_ in artist_log_full_docs:
                self.__artist_log_map.add(d_['artist_id'])
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
            self.__artist_map.add(artist_id)
        if not artist_name:
            common.log('add_artist: artist_name is null, artist_id is [%s]' % artist_id)
        post = {'artist_id': artist_id,
                'artist_name': artist_name}
        try:
            global artist_
            artist_db = self.__db[artist_]
            artist_db.insert(post)
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




