import numpy as np
import scipy as sp
import pandas as pd
import matplotlib.pyplot as plt
import math
import requests
import json
import datetime
import time
import urllib
import calendar

def serRunAv(y,r):
    Nr = int(r)
    Ntot = y.shape[0]
    y_av = np.convolve(y,np.ones(Nr)/r,'same')
    for i in range(0,int(r/2)):
        y_av[i] = sum(y[i:(Nr+i)])/r
        y_av[Ntot-i-1] = sum(y[(Ntot-i-Nr):(Ntot-i)])/r

    return y_av

def serSmooth(y,beta,r):
    """ kaiser window smoothing """
    Nr = int(r)
    Nr2 = int(r/2)
    s = np.r_[y[Nr-1:0:-1],y,y[-1:-Nr:-1]]
    w = np.kaiser(Nr,beta)
    y = np.convolve(w/w.sum(),s,mode='valid')
    return y[Nr2:y.shape[0]-Nr2]

def serKalman(y,R):
    ##R = 0.01**2
    sz = (y.shape[0],) # size of array
    z = np.array(y) # observations (normal about x, sigma=0.1)
    Q = 1e-5 # process variance
    xhat=np.zeros(sz)      # a posteri estimate of x
    P=np.zeros(sz)         # a posteri error estimate
    xhatminus=np.zeros(sz) # a priori estimate of x
    Pminus=np.zeros(sz)    # a priori error estimate
    K=np.zeros(sz)         # gain or blending factor
    # intial guesses
    xhat[0] = y[0]
    P[0] = 1.0
    for k in range(1,nLin):
        # time update
        xhatminus[k] = xhat[k-1]
        Pminus[k] = P[k-1]+Q
        # measurement update
        K[k] = Pminus[k]/( Pminus[k]+R )
        xhat[k] = xhatminus[k]+K[k]*(z[k]-xhatminus[k])
        P[k] = (1-K[k])*Pminus[k]

    return z

from statsmodels.tsa.stattools import adfuller
def serTestStat(timeseries):
    #Determing rolling statistics
    rolmean = pd.rolling_mean(timeseries, window=12)
    rolstd = pd.rolling_std(timeseries, window=12)
    #Plot rolling statistics:
    orig = plt.plot(timeseries, color='blue',label='Original')
    mean = plt.plot(rolmean, color='red', label='Rolling Mean')
    std = plt.plot(rolstd, color='black', label = 'Rolling Std')
    plt.legend(loc='best')
    plt.title('Rolling Mean & Standard Deviation')
    plt.show(block=False)
    #Perform Dickey-Fuller test:
    print 'Results of Dickey-Fuller Test:'
    dftest = adfuller(timeseries, autolag='AIC')
    dfoutput = pd.Series(dftest[0:4], index=['Test Statistic','p-value','#Lags Used','Number of Observations Used'])
    for key,value in dftest[4].items():
        dfoutput['Critical Value (%s)'%key] = value
    print dfoutput

