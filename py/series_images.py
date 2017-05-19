##https://www.aaai.org/ocs/index.php/WS/AAAIW15/paper/viewFile/10179/10251
import os
import sys
import random
import numpy as np
import pandas as pd
import pylab 
import matplotlib.pyplot as plt
import series_lib as sl
import db_sql as dbs
import datetime
import calendar
import string
import json
from scipy import signal as sg


todayD = datetime.datetime.today()
todayD = todayD.replace(hour=0,minute=0,second=0,microsecond=0)
yesterdayD = todayD - datetime.timedelta(days=1)

startC = {}
with open(os.environ['LAV_DIR']+"/train/series_interp.json") as f:
    startC = json.load(f)

resqW = pd.DataFrame()
nAhead = 14 + datetime.datetime.today().weekday()
nr = sorted(startC.keys(),key=lambda x:x[0])[0]
print '-------------------' + nr + '--------------------------'
sData = {'tab':'daily','sect':nr}
sDay, sWeek, sMonth = sl.getSeries({'tab':'daily','sect':nr})

sDay['x'] = ( (sDay['y'] - sDay['y'].max()) + (sDay['y'] - sDay['y'].min()) ) / (sDay['y'].max() - sDay['y'].min())
sDay['phi'] = 2.*np.arccos(sDay['x'])
sDay['r'] = [float(x)/sDay.shape[0] for x in range(sDay.shape[0])]

# ax = plt.subplot(111, projection='polar')
# ax.plot(sDay['phi'],sDay['r'])
# ax.grid(True)
# ax.set_title("A line plot on a polar axis", va='bottom')
# plt.show()
# plt.plot(sDay['r'],sDay['phi'])
# plt.plot(sDay['r'],sDay['x'])
# plt.show()

def innerP(x,y):
    #return np.tensordot(x,y,axes=(-1,-1))
    return x*y - np.sqrt(1-x**2)*np.sqrt(1-y**2)

nSet = sDay.shape[0]
img = np.matrix([[innerP(i,j) for j in sDay['x']] for i in sDay['x']])

quant = np.percentile(sDay['x'],[x for x in range(0,105,5)])
sDay['quant'] =  pd.cut(sDay['x'],bins=quant,labels=range(len(quant)-1),right=True,include_lowest=True)
""" adjacent matrix - graph representation """
markovMat = np.matrix([[0. for i in xrange(len(quant))] for i in xrange(len(quant))])
timeStep = 1
for x in range(nSet-timeStep):
    i = sDay['quant'][x]
    j = sDay['quant'][x+timeStep]
    markovMat[i,j] += 1.

markovMat = markovMat/markovMat.sum()
markovField = np.matrix([[0. for i in xrange(nSet)] for i in xrange(nSet)])
for i in range(nSet):
    for j in range(nSet):
        ii = sDay['quant'][i]
        jj = sDay['quant'][j]
        markovField[i,j] += markovMat[ii,jj]

markovBlur = np.matrix([[0. for i in xrange(nSet/2)] for i in xrange(nSet/2)])
for i in range(nSet/2):
    for j in range(nSet/2):
        markovBlur[i,j] = (markovField[2*i,2*j] + markovField[2*i+1,2*j] + markovField[2*i,2*j+1] + markovField[2*i+1,2*j+1])/4


#markovF = sg.convolve(markovMat,fGaussBlur)

if False:
    sMat = img#markovMat
    sMat = markovBlur
    plt.imshow(sMat, interpolation='nearest', cmap=plt.cm.ocean, extent=(0.5,10.5,0.5,10.5))
    plt.colorbar()
    plt.show()

