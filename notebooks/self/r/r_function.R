library(rlang)
library(lobstr)

library(stringr)
library(dplyr)


# 先按照参数名传递参数；
# 对于没有名的参数，按照位置顺序传递；
# 有默认值的参数，可以直接省略，或者在对应位置使用 ,, 跳过
fn <- function(a, b=3, ..., c) {
  print(str_interp("a = ${a}")) 
  print(str_interp("b = ${b}")) 
  # print(str_interp("args = ${...}")) 
  print(str_interp("c = ${c}"))
}

fn(b=2, a = 5, , c=4)


# get all function in base package
objs <- mget(ls("package:base"), inherits = TRUE)
funs <- Filter(is.function, objs)


fn <- function(a=2, b,c) {
  print(str_interp("a = ${a}")) 
  print(str_interp("b = ${b}")) 
  print(str_interp("c = ${c}")) 
}

fn(b=3, , c=4)

# list, dataframe 可以被作为 env 传入 eval
a <- list(apple=4, orange=5)
a

eval(quote(apple + orange), a)

# substitue + eval 天下无敌
fn <- function (formula, env) {
  eval(substitute(formula), env)
}

fn(apple + orange, a)


# { } 中的是表达式，可以有多个表达式，会被执行
fn({ apple + orange }, a)

fn({ apple + orange 
  print("haha")
  }, a)

print("haha");
print("wowow");


# expr 和 quote 是一样的效果

expr(10 + 100 + 1000)

quote(10 + 100 + 1000)


capture_it <- function(x) {
  # expr(x) 中的 x 不是传入的参数，而是一个字面量
  expr(x)
}

capture_it(a + b + c)

# 需要使用 enexpr 才能传递 block
capture_it2 <- function(x) {
  enexpr(x)
}
capture_it2(a + b + c)


# 查看 ats
lobstr::ast(f(a, "b"))

lobstr::ast(f1(f2(a, b), f3(1, f4(2))))


lobstr::ast(1 + 2 * 3)

# 生成 AST，unquote
# 返回值是 ATS，是没有 evaluate 的

call2("f", 1, 2, 3)

xx <- expr(x + x)
yy <- expr(y + y)

expr(!!xx / !!yy)

cv <- function(var) {
  var <- enexpr(var)
  expr(sd(!!var) / mean(!!var))
}

cv(x + y)

# evaluation
eval(expr(x + y), env(x = 2, y = 100))



df <- data.frame(x = 1:5, y = sample(5))
df

eval_tidy(expr(x + y), df)
eval(expr(x + y), df)

with2 <- function(df, expr) {
  eval_tidy(enexpr(expr), df)
}

with2(df, x + y)


# data mask
df <- data.frame(x = 1:3)
df

# 这里的 a，外层数据
a <- 10


with3 <- function(df, expr) {
  # 这里的 a ，对于 enexpr 也是 eval 的环境
  a <- 1000
  eval_tidy(enexpr(expr), df)
}
with3(df, x + a)

with4 <- function(df, expr) {
  # 这里的 a ，不是 enquo 的环境 
  a <- 1000
  eval_tidy(enquo(expr), df)
}
with4(df, x + a)




# x <- lobstr::ast(read.table("important.csv", row.names = FALSE))

# call 函数调用，就是 list
x <- quote(add(1, 2))

typeof(x)

is.call(x)

x[[1]]
x[[2]]

as.list(x[-1])


starwars %>% 
  filter(species == "Droid")


starwars %>% 
  select(name, ends_with("color"))


starwars %>% 
  mutate(bmi = mass / ((height / 100)  ^ 2)) %>%
  select(name:mass, bmi)

starwars %>% 
  arrange(desc(mass))


starwars %>%
  group_by(species) %>%
  summarise(
    n = n(),
    mass = mean(mass, na.rm = TRUE)
  ) %>%
  filter(n > 1)