def getSeries(sData):
    baseUrl = "http://analisi.ad.mediamond.it/jsonp.php?"
    resq = requests.get(baseUrl+urllib.urlencode(sData))##,'callback':'?'}))
    ser = np.array(resq.json()['data']).astype(np.float)
    timeL = pd.DataFrame({'t':(np.array(resq.json()['data'])[:,0])/1000-3600})
    timeL = timeL.t.apply(lambda x: datetime.datetime.fromtimestamp(x))
    trainD = pd.DataFrame({'y':ser[:,1]/1000000},index=[timeL[0]+datetime.timedelta(x) for x in range(timeL.size)])
    trainD.index = [pd.datetime.strptime(str(x)[0:10],'%Y-%m-%d') for x in trainD.index]
    trainD['t'] = ser[:,0]/1000000000
    trainD.dropna(inplace=True)
    tempD = trainD.copy(deep=True)
    tempD['week'] = [x.isocalendar()[1] for x in tempD.index]
    sWeek = tempD.groupby(["week"]).sum()
    sWeek['count'] = tempD.groupby(["week"]).size()
    sWeek['y'] = sWeek['y']/sWeek['count']
    normY = sWeek['y'].max()
    sWeek['y'] = sWeek['y']/normY
    base = datetime.datetime.strptime("2017-01-01","%Y-%m-%d")
    nWeek = sWeek.shape[0]*7
    sWeek.index = [base + datetime.timedelta(days=x) for x in range(0,nWeek,7)]
    sWeek.t = [float(calendar.timegm(x.utctimetuple()))/1000000 for x in sWeek.index]
    sWeek['month'] = sWeek.index.month
    sMonth = sWeek.groupby(['month']).sum()
    sMonth['count'] = sWeek.groupby(['month']).size()
    sMonth['y'] = sMonth['y']/sMonth['count']
    normY = sMonth['y'].max()
    sMonth['y'] = sMonth['y']/normY
    sMonth.index = ['2017-%02d-01' % x for x in range(1,len(sMonth)+1)]
    sMonth.index = [datetime.datetime.strptime(x,"%Y-%m-%d") for x in sMonth.index]
    sMonth.t = [float(calendar.timegm(x.utctimetuple()))/1000000 for x in sMonth.index]
    trainD['roll'] = serSmooth(trainD['y'],4,11)
    trainD['e_av'] = pd.ewma(trainD['y'],halflife=14)
    #trainD['e_av'] = pd.Series.ewm(trainD['y'],halflife=14)
    trainD['dev'] = trainD['y'] - trainD['y'].shift()
    trainD['diff'] = trainD['y'] - trainD['e_av']
    trainD['stat'] = trainD['dev']
    return trainD, sWeek, sMonth

def getStartParam(sData):
    baseUrl = "http://analisi.ad.mediamond.it/jsonp.php?"
    resq = requests.get(baseUrl+urllib.urlencode(sData))##,'callback':'?'}))
    x0 = resq.json()['data']
    return x0
##    return [x[1] for x in x0]

def plotSer(sDay,testD,nr):
    plt.plot(sDay.t,sDay.y,'-k',label='series')
    plt.plot(sDay.t,sDay.stat,label='stat')
    plt.plot(testD.t,testD.pred,label='prediction')
    plt.plot(testD.t,testD['hist'],label='history')
    plt.plot(testD.t,testD['trend'],label='trend')
    plt.plot(testD.t,testD['lsq'],label='lsq')
    plt.plot(sDay.t,sDay['resid'],label='residual')
    plt.xlabel('$t$')
    plt.ylabel('$y$')
    plt.title("time series interpolation " + nr)
    plt.legend()
    plt.show()

##from scipy.optimize import least_squares
import statsmodels.formula.api as smf
from scipy.optimize import leastsq as least_squares

def getHistory(sDay,nAhead,x0,hWeek):
    nLin = sDay.shape[0] + nAhead
    nFit = sDay.shape[0] if int(x0['obs_time']) <= 14 else int(x0['obs_time'])
    sDay['hist'] = sp.interpolate.interp1d(hWeek.t,hWeek.y,kind="cubic")(sDay['t'])
    histNorm = sDay['hist'].mean()
    sDay['hist'] = ( (sDay['hist']-sDay['hist'].min())/(sDay['hist'].max()-sDay['hist'].min()) + 1.)*x0['hist_adj']
    lmFor = 'e_av ~ 1 + t + I(t**2) + I(t**3) + I(t**4) + I(t**5)'
    lm = smf.ols(formula=lmFor,data=sDay.tail(nFit)).fit()
    sDay['stat'] = (sDay['y']*sDay['hist']-lm.predict(sDay))
    t_test = np.linspace(sDay['t'][0],sDay['t'][sDay.shape[0]-1]+sDay.t[nAhead]-sDay.t[0],nLin)
    testD = pd.DataFrame({'t':t_test},index=[sDay.index[0]+datetime.timedelta(days=x) for x in range(nLin)])
    testD['y'] = sDay.y
    testD['hist'] = sp.interpolate.interp1d(hWeek.t,hWeek.y,kind="cubic")(testD['t'])
    testD['hist'] = ( (testD['hist']-testD['hist'].min())/(testD['hist'].max()-testD['hist'].min()) + 1.)*x0['hist_adj']

    testD['hist'] = testD['hist']/histNorm*sDay.shape[0]/testD.shape[0]
    testD['trend'] = lm.predict(testD)
    testD['pred'] = 0
    return testD, lm


