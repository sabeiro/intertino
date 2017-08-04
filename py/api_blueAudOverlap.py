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
refId = 218194
refIds = [[150471,"an mediaset"],[184175,"an Radio"],[218858,"an Reality"],[218859,"an Talent"],[133151,"an temptation island"],[132704,"an video viewers"],[128286,"brand donnamoderna"],[125940,"brand isola"],[218194,"brand mediaset.it"],[125936,"brand segreto"],[125937,"brand uomini e donne"]]
refIds = [[128192,"viaggi"]]

def singReq(q,audId,audName):
    print audName
    newUrl = bk.signatureInputBuilder(uDom+uPath+uServ+'/'+str(audId),'GET', None)
    audComp = json.loads(bk.doRequest(newUrl,'GET', None))##audience composition
    dataId = audComp['segments']
    dataOR  = {'AND':[{'AND':[{'OR':[dataId['AND'][0]['AND'][0]['OR'][0],dataRef['AND'][0]['AND'][0]['OR'][0] ]}]}]}
    dataAND = {'AND':[{'AND':[dataId['AND'][0]['AND'][0],dataRef['AND'][0]['AND'][0]]}]}
    data = json.dumps(dataOR,separators=(',', ':'))
    newUrl = bk.signatureInputBuilder(Url,'POST',data)
    respOR = json.loads(bk.doRequest(newUrl,'POST',data))##audience sum
    data = json.dumps(dataAND,separators=(',', ':'))
    newUrl = bk.signatureInputBuilder(Url,'POST',data)
    respAND = json.loads(bk.doRequest(newUrl,'POST',data))##audience intersection
    data = json.dumps(dataId,separators=(',', ':'))
    newUrl = bk.signatureInputBuilder(Url,'POST',data)
    respId = json.loads(bk.doRequest(newUrl,'POST',data))##second audience reach
    aLine = {'name':audName,'id':audId,'AND':respAND['reach'],'OR':respOR['reach'],'second':respId['reach']}
    aReach.append(aLine)
    # q.put(aLine)
    # q.task_done()

for i in range(len(refIds)):
    print refIds[i][1]
    newUrl = bk.signatureInputBuilder(uDom+uPath+uServ+'/'+str(refIds[i][0]),'GET', None)
    audComp = json.loads(bk.doRequest(newUrl,'GET', None))
    dataRef = audComp['segments']
    aReach = []
    concurrent = 20
    q = Queue(concurrent*2)
    for j,aud in enumerate(audL['audiences']):
        if any([x in aud['name'] for x in ["obsolete","pub","s-d","mm01"]]):
            continue
        print "========== completed ("+str(i)+"): " + "%0.0f" % (100*j/float(len(audL['audiences']))) + " =========="
        singReq(q,aud['id'],aud['name'])
    audState = pd.DataFrame(aReach)
    audState.name = audState.name.str.encode('utf-8')
    audState.to_csv(os.environ['LAV_DIR']+"/raw/audReachOverlap"+str(i)+".csv",encoding='utf8')

        
# for aud in audL['audiences']:
#     t = threading.Thread(target=singReq,args=(q,aud['id'],aud['name']))
#     t.daemon = True
#     t.start()





# def list_append(count, id, out_list):
#     for i in range(count):
# 	out_list.append(random.random())
# size = 10000000   # Number of random numbers to add
# threads = 2   # Number of threads to create
# jobs = []
# for i in range(0, threads):
#     out_list = list()
#     thread = threading.Thread(target=list_append(size, i, out_list))
#     jobs.append(thread)
# for j in jobs:
#     j.start()
# for j in jobs:
#     j.join()
