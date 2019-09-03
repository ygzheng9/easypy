## 一、线性回归，单变量，多变量
## R squared: (SS(mean) - SS(fit)) / SS(mean)
## F: 模型有几个参数，自由度就是几；比如：
## mean 只有一个参数 y = y0，所以是 1；
## fit y = ax + b, 有两个参数，所以是 2；
## 输出结果中，coefficient有几行，就是几；

## 对于分类变量（t-test），两类可以用两个开关量，也可以用一个开关量
## y = aA + bB          ==> A, B 都是开关量
## y = a + (b - a)B     ==> 只有 B 是开关量，而且还包含了 A/B 互斥的逻辑

## 二、bootstrap
## 在同一个样本中，反复进行同样数量的有放回抽取，这就是 bootstrap；


## Here's the data from the example:
mouse.data <- data.frame(
  weight = c(0.9, 1.8, 2.4, 3.5, 3.9, 4.4, 5.1, 5.6, 6.3),
  size = c(1.4, 2.6, 1.0, 3.7, 5.5, 3.2, 3.0, 4.9, 6.3),
  tail = c(0.7, 1.3, 0.7, 2.0, 3.6, 3.0, 2.9, 3.9, 4.0)
)


mouse.data # print the data to the screen in a nice format

########## 单变量回归
## plot a x/y scatter plot with the data
plot(mouse.data$weight, mouse.data$size)

## create a "linear model" - that is, do the regression
mouse.regression <- lm(size ~ weight, data = mouse.data)
## generate a summary of the regression
summary(mouse.regression)

## add the regression line to our x/y scatter plot
abline(mouse.regression, col = "blue")

########## 输出数据的解释
rm(list = ls())
# Anscombe's Quartet Q1 Data
y <- c(8.04, 6.95, 7.58, 8.81, 8.33, 9.96, 7.24, 4.26, 10.84, 4.82, 5.68)
x1 <- c(10, 8, 13, 9, 11, 14, 6, 4, 12, 7, 5)
# Some fake data, set the seed to be reproducible.
set.seed(15)
x2 <- sqrt(y) + rnorm(length(y))

res.model <- lm(y ~ x1 + x2)
summary(res.model)

SSE.fit <- sum(res.model$residuals ^ 2)
SSE.fit

fit.RSE <- sqrt(SSE.fit / (length(y) - length(res.model$coefficients)))
fit.RSE
# Residual standard error: 1.141 on 8 degrees of freedom
# 1.140965
# degree of freedom: 8 = 11 - 3
# 样本 length(y) = 11
# 拟合的曲线 length(res.model$coefficients)) = 3

b <- sqrt(sum(x1^2) / (length(y) - 2))
b

fit.RSE / b

#Residual Standard error (Like Standard Deviation)
k = length(res.model$coefficients) - 1  #Subtract one to ignore intercept
SSE.fit = sum(res.model$residuals ** 2)
n = length(res.model$residuals)
sqrt(SSE.fit / (n - (1 + k))) #Residual Standard Error
# Residual standard error: 1.141 on 8 degrees of freedom
length(y) - length(res.model$coefficients)
# 8 degrees of freedom

#Multiple R-Squared (Coefficient of Determination)
SS.mean = sum((y - mean(y)) ** 2)
SSE.fit = sum(res.model$residuals ** 2)
(SS.mean - SSE.fit) / SS.mean
#Alternatively
1 - SSE.fit / SS.mean
# Multiple R-squared:  0.7477

#Adjusted R-Squared
n = length(y)
k = length(res.model$coefficients) #Subtract one to ignore intercept
SSE.fit = sum(res.model$residuals ** 2)
SS.mean = sum((y - mean(y)) ** 2)
1 - (SSE.fit / SS.mean) * (n - 1) / (n - k)
# Adjusted R-squared:  0.6846

