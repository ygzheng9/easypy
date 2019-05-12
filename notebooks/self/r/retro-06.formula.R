e <- ~ x + y + z
length(e)

f <- y ~ x + b 
length(f)


h <- as.formula("y ~ x1 + x2")
length(h)



# Set seed
set.seed(123)

# Data
x = rnorm(5)
x2 = rnorm(5)
y = rnorm(5)

# Model frame
model.frame(y ~ x * x2, data = data.frame(x = x, y = y, x2=x2))

model.frame(y ~ x + x^2, data = data.frame(x = x, y = y))

model.frame(y ~ x + I(x^2), data = data.frame(x = x, y = y))


m <- formula("y ~ x1 + x2")
terms(m)

print(all.vars(m))

as.formula(paste("y ~ x1 + x2", "x3", sep = "+"))

factors <- c("x2", "x3")
as.formula(paste("y~", paste(factors, collapse="+")))



funA <- function(a1 = 2, a2 = 2, a3 = 99) {
    return(sum(a1, a2, a3))
}

funB <- function(b1 = 3, b2 = 3) {
    return(sum(b1, b2))
}

# 参数传递，优先使用 名字；然后才是 位置
funC <- function(c1, c2, ...) {
    tmp2 <- funA(a1=9, a3=1, ...)
    return(tmp2)
}

funC(4,4,1)