def serLsq(sDay,nAhead,x0,hWeek):
    nFit = sDay.shape[0] if int(x0['obs_time']) <= 14 else int(x0['obs_time'])
    testD, lm = getHistory(sDay,nAhead,x0,hWeek)
    testD = testD.tail(nFit+nAhead)
    freqP = x0['freq']
    def fun(x,t):#print 2.*np.pi/(sDay.t[7]-sDay.t[0])
        return x[0] + x[1] * np.sin(freqP[0]*t + x[2])*(1 + x[3]*np.sin(freqP[1]*t + x[4]))    ##confInt = stats.t.interval(0.95,len(y)-1,loc=np.mean(y),scale=stats.sem(y))
    def fun_min(x,t,y):
        return fun(x,t) - y
    res_lsq = least_squares(fun_min,x0['lsq'],args=(sDay.t,sDay.stat))#loss='soft_l1',f_scale=0.1,
    x0['lsq'] = [x for x in res_lsq[0]]
    testD['lsq'] = fun(res_lsq[0],testD.t) # fun(res_robust.x,t_test)
    sDay['resid'] = sDay['y'] - fun(res_lsq[0],sDay.t)/x0['hist_adj'] - lm.predict(sDay)
    rSquare = (sDay['resid'].tail(x0['res'][0]) - sDay['resid'].tail(x0['res'][0]).mean())**2
    x0['res'][1] = rSquare.sum()
    x0['res'][2] = rSquare.sum()/sDay['y'].tail(x0['res'][0]).sum()
    testD['pred'] = (testD['lsq']/(x0['hist_adj']*testD['hist']) + lm.predict(testD))
    testD = testD.drop(testD.index[0])
    return testD, x0

import statsmodels.api as sm
import statsmodels.tsa as tsa
import scipy.optimize as sco
def bestArima(sDay,nAhead,x0,hWeek):
    dta = sDay['y']
    dta.index = [pd.datetime.strptime(str(x)[0:10],'%Y-%m-%d') for x in dta.index]
    t_line = [float(calendar.timegm(x.utctimetuple()))/1000000 for x in dta.index]
    t_line1 = [float(calendar.timegm(x.utctimetuple()))/1000000 for x in hWeek.index]
    sExog = pd.DataFrame({'y':sp.interpolate.interp1d(t_line1,hWeek.y,kind="cubic")(t_line)})
    grid = (slice(1, 4, 1),slice(1,2,1),slice(1, 3, 1))
    def objfunc(order,endog,exog):
        fit = sm.tsa.ARIMA(endog,order).fit(trend="c",method='css-mle',exog=exog)
        return fit.aic
    par = sco.brute(objfunc,grid,args=(dta,sExog), finish=None)
    return par

