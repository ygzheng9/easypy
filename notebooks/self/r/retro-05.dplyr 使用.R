# 常用处理
require(dplyr)

# select()
# filter()
# mutate()
# arrange()
# summarise()
# group_by()


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
