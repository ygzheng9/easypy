# 常用处理
# require(dplyr)
library(rstudioapi)
library(tidyverse)

# the following line is for getting the path of your current open file
current_path <- getActiveDocumentContext()$path
# The next line set the working directory to the relevant one:
setwd(dirname(current_path))
# you can make sure you are in the right directory
print(getwd())

rm(list = ls())


# select()
# filter()
# mutate()
# arrange()
# summarise()
# group_by()


gapminder_orig <- read.csv("gapminder-FiveYearData.csv")
# define a copy of the original dataset that we will clean and play with
gapminder <- gapminder_orig

head(gapminder)

gapminder %>%
    filter(continent == "Americas", year == "2007") %>%
    mutate(gdp = gdpPercap * pop) %>%
    select(country, lifeExp, gdp) %>%
    arrange(desc(lifeExp)) %>%
    head(20)

gapminder %>%
    filter(lifeExp > mean(lifeExp)) %>%
    count(continent)

head(gapminder)

gapminder %>%
    filter(year == "2007") %>%
    group_by(continent) %>%
    summarise(n = n(),
              mean_life = mean(lifeExp),
              total_gdp = sum(gdpPercap))




# 选取列，可以按照列名（开始，结束，包含等等）
iris_data <- select(iris, starts_with("Sepal", ignore.case = F))
head(iris_data)

# ends_with(“Length”) 选择列名以Length结尾的的列
# contains(“Sep”) 选择列名包含有Sep的列
# matches(“\.”) 选择列名正则匹配到有’点’的列
# num_range(“Sepal.Length”, 1:5) 选择列名为Sepal.Length1到Sepal.Length5的列
# one_of(“Sepal.Length”, “Sepal.Width”) 选择列名为Sepal.Length和Sepal.Width的列
# everything() 用于选择所有变量（列名），一般用于改变列名顺序用

# 增加新列
mutate(iris, Sum_Sepal = Sepal.Length + Sepal.Width)


head(iris)

library(dplyr)

head(iris)

specs <- iris %>% distinct(Species)
fac <- factor(specs)

as.integer(fac())

getInd <- function(s) {
    if (s == "setosa") {
        return(1)
    } else if (s == "versicolor") {
        return(2)
    } else {
        return(3)
    }
}

getInd("versicolor")


iris_data %>%
    mutate(ind = getInd(.Species))


directions <- c("North", "East", "South", "South")
directions.factor <- factor(directions)
directions.factor

as.numeric(directions.factor)

v1 <- iris[, "Species"]
v1

v2 <- factor(v1)
v3 <- as.numeric(v2)

df1 <- data.frame(v1 = v1, v2 = v3, v3 = v3)
df1
