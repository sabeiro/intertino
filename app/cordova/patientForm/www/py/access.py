import os, sys, gzip, random, csv, json, datetime, re
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

dL = os.listdir(os.environ['LAV_DIR']+'/src/')
sys.path = list(set(sys.path + [os.environ['LAV_DIR']+'/src/'+x for x in dL]))
baseDir = os.environ['LAV_DIR']

conf = json.load(open(baseDir+"entr/credenza/odoo.json","r"))['odoo']

import xmlrpclib
info = xmlrpclib.ServerProxy('https://demo.odoo.com/start').start()
url, db, username, password = info['host'], info['database'], info['user'], info['password']
common = xmlrpclib.ServerProxy('{}/xmlrpc/2/common'.format(url))
common.version()
uid = common.authenticate(conf['db'],conf['username'],conf['password'], {})
models = xmlrpclib.ServerProxy('{}/xmlrpc/2/object'.format(url))
models.execute_kw(db, uid, password,'res.partner', 'check_access_rights',['read'], {'raise_exception': False})
models.execute_kw(db, uid, password,'res.partner', 'search',[[['is_company', '=', True], ['customer', '=', True]]])
