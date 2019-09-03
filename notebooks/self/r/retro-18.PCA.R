## In this example, the data is in a matrix called
## data.matrix
## columns are individual samples (i.e. cells)
## rows are measurements taken for all the samples (i.e. genes)
## Just for the sake of the example, here's some made up data...

# 逻辑不用看，逻辑查看 2/3; 
# 只需要关注：如何用 ggplot2 直接可视化 PCA 的结果；--> 可以直接使用 fviz_xxx 可视化

## from statquest

rm(list=ls())

## PCA 是把原始维度，通过变换，降低；用降低后的维度，重新表示原来的数据；
## 这里示例：维度是行，观测对象是列，也即：100 个维度，10 个观测对象；
## PCA 之后，还是 100 个维度，只是前几个维度的方差已经占了绝大比例；
data.matrix <- matrix(nrow = 100, ncol = 10)
colnames(data.matrix) <- c(paste("wt", 1:5, sep = ""),
                           paste("ko", 1:5, sep = ""))
rownames(data.matrix) <- paste("gene", 1:100, sep = "")
for (i in 1:100) {
    wt.values <- rpois(5, lambda = sample(x = 10:1000, size = 1))
    ko.values <- rpois(5, lambda = sample(x = 10:1000, size = 1))

    data.matrix[i, ] <- c(wt.values, ko.values)
}
head(data.matrix)
dim(data.matrix)

pca <- prcomp(t(data.matrix), scale = TRUE)

## plot pc1 and pc2
plot(pca$x[, 1], pca$x[, 2])

dim(pca$x)

pca


## make a scree plot
pca.var <- pca$sdev ^ 2
pca.var.per <- round(pca.var / sum(pca.var) * 100, 1)

barplot(pca.var.per,
        main = "Scree Plot",
        xlab = "Principal Component",
        ylab = "Percent Variation")

## now make a fancy looking plot that shows the PCs and the variation:
library(ggplot2)

pca.data <- data.frame(Sample = rownames(pca$x),
                       X = pca$x[, 1],
                       Y = pca$x[, 2])
pca.data

ggplot(data = pca.data, aes(x = X, y = Y, label = Sample)) +
    geom_text() +
    xlab(paste("PC1 - ", pca.var.per[1], "%", sep = "")) +
    ylab(paste("PC2 - ", pca.var.per[2], "%", sep = "")) +
    theme_bw() +
    ggtitle("My PCA Graph")

## get the name of the top 10 measurements (genes) that contribute
## most to pc1.
loading_scores <- pca$rotation[, 1]
gene_scores <- abs(loading_scores) ## get the magnitudes
gene_score_ranked <- sort(gene_scores, decreasing = TRUE)
top_10_genes <- names(gene_score_ranked[1:10])

top_10_genes ## show the names of the top 10 genes

pca$rotation[top_10_genes, 1] ## show the scores (and +/- sign)

#######
##
## NOTE: Everything that follow is just bonus stuff.
## It simply demonstrates how to get the same
## results using "svd()" (Singular Value Decomposition) or using "eigen()"
## (Eigen Decomposition).
##
##
#######

############################################
##
## Now let's do the same thing with svd()
##
## svd() returns three things
## v = the "rotation" that prcomp() returns, this is a matrix of eigenvectors
##     in other words, a matrix of loading scores
## u = this is similar to the "x" that prcomp() returns. In other words,
##     sum(the rotation * the original data), but compressed to the unit vector
##     You can spread it out by multiplying by "d"
## d = this is similar to the "sdev" value that prcomp() returns (and thus
##     related to the eigen values), but not
##     scaled by sample size in an unbiased way (ie. 1/(n-1)).
##     For prcomp(), sdev = sqrt(var) = sqrt(ss(fit)/(n-1))
##     For svd(), d = sqrt(ss(fit))
############################################

svd.stuff <- svd(scale(t(data.matrix), center = TRUE))

## calculate the PCs
svd.data <- data.frame(
    Sample = colnames(data.matrix),
    X = (svd.stuff$u[, 1] * svd.stuff$d[1]),
    Y = (svd.stuff$u[, 2] * svd.stuff$d[2])
)
svd.data

dim(svd.stuff$u)
dim(svd.stuff$v)
svd.stuff$d

## alternatively, we could compute the PCs with the eigen vectors and the
## original data
svd.pcs <-
    t(t(svd.stuff$v) %*% t(scale(t(data.matrix), center = TRUE)))
svd.pcs[, 1:2] ## the first to principal components
dim(svd.pcs)

svd.df <- ncol(data.matrix) - 1
svd.var <- svd.stuff$d ^ 2 / svd.df
svd.var.per <- round(svd.var / sum(svd.var) * 100, 1)

