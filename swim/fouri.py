import numpy as np
import scipy.stats as stats
import matplotlib.pyplot as plt
from scipy import fftpack as fft

normDist = stats.norm(loc=2.5, scale=0.5)
z = normDist.rvs(size=400)

mean = np.mean(z)
med = np.median(z)
dev = np.std(z)

print(f"mean = {mean}, med = {med}, dev = {dev} \n", )

statVal, pVal = stats.kstest(z, 'norm', (mean, dev))

print(f"pVal = {pVal} \n")

# 模拟带噪声的信号

# 定义采样点间隔
timeStep = 0.02
# 生成采样点
timeVec = np.arange(0, 20, timeStep)
# 标准信号 + 模拟噪声
sig = np.sin(np.pi / 5 * timeVec) + 0.1 * np.random.randn(timeVec.size)

plt.plot(timeVec, sig)
plt.show()

# 时域 ==> 频域
n = sig.size

# 傅里叶变换
sig_fft = fft.fft(sig)
sampleFreq = fft.fftfreq(n, d=timeStep)

# 找出信号频率
pidxs = np.where(sampleFreq > 0)
freqs = sampleFreq[pidxs]
power = np.abs(sig_fft)[pidxs]

# 找到主信号频率
freq = freqs[power.argmax()]

# 舍弃所有非信号频率
sig_fft[np.abs(sampleFreq) > freq] = 0

# 傅里叶逆变换
main_sig = fft.ifft(sig_fft)
plt.plot(timeVec, main_sig, linewidth=3)