def serArma(sDay,nAhead,x0,hWeek):
    testD, lm = getHistory(sDay,nAhead,x0,hWeek)
    dta = sDay['y']
    dta.index = [pd.datetime.strptime(str(x)[0:10],'%Y-%m-%d') for x in dta.index]
    sDay.index = dta.index
    t_line = [float(calendar.timegm(x.utctimetuple()))/1000000 for x in dta.index]
    t_line1 = [float(calendar.timegm(x.utctimetuple()))/1000000 for x in hWeek.index]
    sExog = pd.DataFrame({'y':sp.interpolate.interp1d(t_line1,hWeek.y,kind="cubic")(t_line)})
    #par = bestArima(dta,sExog)
    sExog.index = dta.index
    result = sm.tsa.ARIMA(dta,(x0['arma'][0],x0['arma'][1],x0['arma'][2])).fit(trend="c",method='css-mle',exog=sExog)
    predT = [str(dta.index[0])[0:10],str(dta.index[len(dta)-1])[0:10]]
    histS = pd.DataFrame({'pred':result.predict(start=predT[0],end=predT[1])})
    predT = [str(dta.index[0])[0:10],str(dta.index[len(dta)-1]+datetime.timedelta(days=nAhead))[0:10]]    
    predS = pd.DataFrame({'pred':result.predict(start=predT[0],end=predT[1])})
    predS.index = [dta.index[0]+datetime.timedelta(days=x) for x in range(0,len(dta)+nAhead)]
    predS['t'] = [float(calendar.timegm(x.utctimetuple()))/1000000 for x in predS.index]
    predS['hist'] = sp.interpolate.interp1d(t_line1,hWeek.y,kind="cubic")(predS['t'])
    predS['hist'] = predS['hist']/predS['hist'].mean()
    predS['pred'] = predS['pred']*predS['hist']*x0['hist_adj']
    predS['trend'] = lm.predict(predS)
    predS['y'] = sDay['y']
    predS['lsq'] = 0
    ##predS['pred'] = (predS['pred']*predS['hist']+predS['trend'])
    x0['response'] = [x for x in result.params]
    sDay['resid'] = sDay['y'] - predS['pred'][0:sDay.shape[0]]
    rSquare = (sDay['resid'].tail(x0['res'][0]) - sDay['resid'].tail(x0['res'][0]).mean())**2
    x0['res'][1:2] = [rSquare.sum(),rSquare.sum()/sDay['y'].tail(x0['res'][0]).sum()]
    return predS, x0
    # plt.plot(dta,'-k',label="series")
    # plt.plot(sExog,label="exo")
    # plt.plot(hWeek.y,label="hist")
    # plt.plot(predS,'-b',label="pred")
    # plt.legend()
    # plt.show()
    # steps = 1
    # tsa.arima_model._arma_predict_out_of_sample(res.params,steps,res.resid,res.k_ar,res.k_ma,res.k_trend,res.k_exog,endog=dta, exog=None, start=len(dta))

import pydlm    
def SerBayes(sDay,nAhead,x0,hWeek):
    dta = sDay['y']
    dta.index = [pd.datetime.strptime(str(x)[0:10],'%Y-%m-%d') for x in dta.index]
    t_line = [float(calendar.timegm(x.utctimetuple()))/1000000 for x in dta.index]
    dta.index = t_line
    model = pydlm.dlm(dta)
    model = model + pydlm.trend(degree=1,discount=0.98,name='a',w=10.0)
    model = model + pydlm.dynamic(features=[[v] for v in t_line],discount=1,name='b',w=10.0)
    model = model + pydlm.autoReg(degree=3,data=dta.values,name='ar3',w=1.0)
    allStates = model.getLatentState(filterType='forwardFilter')
    model.evolveMode('independent')
    model.noisePrior(2.0)
    model.fit()
    model.plot()
    model.turnOff('predict')
    model.plotCoef(name='a')
    model.plotCoef(name='b')
    model.plotCoef(name='ar3')

