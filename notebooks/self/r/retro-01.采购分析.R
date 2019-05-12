# 计算分位数
a <- c(49.75,  51.25, 51.25, 52.35, 52.20, 51.48, 39.35, 51.48, 51.48 )
quantile(a)

# install.packages("RPostgreSQL")
library(RPostgreSQL)
library(lubridate)
library(ggplot2)
library(dplyr)

# setup connection 
con <- dbConnect(PostgreSQL(), host="localhost", user= "postgres", password="postgres", dbname="pony_development") 

# close connect 
# dbDisconnect(con) 

data("iris")
head(iris)

# 直接把数据写到 db，并且会自动创建 table
# dbWriteTable(con, "iris", iris)


# select 
# step1: build query
data = dbSendQuery(con,  statement = "
                   SELECT * FROM iris
                   ")

# step2: exec query and get data 
df = fetch(data,  n = -1) 

df

##################  明细分析：单一物料每一笔采购记录
# option2: get result directly 
df2 <- dbGetQuery(con,  "
                  select a.company, a.mat_name, a.vendor_name, 
	                  cast(a.unit_price as decimal(20,4)) unit_price, a.item_qty, a.inbound_date
                  from po_items a 
                  where a.mat_name = '品名贴（柚木）'
                  order by a.inbound_date; 
                  ") 

df2

sd(df2$item_qty)  / mean(df2$item_qty) 

str(df2$inbound_date)

# 转成时间序列
# install.packages("lubridate")


# 改字体, 否则不显示中文<br>#下方代码是示例
par(family='STSongti-SC-Black') 

# dt <- ymd('2019-04-28')

# 提取时间数据中的周数和月份
dt <- df2$inbound_date

weekday <- wday(dt)
mday <- month(dt)

wk <- week(dt)
wk


df3 <- data.frame(dt,weekday, wk, qty=(df2$item_qty))
df3

p <- ggplot(df3, aes(factor(wk), factor(weekday), z=log10(qty)))

p + stat_summary_2d(fun=function(x) mean(x))  + 
  theme(text = element_text(family = "STSongti-SC-Black")) + 
  # theme(plot.title = element_text(size=26, face="bold", hjust=0, color="#666666")) +
  theme(axis.title = element_text(size=8,  face="bold", color="#666666")) +
  # theme(axis.title.y = element_text(angle=0, vjust = 0.5)) +
  theme(legend.title = element_text(size=8)) +
  theme(legend.text = element_text(size=6)) +
  theme(legend.position = "bottom") + 
  scale_fill_distiller("数量", palette=2, direction=1) +
  xlab(label = "月份") +
  ylab(label = "星期")


# 按月汇总

df4 <- df3 %>%
  group_by(mday) %>%
  summarise(a = sum(qty))

ggplot(df4, aes(x=factor(mday), y=a)) + geom_bar(stat='identity', fill='dodgerblue') +
  theme(text = element_text(family = "STSongti-SC-Black")) + 
  # theme(plot.title = element_text(size=26, face="bold", hjust=0, color="#666666")) +
  theme(axis.title = element_text(size=10,  face="bold", color="#666666")) +
  # theme(axis.title.y = element_text(angle=0, vjust = 0.5)) +
  theme(legend.title = element_text(size=8)) +
  theme(legend.text = element_text(size=6)) +
  theme(legend.position = "bottom") + 
  xlab("月份") + ylab("入库量")

####################################
# 单一物料，明细分析
df2 <- dbGetQuery(con,  "
                  select a.company, a.mat_name, a.vendor_name, 
                  cast(a.unit_price as decimal(20,4)) unit_price, a.item_qty, a.inbound_date
                  from po_items a 
                  where a.mat_name = '1.2mm白橡'
                  order by a.inbound_date; 
                  ") 

dim(df2)
head(df2)

# 过滤掉单价异常的信息
df2 <- df2[df2$unit_price < 1000,]

mday <- month(df2$inbound_date)
df3 <- data.frame(month=factor(mday), qty=df2$item_qty, amt=df2$unit_price * df2$item_qty, unit_price=df2$unit_price)
head(df3)

df4 <- df3 %>%
          group_by(month) %>%
          summarise(qty=sum(qty), amt=sum(amt))

df4$price = df4$amt / df4$qty

df4

# 每个月的采购量
ggplot(df4, aes(x=factor(month), y=qty)) + 
  geom_bar(stat='identity', fill='dodgerblue') +
  theme(text = element_text(family = "STSongti-SC-Black")) + 
  # theme(plot.title = element_text(size=26, face="bold", hjust=0, color="#666666")) +
  theme(axis.title = element_text(size=10,  face="bold", color="#666666")) +
  # theme(axis.title.y = element_text(angle=0, vjust = 0.5)) +
  theme(legend.title = element_text(size=8)) +
  theme(legend.text = element_text(size=6)) +
  theme(legend.position = "bottom") + 
  xlab("月份") + ylab("入库量")

# 每个月的平均采购价
ggplot(df4, aes(x=factor(month), y=price, group=1)) + 
  geom_line(linetype = "dashed", color="dodgerblue") + 
  geom_point() +
 #  scale_color_brewer(palette="Dark2") +
  theme(text = element_text(family = "STSongti-SC-Black")) + 
  # theme(plot.title = element_text(size=26, face="bold", hjust=0, color="#666666")) +
  theme(axis.title = element_text(size=10,  face="bold", color="#666666")) +
  # theme(axis.title.y = element_text(angle=0, vjust = 0.5)) +
  theme(legend.title = element_text(size=8)) +
  theme(legend.text = element_text(size=6)) +
  theme(legend.position = "bottom") + 
  xlab("月份") + ylab("单价")

# 每个月采购价的 boxplot
ggplot(df3, aes(x=month, y=unit_price, group=month)) + 
  geom_boxplot(aes(fill=1))


# 按供应商看
head(df2)

ggplot(df2, aes(x=vendor_name, y=unit_price, group=vendor_name)) + 
  geom_boxplot(aes(fill=vendor_name)) +
  scale_fill_brewer("供应商", palette="Accent") +
  theme(text = element_text(family = "STSongti-SC-Black")) + 
  # theme(plot.title = element_text(size=26, face="bold", hjust=0, color="#666666")) +
  theme(axis.title = element_text(size=10,  face="bold", color="#666666")) +
  # theme(axis.title.y = element_text(angle=0, vjust = 0.5)) +
  theme(legend.title = element_text(size=8)) +
  theme(legend.text = element_text(size=6)) +
  theme(legend.position = "bottom") + 
  xlab("供应商") + ylab("单价")



ggplot(df2, aes(x=vendor_name, y=item_qty)) + 
  geom_bar(stat='identity', fill='dodgerblue') +
  #  scale_color_brewer(palette="Dark2") +
  theme(text = element_text(family = "STSongti-SC-Black")) + 
  # theme(plot.title = element_text(size=26, face="bold", hjust=0, color="#666666")) +
  theme(axis.title = element_text(size=10,  face="bold", color="#666666")) +
  # theme(axis.title.y = element_text(angle=0, vjust = 0.5)) +
  theme(legend.title = element_text(size=8)) +
  theme(legend.text = element_text(size=6)) +
  theme(legend.position = "bottom") + 
  xlab("供应商") + ylab("采购量")

# 计算均价
base_price <-  sum(df2$unit_price * df2$item_qty) / sum(df2$item_qty) 
# 均价上浮 10% 作为基准价
base_price <- base_price * 1.10

# 实际采购价 和 基准价 的 价差
df2$diff_price = df2$unit_price - base_price

# 超过基准价的采购记录
df5 <- df2[df2$diff_price > 0,]

# 获取月份信息
df5$month = month(df5$inbound_date)

head(df5)
dim(df5)

# 按 供应商 汇总，查看超过基准价的采购量
df5 %>%
  group_by(vendor_name) %>%
  summarise(qty = sum(item_qty))


# 横轴：价格差，纵轴：采购量，分类：供应商
ggplot(df5, aes(x=diff_price, y=item_qty)) + 
  geom_point(aes(color = vendor_name)) +
  scale_color_brewer("供应商", palette="Dark2") +
  theme(text = element_text(family = "STSongti-SC-Black")) + 
  # theme(plot.title = element_text(size=26, face="bold", hjust=0, color="#666666")) +
  theme(axis.title = element_text(size=10,  face="bold", color="#666666")) +
  # theme(axis.title.y = element_text(angle=0, vjust = 0.5)) +
  theme(legend.title = element_text(size=8)) +
  theme(legend.text = element_text(size=6)) +
  theme(legend.position = "bottom") + 
  xlab("价格差") + ylab("采购量")


##### 物料供应源分析
# 只有一个供应商的物料，有多少颗；有两个供应商的物料，有多少颗；
df1 <- dbGetQuery(con,  "
                  with src as (
                  	select a.mat_name col1, a.vendor_name col2, 
                  		   a.item_qty qty1, 
                  		   (a.item_qty * a.unit_price) amt1
                  	  from po_items a 
                  	 where a.unit_price <> 0 
                  ), 
                  shared_cnt as (
                  	select a.col1, 
                  		count(distinct a.col2) shared_cnt, 
                  		cast( sum(amt1) as decimal(20,2)) amt1
                  	  from src a 
                  	group by a.col1
                  )
                  select b.shared_cnt, 
                  	count(col1) col1_cnt, 
                  	sum(amt1) amt1
                    from shared_cnt b 
                   group by b.shared_cnt
                   order by b.shared_cnt; 
                  ") 

total_cnt = sum(df1$col1_cnt)
df1$pect_cnt = 100 * df1$col1_cnt / total_cnt

total_amt = sum(df1$amt1)
df1$pect_amt = 100 * df1$amt1 / total_amt


head(df1)


# 横轴：供应商数量，纵轴：料号比例，或 采购金额比例
ggplot(df1, aes(x=factor(shared_cnt), y=pect_cnt)) + 
  geom_bar(stat='identity', fill='dodgerblue') +
  theme(text = element_text(family = "STSongti-SC-Black")) + 
  # theme(plot.title = element_text(size=26, face="bold", hjust=0, color="#666666")) +
  theme(axis.title = element_text(size=10,  face="bold", color="#666666")) +
  # theme(axis.title.y = element_text(angle=0, vjust = 0.5)) +
  theme(legend.title = element_text(size=8)) +
  theme(legend.text = element_text(size=6)) +
  theme(legend.position = "bottom") + 
  xlab("供应商数量") + ylab("料号 %") 


##### 基本采购分析
# A. 物料集中度分析
# B. 供应商集中度分析

# A. 物料集中度分析
df1 <- dbGetQuery(con, "
                  with src as (
                    select a.mat_name col1, 
                    	cast(sum(a.item_qty * a.unit_price) as decimal(20,2)) amt,
                    	cast(sum(a.item_qty) as decimal(20,2)) qty 
                      from po_items a 
                     where a.unit_price <> 0 
                       and a.item_qty <> 0
                     group by a.mat_name
                    ) 
                    select a.* 
                      from src a 
                     where a.col1 <> '1.2mm白橡'
                    order by a.amt desc; 
                  ")

total_amt <- sum(df1$amt)
df1$pect = df1$amt / total_amt 
df1$pect_sum = cumsum(df1$pect)

# 找出 80-20 点
head(df1)
df3 <- df1[df1$pect_sum <= 0.90,]
head(df3, 100)
dim(df3)

df3$col1

df4 <- df3[grepl("基材", df3$col1) || grepl("mm", df3$col1),]
df4$col1



# 生成数据：料号占比，金额占比
cnt11 <- dim(df3)[1]  / dim(df1)[1] 
cnt12 <- 1 - cnt11

amt1 <- 0.90
amt2 <- 1 - amt1

a <- data.frame(cnt=c(cnt11, cnt12, amt1, amt2), t1=c("cnt", "cnt", "amt", "amt"), t2=c("A", "B", "A", "B"))
head(a)

# 堆叠图
level_order <- factor(a$t1, level = c('cnt', 'amt'), labels=c("料号", "金额"))
ggplot(a, aes(x=level_order,y=cnt, fill=t2)) + 
  geom_bar(stat = "identity") + 
  scale_fill_brewer(palette="Paired")
  theme(
    text = element_text(family = "STSongti-SC-Black"),  
    # plot.title = element_text(size=26, face="bold", hjust=0, color="#666666"), 
    axis.title = element_text(size=10,  face="bold", color="#666666"), 
    # axis.title.y = element_text(angle=0, vjust = 0.5), 
    # axis.title.x = element_blank(), 
    # axis.text.x = element_blank(), 
    # axis.line.x = element_blank(), 
    # axis.ticks.x = element_blank(), 
    legend.title = element_text(size=8), 
    legend.text = element_text(size=6), 
    legend.position = "bottom") + 
  xlab("料号数") + ylab("金额 %")  


# 只使用 金额占比 
rowCount <- dim(df1)[1]

seq(from=1, to=rowCount)

df2 <- data.frame(x=seq(from=1, to=rowCount), y=df1$pect_sum )
head(df2)

# 横轴：每个格代表一颗料，金额从大到小；纵轴：金额累积占比
ggplot(df2, aes(x=factor(x), y=y)) + 
  # geom_line(linetype = "dashed", color="dodgerblue") +
  geom_point(color="dodgerblue") +
  theme(
    text = element_text(family = "STSongti-SC-Black"),  
    plot.title = element_text(size=26, face="bold", hjust=0, color="#666666"), 
    axis.title = element_text(size=10,  face="bold", color="#666666"), 
    # axis.title.y = element_text(angle=0, vjust = 0.5), 
    # axis.title.x = element_blank(), 
    axis.text.x = element_blank(), 
    axis.line.x = element_blank(), 
    # axis.ticks.x = element_blank(), 
    legend.title = element_text(size=8), 
    legend.text = element_text(size=6), 
    legend.position = "bottom") + 
  xlab("料号数") + ylab("金额 %")  + 
  geom_hline(yintercept=0.90, linetype="dashed", color = "red") + 
  geom_vline(xintercept=98, linetype="dashed", color = "red") + 
  geom_text(aes(x=140, label="98", y=0.9), colour="blue", angle=0)
  

## B. 供应商集中度
df1 <- dbGetQuery(con, "
                 with src as (
                    select a.vendor_name col1, 
                    	cast(sum(a.item_qty * a.unit_price) as decimal(20,2)) amt,
                    	cast(sum(a.item_qty) as decimal(20,2)) qty 
                      from po_items a 
                     where a.unit_price <> 0 
                       and a.item_qty <> 0
                       and a.company <> '句容工厂'
                       and a.mat_name <> '1.2mm白橡'
                     group by a.vendor_name
                    )
                    select a.* 
                      from src a 
                     where 1 = 1 
                     -- a.col1 <> '1.2mm白橡'
                    order by a.amt desc;  
                  ")

total_amt <- sum(df1$amt)
df1$pect = df1$amt / total_amt 
df1$pect_sum = cumsum(df1$pect)
dim(df1)

# 找出 80-20 点
head(df1)
df3 <- df1[df1$pect_sum <= 0.90,]

dim(df3)
head(df3)

# 累积图
rowCount <- dim(df1)[1]
seq(from=1, to=rowCount)
df2 <- data.frame(x=seq(from=1, to=rowCount), y=df1$pect_sum )
head(df2)
dim(df2)
# 横轴：每个格代表一供应商，金额从大到小；纵轴：金额累积占比
ggplot(df2, aes(x=factor(x), y=y)) + 
  # geom_line(linetype = "dashed", color="dodgerblue") +
  geom_point(color="dodgerblue") +
  theme(
    text = element_text(family = "STSongti-SC-Black"),  
    plot.title = element_text(size=26, face="bold", hjust=0, color="#666666"), 
    axis.title = element_text(size=10,  face="bold", color="#666666"), 
    # axis.title.y = element_text(angle=0, vjust = 0.5), 
    # axis.title.x = element_blank(), 
    axis.text.x = element_blank(), 
    axis.line.x = element_blank(), 
    # axis.ticks.x = element_blank(), 
    legend.title = element_text(size=8), 
    legend.text = element_text(size=6), 
    legend.position = "bottom") + 
  xlab("供应商数") + ylab("金额 %")  + 
  geom_hline(yintercept=0.90, linetype="dashed", color = "red") + 
  geom_vline(xintercept=13, linetype="dashed", color = "red") + 
  geom_text(aes(x=16, label="13", y=0.9), colour="blue", angle=0)


############################
## 双坐标轴

library(ggplot2)
library(gtable)
library(grid)

temp = data.frame(Product=as.factor(c("A","B","C")),
                  N = c(17100,17533,6756),
                  n = c(5,13,11),
                  rate = c(0.0003,0.0007,0.0016),
                  labels = c(".03%",".07%",".16%"))

p1 = ggplot(data = temp, aes(x=Product,y=N))+
  geom_bar(stat="identity",fill="#F8766D") + 
  geom_text(aes(label=n,col="red",vjust=-0.5))+
  theme(legend.position="none",axis.title.y=element_blank(),
        axis.text.x = element_text(angle = 90, hjust = 1))
p2 = ggplot(data = temp,aes(x=Product,y=rate))+
  geom_line(aes(group=1))+geom_text(aes(label=labels,vjust=0))+
  theme(legend.position="none",axis.title.y=element_blank(),
        axis.text.x = element_text(angle = 90, hjust = 0), 
        panel.background = element_rect(fill = NA), 
        panel.grid = element_blank())+
  xlab("Product")

g1 <- ggplot_gtable(ggplot_build(p1))
g2 <- ggplot_gtable(ggplot_build(p2))

# overlap the panel of 2nd plot on that of 1st plot
pp <- c(subset(g1$layout, name == "panel", se = t:r))
g <- gtable_add_grob(g1, g2$grobs[[which(g2$layout$name == "panel")]], pp$t, 
                     pp$l, pp$b, pp$l)

# axis tweaks
ia <- which(g2$layout$name == "axis-l")
ga <- g2$grobs[[ia]]
ax <- ga$children[[2]]
ax$widths <- rev(ax$widths)
ax$grobs <- rev(ax$grobs)
ax$grobs[[1]]$x <- ax$grobs[[1]]$x - unit(1, "npc") + unit(0.15, "cm")
g <- gtable_add_cols(g, g2$widths[g2$layout[ia, ]$l], length(g$widths) - 1)
g <- gtable_add_grob(g, ax, pp$t, length(g$widths) - 1, pp$b)

# draw it
grid.draw(g)