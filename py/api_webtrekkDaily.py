import urlparse
from urllib import quote_plus as urlquote
import urllib2
import requests
import json
import re
import time
import MySQLdb
from pandas.io import sql
import sqlalchemy
import os
import pandas as pd
import datetime

print '----------------------api-webtrekk-------------------'

headers = {"Accept":"application/json","Content-type":"application/x-www-form-urlencoded; charset=UTF-8","User_Agent":"Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; en-US; rv:1.9.1) Gecko/20090624 Firefox/3.5"}
baseUrl = 'https://report2.webtrekk.de/cgi-bin/wt/JSONRPC.cgi'

sData = {"params": {},"version": "1.1","method": "getConnectionTest"}
resq = requests.post(baseUrl,data=json.dumps(sData))
key_file = os.environ['HOME'] + '/lav/media/credenza/webtrekk.json'
cred = []
with open(key_file) as f:
    cred = json.load(f)
resq = requests.post(baseUrl,data=json.dumps(cred))
token = resq.json()['result']

query = {"params": {"token": token,"report_name": "Player"},"version": "1.1","method": "getReportData"}
resq = requests.post(baseUrl,data=json.dumps(query))
videoD = resq.json()['result']['analyses'][1]['analysisData']

query = {"params": {"token": token,"report_name": "preroll"},"version": "1.1","method": "getReportData"}
resq = requests.post(baseUrl,data=json.dumps(query))
prerollD = resq.json()['result']['analyses'][0]['analysisData']

videoL = []
roll = 0
partner = 0
for d in range(0,len(videoD)):
    if re.search("roll",videoD[d][1]):
        roll = roll + int(videoD[d][2])
    if re.search("embed",videoD[d][1]):
        partner = partner + int(videoD[d][2])



today = str(resq.json()['result']['analyses'][0]['timeStart'])[0:10]
todayD = datetime.datetime.strptime(today,"%Y-%m-%d")
videoL = pd.DataFrame(
    {"date":today,videoD[0][1]:[videoD[0][2]],videoD[1][1]:[videoD[1][2]],videoD[2][1]:[videoD[2][2]],"preroll":[roll],"embed":[partner],"week":todayD.strftime("%y-%W"),"weekD":todayD.weekday()}
##    ,index=[today]
    ,columns=["date",videoD[0][1],videoD[1][1],videoD[2][1],"preroll","embed","week","weekD"])
videoL.index.name = "idx"
videoL = videoL.set_index(['date'])

key_file = os.environ['HOME'] + '/lav/media/credenza/intertino.json'
cred = []
with open(key_file) as f:
    cred = json.load(f)

cred = cred['mysql']['intertino']
engine = sqlalchemy.create_engine('mysql://'+cred['user']+':'+cred['pass']+'@'+cred['host']+'/'+cred['db'],echo=False)
conn = engine.connect()
videoL.to_sql('inventory_webtrekk_preroll',conn,if_exists='append',chunksize=100,index_label="date")
conn.close()




