#!/usr/bin/env python
# -*- coding: utf-8 -*-
# @Time    : 2019/6/18 20:10
# @Author  : Poet Yin
# @Email   : poet@poetyin.com
# @Site    : 
# @File    : RF_result-to-CSV.py
# @Software: PyCharm
import pandas as pd
import numpy as np
import csv
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn import metrics
df = pd.read_csv("dodata_303.csv")

x, y = df.iloc[:, 1:].values, df.iloc[:, 0].values
x_train, x_test, y_train, y_test = train_test_split(x, y, test_size = 0.3, random_state = 0)
feat_labels = df.columns[1:]
forest = RandomForestClassifier(n_estimators=529,min_samples_split=88,max_depth=5,oob_score=True,random_state=0, n_jobs=-1)
forest.fit(x_train, y_train)

importances = forest.feature_importances_
indices = np.argsort(importances)[::-1]
with open("RFr.csv", "w", encoding='utf-8') as csvfile:
    writer = csv.writer(csvfile)
for f in range(x_train.shape[1]):
    tup_d=(feat_labels[indices[f]],str(importances[indices[f]]))
    lis = list(tup_d)
    with open("RFr.csv", "a+",encoding='utf-8') as csvfile:
        csv_write = csv.writer(csvfile)
        csv_write.writerow(lis)
print('\n')
print (forest.oob_score_)
y_predprob = forest.predict_proba(x_train)[:,1]
print ("AUC Score (Train): %f" % metrics.roc_auc_score(y_train, y_predprob))
print("RF training set score: %f" % forest.score(x_train, y_train))
print("RF test set score: %f" % forest.score(x_test, y_test))








