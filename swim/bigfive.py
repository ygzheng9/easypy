import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import scipy.stats as stats

# 二项分布
n = 10
p = 0.3

# 在每个点的概率
x = np.arange(0, 21)
binomial = stats.binom.pmf(x, n, p)
binomial

plt.plot(x, binomial, 'o-')
plt.title('Binomial: n=%i , p=%.2f' % (n, p), fontsize=15)
plt.xlabel('Number of success')
plt.ylabel('Probability of success', fontsize=15)
plt.show()

# 模拟
binom_sim = stats.binom.rvs(n=10, p=0.5, size=1000)

plt.hist(binom_sim, bins=10, normed=True)
plt.xlabel('x')
plt.ylabel('Density')
plt.show()

a = [stats.binom.rvs(n=1, p=0, 5, size=1) for i in range(1, 20)]
