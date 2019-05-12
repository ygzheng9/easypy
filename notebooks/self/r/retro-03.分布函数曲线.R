require(ggplot2)

df <- data.frame(x = c(-4, 4))

# 正态曲线，参数是 fun
ggplot(data = df, aes(x = x)) +
    stat_function(fun = dnorm)

# 自定义函数
cubeFun <- function(x) {
    x^3 * 0.5
}
# 传入自定义函数，画函数曲线
ggplot(data = df, aes(x = x)) +
    stat_function(fun = cubeFun)


xsquare <- function(x) {
    x^2
}

ggplot(data.frame(x = c(-5, 10)), aes(x = x)) +
    stat_function(fun = xsquare)


# args 可以传参数给 fun，相当于 partial apply
ggplot(data = df, aes(x = x)) +
    stat_function(fun = dt, args = list(df = 8))

# 先定一个 partial apply
dt8 <- function(x) {
    dt(x, 3)
}
# 再调用
ggplot(data = df, aes(x = x)) +
    stat_function(fun = dt8)


# 通过图层叠加，画两条曲线
# dnorm(x, mean = 0, sd = 1, log = FALSE)  第一个参数是 x，后面两个由 args = list(0.2, 0.1)  传入
ggplot(data.frame(x = c(0, 1)), aes(x = x)) +
    stat_function(fun = dnorm, args = list(0.2, 0.1)) +
    stat_function(fun = dnorm, args = list(0.4, 0.05))


ggplot(data.frame(x = c(-5, 5)), aes(x = x)) +
    stat_function(fun = sin) +
    stat_function(fun = cos)


# 横纵轴显示名称，刻度间隔，刻度文字；
# 图的标题，图例名字
# 背景色
# 刻度的网格线
ggplot(data.frame(x = c(0, 1)), aes(x = x)) +
    stat_function(fun = dnorm, args = list(0.2, 0.1), 
                  aes(colour = "类型 1"), size = 1.5) +
    stat_function(fun = dnorm, args = list(0.3, 0.05), 
                  aes(colour = "类型 2"), size = 0.5, linetype="dotted") +
    scale_x_continuous(name = "X 轴-Probability(概率)",
                       breaks = seq(0, 1, 0.1),
                       limits=c(0, 1)) +
    scale_y_continuous(name = "Y 轴-Frequency(频率)") +
    scale_colour_brewer(palette="Accent") +
    theme(text = element_text(family = "MicrosoftYaHei"),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          panel.grid.major.y = element_line(linetype="dashed", color="grey", size=0.25),
          panel.border = element_blank(),
          panel.background = element_blank(),
          plot.title=element_text(colour="blue", size = 16),
          axis.text.x=element_text(colour="red", size = 6),
          axis.text.y=element_text(colour="green", size = 6),
          legend.position = "bottom"
          ) + 
    ggtitle("图的主标题-Normal function curves of probabilities中文") +
    labs(colour = "图例名字")


# 曲线下面填充颜色
funcShaded2 <- function(x, mean = 0, sd = 1, min, max) {
    y <- dnorm(x, mean = mean, sd = sd)
    y[x < min | x > max] <- NA
    return(y)
}

x.mu <- 0
x.sd <- 1

# 通过叠加：曲线 + 中间区块 + 左边区块 + 右边区块
ggplot(data.frame(x = c(-4, 4)), aes(x = x)) +
    stat_function(fun = dnorm, args = list(mean = x.mu, sd = x.sd)) +
    stat_function(fun = funcShaded2, geom = "area",
                  fill = "#84CA72", alpha = 0.2,
                  args = list(mean = x.mu, sd = x.sd, min = -1, max = 1)) +
    stat_function(fun = funcShaded2, geom = "area",
                  fill = "red", alpha = 0.3,
                  args = list(mean = x.mu, sd = x.sd, min = -Inf, max = -1.96)) +
    stat_function(fun = funcShaded2, geom = "area",
                  fill = "blue", alpha = 0.3,
                  args = list(mean = x.mu, sd = x.sd, min = 1.96, max = Inf)) +
    # theme_minimal() +
    # theme_classic() +
    theme_linedraw() 



# car 
head(mtcars)

# 增加了 4 列，前两列从 数字 转成 文本
mtcars2 <- within(mtcars, {
    vs <- factor(vs, labels = c("V-shaped", "Straight"))
    am <- factor(am, labels = c("Automatic", "Manual"))
    cyl  <- factor(cyl)
    gear <- factor(gear)
})

head(mtcars2)

p1 <- ggplot(data = mtcars2) +
    geom_point(aes(x = wt, y = mpg, colour = gear)) +
    labs(title = "Fuel economy declines as weight increases",
         subtitle = "(1973-74)",
         caption = "Data from the 1974 Motor Trend US magazine.",
         tag = "Figure 1",
         x = "Weight (1000 lbs)",
         y = "Fuel economy (mpg)",
         colour = "Gears")

p1 + theme_classic()

# 根据两个变量细分图形
p2 <- p1 + facet_grid(vs ~ am)

p2 + theme_light() + 
    bbc_style()
