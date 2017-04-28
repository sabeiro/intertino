import os
import sys
sys.path.append("/home/sabeiro/lav/media/script/py/")
import json
import random
import numpy as np
import pandas as pd
import api_blueLib as bk
import datetime

urlPush = 'services.bluekai.com/Services/WS/Campaign?bkuid=ebfff347706bc9a0e5232723d135036bab2bb669dc5967923435e3eedcba9bec&bksig=IUF%2BDS46APwdJCVxJR6aI4iNvFZQlmAiNIR%2FL7muyW4%3D'
urlGet = 'services.bluekai.com/Services/WS/Campaign?bkuid=750191b6ae4af549a35fffae8dd27930500f6b5ec43569b72b741680f92ab26f&bksig=mYryT6VXQYSb3pTwzxfp6%2BE%2BpKrvr9t8r5VpKYeaVR4%3D'

uDom = 'http://services.bluekai.com'
uPath = '/Services/WS/'
uServ = 'Campaign'

data = '{}'
method = 'GET'
newUrl = bk.signatureInputBuilder(uDom+uPath+uServ,'GET', None)
campL = json.loads(bk.doRequest(newUrl,'GET', None))

campT = []
camp = campL['campaigns'][0]
for camp in campL['campaigns']:
    cLine = {'campaignId':camp["campaignId"],'name':camp["name"],'startDate':camp["startDate"],'campaignState':camp["campaignState"],'audienceId':camp["audienceId"],'audienceName':camp["audienceName"],'activated':camp["activated"],'campaignType':camp["campaignType"],'includeTopNodes':camp["includeTopNodes"],'categoryTransferMethod':camp["categoryTransferMethod"],'pixelURL':json.dumps(camp["pixelURLs"]),'privateSellerTargets':camp["privateSellerTargets"],'retargetingSites':camp["retargetingSites"]}
    campT.append(cLine)
audState = pd.DataFrame(campT)
#print audState
# audState.to_csv("~/lav/media/raw/audCampList.csv",encoding='utf-8')
# pd.DataFrame(campL).to_csv("tmp.csv")

nCamp = 10
pixUrl = "https://secure-gl.imrworldwide.com/cgi-bin/m"
campA = pd.read_csv("~/lav/media/raw/audCampList.csv") 

##pixUrl = "https://beacon.krxd.net/event.gif"
##campA = pd.read_csv("../../raw/audCampListKx.csv")

pcList = list()
idList = list()
for idx,i in campA.iterrows():
    pcList.append(pixUrl + '?ca=' + str(i['ca']) + '&cr=' + str(i['cr']) + '&ce=' + str(i['ce']) + '&ci=' + str(i['ci']) + '&am=' + str(i['am']) + '&at=' + str(i['at']) + '&rt=' + str(i['rt']) + '&st=' + str(i['st']) + '&pc=' + str(i['pc']) + "&r=$TIMESTAMP")
    idList.append({"id":i['id'],'name':i['name']})
    ##pcList.append(i['baseUrl'] + '?event_id=' + i['event'] + '&event_type=' + i['type'] + '&aud=' + i['camp'])
campA['pix'] = pcList

pd.DataFrame(pcList).to_csv("tmp.csv")

