library(reshape2)

library(plyr)

library(ggplot2)
library(ggmap)

scope <- c(0.9, 0.8, 0.6, 0.4, 0.2)

Part <- paste("part", 1:5, sep = "")

Order <- 1:5

help <- (1 - scope) / 2

mydata <- data.frame(Order, Part, help, scope)

mydata1 <-
    melt(
        mydata,
        id.vars = c("Order", "Part"),
        variable.name = "perform",
        value.name = "scope"
    )

str(mydata)

str(mydata1)

# level 是设置 水平顺序
mydata1$perform <-
    factor(mydata1$perform,
           level = c("scope", "help"),
           order = T)


ggplot(mydata1, aes(
    x = Order,
    y = scope,
    order = desc(scope),
    fill = perform
)) +
    geom_bar(stat = "identity", position = "stack")

# 沙漏图：本质还是 stacked bar chart；
# 下面的序列 填充色是白色，并且，不显示坐标轴 (theme_nothing)
# 下面的序列，是 level 中 靠后的；对应的 fill color 也是 白色 white FFFFFF；

Color <- c( "#088158", "#FFFFFF")

# 一个图上，可以有多个 data source，这里有两个，mydata1 和 mydata；
# 本质是设置 位置(x,y) 以及 显示的内容 label
# 反转 x 轴 scale_x_reverse
# x/y 互换 coord_flip()+
ggplot() +
    geom_bar(
        data = mydata1,
        aes(x = Order, y = scope, fill = perform),
        stat = "identity",
        position = "stack"
    ) +
    scale_fill_manual(values = sort(Color)) +
    geom_text(
        data = mydata,
        aes(
            x = Order,
            y = help + scope / 2 - .025,
            label = Part
        ),
        col = "white",
        size = 4
    ) +
    geom_text(
        data = mydata,
        aes(
            x = Order,
            y = help + scope / 2 + .035,
            label = paste(100 * mydata$scope, "%", sep = "")
        ),
        col = "white",
        size = 5
    ) +
    scale_x_reverse() +
    # coord_flip() +
    theme_nothing()


