import numpy as np
import matplotlib.pyplot as plt


def force(t):
    if t >= 0 and t < 0.5:
        return 0.0

    if t >= 0.5 and t < 1.0:
        return 1.0

    if t >= 1.0 and t < 1.4:
        return -1.3

    if t >= 1.4:
        return 0.0


def run():
    A = np.array([[1, 0.01], [0, 0.99]])
    B = np.array([[0], [0.01]])

    x = np.array([0, 0])

    tm = []
    ft = []
    pt = []
    vt = []

    tm.append(0)
    ft.append(0)
    pt.append(0)
    vt.append(0)

    for i in range(0, 601):
        t = i / 100
        f = force(t)

        x = np.dot(A, x) + np.dot(B, f)

        tm.append(t)
        ft.append(f)
        pt.append(x[0][0])
        vt.append(x[1][0])

    # 开始画图
    plt.figure()

    plt.subplot(311)
    plt.plot(tm, ft, label="F(t)")
    plt.legend(loc='best', frameon=False)

    plt.subplot(312)
    plt.plot(tm, pt, label="P(t)")
    plt.legend(loc='best', frameon=False)

    plt.subplot(313)
    plt.plot(tm, vt, label="V(t)")

    plt.xlabel('time')
    plt.legend(loc='best', frameon=False)
    plt.show()


run()
