install.packages("BiocManager")
BiocManager::install("ComplexHeatmap")

library(ComplexHeatmap)
library(circlize)
library(dendextend)

set.seed(123)
nr1 = 4; nr2 = 8; nr3 = 6; nr = nr1 + nr2 + nr3
nc1 = 6; nc2 = 8; nc3 = 10; nc = nc1 + nc2 + nc3
mat = cbind(rbind(matrix(rnorm(nr1*nc1, mean = 1,   sd = 0.5), nr = nr1),
                  matrix(rnorm(nr2*nc1, mean = 0,   sd = 0.5), nr = nr2),
                  matrix(rnorm(nr3*nc1, mean = 0,   sd = 0.5), nr = nr3)),
            rbind(matrix(rnorm(nr1*nc2, mean = 0,   sd = 0.5), nr = nr1),
                  matrix(rnorm(nr2*nc2, mean = 1,   sd = 0.5), nr = nr2),
                  matrix(rnorm(nr3*nc2, mean = 0,   sd = 0.5), nr = nr3)),
            rbind(matrix(rnorm(nr1*nc3, mean = 0.5, sd = 0.5), nr = nr1),
                  matrix(rnorm(nr2*nc3, mean = 0.5, sd = 0.5), nr = nr2),
                  matrix(rnorm(nr3*nc3, mean = 1,   sd = 0.5), nr = nr3))
)
mat = mat[sample(nr, nr), sample(nc, nc)] # random shuffle rows and columns
rownames(mat) = paste0("row", seq_len(nr))
colnames(mat) = paste0("column", seq_len(nc))

Heatmap(mat)

col_fun = colorRamp2(c(-2, 0, 2), c("green", "white", "red"))
col_fun(seq(-3, 3))
Heatmap(mat, name = "mat", col = col_fun)


Heatmap(mat, col = colorRamp2(c(-3, 0, 3), c("green", "white", "red")), 
        cluster_rows = FALSE, cluster_columns = FALSE)



set.seed(1)

mat = cbind(rbind(matrix(rnorm(16, -1), 4), matrix(rnorm(32, 1), 8)),
            rbind(matrix(rnorm(24, 1), 4), matrix(rnorm(48, -1), 8)))

# permute the rows and columns
mat = mat[sample(nrow(mat), nrow(mat)), sample(ncol(mat), ncol(mat))]
rownames(mat) = paste0("R", 1:12)
colnames(mat) = paste0("C", 1:10)

# color for dendrogram
dend = hclust(dist(mat))
dend = color_branches(dend, k = 2)

Heatmap(mat,name = "foo", 
        column_title = "This is a column title",
        column_names_side = "top",
        row_title_rot = 90, 
        column_title_rot = 0,
        col = colorRamp2(c(-3, 0, 3), c("green", "white", "red")),
        cluster_rows = dend, 
        row_dend_side = "left",
        row_names_side = "left",
        row_title = c("cluster1","cluster2"),
        column_dend_height = unit(2, "cm"),
        clustering_method_rows = "complete",
        split = 2,
        row_title_gp = gpar(col = c("red", "green")),
        #        row_names_gp = gpar(col = c("red", "green")),
        cell_fun = function(j, i, x, y, width, height, fill) {
            grid.text(sprintf("%.1f", mat[i, j]), x, y, gp = gpar(fontsize = 10))
            grid.rect(x = x, y = y, width = width, height = height, gp = gpar(col = "grey", fill = NA))
        }
)
