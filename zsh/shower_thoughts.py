#!/usr/bin/env python
import json
import sys
import urllib2

REDDIT_URL = 'http://reddit.com/r/showerthoughts/hot.json?limit=1'

def main():
    json_string = urllib2.urlopen(REDDIT_URL).read()
    print json.loads(json_string)['data']['children'][0]['data']['title']

if __name__ == '__main__':
    sys.exit(main())

