#!/bin/python
#Measures the time it takes to migrate a site when draining a member node.

import urllib.request
import time
import datetime

url = "https://site.name"

while 1:
  error = False
  start = datetime.datetime.now()
  
  while 1:
    try:
      urllib.request.urlopen(url, timeout=1)
    except:
      error = True
      continue
    break

  end = datetime.datetime.now()
  if error:
    delta = end - start
    print (delta)
  time.sleep(.3)
