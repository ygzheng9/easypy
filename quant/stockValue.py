# -*- coding:utf-8 -*-
import numpy as np
import pandas as pd
from datetime import datetime
import matplotlib.pylab as plt


# 读取数据，pd.read_csv默认生成DataFrame对象，需将其转换成Series对象
df = pd.read_csv('test.csv', encoding='utf-8', header=None, index_col=0)

df.index = pd.to_datetime(df.index)  # 将字符串索引转换成时间索引

# print(df[1])

balance = df[[1,2]]

plt.figure()

plt.plot(balance)

plt.show()
