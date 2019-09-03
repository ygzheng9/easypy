library("FactoMineR")
library("factoextra")

rm(list = ls())

# 演示：PCA, SVD, eigenValue/eigVector 之间的关系

# 计算累计值，累积比例
printCum <- function(d) {
    data.frame(d, d / sum(d), cumsum(d) / sum(d))
}


# 单位化向量，注意，不是 scale，scale 是标准化到 N(0,1) 下，单位化只要保证 xt*x = 1 即可
normalize_vector = function(x) {
    x / sqrt(sum(x * x))
}

##############

# 第 5 列是 category，去除
d1 <- iris[, -5]
dim(d1)
# 150 * 4

d2 = t(d1)
dim(d2)
# 4 * 150

# dataframe -> matrix
# m1 是初始矩阵，150 * 4，每行是观测对象，每列代表 variable
m1 <- as.matrix(d1)
m2 <- as.matrix(d2)

# 构造对角阵 At * A
d3 <- m2 %*% m1
dim(d3)
# 4 * 4
d3

# 相关系数：At * A，也即结果是：A 的列之间的关系
d4 <- cor(m1)
dim(d4)
d4

# 特征值分解，这里的特征向量已经标准化
# d3 是对阵矩阵
test.eig = eigen(d3)
summary(test.eig)
print(test.eig)

test.eig$vectors[,1]

# 使用特征值，构造对角阵，进行矩阵还原
a <- diag(test.eig$values)
test.eig$vectors %*% a %*% t(test.eig$vectors)

###################
# 直接对初始矩阵做 SVD 分解
test.svd <- svd(m1)
summary(test.svd)
print(test.svd)
test.svd

# 特征值: At*A 特征值的 开根号
test.svd$d
test.eig$values
sqrt(test.eig$values)

# v 和 At*A 的特征向量一样
test.svd$v
test.eig$vectors

# 对原矩阵还原
a <- test.svd$u %*% diag(test.svd$d) %*% t(test.svd$v)
head(m1)
head(a)

# 特征值从大到小占比，也即：碎石图
data.frame(test.svd$d, test.svd$d / sum(test.svd$d), cumsum(test.svd$d) / sum(test.svd$d))
data.frame(test.eig$values, test.eig$values / sum(test.eig$values), cumsum(test.eig$values) / sum(test.eig$values))

par(mfrow=c(1, 2))
plot(test.svd$d, type = "o", main = "scree Plot", xlab = "Component Number", ylab = "Eigen Value")
plot(cumsum(test.svd$d) / sum(test.svd$d), type = "o", main = "Cumulative Ratio", xlab = "Component Number", ylab = "Cumulative Ratio")

# 初始矩阵 * v = 在新坐标系的坐标
m1 %*% test.svd$v

#####################
##### 先对原始数据做单位化，再做 SVD，和 prcomp 一致，但是和 PCA 不一致
m1_scaled <- scale(m1, center = TRUE, scale = TRUE)

# 对称阵的 eigen
test.eig2 <- eigen(t(m1_scaled) %*% m1_scaled)

## 直接 svd 分解
test.svd2 <- svd(m1_scaled)

# 对称阵的特征向量，和直接 svd 的 v 是一个东西
test.svd2$v
test.eig2$vectors

# 特征值的开方，就是 svd 中的 d
printCum(test.svd2$d)
printCum(sqrt(test.eig2$values))

# svd 中的 d 的碎石图，和 pca 中主成分占比是一个东西
par(mfrow=c(1, 2))
plot(test.svd2$d, type = "o", main = "scree Plot", xlab = "Component Number", ylab = "Eigen Value")
plot(cumsum(test.svd2$d) / sum(test.svd2$d), type = "o", main = "Cumulative Ratio", xlab = "Component Number", ylab = "Cumulative Ratio")

###############
## 对初始矩阵做 pca
# test.pca <- prcomp(m1, scale = TRUE)
test.pca <- prcomp(m1_scaled)

test.pca
summary(test.pca)
print(test.pca)
str(test.pca)

# 和 scaled 后的 svd 分解结果一致
printCum(test.pca$sdev)
printCum(test.svd2$d)
printCum(sqrt(test.eig2$values))

