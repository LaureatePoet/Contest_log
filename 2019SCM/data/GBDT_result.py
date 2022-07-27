#!/usr/bin/env python
# -*- coding: utf-8 -*-
# @Time    : 2019/6/18 20:53
# @Author  : Poet Yin
# @Email   : poet@poetyin.com
# @Site    : 
# @File    : GBDT_result.py
# @Software: PyCharm
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.ensemble import GradientBoostingClassifier
from sklearn import metrics
from sklearn.externals import joblib
df = pd.read_csv("dodata_GBDT.csv")

x, y = df.iloc[:, 1:].values, df.iloc[:, 0].values
x_train, x_test, y_train, y_test = train_test_split(x, y, test_size = 0.3, random_state = 0)
feat_labels = df.columns[1:]
# 模型训练，使用GBDT算法
gbr = GradientBoostingClassifier(n_estimators=100, max_depth=3,
                min_samples_split=2,learning_rate=0.1,subsample=1)
gbr.fit(x_train, y_train.ravel())
joblib.dump(gbr, 'GBDT_train_model.m')   # 保存模型

y_gbr = gbr.predict(x_train)
y_gbr1 = gbr.predict(x_test)
y_predprob= gbr.predict_proba(x_train)[:,1]
acc_train = gbr.score(x_train, y_train)
acc_test = gbr.score(x_test, y_test)
print(acc_train)
print(acc_test)

print("Accuracy : %.4g" % metrics.accuracy_score(y_train, y_gbr))
print("AUC Score (Train): %f" % metrics.roc_auc_score(y_train, y_predprob))
