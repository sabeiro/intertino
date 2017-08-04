import sys
import numpy as np
import pandas as pd
import re
import requests
import time
import datetime
import json
from urllib import quote_plus as urlquote
import os
import requests
import string

##create index
headers = {"Accept":"application/json","Content-type":"application/x-www-form-urlencoded; charset=UTF-8","User_Agent":"Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; en-US; rv:1.9.1) Gecko/20090624 Firefox/3.5"}
baseUrl = 'http://localhost:9200/'
sData = {"pretty":""}
indexN = 'brightroll-17-06'
key_file = os.environ['LAV_DIR'] + '/credenza/intertino.json'
cred = []
with open(key_file) as f:
    cred = json.load(f)

##create
##requests.put(baseUrl+indexN+'?pretty&pretty',headers=headers,data={})
##delete
##requests.delete(baseUrl+indexN+'/external/'+str(i)+"?pretty",headers=headers)
requests.delete(baseUrl+indexN+"?pretty",headers=headers,auth=(cred['elastic']['user'],cred['elastic']['pass']))
##list
resq = requests.get(baseUrl+'_cat/indices?v&pretty',headers=headers,auth=(cred['elastic']['user'],cred['elastic']['pass']))
##set geo points
# sData = {"mappings": {"_default_": {"properties": {"geo": {"type": "geo_point"}}}}}
# requests.put(baseUrl+indexN+'?pretty&pretty',headers={},data=json.dumps(sData))

fileL = ["raw/brHistory17-04.csv","raw/brHistory17-05.csv","raw/brHistory17-06.csv","raw/brHistory17-07.csv"]
fileL = ["raw/brHistory17-07.csv"]
for k in fileL:
    notA = pd.read_csv(os.environ['LAV_DIR'] + k)
    #notA['Day'].fillna("6/1/17",inplace=True)
    notA['date'] = [datetime.datetime.strptime(x,"%m-%d-%Y") for x in notA['Day']]
    notA.fillna("",inplace=True)
    notA['Campaign'] = notA['Campaign'].apply(lambda x: re.sub("_"," ",x))
    notA['Targeted Audience Name'] = notA['Targeted Audience Name'].apply(lambda x: re.sub("_"," ",x))
    notA['Impressions'] = notA['Impressions'].apply(lambda x: int(re.sub(",","",x)) )
    notA['Clicks'] = notA['Clicks'].apply(lambda x: int(re.sub(",","",x)) )
    notA['Conversion'] = notA['Conversion'].apply(lambda x: int(x) )
    notA['Advertiser Spending Advertiser Currency'] = notA['Advertiser Spending Advertiser Currency'].apply(lambda x: float(re.sub(",","",x)) )
    notA['source'] = "rest"
    sectL = ['Banzai','Yahoo','Mediamond']
    for i in range(0,len(sectL)):
        idxA = notA['Targeted Audience Name'].str.contains(str(sectL[i]))
        notA['source'][idxA] = str(sectL[i])
    
    stopW = ['IT','Banzai',"Mediamond","Yahoo","Interest","Premium Audience"]
    notA['Targeted Audience Name'] = notA['Targeted Audience Name'].apply(lambda x: ' '.join(w for w in x.split() if w not in stopW))
    
    sucS = ""
    for i in range(0,len(notA)):
        idS = {"index":{"_index":int(datetime.datetime.strftime(notA.loc[i,'date'],"%Y%m%d")),"_type":"log"}}
        timest = list(str(notA.loc[i]['date']) + "Z")
        timest[10] = 'T'
        timest = "".join(timest)
        tS = "".join(timest)
        sData = {"@timestamp":tS,"client":notA.loc[i]['Advertiser'],"target":notA.loc[i]['Targeted Audience Name'],"source":notA.loc[i]['source'],"order":notA.loc[i]['Campaign Id'],'size':notA.loc[i]['Ad Size'],'rev':notA.loc[i]['Advertiser Spending Advertiser Currency'],"imps":notA.loc[i]['Impressions'],"click":notA.loc[i]['Clicks'],"conversion":notA.loc[i]['Conversion']}
        resq = requests.post(baseUrl+indexN+'/external/'+str(i)+"?pretty",headers=headers,data=json.dumps(sData),auth=(cred['elastic']['user'],cred['elastic']['pass']))
        if resq.status_code >= 400:
            print resq.json()
        sucS += " " + str(resq.status_code) #+ resq.text
        if i%20 == 0:
            print sucS
            sucS = ""


##    print "curl -XPUT '" + baseUrl + indexN + '/external/' + i + "?pretty&pretty'" + " -H 'Content-Type: application/json' -d '" + json.dumps(sData) + "'"