# 碎石图计算方差占比，sdev 是开过根号的，所以要平方
printCum(test.pca$sdev^2)
printCum(test.svd2$d^2)
printCum(test.eig2$values)


# 新成分，和原变量 之间的对应关系，这三种方法得到的结果是一样的
test.pca$rotation
test.svd2$v
test.eig2$vectors

# 观测对象在新坐标系的新坐标
# 右乘 v，相当于 v 在右侧，左边有多个 行向量(老坐标系下的坐标) 乘 v，相当于对 v 做行的线性组合，
# v 的行是 老变量，列是 新变量；--> 直观理解：换基的要求；或者，从公式上看，公式表明 v 一定是这样的结构；
# (左侧矩阵)右乘列向量，表示对(左侧矩阵的)列的线性组合；--> 多个右乘列向量，构成了右乘矩阵的列；
# (右侧矩阵)左乘行向量，表示对(右侧矩阵的)行的线性组合；--> 多个左乘行向量，构成了左乘矩阵的行；
head(test.pca$x, 5)
head(m1_scaled %*% test.pca$rotation, 5)
head(m1_scaled %*% test.svd2$v, 5)
head(m1_scaled %*% test.eig2$vectors, 5)

## 通过 u，也能找到新坐标系下的坐标
head(test.svd2$u %*% diag(test.svd2$d), 5)

####### 总结
# pca
# 1. 主成分方差及占比（碎石图），
# 2. 主成分和原变量的对应关系（loading），这是个方阵，loading；也即：svd 中得到的 v；
# 3. 如果只取前两个主成分，可以把原变量投影在主成分的平面上，散点图，或雷达图，
# 4. 观测值在主成分下的新坐标，维度数量没有变，但是前两个维度非常重要，因此可以投影到平面；
# 5. 新坐标 = 原坐标 * svd.v ，或者，新坐标 = svd.v * diag(svd.d)
# svd 的 u, d, v，与之对应的是 at*a，是对称阵，特征值，特征向量；
# v,d  是 关注对象，因为 at*a 之后，u 抵消了，只剩下 v 和 d；
# v 是 对称阵的特征向量；
# d 是 对称阵的特征值的开方；
# 处理前，一定要先标准化；
###############


###### 使用另一个 PCA，两种方法输出结果数值不一样：
# 1. 特征值：方差(对称阵的特征向量) vs 方差的开方(特征向量的开方，或 svd 中的 sigma)
# 2. looading 矩阵：非单位向量 vs 单位向量

# PCA 默认会做标准化
# test.pca2 <- PCA(m1_scaled, scale.unit = TRUE)
test.pca2 <- PCA(m1)

test.pca2

# 每个主成分的方差及占比
test.pca2$eig
# 对应的是 对称阵的特征向量，是 svd.d 的平方
printCum(test.pca$sdev^2)
printCum(test.svd2$d^2)
printCum(test.eig2$values)

# 主成分 和 原变量 的转换矩阵
test.pca2$var$coord

# 和 prcomp 不一致，
test.pca$rotation

x1 <- test.pca2$var$coord[,1]
x2 <- test.pca$rotation[,1]

# PCA 是未单位化的向量， prcomp 是单位化后的
x1 %*% x1
x2 %*% x2

# 相差一个系数, 正好是单位化的系数
c <- x1 / x2
c

# 单位化后，和 x2 一样
normalize_vector(x1)
x2

# 数据在主成分下的坐标
head(test.pca2$ind$coord, 5)

# 有细微差异，据说是因为协方差的 n-1 导致
head(test.pca$x, 5)

head(m1_scaled %*% test.pca2$var$coord, 5)

# 协方差要除以 n-1

symm1 <- ( t(m1_scaled) %*% m1_scaled ) / (4 - 1)

test.symm.eig <- eigen(symm1)

# 特征值只相差了 n-1
printCum(test.symm.eig$values)
printCum(test.eig2$values / (4-1))

# eigen 特征向量是单位化的，也即：长度为 1
y1 <- test.symm.eig$vectors[,1]
y1 %*% y1

# PCA 结果的是未单位化的，单位化后，两者一样；


