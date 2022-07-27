#!/usr/bin/env python
# -*- coding: utf-8 -*-
# @Time    : 2019/6/18 22:20
# @Author  : Poet Yin
# @Email   : poet@poetyin.com
# @Site    : 
# @File    : GBDT参数调优.py
# @Software: PyCharm
import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.ensemble import GradientBoostingClassifier
from sklearn.model_selection import GridSearchCV
from sklearn import metrics
df = pd.read_csv("dodata_GBDT.csv")

x, y = df.iloc[:, 1:].values, df.iloc[:, 0].values
x_train, x_test, y_train, y_test = train_test_split(x, y, test_size = 0.3, random_state = 0)

feat_labels = df.columns[1:]

gbr= GradientBoostingClassifier(random_state=10)
gbr.fit(x_train, y_train)
y_pred= gbr.predict(x_train)
y_predprob= gbr.predict_proba(x_train)[:,1]
print("Accuracy : %.4g" % metrics.accuracy_score(y_train, y_pred))
print("AUC Score (Train): %f" % metrics.roc_auc_score(y_train, y_predprob))


param_test1= {'n_estimators':list(range(20,81,10))}
gsearch1= GridSearchCV(estimator = GradientBoostingClassifier(learning_rate=0.1,min_samples_split=300,min_samples_leaf=20,max_depth=8,max_features='sqrt',subsample=0.8,random_state=10), param_grid= param_test1, scoring='roc_auc',iid=False,cv=5)
gsearch1.fit(x_train, y_train)
print(gsearch1.best_params_, gsearch1.best_score_)