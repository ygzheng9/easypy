library(ggplot2)
library(ggmap)
library(dplyr)
library(factoextra)
library(Hmisc)
library(gridExtra)
library(lubridate)
library(corrplot)
library(vcd)
library(gmodels)

setwd("~/Documents/playground/easypy/notebooks/self")

# 显示 packages 版本
packages <- c("ggplot2", "ggmap", "dplyr", "factoextra", "Hmisc", "gridExtra", "lubridate", "corrplot", "vcd", "gmodels")
version <- lapply(packages, packageVersion)
version_c <- do.call(c, version)
# version_c2 <- unlist(lapply(packages, packageVersion), use.names = FALSE)
data.frame(packages=packages, version = as.character(version_c))

# 下载数据
if ("all_month.csv" %in% dir(".") == FALSE) {
    url <- "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_month.csv"
    download.file(url = url, destfile = "all_month.csv")
}

# 读取本地数据
quakes <- read.csv("./dataset/all_month.csv", header=TRUE, sep=',', stringsAsFactors = FALSE)

# 转换日期和 factor
quakes$time <- ymd_hms(quakes$time)
quakes$updated <- ymd_hms(quakes$updated)
quakes$magType <- as.factor(quakes$magType)
quakes$net <- as.factor(quakes$net)
quakes$type <- as.factor(quakes$type)
quakes$status <- as.factor(quakes$status)
quakes$locationSource <- as.factor(quakes$locationSource)
quakes$magSource <- as.factor(quakes$magSource)


# 倒过来排序
quakes <- arrange(quakes, -row_number())

# The rows not having any missing values are:
sum(complete.cases(quakes))

sum(complete.cases(quakes))/nrow(quakes)

str(quakes)

sort(unique(quakes$type))

# 类型是 数值 的列的名字（变量名）
(numeric_vars <- names(which(sapply(quakes, class) == "numeric")))

(integer_vars <- names(which(sapply(quakes, class) == "integer")))

(factor_vars <- names(which(sapply(quakes, class) == "factor")))

(character_vars <- names(which(sapply(quakes, class) == "character")))

setdiff(names(quakes), c(numeric_vars, integer_vars, factor_vars, character_vars))


#  Quantitative Variables 数值型变量：连续性 numeric，离散型 int
quantitative_vars <- c(numeric_vars, integer_vars)
sapply(quakes[, quantitative_vars], summary)

# Hmisc
describe(quakes[, quantitative_vars])

## from Kmisc
chunk <- function(min, max, size, by=1) {
    if( missing(max) ) {
        max <- min
        min <- 1
    }
    n <- ceiling( (max-min) / (size*by) )
    out <- vector("list", n)
    lower <- min
    upper <- by * (min + size - 1)
    for( i in 1:length(out) ) {
        out[[i]] <- seq(lower, min(upper, max), by=by)
        lower <- lower + size * by
        upper <- upper + size * by
    }
    names(out) <- paste(sep="", "chunk", 1:length(out))
    return(out)
}


gp <- invisible(lapply(quantitative_vars, function(x) {
    ggplot(data = quakes, aes(y = eval(parse(text = x)))) +
        geom_boxplot(fill = "palegreen4") +
        ylab(x) +
        ggtitle(x) +
        theme(legend.position ="none") +
        coord_flip()
}))

grob_plots <-
    invisible(lapply(chunk(1, length(gp), 4), function(x) {
        marrangeGrob(grobs = lapply(gp[x], ggplotGrob),
                     nrow = 2,
                     ncol = 2)
    }))

grob_plots$chunk1











