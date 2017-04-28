import os
import sys
sys.path.append("/home/sabeiro/lav/media/script/py/")
import random
import json
import numpy as np
import scipy, scipy.stats
from scipy.optimize import least_squares
from scipy import stats
import pandas as pd
import requests
from pylab import plot, ylim, xlim, show, xlabel, ylabel
import pylab 
import matplotlib.pyplot as plt
#import statsmodels.formula.api as sm
import statsmodels.api as sm
import statsmodels.formula.api as smf
from statsmodels.graphics.api import qqplot
import statsmodels.tsa as tsa
import sklearn.model_selection as crossval
from sklearn import datasets
from sklearn import svm
import datetime
import series_lib as sl


from matplotlib import rcParams
rcParams['figure.figsize'] = (10, 6)
rcParams['legend.fontsize'] = 16
rcParams['axes.labelsize'] = 16

beta = [2,4,16,32]



baseUrl = "http://analisi.ad.mediamond.it/jsonp.php"
resq = requests.get(baseUrl+"?tab=uominiedonne")
#ser = resq.json()['data'] # x = [row[0] for row in ser]
ser = np.array(resq.json()['data']).astype(np.float)
#time = trainD.t.dropna().apply(lambda x: int(x) )
time = pd.DataFrame({'t':np.array(resq.json()['data'])[:,0]/1000})
dta = pd.DataFrame({'y':ser[:,1]})
dta.index = pd.Index(time.t.apply(lambda x: datetime.datetime.fromtimestamp(x)))
##dta['roll'] = pd.rolling_mean(dta,window=14).values
t = ser[:,0]/1000000000
y = ser[:,1]/1000000
trainD = pd.DataFrame({'t':t,'y':y})
rollD = pd.DataFrame({'t':t,'y':smooth(y,4,11)})
testD = pd.DataFrame({'t':np.linspace(trainD.t[0],trainD.t[trainD.t.size-1]+t[6]-t[0],t.size+7)})
##dtaRoll = pd.rolling_mean(dta,window=14)
dtaRoll = pd.ewma(dta,halflife=14)
##dtaDiff = dta - dta.shift()
dtaDiff = dta - dtaRoll
dtaDiff.dropna(inplace=True)

dtaAcf = tsa.stattools.acf(dtaDiff,nlags=40)
dtaPacf = tsa.stattools.pacf(dtaDiff,nlags=20,method='ols')

model = tsa.arima_model.ARIMA(dta,order=(2, 1, 0))
res_AR = model.fit(disp=-1)
pred_ARIMA = pd.Series(res_AR.fittedvalues,copy=True)
pred_ARIMAsum = pred_ARIMA.cumsum()
predARIMAlog = pd.Series(dta.y,index=dta.index)
predARIMAlog = predARIMAlog.add(pred_ARIMAsum,fill_value=0)
predARIMA = np.exp(predARIMAlog)
plt.plot(dta)
plt.plot(predictions_ARIMA_log)
#plt.title('RMSE: %.4f'% np.sqrt(sum((predictions_ARIMA-dta)**2)/len(dta)))
plt.show()



plt.plot(dtaDiff)
plt.plot(results_AR.fittedvalues, color='red')
plt.show()

plt.subplot(121) 
plt.plot(dtaAcf)
plt.axhline(y=0,linestyle='--',color='gray')
plt.axhline(y=-1.96/np.sqrt(len(dtaDiff)),linestyle='--',color='gray')
plt.axhline(y=1.96/np.sqrt(len(dtaDiff)),linestyle='--',color='gray')
plt.title('Autocorrelation Function')
#Plot PACF:
plt.subplot(122)
plt.plot(dtaPacf)
plt.axhline(y=0,linestyle='--',color='gray')
plt.axhline(y=-1.96/np.sqrt(len(dtaDiff)),linestyle='--',color='gray')
plt.axhline(y=1.96/np.sqrt(len(dtaDiff)),linestyle='--',color='gray')
plt.title('Partial Autocorrelation Function')
plt.tight_layout()
plt.show()


