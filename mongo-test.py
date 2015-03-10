#!/usr/bin/python

import pymongo

client = pymongo.MongoClient('localhost', 27017)

db = client['local']

test = db['test']
