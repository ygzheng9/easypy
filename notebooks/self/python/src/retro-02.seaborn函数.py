import seaborn as sns  # 添加Seaborn模块
import numpy as np
# import matplotlib as mpl
import matplotlib.pyplot as plt

# 添加了Seaborn模块

np.random.seed(sum(map(ord, "aesthetics")))
# 首先定义一个函数用来画正弦函数，可帮助了解可以控制的不同风格参数


def sinplot(flip=1):
    x = np.linspace(0, 14, 100)
    for i in range(1, 7):
        plt.plot(x, np.sin(x+i*0.5)*(7-i)*flip)


'''
Seaborn有5种预定义的主题：
darkgrid（灰色背景+白网格）
whitegrid（白色背景+黑网格）
dark（仅灰色背景）
white（仅白色背景）
ticks（坐标轴带刻度）
默认的主题是darkgrid，修改主题可以使用set_style函数
'''
sns.set_style("whitegrid")

# 转换成Seaborn模块，只需要引入seaborn模块
sinplot()
plt.show()



