#!/usr/bin/env python
# -*- coding: utf-8 -*-
# @Time    : 2019/6/19 0:08
# @Author  : Poet Yin
# @Email   : poet@poetyin.com
# @Site    : 
# @File    : GBDT_predict.py
# @Software: PyCharm
import numpy as np
import pandas as pd
from sklearn.externals import joblib
import csv

gbr = joblib.load('GBDT_train_model.m')    # 加载模型
test_data = pd.read_csv("dodata_GBDT.csv")
testx_columns = []
for xx in test_data.columns:
    if xx not in ['12.您的运动类 APP 使用经历是:  *']:
        testx_columns.append(xx)
test_x = test_data[testx_columns]
test_y = gbr.predict(test_x)
test_y = np.reshape(test_y, (303, 1))
with open("predict.csv", "w", encoding='utf-8') as csvfile:
    writer = csv.writer(csvfile)
with open("predict.csv", "a+",encoding='utf-8') as csvfile:
    csv_write = csv.writer(csvfile)
    csv_write.writerow(list(test_y))