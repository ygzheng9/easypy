
# 雷达图
# Example from https://github.com/ricardo-bion/ggradar
library(ggplot2)
library(ggradar)
suppressPackageStartupMessages(library(dplyr))
library(scales)
library(tibble)

has_rownames(mtcars)
# TRUE
head(mtcars)

has_rownames(iris)
# FALSE
head(iris)

a <- as_tibble(mtcars)
a <- tibble(mtcars)
a

b <- add_rownames(mtcars, var = "group")
b

c <- rownames_to_column(a, var = "group")
c

d <- mutate_each(mtcars, funs=rescale)
d

# rescale 数据源中各个变量(列)数量不具可比性，需要做归一化，再做雷达图
mtcars %>%
    add_rownames( var = "group" ) %>%
    mutate_each(funs = rescale, -group) %>%
    tail(4) %>% select(1:10) -> mtcars_radar

mtcars_radar

ggradar(mtcars_radar) 

####################################################
##### 蝴蝶图
#导入工具包：
library("ggplot2")
library("dplyr")
library("grid")
library("showtext")
library("Cairo")

# font.add("myfont","msyh.ttc")

##########
######################
# 基本实现
# 1. 柱状图 + 均值的水平线；
# 2. 设置 y 轴范围，把图向上移动，空出底部空白；
# 3. 显示x 轴的 label（可以在任意位置）;
# 4. x 轴左右互反；
# 5. x、y 轴 互换；

df <- data.frame(
    id = 1:14,
    A = c(5.0,14.7,2.5,8.5,5.1,6.9,7.7,6.8,4.4,4.9,5.3,1.0,0.9,7.8),
    B = c(31.3,24.7,17.8,17.2,15.3,14.3,13.9,13.9,12.4,10.0,6.5,4.2,2.5,0.9),
    Label = c("A","B","C","D","E","F","G","H","I","G","K","L","M","N")
)

p1 <- ggplot(df) +
    geom_bar(aes(x=id,y=A),stat="identity",fill="#E2BB1E",colour=NA) + 
    geom_hline(yintercept=mean(df$A),linetype=2,size=.25,colour="grey") +
    ylim(-5.5,16) + 
    geom_text(aes(x=id,y=-4,label=Label),vjust=.5) + 
    geom_text(aes(x=id,y=A+.75,label=paste0(A,"%")),size=2.5,fontface="bold") +  
    geom_text(aes(x=9,y=4,label="Any where Any Thing"),vjust=.5) + 
    theme(text = element_text(family = "MicrosoftYaHei")) + 
    theme_void(); p1

p2 <- p1 + scale_x_reverse() +  coord_flip(); p2



##########
## 完整
#生成图形所需数据集：
mydata<-data.frame(
    id=1:14,
    A=c(5.0,14.7,2.5,8.5,5.1,6.9,7.7,6.8,4.4,4.9,5.3,1.0,0.9,7.8),
    B=c(31.3,24.7,17.8,17.2,15.3,14.3,13.9,13.9,12.4,10.0,6.5,4.2,2.5,0.9),
    Label=c("Website","Customer & Employee Referral","Webinar","Facebook/Twitter/Other Social","Marketting & Advertising","Paid Serch","Other","Sales generated","Tradeshows","Parter","Linkedin","Events","Lead list","Emial Campaign")
)

# 右边图
p1 <- ggplot(mydata)+
    geom_hline(yintercept=mean(mydata$A),linetype=2,size=.25,colour="grey")+
    geom_bar(aes(x=id,y=A),stat="identity",fill="#E2BB1E",colour=NA)+
    ylim(-5.5,16)+
    scale_x_reverse()+
    geom_text(aes(x=id,y=-4,label=Label),vjust=.5)+
    geom_text(aes(x=id,y=A+.75,label=paste0(A,"%")),size=4.5,family="myfont",fontface="bold")+
    coord_flip()+
    theme_void();

p1

# 左边图
p2 <- ggplot(mydata)+
    geom_hline(yintercept=-mean(mydata$B),linetype=2,size=.25,colour="grey")+
    geom_bar(aes(x=id,y=-B),stat="identity",fill="#C44E4C",colour=NA)+
    ylim(-40,0)+
    scale_x_reverse()+
    geom_text(aes(x=id,y=-B-1.75,label=paste0(B,"%")),size=4.5,family="myfont",fontface="bold")+
    coord_flip()+
    theme_void();

p2


# 两张图合并
setwd("/Users/ygzheng/Documents/playground/easypy/notebooks/self/r")
CairoPNG(file="butterfly.png",width=1200,height=696)
showtext.begin()


grid.newpage()
pushViewport(viewport(layout=grid.layout(7,11)))
vplayout <- function(x,y) {viewport(layout.pos.row =x,layout.pos.col=y)}
print(p2,vp=vplayout(2:7,1:5))
print(p1,vp=vplayout(2:7,6:11))
grid.text(label="Opportunity-to-Deal\nConversion Rate",x=.80,y=.88,gp=gpar(col="black",fontsize=15,fontfamily="myfzhzh",draw=TRUE,just="centre"))
grid.text(label="Lead-to-Opportunity\nConversion Rate",x=.20,y=.88,gp=gpar(col="black",fontsize=15,fontfamily="myfzhzh",draw=TRUE,just="centre"))
grid.text(label="Webinars convert opportunities,but don't close",x=.50,y=.95,gp=gpar(col="black",fontsize=20,fontfamily="myfzhzh",draw=TRUE,just="centre"))


showtext.end()
dev.off()



    

