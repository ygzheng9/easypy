# Rscript retro-11.模拟抽样.R

# 8.6.3 组合的模拟
# 从 20 个人中，组建 3/4/5 三个小组，问 A 和 B 在同一组的概率多少？

sim <- function(nreps) {
    commdata <- list()

    # 初始包含 AB 的个数为 0
    commdata$count <- 0

    # 每次循环，模拟一次（组件三个小组）
    for (rep in 1:nreps) {
        # 每次都是 20 个人
        commdata$remains <- 1:20

        # 在这一次模拟中，一组中同时有 AB 的个数
        commdata$both <- 0

        # both=2 表示 AB 在同一组；=1 表示不在同一组，这两种情况都是确定的，所以不需要再看其他组
        commdata <- choosecomm(commdata, 5)
        if (commdata$both > 0 ) next

        commdata <- choosecomm(commdata, 4)
        if (commdata$both > 0 ) next

        commdata <- choosecomm(commdata, 3)
    }

    print(commdata$count / nreps)
}

choosecomm <- function(comdat, comsize) {
    # 随机抽取，从 remains 中，抽取出 comsize 个
    committee <- sample(comdat$remains, comsize)

    # AB 假设为 1、2，这里是看抽取出来的，是否包含 1、2
    comdat$both <- length(intersect(1:2, committee))
    if (comdat$both == 2) {
        # 包含两个，总计数器 + 1
        comdat$count <- comdat$count + 1
    }

    # 这里是不放回抽取
    comdat$remains <- setdiff(comdat$remains, committee)
    return(comdat)
}


sim(1000)

#################
guess <- function(nreps) {
    # 一次生成 2n 个，分两组，前 n个，后 n 个
    x <- rnorm(2 * nreps)
    # 有两组，对应位置取最大值
    maxxy <- pmax(x[1:nreps], x[(nreps + 1):(2 * nreps)])
    # 对最大值，再求均值
    mean(maxxy)
}

guess(100000)

################
# 游程 runs，找到出现长度为 k 的游程的起始位置
findruns <- function(x, k) {
    n <- length(x)
    runs <- NULL
    for (i in 1:(n-k+1)) {
        # i 到 i+k-1 共有 k 个元素，都是 1 时，把 i 记录下来
        if (all(x[i:(i+k-1)] == 1)) runs <- c(runs, i)
    }
    runs
}

x <- c(1,0,0,1,1,1,1,0,1,1,1,0,1)
findruns(x, 2)

#################
# 0-1 预测，根据之前 k 天出现的 1 的次数，预测接下来的是否为 1
predc <- function(x, k) {
    n <- length(x)

    # majority rule，如果前面连续 k 天的总和大于 k/2 就认为会发生，否则不会发生；
    k2 <- k / 2

    # k 是窗口
    pred <- vector(length = n - k)

    # 累加
    csx <- c(0, cumsum(x))

    for (i in 1:(n - k)) {
        # k 是窗口大小，一头一尾的差值，就是 k 的值
        if ((csx[i+k] - csx[i]) >= k2) {
            pred[i] <- 1
        } else {
            pred[i] <- 0
        }
    }

    # pred 中是预测值，x 中是实际值，通过偏差的均值，作为预测准确性
    mean(abs(pred - x[(k+1):n]))
}

#####################################
library(pixmap)
setwd("~/Documents/playground/easypy/notebooks/self")

mt <- read.pnm("dataset/mtrush1.pgm")
mt

# @ 表示是 S4，不是 S3($)
str(mt)

plot(mt)


# grey 是灰度，0 是黑色，1 是白色
mt2 <- mt
mt2@grey[84:163, 135:177] <- 1
plot(mt2)

blur_img <- function(img, rows, cols, q) {
    lrows <- length(rows)
    lcols <- length(cols)

    newimg <- img

    # 模拟噪音，是在固定大小的范围内的
    random_noise <- matrix(nrow = lrows, ncol = lcols, runif(lrows * lcols))

    # newimg 是完整的，除了有噪音的部分外，还有原先的；
    # 只在噪音区域，q 才有用；非噪音区域，保持原样；
    newimg@grey[rows, cols] <- (1-q) * img@grey[rows, cols] + q * random_noise

    return(newimg)
}

mt3 <- blur_img(mt, 84:163, 135:177, 0.5)
plot(mt3)

##########################
# 求矩阵中最小值，所在的行/列
# 这里利用了上三角矩阵
# 矩阵是对称矩阵
imin <- function(x) {
    lx <- length(x)

    # 当前行
    i <- x[lx]

    # 上三角矩阵，并且不要最后一列，取最小值的位置（相对于对角线）
    j <- which.min(x[(i + 1):(lx - 1)])

    # 把相对于对角线的坐标，变换成相对于第 1 列的坐标
    k <- i + j

    # 返回值是 vector，两个元素，列序号，最小元素
    return(c(k, x[k]))
}

mind <- function(d) {
    n <- nrow(d)

    # 矩阵中没有行号，所以增加一列，记录当前行
    dd <- cbind(d, 1:n)

    # 最后一行不用考虑，因为 imin 使用了上三角矩阵
    wmins <- apply(dd[-n, ], 1, imin)

    # 取最小元素中的最小的下标，也即：最小值所在的行
    i <- which.min(wmins[2,])
    # 最小值所在的列
    j <- wmins[1, i]

    return(c(d[i, j], i, j))
}

q <- matrix(c(0,12,13,8,20,
              12,0,15,28,88,
              13,15,0,6,9,
              8,28,6,0,33,
              20,88,9,33,0), nrow = 5, byrow = TRUE)

mind(q)