dta.plot(figsize=(12,8));
fig = plt.figure(figsize=(12,8))
ax1 = fig.add_subplot(211)
fig = sm.graphics.tsa.plot_acf(dta.values.squeeze(),lags=40,ax=ax1)
ax2 = fig.add_subplot(212)
fig = sm.graphics.tsa.plot_pacf(dta, lags=40, ax=ax2)
fig.show()



lm = smf.ols(formula='y ~ 1 + t + I(t**2) + I(t**3) + I(t**4) + I(t**5)',data=trainD).fit()
testD = pd.concat([testD,pd.DataFrame({"y":lm.predict(testD.t)})],axis=1)
#zip(['x'], lm.coef_)

frWeek = 2.*np.pi/(t[7]-t[0])
frMonth = 2.*np.pi/(t[28]-t[0])
confInt = stats.t.interval(0.95,len(y)-1,loc=np.mean(y),scale=stats.sem(y))
#wavelet - beta 

yy = smooth(y,4,11)
def fun_smooth(t):
    idx = (np.abs(trainD.t-t)).argmin()
    return yy[idx]

def fun(x,t):
    return x[0] + x[1] * np.sin(frWeek*t + x[2]) + x[3] * np.sin(frMonth*t + x[4]) #+ fun_smooth(t)
    
def fun_min(x,t,y):
    return fun(x,t) - y

x0 = [1.37802236e+00,8.37155618e-01,8.32309778e+00,2.15614241e-01,2.68712056e+00,3.00000000e+01,5.00000000e-02,1.00000000e-04,1.00000000e-06]

res_lsq = least_squares(fun_min,x0,args=(trainD.t,trainD.y))
res_robust = least_squares(fun_min,x0,loss='soft_l1',f_scale=0.1,args=(trainD.t,trainD.y))

print res_robust.x
print res_lsq.x

plt.figure(figsize=(6 * 1.618, 6))
plt.plot(trainD.t,trainD.y, '-k', label='data')
plt.plot(t_test,fun(res_lsq.x,t_test),label='lsq')
plt.plot(t_test,fun(res_robust.x,t_test),label='robust lsq')
plt.plot(trainD.t,lm.predict(trainD.t),'-k',label='Poly n=2 $R^2$=%.2f' % lm.rsquared,alpha=0.9)
#for b in beta:
plt.plot(t,smooth(y,4,11),label="beta = "+str(4)+"")
plt.xlabel('$t$')
plt.ylabel('$y$')
pylab.title("time series interpolation")
plt.legend()
plt.show()
##pylab.savefig('interp.png', fmt='PNG', dpi=100 )


test_stationarity(dtaDiff)

plt.plot(dtaDiff,'-k',label='data')
plt.show()


plt.plot(dta,'-k',label='data')
plt.plot(dtaRoll,label="arima 3")
plt.plot(dtaExp,label="arima 2")
plt.show()



arma_mod20 = sm.tsa.ARMA(dta, (2,0)).fit()
arma_mod30 = sm.tsa.ARMA(dta, (3,0)).fit()


plt.plot(dta,'-k',label='data')
plt.plot(arma_mod30.resid,label="arima 3")
plt.plot(arma_mod20.resid,label="arima 2")
plt.show()






fig = plt.figure(figsize=(12,8))
ax = fig.add_subplot(111)
fig = qqplot(resid, line='q', ax=ax, fit=True)
fig.show()


stats.normaltest(arma_mod30.resid)
sm.stats.durbin_watson(arma_mod30.resid.values)
print(arma_mod20.params)
print(arma_mod20.aic, arma_mod20.bic, arma_mod20.hqic)
print(arma_mod30.params)
print(arma_mod30.aic, arma_mod30.bic, arma_mod30.hqic)



