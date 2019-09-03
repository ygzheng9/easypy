library(rstudioapi) # load it
# the following line is for getting the path of your current open file
current_path <- getActiveDocumentContext()$path
# The next line set the working directory to the relevant one:
setwd(dirname(current_path ))
# you can make sure you are in the right directory
print( getwd() )

rm(list = list())

wcgs <- read.csv("./wcgsdata.csv")


# wt2: category 0/1
result.lr <- glm(chd ~ wt2, family = "binomial", data = wcgs)
# $ chd     : int  0 1 0 0 0 0 0 0 0 0 ...
# $ wt2     : int  1 0 1 0 0 0 0 0 1 1 ...

summary(result.lr)
str(result.lr)

fit.SSE <- sum(result.lr$residuals ^ 2)
fit.SSE

fit.DF <- length(wcgs$chd) - length(result.lr$coefficients)

fit.residualDeviance <- sqrt(fit.SSE / fit.DF)
fit.residualDeviance

sum(result.lr$residuals ** 2)
str(wcgs)

# weight: continue
result.lr2 <- glm(chd ~ weight, family = "binomial", data = wcgs)
summary(result.lr2)

# wcgs$wt4 <- as.factor(wcgs$wghtcat)

wcgs$wt4 <- factor(wcgs$wghtcat, levels = c("< 140", "140-170", "170-200", " > 200 "))
wcgs$wt4


#######################
rm(list = ls())
info.mtcars <- glm(formula= vs ~ wt + disp, data=mtcars, family=binomial)
summary(info.mtcars)
# Null deviance: 43.86  on 31  degrees of freedom
# Residual deviance: 21.40  on 29  degrees of freedom
# AIC: 27.4

# Deviance is a measure of goodness of fit of a model. Higher numbers always indicates bad fit.

# The null deviance shows how well the response variable is predicted by a model that includes only the intercept (grand mean) where as residual with inclusion of independent variables.

# 31 df = 32 - 1
length(info.mtcars$residuals)
# 32
# 1 is the mean, which is only one parameter

# 29 df = 32 - 3
length(info.mtcars$coefficients)
# 3


length(mtcars)


