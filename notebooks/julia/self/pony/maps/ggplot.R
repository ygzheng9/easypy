library("showtext")
library("ggplot2")
library("magrittr")
library("reshape2")
library("ggthemes")
library('dplyr')

mydata <- data.frame(
  Lebal  = c("Point1","Point2","Point3","Point4","Point5"),
  xstart = c(5.5,15.7,19.5,37.2,36.9),
  xend   = c(9.7,28.1,24.6,44.6,47.1), 
  ystart = c(9.6,23.1,2.3,33.2,9.2),
  yend   = c(16.1,36.2,11.7,38.5,15.3),
  size   = c(12,48,30,11.5,28),
  class  = c("A","A","A","C","C")
)

# geom_rect 画矩形
ggplot(mydata)+
  geom_rect(aes(xmin = xstart,xmax = xend , ymin = ystart , ymax = yend , fill = class)) +
  scale_fill_wsj()

# 按照x轴进行圆周化：
ggplot(mydata)+
  geom_rect(aes(xmin = xstart,xmax = xend , ymin = ystart , ymax = yend , fill = class)) +
  scale_fill_wsj() +
  ylim(-10,40) +
  scale_x_continuous(expand = c(0,0)) +
  coord_polar(theta = 'x')

#按照y轴进行圆周化
ggplot(mydata)+
  geom_rect(aes(xmin = xstart,xmax = xend , ymin = ystart , ymax = yend , fill = class)) +
  scale_fill_wsj() +
  scale_y_continuous(expand = c(0,0)) +
  coord_polar(theta = 'y')

# 分面操作：
ggplot(mydata)+
  geom_rect(aes(xmin = xstart,xmax = xend , ymin = ystart , ymax = yend , fill = class)) +
  scale_fill_wsj() +
  facet_grid(.~class) +
  scale_y_continuous(expand = c(0,0))

# 分页箭头
ggplot(mydata) +
  geom_segment(
    aes(
      x = xstart , 
      y = ystart , 
      xend = xend ,
      yend = yend  , 
      colour = class
    ),
    arrow = arrow(length = unit(0.5,"cm")),
    size = 1.5
  ) +
  facet_grid(.~class) +
  scale_colour_wsj() +
  scale_y_continuous(expand = c(0,0))


###########
## 绘制垂直线，水平线
mydata <- data.frame(
  Lebal  = c("linerange1","linerange2","linerange3","linerange4","linerange5"),
  xstart = c(3.5,7,12,16,20),
  ymin   = c(2.5,6.5,3,4.5,3.8),
  ymax   = c(7.5,9.5,9,13.5,4.2),
  class  = c("A","A","A","C","C")
)

# 垂直线
ggplot(mydata) +
  geom_linerange(aes(x = xstart, ymin = ymin , ymax = ymax , colour = class) , size = 1.5) +
  scale_colour_wsj()

# 横纵轴互换：
ggplot(mydata) +
  geom_linerange(aes(x = xstart, ymin = ymin , ymax = ymax , colour = class) , size = 1.5) +
  coord_flip() +
  scale_colour_wsj()

#按x轴圆周化：
ggplot(mydata) +
  geom_linerange(aes(x = xstart, ymin = ymin , ymax = ymax , colour = class) , size = 1.5) +
  scale_colour_wsj() +
  scale_x_continuous(limits = c(0,25),expand = c(0,0)) +
  coord_polar(theta = 'x')

#按y轴圆周化：
ggplot(mydata) +
  geom_linerange(aes(x = xstart, ymin = ymin , ymax = ymax , colour = class) , size = 1.5) +
  scale_colour_wsj() +
  scale_y_continuous(expand = c(0,0)) +
  coord_polar(theta = 'y')

#分面：
ggplot(mydata) +
  geom_linerange(aes(x = xstart, ymin = ymin , ymax = ymax , colour = class) , size = 1.5) +
  scale_colour_wsj() +
  facet_grid(.~class) +
  scale_x_continuous(limits = c(0,25),expand = c(0,0))

