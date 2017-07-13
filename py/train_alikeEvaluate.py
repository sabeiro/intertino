import os
import gzip
import sys
import numpy as np
import pandas as pd
import scipy as sp
import random
import matplotlib.pyplot as plt
from sklearn.externals import joblib
from treeinterpreter import treeinterpreter as ti
import sklearn as sk
import sklearn.metrics as skm
import sklearn.tree as skt

x_test = joblib.load(os.environ['LAV_DIR']+"/train/"+'x_test'+'.pkl')
y_test = joblib.load(os.environ['LAV_DIR']+"/train/"+'y_test'+'.pkl')

model = dict()
for i in range(3):
    model[i] = joblib.load(os.environ['LAV_DIR']+"/train/"+'lookAlike'+str(i)+'.pkl')
   
mName = ["entro","gini ","dectr"]
plt.clf()
plt.plot([0, 1],[0, 1],'k--',label="model | auc  fsc  acc")
for i in range(len(model)):
    fpr, tpr, _ = skm.roc_curve(y_test,model[i].predict_proba(x_test)[:,1])
    roc_auc = skm.auc(fpr,tpr)
    ##auc = np.trapz(fpr,tpr)
    fsc = skm.f1_score(y_test,model[i].predict(x_test))
    acc = skm.accuracy_score(y_test,model[i].predict(x_test))
    plt.plot(fpr,tpr,label='%s | %0.2f %0.2f %0.2f ' % (mName[i],roc_auc,fsc,acc))
    
plt.xlim([0.0, 1.0])
plt.ylim([0.0, 1.0])
plt.xlabel('False Positive Rate')
plt.ylabel('True Positive Rate')
plt.title('Receiver operating characteristic')
plt.legend(loc="lower right",prop={'size':12,'family':'monospace'})
plt.show()
    
importances = pd.DataFrame({'feature':dSet_x.columns,'importance':np.round(rf.feature_importances_,3)})
importances = importances.sort_values('importance',ascending=False).set_index('feature')
print importances
importances.plot.bar()

y_prob = model[1].predict_proba(x_test)[:,1]
y_pred = np.asarray([x for x in y_prob],dtype=np.float32)
thMod = [x*0.05+0.5 for x in range(11)]
accL = []
for th in thMod:
    thSet = y_prob>=th 
    y_pred[thSet] = 1
    y_pred[thSet==False] = 0
    if thSet.sum() == 0 :
        continue
    accL.append([th,skm.accuracy_score(y_test,y_pred),skm.accuracy_score(y_test[thSet],y_pred[thSet]),float(2*thSet.sum())/y_test.shape[0]])

xnew = np.arange(.5,1.0,0.005) 
y_reach = sp.interpolate.interp1d([x[0] for x in accL],[x[3] for x in accL])(xnew)
f_reach_inv = sp.interpolate.interp1d([x[3] for x in accL],[x[0] for x in accL])(y_reach)
y_acc = sp.interpolate.interp1d([x[0] for x in accL],[x[2] for x in accL])(f_reach_inv)
plt.plot(y_reach,y_acc,'-k',label='acc1')
plt.xlabel('reach')
plt.ylabel('accuracy')
plt.title("male classification")
plt.legend()
plt.show()
