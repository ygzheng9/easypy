# EDA (Exploratory Data Analysis)

library(fakir)
library(tidyverse)
library(DataExplorer)
web <- fakir::fake_visits()
glimpse(web)

# year,month,day to factor

web$year <- as.factor(web$year)
web$month <- as.factor(web$month)
web$day <- as.factor(web$day)

# 查看所有变量（列）
introduce(web)

plot_intro(web)

# 使用 theme，美化
plot_intro(web,
           ggtheme = theme_minimal(),
           title = "Automated EDA with Data Explorer",
)

# 查看每个变量的空值情况
plot_missing(web)

####################### 单变量
# 单变量，numeric，数值分布
plot_histogram(web)
plot_density(web)

# categorical 变量的 barchart，针对所有 observation（不区分其余变量，和下一个对比）
plot_bar(web,maxcat = 20, parallel = TRUE)

# categorical 变量，在另一个变量 home 下的 barchat
plot_bar(web,with = c("home"), maxcat = 20, parallel = TRUE)

######################### 多变量
# boxplot：month 是 categorical，数据集中所有 numeric 变量的 boxplot，
plot_boxplot(web, by = 'month', ncol = 2)

# 所有变量间的 cor
# 对于 categorical 变量，直接计算 cor 是没有意义的，但是
# 可以先用 xtab 做出 contingency table，然后做 chq-square 检验；判断两变量是否独立(在另一个 numeric 变量下);
plot_correlation(web, cor_args = list('use' = 'complete.obs'))

# 只显示 continuous 变量间的 cor
plot_correlation(web, type = 'c',cor_args = list( 'use' = 'complete.obs'))

create_report(web)


