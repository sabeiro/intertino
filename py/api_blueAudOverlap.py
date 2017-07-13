import os
import sys
import random
import json
import numpy as np
import pandas as pd
import api_blueLib as bk
import threading
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

def singReq(q,audId,audName):
    print audName
    newUrl = bk.signatureInputBuilder(uDom+uPath+uServ+'/'+str(audId),'GET', None)
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
    aLine = {'name':audName,'id':audId,'AND':respAND['reach'],'OR':respOR['reach'],'second':respId['reach']}
    aReach.append(aLine)
    q.put(aLine)
    # q.task_done()

    
aReach = []
concurrent = 20
q = Queue(concurrent*2)
for aud in audL['audiences']:
    singReq(q,aud['id'],aud['name'])

# for aud in audL['audiences']:
#     t = threading.Thread(target=singReq,args=(q,aud['id'],aud['name']))
#     t.daemon = True
#     t.start()


audState = pd.DataFrame(aReach)
audState.to_csv(os.environ['LAV_DIR']+"/raw/audReachOverlap.csv",encoding='cp1252')