import algo_holtwinters as ht
def serHolt(sDay,nAhead,x0,hWeek):
    Y = [x for x in sDay.y]
    ##Yht, alpha, beta, gamma, rmse = ht.additive([x for x in sDay.y],int(x0[0]),nAhead,x0[1],x0[2],x0[3])
    nAv = int(x0['holt'][0]) if int(x0['holt'][0]) > 1 else 5
    Yht, alpha, beta, gamma, rmse = ht.additive([x for x in sDay.y],x0['holt'][0],nAhead,x0['holt'][1],x0['holt'][2],x0['holt'][3])
    sDay['resid'] = sDay['y'] - Yht[0:sDay.shape[0]]
    x0['holt'] = [x0['holt'][0],alpha,beta,gamma,rmse]
    nLin = sDay.shape[0] + nAhead
    t_test = np.linspace(sDay['t'][0],sDay['t'][sDay.shape[0]-1]+sDay.t[nAhead]-sDay.t[0],nLin)
    predS = pd.DataFrame({'t':t_test},index=[sDay.index[0]+datetime.timedelta(days=x) for x in range(nLin)])
    predS['pred'] = Yht
    predS['hist'] = sp.interpolate.interp1d(hWeek.t,hWeek.y,kind="cubic")(predS['t'])
    predS['hist'] = predS['hist']/predS['hist'].mean()
    predS['pred'] = predS['pred']*predS['hist']*x0['hist_adj']
    lmFor = 'e_av ~ 1 + t + I(t**2) + I(t**3) + I(t**4) + I(t**5)'
    lm = smf.ols(formula=lmFor,data=sDay).fit()
    predS['trend'] = lm.predict(predS)
    predS['lsq'] = 0
    predS['y'] = sDay['y']
    sDay['resid'] = sDay['y'] - predS['pred'][0:sDay.shape[0]]
    rSquare = (sDay['resid'].tail(x0['res'][0]) - sDay['resid'].tail(x0['res'][0]).mean())**2
    x0['res'][1] = rSquare.sum()
    x0['res'][2] = rSquare.sum()/sDay['y'].tail(x0['res'][0]).sum()
    return predS, x0
    
from scipy.optimize import curve_fit
def serAuto(sDay,nAhead,x0,hWeek):
    testD, lm = getHistory(sDay,nAhead,x0,hWeek)
    todayD = datetime.datetime.today()
    todayD = todayD.replace(hour=0,minute=0,second=0,microsecond=0)
    dta = pd.DataFrame({'y':sDay.y})
    dta['day'] = sDay.index.weekday
    phase = dta.head(int(x0['obs_time'])).groupby(['day']).mean()
    phase['std'] = dta.groupby(['day']).std()['y']
    phase = phase.sort_values(['y'],ascending=False)
    phase['csum'] = phase['y'].cumsum()/phase['y'].sum()
    phaseN = phase.index[0] - todayD.weekday()
    r,q,p = sm.tsa.acf(sDay['y'].tail(phaseN+int(x0['obs_time'])).squeeze(),qstat=True)
    def fit_fun(x,decay):
        return np.exp(-decay*x)
    popt, pcov = curve_fit(fit_fun,np.array(range(0,6)),r[0:6]-min(r),p0=(x0['decay'][0]))
    X = np.array(range(0,r.size,7))
    popt1, pcov1 = curve_fit(fit_fun,X,r[X],p0=(x0['decay'][0]))
    autD = pd.DataFrame({'r':r,'exp':fit_fun(range(0,r.size),popt),'exp1':fit_fun(range(0,r.size),popt1)})    
    x0['decay'] = [x for x in popt]
    # testD = pd.DataFrame(index=[todayD + datetime.timedelta(days=x) for x in range(-sDay.shape[0],nAhead)])
    # testD['t'] = [float(calendar.timegm(x.utctimetuple()))/1000000. for x in testD.index]
    # testD['hist'] = sp.interpolate.interp1d(hWeek.t,hWeek.y,kind="cubic")(testD['t'])
    # testD['pred'] = 0
    # testD['trend'] = lm.predict(testD)
    wN = 0
    sY = np.random.normal(phase['y'].head(1),dta.y.std())
    for i in testD.index:
        wN = 6 - np.abs(phase.index[0] - i.weekday())
        wN = wN + 1 if wN < 6 else 0
        if(wN == 0):
            sY = np.random.normal(phase['y'].head(1),dta.y.std()/2)
        sY = sY*(1+testD['hist'][i]*x0['hist_adj'])
        testD.loc[i,'pred'] = sY*fit_fun(float(wN),popt)

    # testD['pred1'] = testD['pred']
    testD['pred'] = serSmooth(testD['pred'],16,5)
    sDay['resid'] = sDay['y'] - testD['pred'][0:sDay.shape[0]]
    # sDay['resid1'] = sDay['resid']
    freqP = x0['freq']
    def fun(x,t):
        return x[0] + x[1] * np.sin(freqP[0]*t + x[2])*(1 + x[3]*np.sin(freqP[1]*t + x[4]))    
    def fun_min(x,t,y):
        return fun(x,t) - y
    res_lsq = least_squares(fun_min,x0['lsq'],args=(sDay['t'],sDay['resid']))
    testD['lsq'] = fun(res_lsq[0],testD['t']) # fun(res_robust.x,t_test)
    x0['lsq'][0:res_lsq[0].size] = res_lsq[0]
    testD['pred2'] = testD['pred']
    testD['pred'] = testD['pred'] + testD['lsq']
    sDay['resid'] = sDay['y'] - testD['pred'][0:sDay.shape[0]]    
    rSquare = (sDay['resid'].tail(x0['res'][0]) - sDay['resid'].tail(x0['res'][0]).mean())**2
    x0['res'][1] = rSquare.sum()
    x0['res'][2] = rSquare.sum()/sDay['y'].tail(x0['res'][0]).sum()
    # sDay.to_csv('tmpAuto1.csv')
    # testD.to_csv('tmpAuto2.csv')
    # autD.to_csv('tmpAuto3.csv')
    return testD, x0
    

