#########
##### 预备知识
# 特征值 最大，对应的 特征向量 方向上的 形变 越厉害；是主要变换的方向 PCA；

a <- matrix(c(1,3,3,1/3,1,9,1/3,1/9,1), 3,3,byrow=TRUE)
a

ev <- eigen(a)

ev

b <- c(-0.8147522, -0.5649176,-0.1305640)

b * b

a %*% b

3.560 * b


######################

# PCA 降维

### 示例 1： iris 数据分析, 删除 Species 列（这列是字符串，而不是数字）
iris_data <- select(iris,-Species)
head(iris_data)

# 标准包中的 pca 函数
iris.pca<-princomp(iris_data,cor = T)
names(iris.pca)

summary(iris.pca, loadings = T)

iris.pca$loadings

# scores 和 predict 是一致的，
iris.pca$scores

######################### 
# 示例 2
student<- data.frame(  
        x1=c(148,139,160,149,159,142,153,150,151),  
        x2=c(41 ,34 , 49 ,36 ,45 ,31 ,43 ,43, 42),  
        x3=c(72 ,71 , 77 ,67 ,80 ,66 ,76 ,77,77),  
        x4=c(78 ,76 , 86 ,79 ,86 ,76 ,83 ,79 ,80)  
    )
    
# PCA 分解，本质是 A * At 的特征值和特征向量
student.pr <- princomp(student, cor=TRUE)        

# x1~x4 为属性(维度)，有 4 个，观测对象有 9 个
# PCA 分解后，最多就有 4 个属性(维度)，并且每个属性的方差是急剧下降的；
summary(student.pr, loadings=TRUE)

# loadings： 新维度 Comp.1 = 0.510*x1 + 0.513*x2 + 0.473*x3 + 0.504*x4
##
# Importance of components:
#     Comp.1     Comp.2     Comp.3      Comp.4
# Standard deviation     1.884603 0.57380073 0.30944099 0.152548760
# Proportion of Variance 0.887932 0.08231182 0.02393843 0.005817781
# Cumulative Proportion  0.887932 0.97024379 0.99418222 1.000000000
# 
# Loadings:
#     Comp.1 Comp.2 Comp.3 Comp.4
# x1  0.510  0.436  0.139  0.728
# x2  0.513 -0.172  0.741 -0.398
# x3  0.473 -0.761 -0.396  0.201
# x4  0.504  0.448 -0.524 -0.520
##


# 查看每个新维度下的 方差
plot(student.pr)

# 查看每个维度的方查看占比累积图(碎石图，碎石从山上滚落)
screeplot(student.pr,type="lines")

# 以前两个维度为基准，查看散点图
biplot(student.pr)

# 把原来的观测值，都转换到新的四个维度下
temp <- predict(student.pr) 

# 前两个维度方差贡献了 97%，所以，以前两个维度为轴，看散点图；
plot(temp[,1:2])




#################################################################################
# 示例 3： 
library("FactoMineR")
library("factoextra")

data(decathlon2)
head(decathlon2)

# We start by subsetting active individuals and active variables for the principal component analysis:
decathlon2.active <- decathlon2[1:23, 1:10]
head(decathlon2.active[, 1:6], 4)

res.pca <- PCA(decathlon2.active, graph = FALSE)
print(res.pca)
# 
# get_eigenvalue(res.pca): Extract the eigenvalues/variances of principal components
# fviz_eig(res.pca): Visualize the eigenvalues
# get_pca_ind(res.pca), get_pca_var(res.pca): Extract the results for individuals and variables, respectively.
# fviz_pca_ind(res.pca), fviz_pca_var(res.pca): Visualize the results individuals and variables, respectively.
# fviz_pca_biplot(res.pca): Make a biplot of individuals and variables.


eig.val <- get_eigenvalue(res.pca)
eig.val

# 碎石图
fviz_eig(res.pca, addlabels = TRUE, ylim = c(0, 50))

# 取得方差信息
var <- get_pca_var(res.pca)
var

# Coordinates
head(var$coord)
# Cos2: quality on the factore map
head(var$cos2)
# Contributions to the principal components
head(var$contrib)

#  variable correlation plots
fviz_pca_var(res.pca, col.var = "black")