ggplot(data = svd.data, aes(x = X, y = Y, label = Sample)) +
    geom_text() +
    xlab(paste("PC1 - ", svd.var.per[1], "%", sep = "")) +
    ylab(paste("PC2 - ", svd.var.per[2], "%", sep = "")) +
    theme_bw() +
    ggtitle("svd(scale(t(data.matrix), center=TRUE)")

############################################
##
## Now let's do the same thing with eigen()
##
## eigen() returns two things...
## vectors = eigen vectors (vectors of loading scores)
##           NOTE: pcs = sum(loading scores * values for sample)
## values = eigen values
############################################
# data.matrix 是 100 *10，并且 列 是sample，行是 维度；
# t(data.matrix) 把列变成 变量/维度；
# cov 形成 变量*变量 之间的关系，100 * 100
cov.mat <- cov(scale(t(data.matrix), center = TRUE))
dim(cov.mat)

## eig 分解后，都是 100 * 100
## since the covariance matrix is symmetric, we can tell eigen() to just
## work on the lower triangle with "symmetric=TRUE"
eigen.stuff <- eigen(cov.mat, symmetric = TRUE)
dim(eigen.stuff$vectors)
head(eigen.stuff$vectors[, 1:2])


## 最终结果是：每行表示一个 sample，每列是新维度下的坐标值，也即：10 * 100，其中最前面的列，就是最重要的列；
eigen.pcs <-
    t(t(eigen.stuff$vectors) %*% t(scale(t(data.matrix), center = TRUE)))
eigen.pcs[, 1:2]
dim(eigen.pcs)

eigen.data <- data.frame(
    Sample = rownames(eigen.pcs),
    X = (-1 * eigen.pcs[, 1]),
    ## eigen() flips the X-axis in this case, so we flip it back
    Y = eigen.pcs[, 2]
) ## X axis will be PC1, Y axis will be PC2
eigen.data

length(eigen.stuff$values)

eigen.var.per <-
    round(eigen.stuff$values / sum(eigen.stuff$values) * 100, 1)

ggplot(data = eigen.data, aes(x = X, y = Y, label = Sample)) +
    geom_text() +
    xlab(paste("PC1 - ", eigen.var.per[1], "%", sep = "")) +
    ylab(paste("PC2 - ", eigen.var.per[2], "%", sep = "")) +
    theme_bw() +
    ggtitle("eigen on cov(t(data.matrix))")

############################################
data.matrix

cov.mat <- cov(scale(t(data.matrix), center = TRUE))
dim(cov.mat)


dim(data.matrix)
pca <- prcomp(data.matrix, scale. = TRUE)
dim(pca$x)

dim(data.matrix)
d2 <- t(data.matrix)
dim(d2)
pca2 <- prcomp(d2, scale. = TRUE)
dim(pca2$x)

d3 <- t(d2)
dim(d3)
pca3 <- prcomp(d3, scale. = TRUE)
dim(pca3$x)


## plot pc1 and pc2
plot(pca$x[, 1], pca$x[, 2])

# 行列互换后（variable 比 sample 还多），prcomp 出问题了
c1 <- iris[, -5]
c2 <- t(c1)
dim(c2)
tmp.pca2 <- prcomp(c2, scale. = TRUE)
dim(tmp.pca2$x)
tmp.pca2$x


#############
# 使用 iris2，列是 vairable（排除第 5 列），行是 sample
dim(iris[, -5])

tmp.pca <- prcomp(iris[, -5], scale. = TRUE)
summary(tmp.pca)
print(tmp.pca)
str(tmp.pca)
tmp.pca$x

dim(tmp.pca$x)

## make a scree plot
tmp.pca.var <- tmp.pca$sdev ^ 2
tmp.pca.var.per <- round(tmp.pca.var / sum(tmp.pca.var) * 100, 1)

barplot(tmp.pca.var.per,
        main = "Scree Plot",
        xlab = "Principal Component",
        ylab = "Percent Variation")

plot(x=tmp.pca$x[, 1], y=tmp.pca$x[, 2])

## now make a fancy looking plot that shows the PCs and the variation:
library(ggplot2)

tmp.pca.data <- data.frame(
                       X = tmp.pca$x[, 1],
                       Y = tmp.pca$x[, 2])
tmp.pca.data

ggplot(data = tmp.pca.data, aes(x = X, y = Y)) +
    geom_point() +
    xlab(paste("PC1 - ", pca.var.per[1], "%", sep = "")) +
    ylab(paste("PC2 - ", pca.var.per[2], "%", sep = "")) +
    theme_bw() +
    ggtitle("My PCA Graph")




