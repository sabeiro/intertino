#!/usr/bin/env python3

import os, sys, requests, json
from common import writefile


def eprint(msg):
	print(msg, file=sys.stderr)

API_KEY = os.environ.get("MAILREACH_API_KEY")

if not API_KEY:
	eprint(f"Undefined env var MAILREACH_API_KEY")
	sys.exit(1)

API_BASE_URL = "https://api.mailreach.co/api/v1"


session = requests.Session()
h = {"X-Api-Key": f"Bearer {API_KEY}"}

p = 0
mboxes = []
while True:
	resp = session.get(f"{API_BASE_URL}/accounts?page={p}", headers=h)
	
	if resp.status_code != 200:
		eprint(f"{resp.status_code} Problem getting list of mailreach mboxes: {resp.content}")
		sys.exit(1)
	
	new_mboxes = json.loads(resp.content)
	if len(new_mboxes) == 0:
		break
	
	mboxes += new_mboxes
	p += 1
	

eprint(f"{len(mboxes)} mboxes")

regexp = []

for mb in mboxes:
	resp = session.get(f"{API_BASE_URL}/accounts/{mb['id']}", headers=h)
	if resp.status_code != 200:
		eprint(f"{resp.status_code} Problem getting account {mb['id']}: {resp.content}")
		sys.exit(1)
	
	acc = json.loads(resp.content)
	eprint(f"{mb['email']}, {mb['id']}, {acc['custom_message_content_ref']}")
	
	regexp.append(acc["custom_message_content_ref"])

writefile("./mailreach_codes", "|".join(regexp))
