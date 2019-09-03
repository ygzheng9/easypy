## 生存模型，
## 1. 作为整体的生存曲线；
## 2. 以一个变量的两个 levels 作为分组，两条生存曲线
## 3. Surv/coxph, survfit, survdiff, plot/autoplot/ggsurvplot/ggforest/aareg

# options(repos=structure(c(CRAN="https://mirrors.tuna.tsinghua.edu.cn/CRAN/")))

library(survival)
library(KMsurv)
library(survminer)
library(dplyr)

rm(list = ls())

# 查看 package 中有哪些 dataset
library(help = KMsurv)
data(aids)
aids

######
library(help = survival)
data(lung)
head(lung)

# load dataset
mydata <- lung
head(mydata)

# event: must be 0 or 1
mydata$recodedStatus <- ifelse(test = mydata$status == 1,
  0, 1
)


# create surv object: time, event
mySurv <- Surv(time = mydata$time, event = mydata$recodedStatus)
class(mySurv)
head(mySurv)

############################
# fit as a whole
myFit <- survfit(mySurv ~ 1)
myFit

# median survial is the time at which the survivorship function equals 50%
median(mydata$time)

plot(myFit)
plot(myFit, conf.int = "none")
abline(h = 0.5)
abline(v = 310)

############################
# fit by sex
myFit <- survfit(mySurv ~ mydata$sex)
myFit
plot(myFit)
table(mydata$sex)

plot(myFit, col = c("red", "blue"), conf.int = "both")
plot(myFit, col = c("red", "blue"), mark = 3)

legend("topright", c("male", "female"), col = c("red", "blue"), lty = 1)
abline(h = 0.5)
abline(v = 270, col = "red")
abline(v = 426, col = "blue")

# check thek p-value
survdiff(mySurv ~ mydata$sex)


############################
# cov
coxph(mySurv ~ mydata$sex + mydata$age)
# mydata$sex -0.513219
# sex: 1 change to 2, ln(HR) drop 0.51.

#############################
# 第二段示例： Import the ovarian cancer dataset and have a look at it
data(ovarian)
glimpse(ovarian)
help(ovarian)

# Dichotomize age and change data labels
ovarian$rx <- factor(ovarian$rx,
  levels = c("1", "2"),
  labels = c("A", "B")
)
ovarian$resid.ds <- factor(ovarian$resid.ds,
  levels = c("1", "2"),
  labels = c("no", "yes")
)
ovarian$ecog.ps <- factor(ovarian$ecog.ps,
  levels = c("1", "2"),
  labels = c("good", "bad")
)

# 在什么都不知道的情况下，首先看一下关注变量的分布(直方图)
# Data seems to be bimodal
hist(ovarian$age)

# 从分布图上，50 岁是个槛，所以创建一个变量
ovarian <- ovarian %>% mutate(age_group = ifelse(age >= 50, "old", "young"))
ovarian$age_group <- factor(ovarian$age_group)

# 建立 survial 模型
# Fit survival data using the Kaplan-Meier method
surv_object <- Surv(time = ovarian$futime, event = ovarian$fustat)
surv_object


############# 单个变量 rx 对事件的影响，这里是 servival rate，随时间逐渐下降
## rx 有两个 level，所以表现为两条线；
fit1 <- survfit(surv_object ~ rx, data = ovarian)
summary(fit1)
ggsurvplot(fit1, data = ovarian, pval = TRUE)


# Examine prdictive value of residual disease status
fit2 <- survfit(surv_object ~ resid.ds, data = ovarian)
ggsurvplot(fit2, data = ovarian, pval = TRUE)

library(help = survminer)


############# 同时查看多个变量对事件的影响，这里是 hazard function
# Fit a Cox proportional hazards model
fit.coxph <- coxph(surv_object ~ rx + resid.ds + age_group + ecog.ps,
  data = ovarian
)
ggforest(fit.coxph, data = ovarian)

#############
## 使用 age 连续值
fit.coxph2 <- coxph(surv_object ~ age + rx, data = ovarian)
summary(fit.coxph2)

ggforest(fit.coxph2, data = ovarian)
# age 每增加 1 岁，风险增加 16%

############
fit.s <- coxph(surv_object ~ pspline(age) + rx, data = ovarian)
termplot(fit.s, term = 1, se = TRUE, col.term = 1, col.se = 1)
