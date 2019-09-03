# h1
a <- c(6, 6, 6, 7, 10, 13, 16, 22, 23, 6, 9, 10, 11, 17, 19, 20, 25, 32, 32, 34, 35)
9 / sum(a)
# 0.02506964

b  <- c(6, 6, 6, 7, 10, 13, 16, 22, 23)
mean(b)
median(b)

c <- cumsum(b) / sum(b)

res.lm <- lm(b ~ c)
summary(res.lm)

0.5 * 20.81879 + 3.55864
# 13.96804

ex <- data.frame(c = 0.5)
predict(res.lm, ex, interval = "prediction", level = 0.95)
# 13.96804 10.88588 17.05019

##################
rm(list = ls())
group1  <- data.frame(
    year = c(6, 6, 6, 7, 10, 13, 16, 22, 23, 6, 9, 10, 11, 17, 19, 20, 25, 32, 32, 34, 35),
    status = c(rep(1, 9), rep(0, 12)),
    group = rep(1, 21)
)

group2  <- data.frame(
    year = c(1,1,2,2,3,4,4,5,5,8,8,8,8,11,11,12,12,15,17,22,23),
    status = rep(1, 21),
    group = rep(2, 21)
)

cmb <- rbind(group1, group2)

# cmb$status <- as.factor(cmb$status)
cmb$group <- as.factor(cmb$group)

cmb$group

dim(cmb)
cmb
str(cmb)

library(survival)
library(survminer)
library(ggfortify)
library(dplyr)


res.surv <- Surv(time = cmb$year, event = cmb$status)
res.surv


res.fit1 <- survfit(res.surv ~ group, data = cmb)
summary(res.fit1)
ggsurvplot(res.fit1, data = cmb, pval = TRUE)

autoplot(res.fit1)

cmb
