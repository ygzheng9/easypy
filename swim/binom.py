import numpy as np
from scipy import stats
import matplotlib.pyplot as plt


def binom_dis(n=1, p=0.1):
    """
    二项分布，模拟抛硬币试验
    :param n: 实验总次数
    :param p: 单次实验成功的概率
    :return: 试验成功的次数
    """
    binom_dis = stats.binom(n, p)
    simulation_result = binom_dis.rvs(size=5)  # 取5个符合该分布的随机变量
    print(simulation_result)  # [ 7 11 13  8 13], 每次结果会不一样
    prob_10 = binom_dis.pmf(10)
    print(prob_10)  # 0.117


# binom_dis(n=20, p=0.6)


def binom_pmf(n=1, p=0.1):
    """
     二项分布有两个参数
     https://docs.scipy.org/doc/scipy/reference/generated/scipy.stats.binom.html#scipy.stats.binom
     :param n:试验次数
     :param p:单次实验成功的概率
     :return:
     """
    binom_dis = stats.binom(n, p)
    x = np.arange(binom_dis.ppf(0.0001), binom_dis.ppf(0.9999))
    print(x)  # [ 0.  1.  2.  3.  4.]
    _, ax = plt.subplots(1, 1)
    ax.plot(x, binom_dis.pmf(x), 'bo', label='binom pmf')
    ax.vlines(x, 0, binom_dis.pmf(x), colors='b', lw=5, alpha=0.5)
    ax.legend(loc='best', frameon=False)
    plt.ylabel('Probability')
    plt.title('PMF of binomial distribution(n={}, p={})'.format(n, p))
    plt.show()


#binom_pmf(n=20, p=0.6)


def diff_chi2_dis():
    """
     不同参数下的卡方分布
     :return:
     """
    # chi2_dis_0_5 = stats.chi2(df=0.5)
    chi2_dis_1 = stats.chi2(df=1)
    chi2_dis_4 = stats.chi2(df=4)
    chi2_dis_10 = stats.chi2(df=10)
    chi2_dis_20 = stats.chi2(df=20)

    # x1 = np.linspace(chi2_dis_0_5.ppf(0.01), chi2_dis_0_5.ppf(0.99), 100)
    x2 = np.linspace(chi2_dis_1.ppf(0.65), chi2_dis_1.ppf(0.9999999), 100)
    x3 = np.linspace(chi2_dis_4.ppf(0.000001), chi2_dis_4.ppf(0.999999), 100)
    x4 = np.linspace(chi2_dis_10.ppf(0.000001), chi2_dis_10.ppf(0.99999), 100)
    x5 = np.linspace(chi2_dis_20.ppf(0.00000001), chi2_dis_20.ppf(0.9999), 100)
    _, ax = plt.subplots(1, 1)
    # ax.plot(x1, chi2_dis_0_5.pdf(x1), 'b-', lw=2, label=r'df = 0.5')
    ax.plot(x2, chi2_dis_1.pdf(x2), 'g-', lw=2, label='df = 1')
    ax.plot(x3, chi2_dis_4.pdf(x3), 'r-', lw=2, label='df = 4')
    ax.plot(x4, chi2_dis_10.pdf(x4), 'b-', lw=2, label='df = 10')
    ax.plot(x5, chi2_dis_20.pdf(x5), 'y-', lw=2, label='df = 20')
    plt.ylabel('Probability')
    plt.title(r'PDF of $\chi^2$ Distribution')
    ax.legend(loc='best', frameon=False)
    plt.show()


diff_chi2_dis()