library("corrplot")
corrplot(var$cos2, is.corr=FALSE)

# Color by cos2 values: quality on the factor map
fviz_pca_var(res.pca, col.var = "cos2",
             gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"), 
             repel = TRUE # Avoid text overlapping
)


# The variable Species (index = 5) is removed
# before PCA analysis
iris.pca <- PCA(iris[,-5], graph = FALSE)

fviz_pca_ind(iris.pca,
             geom.ind = "point", # show points only (nbut not "text")
             col.ind = iris$Species, # color by groups
             palette = c("#00AFBB", "#E7B800", "#FC4E07"),
             addEllipses = TRUE, # Concentration ellipses
             legend.title = "Groups"
)

#################################################################################
# 示例 4： 
library("FactoMineR")
library("factoextra")

data(decathlon2)
data <- decathlon2[1:23, 1:10]
head(data)

# 自带了列的标准化
res.pca <- PCA(data, graph = FALSE)

# 新维度，新维度对应的特征值，特征值的方差占比，方差累积占比
# Kaiser-Harris准则建议保留特征值大于1的主成分
eig.val <- get_eigenvalue(res.pca)
eig.val

# 碎石图
fviz_eig(res.pca, addlabels = TRUE, ylim = c(0, 50))

# 展示变量与主成分之间的关系，以及变量之间的关联
fviz_pca_var(res.pca, col.var = "black")

# 提取变量信息
var <- get_pca_var(res.pca)
var

# 还有Quality of representation（对应var$cos2），
# 用于展示每个变量在各个主成分中的代表性（高cos2值说明该变量在主成分中有good representation，
# 对应在Correlation circle图上则是接近圆周边上；低cos2值说明该变量不能很好的代表该主成分，
# 对应Correlation circle图的圆心位置）；对于变量来说，所有主成分上cos2值的和等于1，
# 所以变量在越少主成分下累计cos2值接近于1，则其在Correlation circle上处于圆周圈上
library("corrplot")
corrplot(var$cos2, is.corr=FALSE)

# 如果一个变量在PC1和PC2的Contributions很高的话，则说明该变量可有效解释数据的变异，
# 我们可以用图形展示各个变量在PC1和PC2上的Contributions
fviz_pca_var(res.pca, col.var = "contrib",
             gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07")
)


#### 以上均是对变量在PCA中的分析，下面则是观测值的分析
# 先用提取出individuals信息，会发现也有coord，cos2和contrib等信息
ind <- get_pca_ind(res.pca)
ind


# 然后按照上面的模式来展示下individuals的点图，比如以cos2值来代表各个individuals点的圆圈大小
fviz_pca_ind(res.pca, pointsize = "cos2", 
             pointshape = 21, fill = "#E7B800",
             repel = TRUE # Avoid text overlapping (slow if many points)
)

# data(iris)
head(iris)
species = iris[,"Species"]

iris.pca <- PCA(iris, graph = FALSE)
fviz_pca_ind(iris.pca,
             geom.ind = "point", # show points only (nbut not "text")
             col.ind = iris$Species, # color by groups
             palette = c("#00AFBB", "#E7B800", "#FC4E07"),
             addEllipses = TRUE, # Concentration ellipses
             legend.title = "Groups"
)
#########################################

# 示例 4 
# 模拟数据，10000行（变量），30 个观测对象
chip.dat<-matrix(rnorm(10000*30,mean=0),ncol=30,nrow=10000)
head(chip.dat)

# 我把30个样本分为两组，前15列和后15列各为一组，给它们定义不同的颜色：
colour<-c(rep(2,15),rep(3,15))
colour

# 在10000个基因中，我们假定有100个基因在两个组间是有差异的，
# 我们假设其中有50个在前一组是上调的，另50个在前一组中是下调的：
diff.ind<-sample(1:10000,100)
chip.dat[diff.ind[1:50],1:15]<-rnorm(50*15,mean=2)
chip.dat[diff.ind[51:100],1:15]<-rnorm(50*15,mean=-2)
head(chip.dat)

# 进行 PCA 分解
chip.dat.pca<-princomp(chip.dat)
summary(chip.dat.pca)

library(rgl)

plot3d(chip.dat.pca$loadings[,1:3], col=colour, type="s", radius=0.025)
