import os, sys, gzip, random, csv, json, datetime, re
sys.path.append(os.environ['LAV_DIR']+'/src/')
baseDir = os.environ['LAV_DIR']
import numpy as np
import pandas as pd
import scipy as sp
import matplotlib.pyplot as plt
import urllib3,requests
from datetime import timezone

cred = json.load(open(baseDir + "credenza/geomadi.json","r"))['darksky']
metr = json.load(open(baseDir + "raw/basics/metrics.json","r"))['geo']

headers = {"Accept":"application/json","Content-type":"application/x-www-form-urlencoded; charset=UTF-8","User_Agent":"Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; en-US; rv:1.9.1) Gecko/20090624 Firefox/3.5"}
custD = "dep"

dayL = pd.read_csv(baseDir + "raw/"+custD+"/dateList.csv")
dayL.loc[:,"ts"] = [datetime.datetime.strptime(x,"%Y-%m-%dT").strftime("%s") for x in dayL['day']]
dayL.loc[:,"wday"] = [datetime.datetime.strptime(x,"%Y-%m-%dT").weekday() for x in dayL['day']]

x = metr['de']['berlin']['x']
y = metr['de']['berlin']['y']
baseUrl = "https://api.darksky.net/forecast/"
def clampF(x):
    return pd.Series({"prec":np.mean(x['precipIntensity'])
                      ,"temp_min":min(x['temperature'])
                      ,"temp_max":max(x['temperature'])
                      ,"humidity":np.mean(x['temperature'])
                      ,"pressure":np.mean(x['pressure'])
                      ,"cloudCover":np.mean(x['cloudCover'])
                      ,"visibility":np.mean(x['visibility'])
                      })

print(baseUrl + cred['token'] + "/%f,%f,%s?exclude=currently,flags" % (y,x,dayL['ts'][0]))
weatL = []
hourL = []
for i,c in dayL.iterrows():
    locL = {}
    for j in c.keys():
        locL[j] = c[j]
    if c['humidity'] != c['humidity']:
        print(c['day'])
        try:
            resq = requests.get(baseUrl + cred['token'] + "/%f,%f,%s?exclude=currently,flags" % (y,x,dayL['ts'][i]),headers=headers)
            if resq.status_code == 200:
                resp = resq.json()['daily']['data'][0]
                for j in resq.json()['hourly']['data']:
                    hourL.append(j)
                for j in resp.keys():
                    locL[j] = resp[j]
        except: print("not reached")
    weatL.append(locL)

dayL = pd.DataFrame(weatL)
hourL = pd.DataFrame(hourL)
#dayL = pd.merge(dayL,weathL,on="day",how="left",suffixes=["_x",""])
# dayL.loc[:,"ts"] = [datetime.datetime.strptime(x,"%Y-%m-%d").strftime("%s") for x in dayL['day']]
dayL.loc[:,"ts"] = dayL['ts'].astype(int)
t = dayL['temperatureMaxTime'] - dayL['ts']
t = dayL['apparentTemperatureMax'] - dayL['apparentTemperatureHigh']
if False:
    plt.hist(t,bins=20)
    plt.show()
dayL.loc[:,"lightDur"] = dayL['sunsetTime'] - dayL['sunriseTime']
for i,g in dayL.iterrows():
    if dayL.loc[i,'apparentTemperatureLow'] == dayL.loc[i,'apparentTemperatureLow']:
        dayL.loc[i,"Tmin"] = (dayL.loc[i,'apparentTemperatureLow']-32.)*5./9.
        dayL.loc[i,"Tmax"] = (dayL.loc[i,'apparentTemperatureHigh']-32.)*5./9.
dayL = dayL.drop(columns=['apparentTemperatureHighTime','apparentTemperatureLowTime','apparentTemperatureMaxTime','apparentTemperatureMinTime','precipIntensityMaxTime','sunriseTime','sunsetTime','temperatureHigh','temperatureHighTime','temperatureLow','temperatureLowTime','temperatureMaxTime','temperatureMin','temperatureMinTime','windGustTime','time'])
#dayL = dayL.drop(columns=['apparentTemperatureMax','apparentTemperatureMin','moonPhase','precipIntensityMax','precipType','summary','temperatureHigh','temperatureLow','temperatureMax','temperatureMin','time','windGust'])
#dayL = dayL.drop(columns=['cloudCoverError','temperatureHighError','temperatureMaxError'])
#dayL = dayL.drop(columns=['apparentTemperatureLow','apparentTemperatureHigh','ts'])
dayL.replace(float('NaN'),0,inplace=True)

isocal = [datetime.datetime.strptime(x,"%Y-%m-%dT").isocalendar() for x in dayL['day']]
dayL.loc[:,"isocal"] = ["%02d-%02dT" % (x[1],x[2]) for x in isocal]
dayL.to_csv(baseDir + "raw/"+custD+"/dateList.csv",index=False)

time = [datetime.datetime.fromtimestamp(x) for x in hourL['time']]
hourL.loc[:,"isocal"] = ["%02d-%02dT%02d" % (x.isocalendar()[1],x.isocalendar()[2],x.hour) for x in time]
#hourL = pd.concat([pd.read_csv(baseDir+"raw/"+custD+"/hourWeather.csv"),hourL])
hourL.loc[:,"apparentTemperature"] = (hourL['apparentTemperature']-32.)*5./9.
hourL.loc[:,"temperature"] = (hourL['temperature']-32.)*5./9.
hourL.loc[:,"id_poi"] = 1
hourL.loc[:,"hour"] = [x.hour for x in time]
hourL.loc[:,"day"] = ["%04d-%02d-%02d" % (x.year,x.month,x.day) for x in time]
try :
    hourL1 = pd.read_csv(baseDir+"raw/"+custD+"/weather_h_1.csv.gz",compression="gzip")
    hourL = pd.concat([hourL,hourL1])
except: i = 1
    
hourL.to_csv(baseDir+"raw/"+custD+"/weather_h.csv.gz",compression="gzip",index=False)

if False:
    dayL = pd.read_csv(baseDir + "raw/"+custD+"/dateList.csv")
    dayL1 = pd.DataFrame()
    year = datetime.datetime.today().year-2
    orig = datetime.datetime.strptime(str(year) + "-01-01","%Y-%m-%d")
    lL = [orig + datetime.timedelta(days=x) for x in range(365)]
    dL = [x.strftime("%Y-%m-%dT%H:%M:%S") for x in lL]
    dayL1.loc[:,"time"] = dL
    dayL1.loc[:,"day"]  = dayL1['time'].apply(lambda x: x[:11])
    dayL = dayL1#pd.concat([dayL1,dayL])
    dayL.to_csv(baseDir + "raw/"+custD+"/dateList1.csv",index=False)

print('-----------------te-se-qe-te-ve-be-te-ne------------------------')