ggplot(mydata) +
  geom_linerange(aes(x = xstart, ymin = ymin , ymax = ymax , colour = class) , size = 1.5) +
  coord_flip() +
  scale_colour_wsj() +
  facet_grid(.~class) +
  scale_x_continuous(limits = c(0,25),expand = c(0,0))


###################
# 绘制多边形
mydata <- data.frame(
  long = c(15.4,17.2,19.7,15.9,7.4,8.9,8.5,10.4,11.3,9.7,4.8,3.7,22.4,25.6,27.8,25.1,16.7,15.9,29.9,38.7,43.2,40.2,35.6,29.4),
  lat  = c(38.1,36.2,33.1,24.6,29.0,33.6,12.1,11.7,8.9,6.1,5.7,9.1,8.4,7.6,5.7,3.9,4.3,5.9,32.6,31.8,27.6,22.3,24.5,29.6),
  group= c(1,1,1,1,1,1,2,2,2,2,2,2,3,3,3,3,3,3,4,4,4,4,4,4),
  order =c(1,2,3,4,5,6,1,2,3,4,5,6,1,2,3,4,5,6,1,2,3,4,5,6),
  class = rep(c("A","c"),each = 12)
)

# 多边形
ggplot(mydata) +
  geom_polygon(aes(x = long , y = lat , group  = group , fill = class),colour = "white") +
  scale_fill_wsj()

#按照X轴圆周化：
ggplot(mydata) +
  geom_polygon(aes(x = long , y = lat , group  = group , fill = class),colour = "white") +
  coord_polar(theta = 'x') +
  scale_x_continuous(expand = c(0,0)) +
  scale_fill_wsj()

#按照y轴圆周化：
ggplot(mydata) +
  geom_polygon(aes(x = long , y = lat , group  = group , fill = class),colour = "white") +
  coord_polar(theta = 'y') +
  scale_y_continuous(expand = c(0,0)) +
  scale_fill_wsj()

#分面：
ggplot(mydata) +
  geom_polygon(aes(x = long , y = lat , group  = group , fill = class),colour = "white") +
  facet_grid(.~class) +
  scale_fill_wsj()


# 正负分开显示
set.seed(1234)
x = 1980 + 1:35
y = round(100*rnorm(35))
df = data.frame(x = x, y = y)
#判断y是否为正值
df <- transform(df, judge = ifelse(y>0, 'Yes', 'No'))
ggplot(data = df, mapping = aes(x = x, y = y, fill = judge)) + 
  geom_bar(stat = 'identity', position = 'identity') + 
  scale_fill_manual(values = c('blue','red'), guide = FALSE) + xlab('Year')


################
library("tidyverse")
library("scales")
library("countrycode")
library("ggimage")
library("grid")
library("Rmisc")
library("showtext")

name<-c("司法界","商人","外交领域","军人","记者","经济学家","医学界","学术界","工程师")
label<-factor(name,levels=name,order=T)
percent<-c(0.196,0.166,0.126,0.107,0.083,0.083,0.082,0.078,0.072)
mydata<-data.frame(label,percent)

mydata$anti_percent<-1-mydata$percent
mydata1<-gather(mydata,index,Percent,-label)

conservation_status <-paste0(name,"\n",percent(percent))
names(conservation_status)<-name
global_labeller <-labeller(.defalut=label_value,label=conservation_status)
font_add("myfont","msyhl.ttc")


p1<-ggplot()+
  geom_col(data=mydata1,aes(x=1,y=Percent,fill=index),width=.2)+
  scale_fill_manual(values=c("percent"="#00A0E9","anti_percent"="#EAEBEB"),guide=FALSE)+
  xlim(0.6,1.1)+
  coord_polar(theta="y")+
  facet_grid(.~label,labeller=global_labeller)+
  theme_minimal()+
  theme(
    line=element_blank(),
    axis.text=element_blank(),
    title=element_blank(),
    panel.spacing=unit(0,"cm"),
    strip.text=element_text(family="myfont",size=25,lineheight=1.2),
    plot.margin=unit(c(.5,3,0,2),'lines')
  );p1