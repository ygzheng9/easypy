## 分析销售数据

library(readxl)
## library(dplyr)
##  library(ggplot2)

library(tidyverse)

setwd("~/Documents/playground/easypy/notebooks/self")
getwd()

# read from excel file
df1 <-  read_excel("./dataset/pd_sales.xlsx", sheet = "Sheet1")

str(df1)

df1 <- subset(df1, select = c(level1, level2, YR2016, YR2017))

names(df1)

# 转换成数字
df1$YR2016 = as.numeric(df1$YR2016)
df1$YR2017 = as.numeric(df1$YR2017)

df1 <- gather(df1, key="year", value="qty", -level1, -level2)
df1$qty = as.numeric(df1$qty)


df1

df1[which(is.na(df1$qty) == TRUE), ]



df1

df1 %>%
    filter(year == "YR2017") %>%
    group_by(level1) %>%
    summarise(
        n = n(),
        total_qty = sum(qty),
        score = myFunc(qty)
    ) %>%
    arrange(desc(total_qty))


# 每个区域：第一名量 / (第二名 + 第三名)
myScore <-  function(x) {
    s <- sort(x, decreasing = TRUE)
    num <- length(s)

    if (num <= 1) {
        1
    } else if (num == 2) {
        s[1L] / s[2L]
    } else {
        s[1L] / (s[2L] + s[3L])
    }
}


# 按照 level1 汇总
df2 <- df1 %>%
    group_by(level1) %>%
    summarise(
        n = n(),
        Y16 = sum(YR2016),
        Y17 = sum(YR2017)
    ) %>%
    arrange(desc(Y17))

df2

df3 <- gather(df2, key="year", value="qty", -level1, -n)

df3

as.character(unique(unlist(df2$level1)))

# 显示行数
count(df2)

names(df2)
# "level1" "n"      "YR2016" "YR2017"

###################

font <- "MicrosoftYaHei"

# hard code column name
ggplot(df2, aes(x=reorder(level1, -QTY2), y = QTY2)) +
    geom_bar(stat='identity', fill='dodgerblue') +
    scale_y_continuous(expand = c(0, 0), limits = c(0, 370)) +
    theme_bw() +
    theme(
        text = element_text(family = font),
        # plot.title = element_text(size=26, face="bold", hjust=0, color="#666666"),
        axis.title = element_text(size=10,  face="bold", color="#666666"),
        # axis.title.y = element_text(angle=0, vjust = 0.5),
        axis.text.x = element_text(size=5,  face="bold", color="#666666"),
        legend.title = element_text(size=8),
        legend.text = element_text(size=6),
        legend.position = "bottom") +
    xlab("省份") + ylab("出库量")



############################################
# barchar order by yQty desc
# usage: drawBar(df2, "省份", "reorder(level1, -QTY2)", "出库量", "QTY2")
drawBar <- function(df, labx, xName, laby, yQty, hLayout = TRUE) {
    font <- "MicrosoftYaHei"

    # use string for column name
    p <- ggplot(df, aes_string(x=xName, y = yQty)) +
        geom_bar(stat='identity', fill='dodgerblue') +
        scale_y_continuous(expand = expand_scale(mult = c(0, .05))) +
        theme_bw() +
        theme(
            text = element_text(family = font),
            # plot.title = element_text(size=26, face="bold", hjust=0, color="#666666"),
            axis.title = element_text(size=10,  face="bold", color="#666666"),
            # axis.title.y = element_text(angle=0, vjust = 0.5),
            axis.text.x = element_text(size=4,  face="bold", color="#666666"),
            legend.title = element_text(size=8),
            legend.text = element_text(size=6),
            legend.position = "bottom") +
        xlab(labx) + ylab(laby)

    if (hLayout) {
        p + coord_flip()
    } else {
        p
    }
}

# 竖直方向
drawBar(df2, "省份", "reorder(level1, -QTY2)", "出库量", "QTY2", hLayout=FALSE)

# 水平方向
drawBar(df2, "省份", "reorder(level1, QTY2)", "出库量", "QTY2", hLayout = TRUE)


##############
## 输入一个 省，取得省下面所有的市

province <- "江苏"

df3 <- df1 %>%
    filter(str_detect(level1, province))

summary(df3)

str(df3)

unique(df3$level1)

df3

dim(df3)[1]

names(df3)

drawBar(df3, "地区",  "reorder(level2, YR2017)", "出库量", "YR2017")


# 下钻到某个省份
# usage: drill("四川")
drill <- function(allData, province) {
    df3 <- allData %>%
        filter(level1 == province)

    drawBar(df3, "地区",  "reorder(level2, YR2017)", "出库量",  "YR2017")
}

drill(df1, "郑州")

?plotOutput

###############################
## treemap 省公司一级
library(treemapify)

library(ggthemes)

theme_economist()

df2


##
## 省公司
# 拼接字符串
df2$msg <- paste(df2$level1, df2$QTY2)

## grow 不换行， reflow 换行
font <- "MicrosoftYaHei"
ggplot(df2, aes(area = QTY2, fill = n, label = msg)) +
    geom_treemap() +
    geom_treemap_text(colour = "black", place = "center", reflow = T,
                      padding.x = grid::unit(1.5, "mm"),  padding.y = grid::unit(2, "mm"),
                      alpha = .6,
                      fontface = "italic", family = font) +
    theme(text = element_text(family = font),
        legend.title = element_text(size = 8, family = font)) +
    scale_fill_distiller("区域数量", palette = "Greens", direction = 1)



###########################
## treemap demo

str(G20)

# 一层数据，属性：大小，颜色，文本
ggplot(G20, aes(area = gdp_mil_usd, fill = hdi, label = country)) +
    geom_treemap() +
    geom_treemap_text(fontface = "italic", colour = "red", place = "topleft",grow = T, alpha=.5) +
    scale_fill_distiller(palette = "Greens")

# 两层数据：多一个 subgroup
# grow则控制标签是否与方块大小自适应（呈大致比例放大缩小），不换行
# reflow参数用于控制标签是否自适应矩形块大小，若按照原始大小超过矩形块，则会自动换行显示。
ggplot(G20, aes(area = gdp_mil_usd, fill = hdi, label = country, subgroup = region)) +
    geom_treemap() +
    geom_treemap_text(fontface = "italic", colour = "red", place = "topleft",reflow = T, alpha=.5) +
    geom_treemap_subgroup_border() +
    geom_treemap_subgroup_text(place = "centre", grow = T, alpha = 0.5, colour ="black", fontface = "italic", min.size = 0) +
    scale_fill_distiller(palette = "Greens")