#F-Statistic
#Ho: All coefficients are zero
#Ha: At least one coefficient is nonzero
#Compare test statistic to F Distribution table
n <- length(y)
SSE.fit <- sum(res.model$residuals ** 2)
SS.mean <- sum((y - mean(y)) ** 2)
k <- length(res.model$coefficients) - 1
((SS.mean - SSE.fit) / k) / (SSE.fit / (n - (k + 1)))
# F-statistic: 11.85 on 2 and 8 DF
# 2 = k = 3 - 1
# 8 = 11 - 3
# 1: SS.mean 只需要一个参数，所以是 1；

########## 多变量回归
plot(mouse.data)

multi.regression <- lm(size ~ weight + tail, data = mouse.data)
summary(multi.regression)

########################
# 分两组：control, mutant
Type <- factor(c(rep("Control", 4), rep("Mutant", 4)))
Weight <- c(2.4, 3.5, 4.4, 4.9, 1.7, 2.8, 3.2, 3.9)
Size <- c(1.9, 3, 2.9, 3.7, 2.8, 3.3, 3.9, 4.8)
model.matrix(~ Type + Weight)

m <- lm(Size ~ Type + Weight)
summary(m)

############################
# 先是LabA、LabB；每个lab 里又有 control、mutant

Lab <- factor(c(
  rep("A", 6),
  rep("B", 6)
))

Type <- factor(c(
  rep("Control", 3),
  rep("Mutant", 3),
  rep("Control", 3),
  rep("Mutant", 3)
))

Expression <- c(
  1.7, 2, 2.2,
  3.1, 3.6, 3.9,
  0.9, 1.2, 1.9,
  1.8, 2.2, 2.9
)

model.matrix(~ Lab + Type)

batch.lm <- lm(Expression ~ Lab + Type)
summary(batch.lm)


#####################
# bootstrap
## bootstrap demo...

# Step 1: get some data
# (in this case, we will just generate 20 random numbers)
n <- 20
data <- rnorm(n)

## Step 2: plot the data
stripchart(data, pch = 3)

## Step 3: calculate the mean and put it on the plot
data.mean <- mean(data)
abline(v = data.mean, col = "blue", lwd = 2)

## Step 4: calculate the standard error of the mean using the
## standard formula (there is a standard formula for the standard
## error of the mean, but not for a lot of other things. We use
## the standard formula in this example to show you that the
## bootstrap method gets the about the same values
data.stderr <- sqrt(var(data)) / sqrt(n)
data.stderr ## this just prints out the calculated standard err

## Step 5: Plot 2*data.stderr lines +/- the mean
## 2 times the standard error +/- the mean is a quick and dirty
## approximatino of a 95% confidence interval
abline(v = (data.mean) + (2 * data.stderr), col = "red")
abline(v = (data.mean) - (2 * data.stderr), col = "red")

## Step 6: Use "sample()" to bootstrap the data and calculate a lot of
## bootstrapped means.
num.loops <- 1000
boot.means <- vector(mode = "numeric", length = num.loops)
for (i in 1:num.loops) {
  boot.data <- sample(data, size = 20, replace = TRUE)
  boot.means[i] <- mean(boot.data)
}

## Step 7: Calculate the standard deviation of the bootstrapped means.
## This is the bootstrapped standard error of the mean
boot.stderr <- sqrt(var(boot.means))
boot.stderr

## Step 8: Plot 2*boot.stderr +/- the mean.
## Notice that the 2*data.stderr lines and the 2*boot.stderr lines
## nearly overlap.
abline(v = (data.mean) + (2 * boot.stderr), col = "green")
abline(v = (data.mean) - (2 * boot.stderr), col = "green")


######################
# fisher exact test
data <- matrix(data = c(1, 0, 0, 0, 0, 7, 5, 6, 8, 8, 5, 8), nrow = 6)

colnames(data) <- c("handful", "bag")
rownames(data) <- c("red", "yellow", "orange", "green", "brown", "blue")

data

fisher.test(data)
