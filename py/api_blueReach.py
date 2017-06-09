import os
import sys
sys.path.append("/home/sabeiro/lav/media/script/py/")
import random
import json
import numpy as np
import pandas as pd
import api_blueLib as bk

Url = 'http://services.bluekai.com/Services/WS/SegmentInventory?countries=ALL'
uDom = 'http://services.bluekai.com'
uPath = '/Services/WS/'
uServ = 'audiences'
data = '{}'
method = 'GET'


newUrl = bk.signatureInputBuilder(uDom+uPath+uServ,'GET', None)
audL = json.loads(bk.doRequest(newUrl,'GET', None))
aReach = []
aCamp = []
aud = audL['audiences'][15]
for aud in audL['audiences']:
    print aud['name']
    newUrl = bk.signatureInputBuilder(uDom+uPath+uServ+'/'+str(aud['id']),'GET', None)
    audComp = json.loads(bk.doRequest(newUrl,'GET', None))
    aCamp.append(json.dumps(audComp['campaigns']))
    data = json.dumps(audComp['segments'],separators=(',', ':'))
    newUrl = bk.signatureInputBuilder(Url,'POST',data)
    resp = json.loads(bk.doRequest(newUrl,'POST',data))
    sCat = ''
    sReach = ''
    for cat in resp['AND'][0]['AND'][0]['OR']:
        sCat += str(cat['AND'][0]['cat']) + ', '
        sReach += str(cat['AND'][0]['reach']) + ', '
    aLine = {'name':aud['name'],'id':aud['id'],'reach':resp['reach'],'camp':json.dumps(audComp['campaigns']),"cat":sCat,"catReach":sReach}
    aReach.append(aLine)

# for col in aLine:
#     aLine[col] = data[col].str.decode('iso-8859-1').str.encode('utf-8')

audState = pd.DataFrame(aReach)
##audState.to_csv("../../raw/audReach.csv",encding='utf-8')
audState.to_csv("../../raw/audReach.csv",encoding='cp1252')
# aList = namedtuple('name', 'id')
# aName = [aList(**k) for k in resp["audiences"]]

