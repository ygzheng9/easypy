# 演示最基础的非监督分类：kmean, kmodiod, CLARA
# 1. 事先确定分几组，通过类似 scree 碎石图 可以看出；
# 2. 对结果进行可视化时，背后的逻辑是 PCA，fviz_xxx 自动完成；

install.packages("cluster")

# install.packages("devtools")
# devtools::install_github("kassambara/factoextra")

install.packages("factoextra")
install.packages("fpc")

rm(list = ls())
library(factoextra)

data("USArrests") # Loading
head(USArrests, 3) # Print the first 3 rows

head(USArrests$Murder)

USArrests[, 'Murder']


data("USArrests") # Load the data set
df <- USArrests # Use df as shorter name

df <- na.omit(df)

# 标准化
df <- scale(df)
head(df, n = 3)


# Subset of the data
# Take 15 random rows
# Subset the 15 rows
# Standardize the variables
set.seed(123)
ss <- sample(1:50, 15)
df <- USArrests[ss, ]
df.scaled <- scale(df)


# 3.4.3 Computing euclidean distance

dist.eucl <- dist(df.scaled, method = "euclidean")

dist.eucl

# Reformat as a matrix
# Subset the first 3 columns and rows and Round the values
round(as.matrix(dist.eucl)[1:3, 1:3], 1)



# 3.4.4 Computing correlation based distances
# Compute
dist.cor <- get_dist(df.scaled, method = "pearson")
# Display a subset
round(as.matrix(dist.cor)[1:3, 1:3], 1)


# 3.5 Visualizing distance matrices

fviz_dist(dist.eucl)

fviz_dist(dist.cor)


# 4. K-Means Clustering
df <- scale(USArrests) # Scaling the data

# View the firt 3 rows of the data
head(df, n = 3)

# 观察下分几组合适，结果是 4 组；
fviz_nbclust(df, kmeans, method = "wss") +
    geom_vline(xintercept = 4, linetype = 2)

# Compute k-means with k = 4
set.seed(123)
km.res <- kmeans(df, 4, nstart = 25)

# Print the results
print(km.res)

# It’s possible to compute the mean of each variables by clusters using the original data:
aggregate(USArrests, by=list(cluster=km.res$cluster), mean)


# If you want to add the point classifications to the original data, use this:
dd <- cbind(USArrests, cluster = km.res$cluster)
head(dd)


# Cluster number for each of the observations
km.res$cluster
head(km.res$cluster, 4)

# Cluster size
km.res$size

# Cluster means
km.res$centers

# 通过 PCA 处理，显示在 x-y 平面
fviz_cluster(km.res, data = df,
             palette = c("#2E9FDF", "#00AFBB", "#E7B800", "#FC4E07"), ellipse.type = "euclid", # Concentration ellipse star.plot = TRUE, # Add segments from centroids to items repel = TRUE, # Avoid label overplotting (slow)
             ggtheme = theme_minimal()
)


# 5. K-Medoids
# k-means 对 outliers 敏感，所以有了新的算法
library(cluster)


df <- scale(USArrests) # Scale the data
head(df, n = 3) # View the firt 3 rows of the data

# The R function fviz_nbclust() [factoextra package] provides a convenient solution to estimate the optimal number of clusters.
fviz_nbclust(df, pam, method = "silhouette")+
    theme_classic()

# k-means 中使用的是 4， pam 中使用的是 2；其实，即使使用 4，分出的 4 组，也不完全相同，但是很相近；
pam.res <- pam(df, 2)
print(pam.res)

# If you want to add the point classifications to the original data, use this:
dd <- cbind(USArrests, cluster = pam.res$cluster)
head(dd, n = 3)

# Cluster medoids: New Mexico, Nebraska
pam.res$medoids

# Cluster numbers
head(pam.res$clustering)

fviz_cluster(pam.res,
             palette = c("#00AFBB", "#FC4E07"), # color palette
             # palette = c("#2E9FDF", "#00AFBB", "#E7B800", "#FC4E07"),
             ellipse.type = "t", # Concentration ellipse repel = TRUE, # Avoid label overplotting (slow) ggtheme = theme_classic()
)

nrow(df)


# 6. CLARA Algorithm: Clustering Large Applications
set.seed(1234)
# Generate 500 objects, divided into 2 clusters.
df <- rbind(cbind(rnorm(200,0,8), rnorm(200,0,8)), cbind(rnorm(300,50,8), rnorm(300,50,8)))

# Specify column and row names
colnames(df) <- c("x", "y")

rownames(df) <- paste0("S", 1:nrow(df))

# Previewing the data
head(df, nrow = 6)

# From the plot, the suggested number of clusters is 2.
# In the next section, we’ll classify the observations into 2 clusters.
fviz_nbclust(df, clara, method = "silhouette")+
    theme_classic()


# Compute CLARA
clara.res <- clara(df, 2, samples = 50, pamLike = TRUE)

# Print components of clara.res
print(clara.res)

dd <- cbind(df, cluster = clara.res$cluster)
head(dd, n = 4)

# Medoids
clara.res$medoids

# Clustering
head(clara.res$clustering, 10)

fviz_cluster(clara.res,
             palette = c("#00AFBB", "#FC4E07"), # color palette
             ellipse.type = "t", # Concentration ellipse geom = "point", pointsize = 1,
             ggtheme = theme_classic()
)


# 7. Agglomerative Clustering
# Load the data
data("USArrests")
# Standardize the data
df <- scale(USArrests)
# Show the first 6 rows
head(df, nrow = 6)

nrow(df)

# Compute the dissimilarity matrix
# df = the standardized data
res.dist <- dist(df, method = "euclidean")

# The R code below displays the first 6 rows and columns of the distance matrix:
as.matrix(res.dist)[1:6, 1:6]

res.hc <- hclust(d = res.dist, method = "ward.D2")

# cex: label size
library("factoextra")

fviz_dend(res.hc, cex = 0.5)
