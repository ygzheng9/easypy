###############################
# 模型已知，参数已知，求指定事件发生的概率

# binom(0.7), 20 次，问 概率 分布
# 也即：发生 1 次的概率，2 次的概率，3 次的概率，....
# x 是发生的次数；
barplot(
    dbinom(
        x = c(0:20),
        size = 20,
        prob = 0.7
    ),
    names.arg = 0:20,
    ylab = "p(x)",
    xlab = "x"
)

###############################
# MLE: Most likelihood estimation
# 模型已知，数据已知，问，最可能的参数取什么？

# 已知模型是 binom，观测到事件是 17 次，问，theta 最有可能是多少？
theta <- seq(from = 0, to = 1, by = 0.01)

plot(theta,
     dbinom(x = 12, size = 20, prob = theta),
     type = "l",
     ylab = "likelihood")


####### 最优化方法
# 定义一个最优化的 cost function
# negative log likelihood function

# data 这里只是一个数值，par 对应的是 theta
nll.binom <- function(data, par) {
    return(-log(dbinom(
        data, size = 20, prob = par
    )))
}

# 执行最优化
optim(par = 0.5, fn = nll.binom, data = 12)


#########
# 正态分布
data <- read.csv("https://git.io/v58i8")
head(data)

# 观察下数据，选定模型，从图形上看，选正态分布
# 所谓观察，是看 density，也即：对于连续变量，对应的是 pdf；对于离散变量，是 histgram；
# 因为观测数据是已知的，所以直接用数据做 histgram，或者 density 曲线；
hist(data$x)
plot(density(data$x))

# 定义 cost function
# 参数 data 是一个 vector，所以 dnorm 返回是也是 vector，同理 log 返回也是 vector，所以需要 sum 成一个数字
nll.normal <- function(data, par) {
    return(-sum(log(dnorm(
        data, mean = par[1], sd = par[2]
    ))))
}

# par 是迭代的起点，可以从图形上观察，设定起始值；
optim(par = c(2.8, 0.5),
      fn = nll.normal,
      data = data$x)

# 求的模型参数后，可以比对一下，模型的 density 曲线，和数据的 density 是否一致
x <- seq(-3, 4, 0.01)
plot(density(data$x))
lines(x, dnorm(x, mean = 2.85, sd = 0.12), lty = 2)


#########
# 有偏度的数据 exGaussian
data2 <- read.csv("https://git.io/v58yI")
plot(density(data2$rt))

# 由于没有现成的 密度函数，所以定义一个
dexg <- function(x, mu, sigma, tau) {
    return((1/tau) * exp((sigma^2 / (2 * tau^2)) - (x - mu) / tau) *
                pnorm((x - mu)/sigma - (sigma/tau)))
}

nll.exg <- function(data, par) {
    return(-sum(log(dexg(x = data,
                         mu = par[1],
                         sigma = par[2],
                         tau = par[3]))))
}

optim(par=c(0, 0.1, 0.1), fn = nll.exg, data = data2$rt)

# 对比模型 与 实际数据
x <- seq(0, 4.5, 0.01)
plot(density(data2$rt))
lines(x, dexg(x, mu = 0.715, sigma = 0.336, tau = 0.465), lty = 2)




