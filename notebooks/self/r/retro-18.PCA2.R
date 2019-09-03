# 演示：PCA 及 fviz_xxx 可视化

##################
library(psych)
dim(USJudgeRatings)
# 43 * 12

fa.parallel(USJudgeRatings[, -1], fa="both", n.iter = 100, show.legend = FALSE, main = "Scree with parallel analysis")

pc <- principal(USJudgeRatings[,-1], nfactors = 5)
pc
###################

library("FactoMineR")
library("factoextra")

rm(list = ls())

# from PCA.pdf

# 每一行对应一个 sample，每一列是 variable
# data("decathlon2")

# 1~23 行，1~10 列
decathlon2.active <- decathlon2[1:23, 1:10]

# ncp 保留多少主成分，默认是 5
res.pca <- PCA(decathlon2.active, graph = FALSE)
summary(res.pca)
print(res.pca)

# 因为是 10 列，也即：有 10 个维度，所以 eigValue 也是 10 个
# get_eigenvalue(res.pca)
# eigenvalue > 1 表示 该成分 代表的方差比 单一变量大，可以作为过滤点
res.pca$eig

# scree 碎石图
fviz_eig(res.pca, addlabels = TRUE, ylim = c(0, 45))

# 雷达图：在前两个主成分下，观测：原变量(variables)，原观测对象(individuals)，两者都观察
fviz_pca_var(res.pca)
fviz_pca_ind(res.pca)
fviz_pca_biplot(res.pca)

# 变量 和 主成分 的对应
res.pca$var$coord

# cos2 是对应的平方
dim(res.pca$var$cos2)
head(res.pca$var$cos2, 5)
res.pca$var$coord^2

# 贡献度
res.pca$var$contrib
x <- res.pca$var$cos2[,1]
x / sum(x)

# 关系可视化
library("corrplot")
corrplot(res.pca$var$cos2, is.corr = FALSE)

fviz_cos2(res.pca, choice = "var", axes = 1:2)

# col.var = "cos2" 可以作为颜色显示
# cos2 contrib
fviz_pca_var(res.pca)
fviz_pca_var(res.pca, col.var = "cos2",
             gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"),
             repel = TRUE)

# contribution
corrplot(res.pca$var$contrib, is.corr = FALSE)

fviz_contrib(res.pca, choice = "var", axes = 1:2, top = 10)
#fviz_contrib(res.pca, choice = "var", axes = 2, top = 10)

# 对 loading 分组
set.seed(123)
res.km <- kmeans(res.pca$var$coord, centers = 3, nstart = 25)
res.km

attributes(res.pca$var$coord)

summary(res.km$cluster)
print(res.km$cluster)
class(res.km$cluster)
str(res.km$cluster)
typeof(res.km$cluster)
attributes(res.km$cluster)
res.km$cluster

# 取得分组
grp <- as.factor(res.km$cluster)
grp

class(grp)
str(grp)
attributes(grp)
names(grp[10])
names(grp)

# 通过 行的名字 关联在一起
rownames(res.pca$var$coord)
names(res.km$cluster)
names(grp)

# 设置绘图参数： col.var, palette, gradient.cols, repel
fviz_pca_var(res.pca, col.var = grp,
             palette = c("#00AFBB", "#E7B800", "#FC4E07"),
             legend.title = "Cluster",
             repel = TRUE)

# dimension description
res.desc <- dimdesc(res.pca, axes = c(1,2), proba = 0.05)
res.desc


#############
## 在 with 内部，不会修改外部的变量
rm(list=ls())

a <- 1
with(iris, {
    print(a)
    # print(b)
    a <- 50
    b <- 100
    print(paste0("a = ", a, ", b = ", b))
})

print(a)

##############
## 相关系数的可视化
rm(list=ls())

library(corrplot)

M <- cor(mtcars)
corrplot(M, method = "circle", type = "upper")
corrplot(M, method = "square")
# 多种显示方式："circle", "square", "ellipse", "number", "shade", "color", "pie".
# type: 显示方式，full/upper/lower(正方形，上三角，下三角)

# "FPC" for the first principal component order.
# "AOE" is for the angular order of the eigenvectors.
corrplot(M, order = "FPC")
corrplot(M, order = "AOE")

## visualize a  matrix in [-100, 100]
ran <- round(matrix(runif(225, -100,100), 15))
corrplot(ran, is.corr = FALSE)

corrplot(cor(ran))


