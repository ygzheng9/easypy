# OO in R
##########
# S3

# S3 中，class 本质是 list，然后设置 class 属性
j <- list(name = "Joe", salary = 55000, union = T, class = "whatever")
j

# 查看所有的
attributes(j)

# 设置 class
class(j) <- "employee"

# 查看所属的 class
attr(j, "class")

# 调用的是 默认的
print(j)

# 重载 print 
print.employee <- function(wker) {
    paste(wker$name, wker$salary, wker$union)
}

print(j)

# 查看 class 有多少个 methods
methods(, class = "employee")

methods(, "lm")

cat("asdf")
paste("asdf") 
