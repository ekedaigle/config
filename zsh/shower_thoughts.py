#!/usr/bin/env python
from BeautifulSoup import BeautifulSoup
import sys
import urllib2

def main():
    soup = BeautifulSoup(urllib2.urlopen('http://reddit.com/r/showerthoughts').read())
    tag = soup.find('p', attrs = {'class' : 'title' })
    index = tag.text.rfind('&')
    print tag.text[:index]

if __name__ == '__main__':
    sys.exit(main())

