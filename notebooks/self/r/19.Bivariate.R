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

###########
# parameter test: 参数检验
# 均值检验：numeric ~ constant
# numeric ~ categorical(2 levels)

# 等方差检验

# 非参数检验 wilcox.test
# 中位数检验：numeric ~ categorical(2 levels)

###########

########## t.test

# 1. 检验单变量的均值是否相同
t.test(lungCap$LungCap, mu = 8, alternative = "greater", conf.level = 0.95)
# alternative = c("two.sided", "less", "greater")

# 2. 在一个 categorical 变量不同 levels 下，另一个变量的均值是否相同
boxplot(LungCap ~ Smoke, data = lungCap)

t.test(LungCap ~ Smoke, data = lungCap, mu = 0, alt = "two.sided", conf = 0.95, var.eq = F, paired = F)

str(lungCap$Smoke)
Smoke.no <- lungCap[lungCap$Smoke == "no",]$LungCap
Smoke.yes <- lungCap[lungCap$Smoke == "yes",]$LungCap

t.test(Smoke.no, Smoke.yes, mu = 0)

# 检查方差
var(Smoke.no)
var(Smoke.yes)
# 方差不等，所以 var.equal = F

# 使用 leveneTest 可以直接检查方差是否相等
# Computes Levene's test for homogeneity of variance across groups.
library(car)
leveneTest(LungCap ~ Smoke, data = lungCap)


#
wilcox.test(Smoke.no, Smoke.yes, conf.int = TRUE)


#######################
## Bootstraping ##
#######################


#######################
## AOV 分析，判断一个 categorical 的多个 levels 之间的均值是否相等  ##
#######################
d <- read.csv("./DietWeigthLoss.txt", sep = "\t")

a <- aov(WeightLoss ~ Diet, data = d)
summary(a)
a

TukeyHSD(a)

# 改变 y 轴的 label 显示方向
plot(TukeyHSD(a), las = 1)

# non-parametic test
k <- kruskal.test(WeightLoss ~ Diet, data = d)
summary(k)
k

#######################
## chi-squared 判断两个 categorical 的不同 levels 之间分布一致，也即这两个 categorical 是否独立（不同 level 间表现相同）  ##
#######################
# contigency table
t <- with(lungCap, table(Gender, Smoke))

barplot(t, beside = T, legend = T)

c <- chisq.test(t)
c
attributes(c)

c$expected
t

# Fisher's exact test: non-parametric alternative to the chi-square test
fisher.test(t, conf.int = T, conf.level = 0.99)

#######################
## Odds Ratio, Relative Risk & Risk Difference  ##
#######################
library(epiR)
help(package = "epiR")

t <- with(lungCap, table(Gender, Smoke))
epi.2by2(t, method="cohort.count", conf.level = 0.95)

(314 / 44) / (334 / 33)

t2 <- matrix(c(44, 314, 33, 334), nrow = 2, byrow = T)
t2

t3 <- cbind(t[,2], t[,1])
t3

colnames(t3) <- c("yes", "no")
t3

pairs(lungCap[, 1:3])
cor(lungCap[, 1:3])

cov(lungCap[, 1:3])

#######################
## AppliedPredictiveModeling  ##
#######################
rm(list = ls())
library(AppliedPredictiveModeling)
data(segmentationOriginal)

d <- segmentationOriginal

str(d)

library(car)

d <- read.csv("./Duncan.txt", sep = " ")

d <- read.table(file.choose(), header = TRUE)

hist(d$prestige)


with(d, pairs(cbind(prestige, income, education),
              panel = function(x, y) {
                  points(x, y)
                  abline(lm(y ~ x), lty = "dashed")
                  lines(lowess(x, y))
              },
              diag.panel = function(x) {
                  par(new = TRUE)
                  hist(x, main = "", axes = FALSE)
              }))

scatmat <- function(...) {
    pairs(cbind(...),
          panel = function(x, y) {
              points(x, y)
              abline(lm(y ~ x), lty = "dashed")
              lines(lowess(x, y))
          },
          diag.panel = function(x) {
              par(new = TRUE)
              hist(x, main = "", axes = FALSE)
          })
}

with(d, scatmat(prestige, income, education))

attach(d)
plot(income, education)

dun <- lm(prestige ~ income + education)
dun
summary(dun)

# options(show.signif.stars = FALSE)
options(show.signif.stars = TRUE)

hist(rstudent(dun))

qqPlot(dun, labels = row.names(d), id.n = 3 )

qqPlot(dun)

influenceIndexPlot(dun, vars = c("Cook", "hat"), id.n = 1)

avPlot(dun, id.n = 3, id.cex = 0.75)

with(Freedman, {
    plot(density, crime)
    # identify(density, crime, labels = row.names(Freedman), n = 5)
})

row.names(Freedman)

set.seed(123456789)

x <- rnorm(100000 * 100)
mx <- matrix(x, 100000, 100)
y <- 10 + as.vector(mx %*% rep(1, 100) + rnorm(100000, sd = 10))

system.time(m <- lm(y ~ mx))

with(Prestige, {
    hist(income, breaks = "FD", col = "gray", freq = FALSE, ylab = "Density")
    lines(density(income), lwd = 2)
    lines(density(income, adjust = 0.5), lwd = 1)
    rug(income)
    box()
})

with(Prestige, {
    scatterplot(prestige ~ income | type , span = 0.6, lwd = 3, id.n = 1)
})





