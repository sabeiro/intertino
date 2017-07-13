#%pylab inline
import os
import gzip
import sys
import numpy as np
import pandas as pd
import scipy as sp
import random
import matplotlib.pyplot as plt

seed = 128
rng = np.random.RandomState(seed)
dSet_x = pd.read_csv(os.environ['LAV_DIR']+"/log/socio_x.csv.gz",compression='gzip',sep=',',quotechar='"',index_col=0)
dSet_x.fillna(0,inplace=True)
dSet_y = pd.read_csv(os.environ['LAV_DIR']+"/log/socio_y.csv.gz",compression='gzip',sep=',', quotechar='"')
dSet_y = dSet_y.ix[:,[1]]
dSet_y = pd.get_dummies(dSet_y)
dSet_y = dSet_y.ix[:,[0]]##M
# dSet_y.loc[dSet_y['gender'] == 'M',['gender']] = 1
# dSet_y.loc[dSet_y['gender'] == 'F',['gender']] = 0

N = dSet_y.shape[0]
shuffleL = random.sample(range(N),N)
partS = [0,int(N*.9),N]
y_train = np.asarray(dSet_y.iloc[shuffleL[partS[0]:partS[1]]],dtype=np.int32)
y_test = np.asarray(dSet_y.iloc[shuffleL[partS[1]:partS[2]]],dtype=np.int32)
x_train = np.asarray(dSet_x.iloc[shuffleL[partS[0]:partS[1]]],dtype=np.int32)
x_test = np.asarray(dSet_x.iloc[shuffleL[partS[1]:partS[2]]],dtype=np.int32)
joblib.dump(x_test,os.environ['LAV_DIR']+"/train/"+'x_test'+'.pkl',compress=1)
joblib.dump(y_test,os.environ['LAV_DIR']+"/train/"+'y_test'+'.pkl',compress=1)


from sklearn.externals import joblib

from sklearn.ensemble import RandomForestRegressor
from sklearn.ensemble import RandomForestClassifier
print 'forest entropy'
rf = RandomForestClassifier(n_estimators=100,criterion='entropy',max_features='sqrt',max_depth=5,bootstrap=True,oob_score=True,n_jobs=12,random_state=33)
model = rf.fit(x_train,y_train.ravel())
joblib.dump(model,os.environ['LAV_DIR']+"/train/"+'lookAlike'+str(0)+'.pkl',compress=1)
print 'forest gini'
rf = RandomForestClassifier(n_estimators=100,criterion='gini',n_jobs=12,max_depth=None,max_features='auto',min_samples_split=2,random_state=None)
model = rf.fit(x_train,y_train.ravel())
joblib.dump(model,os.environ['LAV_DIR']+"/train/"+'lookAlike'+str(1)+'.pkl',compress=1)

from sklearn.tree import DecisionTreeRegressor
import sklearn.tree as skt
print 'dec tree'
clf_gini = skt.DecisionTreeClassifier(criterion="gini",random_state=100,max_depth=10,min_samples_leaf=5)
model = clf_gini.fit(x_train,y_train)
joblib.dump(model,os.environ['LAV_DIR']+"/train/"+'lookAlike'+str(2)+'.pkl',compress=1)

from sklearn.dummy import DummyClassifier
clf = DummyClassifier(strategy='most_frequent', random_state=0)
model = clf.fit(x_train,y_train.ravel())
joblib.dump(model,os.environ['LAV_DIR']+"/train/"+'lookAlike'+str(3)+'.pkl',compress=1)

# from sklearn import svm
# print 'svm svc'
# clf = svm.SVC(C=1.0,cache_size=200,class_weight=None,coef0=0.0,decision_function_shape=None,degree=3,gamma='auto',kernel='rbf',max_iter=-1,probability=True,random_state=0,shrinking=True,tol=0.001,verbose=False)
# model = clf.fit(x_train,y_train.ravel())
# joblib.dump(model,os.environ['LAV_DIR']+"/train/"+'lookAlike'+str(4)+'.pkl',compress=1)
# print 'svm svr'
# clf = svm.SVR(kernel='rbf', degree=3, gamma='auto', coef0=0.0, tol=0.001, C=1.0, epsilon=0.1, shrinking=True, cache_size=200, verbose=False, max_iter=-1)[source]
# model = clf.fit(x_train,y_train.ravel())
# joblib.dump(model,os.environ['LAV_DIR']+"/train/"+'lookAlike'+str(5)+'.pkl',compress=1)

##skm.cross_val_score(clf,x_train,y_train,scoring='neg_log_loss')
##print "Confusion matrix " , skm.confusion_matrix(y_test,model.predict(x_test))


from sklearn.metrics import fbeta_score, make_scorer
ftwo_scorer = make_scorer(fbeta_score,beta=2)
from sklearn.model_selection import GridSearchCV
from sklearn.svm import LinearSVC
grid = GridSearchCV(LinearSVC(),param_grid={'C':[1,10]},scoring=ftwo_scorer)
def my_custom_loss_func(ground_truth,predictions):
    diff = np.abs(ground_truth - predictions).max()
    return np.log(1 + diff)
loss  = make_scorer(my_custom_loss_func,greater_is_better=False)
score = make_scorer(my_custom_loss_func,greater_is_better=True)
print loss(model,x_train,y_train.ravel())
print score(model,x_train,y_train.ravel())

