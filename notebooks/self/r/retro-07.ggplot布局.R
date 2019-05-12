# 布局 grid 
require(Rmisc)

data <- airquality
names(data)


# 我想用箱线图展示每个月份下上述4个测量值的变化，那么可以用代码一张一张分别作图，
# 也可以用lapply函数进行循环作图，为了代码的整洁肯定选用后者
# parse和eval函数，前者将x类型转化为表达式（但不求解），后者则是对表达式求解，我也是长见识了
vars <- names(data)[1:4]
vars
p <- lapply(vars, function(x){
    ggplot(data, aes(x = factor(Month), y = eval(parse(text = x)))) +
        geom_boxplot(na.rm = T,  aes(fill=factor(Month))) +
        labs(y = x, title = paste0(x, " In Different Months")) +
        theme_light() +
        theme(plot.title = element_text(hjust = 0.5)) +
        guides(fill = "none")
})
# p为列表，p[[1]]代表第一张图

# 布局：2 * 2
multiplot(plotlist = p[1:4], cols = 2)  

# 布局：1 * 1 * 2
multiplot(plotlist = p[1:3], layout = matrix(c(1,2,3,3), nrow = 2))

multiplot(plotlist = p[1:3], layout = matrix(c(1,2,3,3), nrow = 2, byrow = T))


## viewport 
library(grid)

draw <- function() {
    grid.newpage()
    pushViewport(viewport(layout = grid.layout(3,4)))
    
    print(p[[1]], vp = viewport(layout.pos.row = 1:3, layout.pos.col = 1))
    print(p[[2]], vp = viewport(layout.pos.row = 1, layout.pos.col = 2:3))
    print(p[[3]], vp = viewport(layout.pos.row = 3, layout.pos.col = 2:3))
    print(p[[4]], vp = viewport(layout.pos.row = 1:3, layout.pos.col = 4))
}

draw() 
