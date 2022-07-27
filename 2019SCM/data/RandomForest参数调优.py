#!/usr/bin/env python
# -*- coding: utf-8 -*-
# @Time    : 2019/6/16 20:23
# @Author  : Poet Yin
# @Email   : poet@poetyin.com
# @Site    : 
# @File    : RandomForst.py
# @Software: PyCharm
import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import GridSearchCV
from sklearn import metrics
df = pd.read_csv("dodata_303.csv")

x, y = df.iloc[:, 1:].values, df.iloc[:, 0].values
x_train, x_test, y_train, y_test = train_test_split(x, y, test_size = 0.3, random_state = 0)
feat_labels = df.columns[1:]
print(feat_labels)
forest = RandomForestClassifier(n_estimators=10000, oob_score=True,random_state=0, n_jobs=-1)
forest.fit(x_train, y_train)

importances = forest.feature_importances_
indices = np.argsort(importances)[::-1]
for f in range(x_train.shape[1]):
    print("%2d) %-*s %f" % (f + 1, 30, feat_labels[indices[f]], importances[indices[f]]))
print('\n')
print (forest.oob_score_)
y_predprob = forest.predict_proba(x_train)[:,1]
print ("AUC Score (Train): %f" % metrics.roc_auc_score(y_train, y_predprob))


'''
#调参数 n_estimators
param_test1 = {'n_estimators':range(525,535,1)}
gsearch1 = GridSearchCV(estimator = RandomForestClassifier(min_samples_split=100,
                                  min_samples_leaf=20,max_depth=8,max_features='sqrt' ,random_state=10),
                       param_grid = param_test1, scoring='roc_auc',cv=5)
gsearch1.fit(x_train,y_train)
print(gsearch1.return_train_score, gsearch1.best_params_, gsearch1.best_score_)
#结果 529


#调参数 max_depth min_samples_split
param_test2 = {'max_depth':range(1,8,1), 'min_samples_split':range(86,92,1)}
gsearch2 = GridSearchCV(estimator = RandomForestClassifier(n_estimators= 529,min_samples_leaf=1,
max_features='sqrt' ,oob_score=True, random_state=10),
   param_grid = param_test2, scoring='roc_auc',iid=False, cv=5)
gsearch2.fit(x_train,y_train)
print( gsearch2.best_params_, gsearch2.best_score_)


#调节参数 内部节点再划分所需最小样本数min_samples_split和叶子节点最少样本数min_samples_leaf

param_test3 = {'min_samples_split':range(86,93,1), 'min_samples_leaf':range(1,14,1)}
gsearch3 = GridSearchCV(estimator = RandomForestClassifier(n_estimators= 529,
   max_features='sqrt' ,oob_score=True, random_state=10),
   param_grid = param_test3, scoring='roc_auc',iid=False, cv=5)
gsearch3.fit(x_train,y_train)
print(gsearch3.best_params_, gsearch3.best_score_)

#调节参数 最大特征数max_features
param_test4 = {'max_features':range(1,30,2)}
gsearch4 = GridSearchCV(estimator = RandomForestClassifier(n_estimators= 529, max_depth=3, min_samples_split=108,
                                  min_samples_leaf=14 ,oob_score=True, random_state=10),
   param_grid = param_test4, scoring='roc_auc',iid=False, cv=5)
gsearch4.fit(x_train,y_train)
print(gsearch4.best_params_, gsearch4.best_score_)
# {'max_features': 1} 0.6573063973063973

'''