from pyneurgen.neuralnet import NeuralNet
from pyneurgen.nodes import BiasNode, Connection
from pyneurgen.recurrent import NARXRecurrent
def serNeural(sDay,nAhead,x0,hWeek):
    nLin = sDay.shape[0] + nAhead
    nFit = sDay.shape[0] if int(x0['obs_time']) <= 14 else int(x0['obs_time'])
    testD = getHistory(sDay,nAhead,x0,hWeek)
    weekS = [x.isocalendar()[1] for x in sDay.index]
    population = [[float(i),sDay['y'][i],float(i%7),weekS[i]] for i in range(sDay.shape[0])]
    all_inputs = []
    all_targets = []
    factorY = sDay['y'].mean()
    factorT = 1.0 / float(len(population))*factorY
    factorD = 1./7.*factorY
    factorW = 1./52.*factorY
    factorS = 4.*sDay['y'].std()
    factorH = factorY/sDay['hist'].mean()

    def population_gen(population):
        pop_sort = [item for item in population]
#        random.shuffle(pop_sort)
        for item in pop_sort:
            yield item
            
    for t,y,y1,y2 in population_gen(population):
        #all_inputs.append([t*factorT,(.5-random.random())*factorS+factorY,y1*factorD,y2*factorW])
        all_inputs.append([y1*factorD,(.5-random.random())*factorS+factorY,y2*factorW])
        all_targets.append([y])

    if False:
        plt.plot([x[0] for x in all_inputs],'-',label='targets0')
        plt.plot([x[1] for x in all_inputs],'-',label='targets1')
        plt.plot([x[2] for x in all_inputs],'-',label='targets2')
        # plt.plot([x[3] for x in all_inputs],'-',label='targets3')
        plt.plot([x[0] for x in all_targets],'-',label='actuals')
        plt.legend(loc='lower left', numpoints=1)
        plt.show()

    net = NeuralNet()
    net.init_layers(3,[10],1,NARXRecurrent(3,.6,2,.4))
    net.randomize_network()
    net.set_random_constraint(.5)
    net.set_learnrate(.1)
    net.set_all_inputs(all_inputs)
    net.set_all_targets(all_targets)
    #testD['pred'] = [item[0][0] for item in net.test_targets_activations]
    length = len(all_inputs)
    learn_end_point = int(length * .8)
    # random.sample(all_inputs,10)
    net.set_learn_range(0, learn_end_point)
    net.set_test_range(learn_end_point + 1, length - 1)
    net.layers[1].set_activation_type('tanh')

    net.learn(epochs=125,show_epoch_results=True,random_testing=False)
    mse = net.test()
    #net.save(os.environ['LAV_DIR'] + "/out/train/net.txt")

    test_positions = [item[0][0] for item in net.get_test_data()]
    all_targets1 = [item[0][0] for item in net.test_targets_activations]
    all_actuals = [item[1][0] for item in net.test_targets_activations]
    #   This is quick and dirty, but it will show the results
    plt.subplot(3, 1, 1)
    plt.plot([i for i in sDay['y']],'-')
    plt.title("Population")
    plt.grid(True)
    
    plt.subplot(3, 1, 2)
    plt.plot(test_positions, all_targets1, 'b-', label='targets')
    plt.plot(test_positions, all_actuals, 'r-', label='actuals')
    plt.grid(True)
    plt.legend(loc='lower left', numpoints=1)
    plt.title("Test Target Points vs Actual Points")

    plt.subplot(3, 1, 3)
    plt.plot(range(1, len(net.accum_mse) + 1, 1), net.accum_mse)
    plt.xlabel('epochs')
    plt.ylabel('mean squared error')
    plt.grid(True)
    plt.title("Mean Squared Error by Epoch")
    plt.show()

