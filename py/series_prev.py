import os
import sys
sys.path.append("/home/sabeiro/lav/media/script/py/")
import random
import numpy as np
import scipy as sp
import pandas as pd
from scipy import stats
import pylab 
import matplotlib.pyplot as plt
#import statsmodels.formula.api as sm
import statsmodels.tsa as tsa
import sklearn.model_selection as crossval
import series_lib as sl
import datetime
import calendar
import string
import json

print '-----------------------series-prev--------------------------------'

todayD = datetime.datetime.today()
todayD = todayD.replace(hour=0,minute=0,second=0,microsecond=0)
yesterdayD = todayD - datetime.timedelta(days=1)

from matplotlib import rcParams
rcParams['figure.figsize'] = (10, 6)
rcParams['legend.fontsize'] = 16
rcParams['axes.labelsize'] = 16

names = ['amici','brand','fascino','fiction','il_segreto','intrattenimento','news/info','reality/talent','rest','soap','sport','uominiedonne']
startC = pd.read_csv(os.environ['HOME'] + "/lav/media/out/interp_val.csv")
startCW = pd.read_csv(os.environ['HOME'] + "/lav/media/out/interp_valW.csv")
predD = pd.DataFrame()
predW = pd.DataFrame()
resquare = pd.DataFrame()
resqW = pd.DataFrame()
nAhead = 14 + datetime.datetime.today().weekday()
nr = names[0]
for nr in names:                ##
    print '-------------------' + nr + '--------------------------'
    nameR = nr.translate(None,string.punctuation)
    sData = {'tab':'train_s','sect':nameR}
    sDay, sWeek, sMonth = sl.getSeries({'tab':'daily','sect':nr})
    ##sTel, tWeek, tMonth = sl.getSeries({'tab':'daily_tel','sect':nr})
    sPali, pWeek, pMonth = sl.getSeries({'tab':'tv_pali','sect':nr})
    hDay, hWeek, hMonth = sl.getSeries({'tab':'daily_hist','sect':nr})
    reload(sl)
    startC = pd.read_csv(os.environ['HOME'] + "/lav/media/out/interp_val.csv")
    x0 = startC[nameR]
    ##x0 = sl.getStartParam({'tab':'train_s','sect':nameR})
    histPali = pd.concat([pWeek.y,hWeek.y],join='outer',axis=1)
    histPali.columns = ['y1','y2']
    histPali['y'] = histPali['y1'] * histPali['y2']
    histPali['y'][np.isnan(histPali.y)] = histPali['y2'][np.isnan(histPali.y)]
    hWeek.y = histPali['y']/histPali['y'].max()
    if(int(startC[nameR][9])==1):
        ##par = sl.bestArima(sDay.drop(sDay.index[0]),14,startC[nameR],hWeek)
        testD, res_lsq, rSq = sl.serArma(sDay,nAhead,x0,hWeek)
    elif(int(startC[nameR][9])==2):
        testD, res_lsq, rSq = sl.serHolt(sDay,nAhead,x0,hWeek)
    elif(int(startC[nameR][9])==3):
        testD, res_lsq, rSq = sl.serAuto(sDay,nAhead,x0,hWeek)
    else:
        testD, res_lsq, rSq = sl.extSeries(sDay,nAhead,x0,hWeek)

    print res_lsq
    #sl.plotSer(sDay,testD)

    resquare[nameR] = res_lsq##pd.Series(res_lsq[0],index=res_lsq.index)
    predD[nameR] = testD['pred']

    ##weekD, week_lsq = sl.serWeek(sWeek.query("count==7"),2,startCW[nameR],hWeek)
    ##resqW[nameR] = week_lsq##pd.Series(week_lsq[0],index=week_lsq.index)
    #predW[nameR] = weekD['pred']

    # trainD = sDay
    # x0 = startC[nameR]
    # avHist = hWeek
    
    # plt.savefig('../../fig/interp'+nameR+'.jpg', fmt='JPG', dpi=100 )


resquare.to_csv(os.environ['HOME'] + "/lav/media/out/interp_val.csv")
resqW.to_csv(os.environ['HOME'] + "/lav/media/out/interp_valW.csv")

import MySQLdb
from pandas.io import sql
import sqlalchemy

key_file = os.environ['HOME'] + '/lav/media/credenza/intertino.json'
cred = []
with open(key_file) as f:
    cred = json.load(f)
cred = cred['mysql']['intertino']
engine = sqlalchemy.create_engine('mysql://'+cred['user']+':'+cred['pass']+'@'+cred['host']+'/'+cred['db'],echo=False)
conn = engine.connect()

predD1 = predD[predD.index>yesterdayD]
predD1.fillna(0,inplace=True)
predW1 = predW[predW.index>yesterdayD]
predD1.columns = names
predD2 = predD1.apply(lambda x:x*1000000).astype(int)
predD2.to_sql('inventory_prediction_daily',conn,if_exists='replace',chunksize=100,index_label="date")

predD2['week'] = [predD2.index[x].isocalendar()[1] for x in range(predD2.shape[0])]
predDW = predD2.groupby(["week"]).sum()/1000000
predDW['count'] = predD2.groupby(["week"]).size()
predDW = predDW.query("count == 7")
base = datetime.datetime.strptime("2017-01-01","%Y-%m-%d")
matchWD = pd.DataFrame(index=[base + datetime.timedelta(days=x) for x in range(0,365)])
matchWD['week'] = [matchWD.index[x].isocalendar()[1] for x in range(matchWD.shape[0])]
##matchWD['date'] = [datetime.datetime.strftime(x,'%Y-%m-%d') for x in matchWD.index]
matchWD = matchWD[matchWD.index.weekday==3]
matchDW = pd.DataFrame({'date':matchWD.index},index=matchWD.week)
predDW =  pd.merge(predDW,matchDW,how="left",left_index=True,right_index=True)
##predDW['date'] = [matchWD.date[matchWD['week'] == int(x)] for x in predDW.index]
predDW['tot'] = predDW.sum(axis=1)
predW['tot'] = predW.sum(axis=1)
predDW.to_sql('inventory_prediction_weekly',conn,if_exists='replace',chunksize=100)

resquare.to_sql('train_series',conn,if_exists='replace',chunksize=100,index_label="row_names")
conn.close()



