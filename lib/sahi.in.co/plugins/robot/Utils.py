'''
Created on May 24, 2013

@author: Vivek
'''

import uuid
import urllib2
import urllib

def encode(s):
    return urllib.quote(s)

def getUUID():
    return str(uuid.uuid4()).replace('-', '0')

def generateId():
    return "sahi_" + getUUID()

def readUrl(url):
    response = urllib2.urlopen(url)
    return response.read()