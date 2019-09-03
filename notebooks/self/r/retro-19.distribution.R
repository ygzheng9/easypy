##### binomial ： 离散分布
# 二项分布是离散的，d 是 x=3 时的概率，density/pdf
dbinom(x = 3, size = 20, prob = 1/6)

dbinom(x = 0:3, size = 20, prob = 1/6)

sum(dbinom(x = 0:3, size = 20, prob = 1/6))

# p 是 累积密度函数，左下方面积
pbinom(q = 3, size = 20, prob = 1/6, lower.tail = TRUE)

##### possion: 离散分布
dpois(x = 4, lambda = 7)

dpois(x = 0:4, lambda = 7)

sum(dpois(x = 0:4, lambda = 7))

# 左下方面积，在离散分布下，等于 0/1/2/3/4 各自概率的和
ppois(q = 4, lambda = 7)

ppois(q = 12, lambda = 7, lower.tail = FALSE)
1 - ppois(q = 12, lambda = 7, lower.tail = TRUE)


#####  norm：连续分布
# <= 70 左下方的面积
pnorm(q = 70, mean = 75, sd = 5, lower.tail = TRUE)

pnorm(q = 85, mean = 75, sd = 5, lower.tail = F)

# find Q1
qnorm(p = 0.25, mean = 75, sd = 5, lower.tail = TRUE )

# density，可以画出密度曲线，下方面积是累积概率
dnorm(x = 75, mean = 75, sd = 5)
x <- seq(from = 55, to = 95, by=0.25)

plot(x, dnorm(x, mean = 75, sd = 5),
     type = "l",
     main = "Normal Distribution(mean = 75, sd = 5)",
     xlab = "x", ylab = "Density")
abline(v = 75)

r <- rnorm(n = 40, mean = 75, sd = 5)
hist(r)

density(r)

###### t-distribution: 连续
# t=2.3 df=25
# one-side p-value: right side
pt(q=2.3, df = 25, lower.tail = FALSE)

# two-side: 手工一左一右加在一起
pt(q=2.3, df = 25, lower.tail = FALSE) + pt(q=-2.3, df = 25, lower.tail = TRUE)

# CI: 95%
# 左侧的 2.5%, 左下方面积
qt(p = 0.025, df = 25, lower.tail = T)
# 右侧的 2.5%，右下方面积
qt(p = 0.025, df = 25, lower.tail = F)

#######
# ?pf F 分布
# ?pexp 指数分布

#########


