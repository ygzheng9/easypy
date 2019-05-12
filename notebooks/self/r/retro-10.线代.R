# 列向量
v <- c(1:3)

# 内积
crossprod(v)
crossprod(v, v)
v %*% v

# 生成矩阵，数字首先是按列填充
m <-  matrix(c(2,2:9), nrow = 3)
m

# 矩阵 * scaler
m * 2

# 叉积，右手规则
crossprod(m, v)

# 矩阵 乘以 向量 (列空间的线性组合)
m %*% v


# 求逆
solve(m)

# 解方程
solve(m, v)

# 求对角阵（直接返回对角线上的元素）
diag(m)

# 得到 n 阶单位阵
diag(3)

# 特征值、特征向量
eigen(m)

# RQ 分解
qr(m)


# Cholesky 分解
m3 <- m %*% solve(m) *2
m3

chol(m3)

# PCA
a <- matrix(c(0.9, 2.4, 1.2, 0.5, 0.3, 1.8, 0.5, 0.3, 2.5, 1.3, 
              1, 2.6, 1.7, 0.7, 0.7, 1.4, 0.6, 0.6, 2.6, 1.1), ncol=2)

b <- t(a) %*%  a 
b

eig <- eigen(b)

max_vector <- eig$vectors[,1]

a %*% max_vector



