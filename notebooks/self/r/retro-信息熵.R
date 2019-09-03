log2(2)
log2(0.75)
log2(3/8)


log2(1/18)
log2(1/6)


x <- c(3/8, 1/4, 1/4, 1/8)
log2(x)

x <- c(1/4, 3/4)

log2(x)

sum(x*log2(x))


x <- c(1/3, 2/3)
sum(x*log2(x))


x1 <- c(4/14, 10/14)
a1 <- sum(x1*log2(x1))

1/14 * log2(14/10) + 10/14 * log2(14/10)

x2 <- c(5/14, 9/14)
a2 <- sum(x2*log2(x2))

a1* (1/3) + a2 * (2/3)


x <- c(2/38, 18/36, 18/36)
sum(x * log2(x))

log2(38)

x <- c(7/24, 1/24, 1/24, 1/4, 1/24, 1/24, 7/24)
-1 * sum(x * log2(x))

log2(3)

2.301098 - log2(3)

x <- c(0.7, 0.3)
sum(x * log2(x))

x <- c(3/8, 1/8, 1/16, 7/16)
a <- sum(x * log2(x))

1 - b + a
b
s
a

(3/8) * log2(12/7) + (1/16) * log2(2/7)
(6/7) * log2(12/7) + (1/7) * log2(2/7)


2 / 2.857


a1 <- c(0.9143, 0.0857)
b1 <- c(0.2, 0.8)

0.7 * (sum(a1 * log2(a1))) + 0.3 * sum(b1 * log2(b1))


(2.1 * 10^6 ) / (4 * log2(10))

4 * log2(10)


b1 <- c(1/3, 1/3, 1/3)
sum(b1 * log2(b1)) * (3/4) - (1/4)

(3/4)*log2(3) + (1/4)


b2 <- c(1/4, 1/8, 1/8, 1/6, 1/12, 1/6, 1/12)
sum(b2 * log2(b2))

################
# P37, 例题：2-13
# 已知：转换矩阵（条件概率），和边缘概率（先验概率），求：联合熵

# -- 条件概率 p(ij)，每行都是概率向量，也即：每行相加为 1
a <- c(9/11, 2/11, 0, 1/8, 3/4, 1/8, 0, 2/9, 7/9)

ma <- matrix(a, nrow = 3, byrow = TRUE)
ma

# 边缘概率 p(i)，也是先验概率
b <- c(11/36, 4/9, 1/4)

# 生成对角阵
mb <- diag(b, nrow = 3)
mb

# 联合概率，P(AB) = P(B|A) * P(A)
# 直观逻辑是，每行乘以对应的边缘概率；
# 是行操作，所以对角阵乘在左边，结果是：右边矩阵行的线性组合（按照左边矩阵每行）；
mc <- B %*% A
mc


# 条件概率，去掉概率为 0；因为 0 对应熵为 0；
p_i_over_j <- a[a>0]

# 把联合概率转成 vector
e <- as.vector(mc)
p_i_and_j <- e[e>0]

# 熵 = 自信息的加权平均，权为联合概率，数值和熵保持一致
h_i_over_j = sum(p_i_and_j * log2(p_i_over_j))
h_i_over_j



###########
a <- c(1/2, 1/4, 1/16, 1/16, 1/16, 1/16)
-1 * sum(a * log2(a))
# 2

# 注意，加总后，熵变小了
a <- c(1/2, 1/4, 1/4)
-1 * sum(a * log2(a))
# 1.5

1/4 + 1/8 + 1/32

log2(0.5)

log2(0.1)


#################
# p76 习题 3-1
# x 的边缘概率，也成为先验概率
p_x <- c(3/4, 1/4)
h_x <- (-1) * sum(p_x * log2(p_x))

m_x <- diag(p_x, nrow=2)
m_x

# 状态转移矩阵，x -> y, 是条件概率，y over x
m_y_over_x <- matrix(c(2/3, 1/3, 1/3, 2/3), nrow = 2, byrow = TRUE)
m_y_over_x

# 联合概率
m_x_and_y = m_x %*% m_y_over_x

# 转成向量，联合概率
p_x_and_y <- as.vector(m_x_and_y)

# 条件概率
p_y_over_x <- as.vector(m_y_over_x)

# 条件熵的定义：sum(联合概率 * 条件概率的自信息量)
h_y_over_x <- (-1) * sum(p_x_and_y * log2(p_y_over_x))

h_y_over_x

# y 的边缘概率
m_x_and_y

p_y <- c(sum(m_x_and_y[,1]), sum(m_x_and_y[,2]))
p_y

h_y <- -1 * sum(p_y * log2(p_y))

# 互信息
i_x_y <- h_y - h_y_over_x
i_x_y

# 利用互信息的对称性，计算 x over y 的熵
# y over x 的熵，根据 状态转移矩阵 可直接计算
h_x_over_y <- h_x - i_x_y
h_x_over_y

#########
# p76 3-3
# 传 100 个 symbol 错 1 个
a <- c(0.99, 0.01)

# 信道容量，按公式计算；
# 单位是 bit / symbol
c <- log2(2) + sum(a * log2(a))

# 1s 传输 1000 个 symbols，那么 1s 传输多少 bits
ct <- 1000 * c
ct


#####################
e
