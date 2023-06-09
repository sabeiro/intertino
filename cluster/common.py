#!/usr/bin/env python3

import os, re

def readfile(path):
	if not os.path.exists(path):
		raise OSError(f"Could not read file: '{path}'")
	
	with open(path, 'r') as f:
		return f.read()

def writefile(path, content):
	with open(path, 'w') as f:
		return f.write(content)

def writebfile(path, content):
	with open(path, 'wb') as f:
		return f.write(content)

def get_domains(filename="../mailserver/origconf/domains"):
	return list(filter(lambda d: d != "", re.compile(r"\s+").split(readfile(filename))))