def corS(x,y):
    x1,x2,y1,y2,xy = (0,)*5
    N = x.shape[0]
    xM,yM = x.mean(),y.mean()
    for i in range(N):
        xy += (x[i]-xM)*(y[i]-yM)
        x2 += (x[i]-xM)**2
        y2 += (y[i]-yM)**2
    return (xy)/np.sqrt(x2*y2)

def corM(M):
    colL = [x for x in M.columns]
    N = len(colL)
    cM = np.zeros((N,N))
    for i in range(N):
        cM[i,i] = 1.;
        for j in range(i+1,N):
            cM[i,j] = corS(webH[colL[i]],webH[colL[j]])
            cM[j,i] = corS(webH[colL[i]],webH[colL[j]])
    return cM

def autCorM(M):
    colL = [x for x in M.columns]
    acM = pd.DataFrame()
    for i in colL:
        r,q,p = sm.tsa.acf(M[i],qstat=True)
        acM[i] = r
    return acM

def pautCorM(M):
    colL = [x for x in M.columns]
    acM = pd.DataFrame()
    for i in colL:
        r = tsa.stattools.pacf(M[i],nlags=20,method='ols')
        acM[i] = r
    return acM

def xcorM(M,L):
    colL = [x for x in M.columns]
    acM = pd.DataFrame()
    for i in colL:
        r = np.correlate(M[i],L[i],"full")
        acM[i] = r
    return acM

def decayM(M):
    colL = [x for x in M.columns]
    acM = pd.DataFrame()
    def fit_fun(x,decay):
        return np.exp(-decay*x)
    for i in colL:
        r = M[i]
        X = np.array(range(0,r.size,7))
        popt, pcov = curve_fit(fit_fun,np.array(range(0,6)),r[0:6]-min(r),p0=(1))
        popt1, pcov1 = curve_fit(fit_fun,np.array(range(0,r.size,7)),r[X],p0=(1))
        acM[i] = np.array([popt[0],pcov[0][0],popt1[0],pcov1[0][0]])
    return acM

def gaussM(M):
    colL = [x for x in M.columns]
    acM = pd.DataFrame()
    def fun(x,t):
        return x[2]*np.exp(-pow((t-x[0]),2)*x[1])
    def fun_min(x,t,y):
        return fun(x,t) - y
    x0 = [float(M.shape[0]/2),1.,1.]
    for i in colL:
        t = [float(x) for x in M.index]
        y = [x for x in M[i]]
        res_lsq = least_squares(fun_min,x0,args=(t,y))
        y = [fun(res_lsq[0],x) for x in t]
        acM[i] = y#res_lsq[0]
        x0 = res_lsq[0]
    return acM

    
def matNN(M):
    #in progress
    colL = [x for x in M.columns]
    N = len(colL)
    Niter = 100
    for i in range(Niter):
        col1 = int(random.random()*N)
        col2 = int(random.random()*N)
        if(col1==col2):
            next
        colD = col1 - col2
        cM = M
    for i in range(N):
        i1 = i+1 if i<N else 0
        i2 = i-1 if i>0 else N
        for j in range(i+1,N):
            j1 = j+1 if j<N else 0
            j2 = j-1 if j>0 else N
            cM[i,j] = corS(webH[colL[i]],webH[colL[j]])
            cM[j,i] = corS(webH[colL[i]],webH[colL[j]])
    return cM
    
