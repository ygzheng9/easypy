import numpy as np
import matplotlib.pyplot as plt


def run():
    # 状态变迁矩阵
    trans = np.array([[0.95, 0.04, 0, 0], [0.05, 0.85, 0, 0], [0, 0.10, 1, 0],
                      [0, 0.01, 0, 1]])

    result = []
    x = np.array([1, 0, 0, 0])
    result.append(x)
    for i in range(1, 201):
        # 迭代一次
        x = np.dot(trans, x)
        result.append(x)

    # 为画图准备数据
    t = []
    x1 = []
    x2 = []
    x3 = []
    x4 = []
    idx = 0
    for i in result:
        t.append(idx)
        idx += 1

        x1.append(i[0])
        x2.append(i[1])
        x3.append(i[2])
        x4.append(i[3])

    # 开始画图
    plt.figure()

    plt.plot(t, x1, label="A")
    plt.plot(t, x2, label="B")
    plt.plot(t, x3, label="C")
    plt.plot(t, x4, label="D")

    plt.ylabel('%')
    plt.xlabel('time')
    plt.legend(loc='best', frameon=False)
    plt.show()


run()