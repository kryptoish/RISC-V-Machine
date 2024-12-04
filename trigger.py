#!/usr/bin/python3
# WARNING: Do not modify this file unless directed to do so by your instructor

import requests
import os
import re

def notify_autograder(lab,section,student):
  API_ENDPOINT = "https://cpen211.ece.ubc.ca/autograder_build_request.php"
  data = {'github_username':student,
          'lab':lab,
          'section':section}
  r = requests.post(url=API_ENDPOINT, data=data, timeout=5)
  if r.text == 'OK':
    print('Queuing your submission for ranking.  You will be emailed when results are available.')
  else:
    print('ERROR unable to queue your submission for ranking; notify instructor.')
    print('Response from server -->')
    print(r.text);
    print('<---')

m = re.search(r'lab-7-l1[a-z]-bonus-([^/])+/lab-7-l1(?P<section>[a-z])-bonus-(?P<user>\S+)', os.getcwd())
if m:
  github_username = m.group('user')
  print("Username: " + github_username)
  section = m.group('section').upper()
  print("Section: L1" + section)
else:
  print("ERROR: Did not match regex. Unable to queue your submission for ranking; notify instructor.")
  exit(1)
notify_autograder(8,section,github_username)
