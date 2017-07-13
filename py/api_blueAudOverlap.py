import os
import sys
import random
import json
import numpy as np
import pandas as pd
import api_blueLib as bk
from threading import Thread
from Queue import Queue

Url = 'http://services.bluekai.com/Services/WS/SegmentInventory?countries=ALL'
uDom = 'http://services.bluekai.com'
uPath = '/Services/WS/'
uServ = 'audiences'
data = '{}'
method = 'GET'

newUrl = bk.signatureInputBuilder(uDom+uPath+uServ,'GET', None)
audL = json.loads(bk.doRequest(newUrl,'GET', None))
aCamp = []
refId = 218194
newUrl = bk.signatureInputBuilder(uDom+uPath+uServ+'/'+str(refId),'GET', None)
audComp = json.loads(bk.doRequest(newUrl,'GET', None))
aCamp.append(json.dumps(audComp['campaigns']))
dataRef = audComp['segments']
aud = audL['audiences'][17]

concurrent = 20

def singReq(aud):
    print aud['name']
    newUrl = bk.signatureInputBuilder(uDom+uPath+uServ+'/'+str(aud['id']),'GET', None)
    audComp = json.loads(bk.doRequest(newUrl,'GET', None))
    aCamp.append(json.dumps(audComp['campaigns']))
    dataId = audComp['segments']
    dataOR  = {'AND':[{'AND':[{'OR':[dataId['AND'][0]['AND'][0]['OR'][0],dataRef['AND'][0]['AND'][0]['OR'][0] ]}]}]}
    dataAND = {'AND':[{'AND':[dataId['AND'][0]['AND'][0],dataRef['AND'][0]['AND'][0]]}]}
    data = json.dumps(dataOR,separators=(',', ':'))
    newUrl = bk.signatureInputBuilder(Url,'POST',data)
    respOR = json.loads(bk.doRequest(newUrl,'POST',data))
    data = json.dumps(dataAND,separators=(',', ':'))
    newUrl = bk.signatureInputBuilder(Url,'POST',data)
    respAND = json.loads(bk.doRequest(newUrl,'POST',data))
    data = json.dumps(dataId,separators=(',', ':'))
    newUrl = bk.signatureInputBuilder(Url,'POST',data)
    respId = json.loads(bk.doRequest(newUrl,'POST',data))
    aLine = {'name':aud['name'],'id':aud['id'],'AND':respAND['reach'],'OR':respOR['reach'],'second':respId['reach']}
    aReach.append(aLine)

aReach = []
for aud in audL['audiences']:
    singReq(aud)

def doWork():
    while True:
        aud = q.get()
        sigReq(aud)
        q.task_done()

# q = Queue(concurrent * 2)
# for i in range(concurrent):
#     t = Thread(target=doWork)
#     t.daemon = True
#     t.start()
# try:
#     for aud in audL['audiences'][1:3]:
#         q.put(aud['id'])
#     q.join()
# except KeyboardInterrupt:
#     sys.exit(1)


audState = pd.DataFrame(aReach)
audState.to_csv(os.environ['LAV_DIR']+"/raw/audReachOverlap.csv",encoding='cp1252')

