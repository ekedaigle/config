#!/usr/bin/env python
import json
import sys
import urllib2

REDDIT_URL = 'http://reddit.com/r/showerthoughts/hot.json?limit=1'
USER_AGENT = 'linux:shower_thoughts_script:v1.0.0'

def main():
    request = urllib2.Request(REDDIT_URL, headers = {'User-Agent' : USER_AGENT})
    json_string = urllib2.urlopen(request).read()
    print json.loads(json_string)['data']['children'][0]['data']['title']

if __name__ == '__main__':
    sys.exit(main())