pData = {"startDate": "2016-11-28T00:00:00-07:00","campaignType": "normal","includeTopNodes":False,"winFrequency": 30,"pixelUrls":[{"status": "active","sequence": 1,"url": "http://b3.example.com/1/","avgLatency": 77,"updatedAt": "2016-11-01T11:45:45-07:00","createdAt": "2016-11-01T11:45:45-07:00"}],"idSwap": False,"updatedAt": "2016-11-01T10:35:45-07:00","partner":{"id":2456,"name": "Example Partner"},"privateSellers":[],"pacingType": "cpm","status": "idle","labels":[],"categoryTransferMethod": "0","activated": True,"bid": 0.1,"solutionType":{"id":1,"name": "Media Targeting"},"httpsPull": False,"pacingGoal": 1,"name": "Example Campaign","revenueRecognition": False,"testCampaign": False,"audience":{"id":72531,"name":"Example Audience"},"recency":-1,"pricingModel":{"id":2,"name":"CPM"}}
pData = {"startDate": "2016-11-28T00:00:00-07:00","campaignType": "normal","includeTopNodes":"false","winFrequency": 30,"pixelUrls":[{"status": "active","sequence": 1,"url": "http://b3.example.com/1/","avgLatency": 77,"updatedAt": "2016-11-01T11:45:45-07:00","createdAt": "2016-11-01T11:45:45-07:00"}],"idSwap": "false","updatedAt": "2016-11-01T10:35:45-07:00","partner":{"id":2456,"name": "Example Partner"},"privateSellers":[],"pacingType": "cpm","status": "idle","labels":[],"categoryTransferMethod": "0","activated": "true","bid": 0.1,"solutionType":{"id":1,"name": "Media Targeting"},"httpsPull": "false","pacingGoal": 1,"name": "Example Campaign","revenueRecognition": "false","testCampaign": "false","audience":{"id":72531,"name":"Example Audience"},"recency":-1,"pricingModel":{"id":2,"name":"CPM"}}
pData1 = pData
# for i,d in campA.iterrows():
#     print d
d = campA.iloc[1]
cTime = datetime.datetime.now().strftime("%Y-%m-%dT%H:%M:%S-05:00")
pData1['startDate'] = cTime
pData1['updatedAt'] = cTime
pData1['status'] = 'active'
pData1['name'] = d['name']
pData1['audience']['id'] = d['id']
pData1['audience']['name'] = d['name']
##pData1['pixelUrls'][0]['url'] = d['pix']
pData1['pixelUrls'][0]['id'] = d['id']
pData1['pixelUrls'][0]['name'] = d['name']
pData1['pixelUrls'][0]['updatedAt'] = cTime
pData1['pixelUrls'][0]['createdAt'] = cTime



print json.dumps(pData1)
newUrl = bk.signatureInputBuilder(uDom+'/rest/campaigns','POST',json.dumps(pData1,separators=(',', ':')))
campL = json.loads(bk.doRequest(newUrl,'POST',json.dumps(pData1,separators=(',', ':'))))
print newUrl

aCamp = []
for camp in campL['items']:
    pixL = []
    for pix in camp['pixelUrls']:
        if(pix['status'] == "deleted"):
            continue
        pixLine = {'url':pix['url'],'status':pix['status']}
        pixL.append(pixLine)
    aLine = {'name':camp['name'],'aud':camp['audience']['name'],'active':camp['status'],'type':camp['campaignType'],'freq':camp['winFrequency'],'test':camp['testCampaign'],'swap':camp['idSwap'],'json':camp['jsonPullMacro'],'pix':json.dumps(pixL)}
    aCamp.append(aLine)
print aCamp

campState = pd.DataFrame(aCamp)
print campState
#campState.to_csv("../../raw/blueCampListJson.csv",encoding='utf-8')
campState.to_csv("../../raw/blueCampListPush.csv",encoding='utf-8')

Url = 'http://services.bluekai.com/Services/WS/SegmentInventory?countries=ALL'
uDom = 'http://services.bluekai.com'
uPath = '/Services/WS/'
uServ = 'audiences'
data = '{}'
method = 'GET'

newUrl = bk.signatureInputBuilder(uDom+uPath+uServ,'GET', None)
audL = json.loads(bk.doRequest(newUrl,'GET', None))
aReach = []
for aud in audL['audiences']:
    aLine = {'name':aud['name'],'id':aud['id'],'recency':aud['recency'],'camp':json.dumps(aud['campaigns']),'date':aud['created_at']}
    ##aLine = {'name':aud['name'],'id':aud['id'],'recency':aud['recency'],}
    aReach.append(aLine)
audState = pd.DataFrame(aReach)
print audState
audState.to_csv("../../raw/audienceReachPush.csv",encoding='utf-8')




# aList = namedtuple('name', 'id')
# aName = [aList(**k) for k in resp["audiences"]]




##https://www.facebook.com/brandlift.php?campaign_id=b391ac47cfd0295195d0ab3ec63bda9344fa73e28fc28c57e19a709eba5679cb&creative_id=b1fe3dba11b81477f4ac3256b6a277152271f298a6462b0fc2449ef8ff83017c&placement_id=5ceab45ce14203078db1e43ba8ac0a23a1aa2be075748b489ebb931f57dde77c&media_type=image&segment1=US&segment2=511&segment3=NA&osversion=NA&device_type=DSK&platform=DSK&advertiser_id=DSK&ver=1&h=7b5f7123d2&rnd=1476354853

	
	
	
