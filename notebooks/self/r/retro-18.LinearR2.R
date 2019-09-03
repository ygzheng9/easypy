library(rstudioapi) # load it
# the following line is for getting the path of your current open file
current_path <- getActiveDocumentContext()$path
# The next line set the working directory to the relevant one:
setwd(dirname(current_path))
# you can make sure you are in the right directory
print(getwd())

rm(list = ls())

lungCap <- read.csv("./LungCapData.txt", sep = "\t")

names(lungCap)
class(lungCap$Height)

# 把 numeric 变成 factor
# 默认是 左开右闭(right = TRUE)
lungCap$HeightCat <- cut(lungCap$Height,
  breaks = c(0, 50, 55, 60, 65, 70, 100),
  labels = c("A", "B", "C", "D", "E", "F"),
  right = FALSE
)
class(lungCap$HeightCat)
lungCap$HeightCat

mod <- lm(LungCap ~ Age, data = lungCap)
summary(mod)

############## 输出结果的计算逻辑
#               Estimate    Std. Error    t value   Pr(>|t|)
# (Intercept)   1.14686     0.18353       6.249     7.06e-10 ***
#     Age       0.54485     0.01416       38.476    < 2e-16 ***

# t value
1.14686 / 0.18353
0.54485 / 0.01416

# Residual standard error: 1.526 on 723 degrees of freedom
sqrt(sum(mod$residuals^2) / (length(mod$residuals) - length(mod$coefficients)))

mod$df.residual
# 723
length(mod$residuals) - length(mod$coefficients)
# 723

# 拟合值 - 实际值 = 残差
lungCap$LungCap[1:5] - mod$fitted.values[1:5]
mod$residuals[1:5]

# Multiple R-squared:  0.6719
SS_mean <- sum((lungCap$LungCap - mean(lungCap$LungCap))^2)
SS_fit <- sum(mod$residuals^2)
1 - SS_fit / SS_mean

# Adjusted R-squared:  0.6714
# 多少行，多少列
nrow(lungCap)
length(lungCap)
dim(lungCap)

n <- dim(lungCap)[1]
k <- length(mod$coefficients)
# y 均值只需要一个参数表示
j <- 1
1 - (SS_fit / SS_mean) * (n - j) / (n - k)

# 正态分布随机变量的平方的和 / 自由度
f1 <- SS_fit / (n - k)
f2 <- SS_mean / (n - j)
1 - f1 / f2

# F-statistic:  1480 on 1 and 723 DF,  p-value: < 2.2e-16
f3 <- (SS_mean - SS_fit) / (k - j)
f3 / f1

############## 线性回归的假设是否满足
abline(mod)

par(mfrow = c(2, 2))
plot(mod)


##################### 多变量
rm(list = ls())

mod2 <- lm(LungCap ~ Age + Height, data = lungCap)
summary(mod2)

# Residual standard error: 1.056 on 722 degrees of freedom
n <- nrow(lungCap)
k <- length(mod2$coefficients)
j <- 1

# 残差个数和 y 是一样多的
r <- length(mod2$residuals)

sqrt(sum(mod2$residuals^2 / (n - k)))

# Multiple R-squared:  0.843,
SS.fit <- sum(mod2$residuals^2)
SS.mean <- getSSMean(lungCap$LungCap)
1 - SS.fit / SS.mean

# 与平均值的差的平方
getSSMean <- function(y) {
  return(sum((y - mean(y))^2))
}

# Adjusted R-squared:  0.8425
f1 <- SS.fit / (n - k)
f2 <- SS.mean / (n - j)
f3 <- (SS.mean - SS.fit) / (k - j)
1 - f1 / f2

# F-statistic:  1938 on 2 and 722 DF,
f3 / f1

# 计算相关性
cor(lungCap$Age, lungCap$Height, method = "pearson")

confint(mod2, conf.level = 0.95)
mod2$coefficients
str(mod2)

################ 改变 categorical 的基准
# 默认第一个是 no
table(lungCap$Smoke)
# 可以改成第一个为 yes
lungCap$Smoke <- relevel(lungCap$Smoke, ref = "no")

mod3 <- lm(LungCap ~ Age + Smoke, data = lungCap)
summary(mod3)

################ 有 interaction 的情况
mod4 <- lm(LungCap ~ Age + HeightCat, data = lungCap)
summary(mod4)

par(mfrow = c(1, 1))
noSmoke <- lungCap[lungCap$Smoke == "no", ]
plot(noSmoke$Age, noSmoke$LungCap,
  col = "blue",
  ylim = c(0, 15), xlim = c(0, 20),
  xlab = "Age", ylab = "LungCap"
)

yesSmoke <- lungCap[lungCap$Smoke == "yes", ]
points(yesSmoke$Age, yesSmoke$LungCap,
  col = "red", pch = 16,
  ylim = c(0, 15), xlim = c(0, 20),
  xlab = "Age", ylab = "LungCap"
)

legend(1, 15,
  legend = c("NonSmoker", "Smoker"),
  col = c("blue", "red"), pch = c(1, 16), bty = "n"
)


mod5 <- lm(LungCap ~ Age * Smoke, data = lungCap)
coef(mod5)
summary(mod5)

################## partial test
# 例子 1
mod.full <- lm(LungCap ~ Age, data = lungCap)
mod.reduced <- lm(LungCap ~ Age + I(Age^2), data = lungCap)
summary(mod.full)
summary(mod.reduced)

anova(mod.full, mod.reduced)

# 例子 2
mod.full <- lm(LungCap ~ Age + Gender + Smoke + Height, data = lungCap)
mod.reduced <- lm(LungCap ~ Age + Gender + Smoke, data = lungCap)

anova(mod.reduced, mod.full)

anova(mod.full, mod.reduced)


##################  coefficient standard error
rm(list = ls())
#------generate one data set with epsilon ~ N(0, 0.25)------
seed <- 1152 # seed
n <- 100 # nb of observations
a <- 5 # intercept
b <- 2.7 # slope

set.seed(seed)
epsilon <- rnorm(n, mean = 0, sd = sqrt(0.25))
x <- sample(x = c(0, 1), size = n, replace = TRUE)
y <- a + b * x + epsilon
#-----------------------------------------------------------

#------using lm------
mod <- lm(y ~ x)
#--------------------

#------using the explicit formulas------
X <- cbind(1, x)
betaHat <- solve(t(X) %*% X) %*% t(X) %*% y
var_betaHat <- anova(mod)[[3]][2] * solve(t(X) %*% X)

var_betaHat

#---------------------------------------

#------comparison------
# estimate
mod$coef
# (Intercept)           x
# 5.020261    2.755577

c(betaHat[1], betaHat[2])
# [1] 5.020261 2.755577

# standard error
summary(mod)$coefficients[, 2]
# (Intercept)           x
# 0.06596021  0.09725302

sqrt(diag(var_betaHat))
# 0.06596021 0.09725302
summary(mod)
#----------------------

