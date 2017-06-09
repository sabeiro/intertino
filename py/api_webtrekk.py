import urlparse
import urllib
import urllib2
import cookielib
import hashlib
import hmac
import base64
import requests
import json
import re
import time

headers = {"Accept":"application/json","Content-type":"application/x-www-form-urlencoded; charset=UTF-8","User_Agent":"Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; en-US; rv:1.9.1) Gecko/20090624 Firefox/3.5"}
baseUrl = 'https://report2.webtrekk.de/cgi-bin/wt/JSONRPC.cgi'

sData = {"params": {},"version": "1.1","method": "getConnectionTest"}
resq = requests.post(baseUrl,data=json.dumps(sData))
key_file = os.environ['LAV_DIR'] + '/credenza/webtrekk.json'
cred = []
with open(key_file) as f:
    cred = json.load(f)
resq = requests.post(baseUrl,data=json.dumps(cred))
token = resq.json()['result']
query = {"params": {"token":token},"version": "1.1","method": "getAnalysisObjectsAndMetricsList"}##metriche
resq = requests.post(baseUrl,data=json.dumps(query))
for i in resq.json()['result']['metrics']:
    if re.search("Media",i):
        print i

metricV = "Media Chapter 4"
metricV = "Qty Media Player Actions"
        
query = {"params": {"token":token},"version": "1.1","method": "getAnalysisObjectsAndMetricsList"}##metriche
query = {"params": {"token":token},"version": "1.1","method": "getCustomReportsList"}##reresq = requests.post(baseUrl,data=json.dumps(query))
query = {"params": {"token":token},"version": "1.1","method": "getDynamicTimeIntervalList"}##time interval

resq = requests.post(baseUrl,data=json.dumps(query))
print resq.json()

startTime = ""
endTime = time.strftime("%Y-%m-%d")


resq = requests.post(baseUrl,data=json.dumps(query))
print resq.json()
query = {"params": {
    "token":token,
    "analysisConfig":
    {"hideFooters": 1
     #     ,"analysisFilter":{"filterRules": [{"objectTitle":"Pages","comparator":"=","filter": "*manieren*","scope": "visit"},{"link":"and","objectTitle":"Browser","comparator": "!=","filter":"*Chrome*"}]}
     ,"metrics": [
         {"sortOrder":"desc","title": "Page Impressions"},
         {"title":"Visits"
##          ,"metricFilter":{"filterRules": [{"objectTitle":"Pages","comparator": "=","filter": "*index*"}]}
         }]
     ,"rowLimit": 1000000,"analysisObjects": [{"title": "Pages"},{"sortOrder": "asc","title": "Days"}]}
},"version": "1.1","method": "getAnalysisData"}##time interval
print query
resq = requests.post(baseUrl,data=json.dumps(query))
print resq.json()['result']

query = {"params": {"token": token,"report_name": "Player"},"version": "1.1","method": "getReportData"}
resq = requests.post(baseUrl,data=json.dumps(query))
print resq.json()



query = {"params": {"token":token,"startRow": 1,"endRow": 1000,"type": "content_categories"},"version": "1.1","method": "exportData"}
resq = requests.post(baseUrl,data=json.dumps(query))
print resq.json()
