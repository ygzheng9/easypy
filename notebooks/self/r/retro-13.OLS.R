# simulate data
rm(list = ls())
set.seed(111) # can be removed to allow the result to change

# set the parameters
n <- 100
b0 <- matrix(1, nrow = 2)
b0
dim(b0)
# 2*1
# 含义是：截距(第一个)和斜率（第二个） 都是 1

# generate the data
e <- rnorm(n)
X <- cbind(1, rnorm(n))
dim(X)
# 100*2

# 这里是模拟有 随机误差e，这样 Y = Xb 中，b 就无解了；
# 随即误差的含义是，每一个确定的 x1, 有很多个可能的 y，这些 y 在 y_real 上下随机；
Y <- X %*% b0 + e
dim(Y)
# 100*1
#

# b 无解的情况下，可以计算 b 的近似解
# OLS estimation
bhat <- solve(t(X) %*% X, t(X) %*% Y)
bhat
dim(bhat)
# 2*1

# plot
plot(
  x = X[, 2],
  y = Y,
  xlab = "X",
  ylab = "Y",
  main = "regression"
)
abline(a = bhat[1], b = bhat[2])
abline(a = b0[1], b = b0[2], col = "red")
abline(h = 0, lty = 2)
abline(v = 0, lty = 2)
