# 供应商共用性分析
library(RPostgreSQL)
library(lubridate)
library(ggplot2)
library(dplyr) 

# font name 
# family = "STSongti-SC-Black")

# setup connection 
con <- dbConnect(PostgreSQL(), host="localhost", user= "postgres", password="postgres", dbname="pony_development") 

# get vendor count of each company
df1 <- dbGetQuery(con,  "
                  with vndr_comp as (
                    	select a.vendor_name, a.company
                    	  from po_items a 
                    	group by a.vendor_name, a.company
                    )
                    select a.company, count(1) vndr_cnt
                      from vndr_comp a 
                     group by a.company; ") 

# bar chart 
ggplot(data = df1, aes(x=company, y=vndr_cnt)) + 
    geom_bar(stat='identity', fill='dodgerblue') +
    theme(text = element_text(family = "MicrosoftYaHei")) + 
    theme(plot.title = element_text(size=16, face="bold", hjust=0.5, color="#666666")) +
    theme(axis.title = element_text(size=8,  face="bold", color="#666666")) +
    theme(axis.text = element_text(size=6,  family = "MicrosoftYaHei", face="bold", color="#666666")) +
    # theme(axis.title.y = element_text(angle=0, vjust = 0.5)) +
    theme(legend.title = element_text(size=6)) +
    theme(legend.text = element_text(size=6)) +
    theme(legend.position = "bottom") +
    ggtitle("供应商数量\n分工厂") + 
    xlab("工厂") + ylab("供应商数量")

# 整合成一个 theme 调用
ggplot(data = df1, aes(x=company, y=vndr_cnt)) + 
    geom_bar(stat='identity', fill='dodgerblue') +
    theme(text = element_text(family = "MicrosoftYaHei", color="#666666"),  
        plot.title = element_text(size=16, face="bold", hjust=0.5), 
        axis.title = element_text(size=8, face="bold"), 
        axis.text = element_text(size=6, face="bold"), 
        # axis.title.y = element_text(angle=0, vjust = 0.5), 
        legend.title = element_text(size=6), 
        legend.text = element_text(size=6), 
        legend.position = "bottom") +
    ggtitle("供应商数量\n分工厂") + 
    xlab("工厂") + ylab("供应商数量")

# 强化工厂下，供应商共用性分析
df1 <- dbGetQuery(con,  "
                  with vndr_comp as (
                    	select a.vendor_name, a.company, 
                    		   cast( sum(a.item_qty * a.unit_price) as decimal(20,4)) amt
                    	  from po_items a 
                    	 where a.company not in  ('圣象康逸', '句容工厂')
                    	group by a.vendor_name, a.company
                    ), 
                    by_vndr as (
                    	select a.vendor_name, count(1) shared_cnt, cast(sum(amt) as decimal(20,4)) amt 
                    	  from vndr_comp a 
                    	group by a.vendor_name
                    ), 
                    by_grade as (
                    	select a.shared_cnt, 
                    		count(1) vndr_cnt, 
                    		cast(sum(amt) as decimal(20,2)) amt 
                    	  from by_vndr a 
                    	group by a.shared_cnt
                    	order by a.shared_cnt desc 
                    )
                    select shared_cnt, vndr_cnt, amt from by_grade; 
 ") 

# bar chart 
ggplot(data = df1, aes(x=shared_cnt, y=amt)) + 
    geom_bar(stat='identity', fill='dodgerblue') +
    theme(text = element_text(family = "STSongti-SC-Black")) + 
    # theme(plot.title = element_text(size=26, face="bold", hjust=0, color="#666666")) +
    theme(axis.title = element_text(size=10,  face="bold", color="#666666")) +
    # theme(axis.title.y = element_text(angle=0, vjust = 0.5)) +
    theme(legend.title = element_text(size=8)) +
    theme(legend.text = element_text(size=6)) +
    theme(legend.position = "bottom") + 
    xlab("共用数") + ylab("采购金额")


## 共用度为 3 的供应商，和各工厂间的采购金额关系
df1 <- dbGetQuery(con,  "
                  with vndr_comp as (
                    	select a.vendor_name, a.company, 
                    		   cast( sum(a.item_qty * a.unit_price) as decimal(20,4)) amt
                    	  from po_items a 
                    	 where a.company not in  ('圣象康逸', '句容工厂')
                    	group by a.vendor_name, a.company
                    ), 
                    by_vndr as (
                    	select a.vendor_name, count(1) shared_cnt, 
                    		cast(sum(a.amt) as decimal(20,4)) amt	
                    	  from vndr_comp a 
                    	group by a.vendor_name
                    ), 
                    vndr_list as (
                    -- 共用度为 3 的供应商，在各家工厂下，都供应什么品类
                    	select a.vendor_name
                    	  from by_vndr a 
                    	  where a.shared_cnt = 3
                    )
                    select a.vendor_name, b.company, b.amt
                      from vndr_list a 
                     inner join vndr_comp b on a.vendor_name = b.vendor_name
                     where a.vendor_name not in ('大亚人造板集团有限公司')
                     order by a.vendor_name, b.amt desc, b.company; 
                ") 

head(df1)

# 采购金额热度图：供应商 ~ 工厂
ggplot(data=df1, aes(x = company, y = vendor_name, z=amt)) +
    stat_summary_2d(fun=function(x) x/10000)  + 
    theme(text = element_text(family = "STSongti-SC-Black")) + 
    # theme(plot.title = element_text(size=26, face="bold", hjust=0, color="#666666")) +
    theme(axis.title = element_text(size=8,  face="bold", color="#666666")) +
    # theme(axis.title.y = element_text(angle=0, vjust = 0.5)) +
    theme(legend.title = element_text(size=8)) +
    theme(legend.text = element_text(size=6)) +
    theme(legend.position = "bottom") + 
    scale_fill_distiller("采购金额", palette=2, direction=1) +
    xlab(label = "工厂") +
    ylab(label = "供应商")



# 每个工厂平均价格 boxchart
# 一家供应商
df1 <- dbGetQuery(con, "
                	select a.vendor_name, a.company, a.mat_name, 
                    	   a.item_qty, 
                    	   a.amt, 
                    	   (a.amt / a.item_qty) unit_price
                      from (
                    	select a.vendor_name, a.company, a.mat_name, 
                    			sum(a.item_qty) item_qty, 
                    			sum(a.unit_price * a.item_qty) amt
                    	  from po_items a 
                    	where a.vendor_name like '夏特装饰%'
                    	group by a.vendor_name, a.company, a.mat_name
                    	  ) a
                	
                  ")

# 另三家供应商
# '杭州天元诚达装饰材料有限公司', '杭州添丽装饰纸有限公司', '英特普莱特（中国）装饰材料有限公司'
df1 <- dbGetQuery(con, "
                    select a.vendor_name, a.company, a.mat_name, 
                    	   a.item_qty, a.amt, 
                    	   cast(a.amt / a.item_qty as decimal(20,2)) unit_price
                      from (
                    	  select a.vendor_name, a.company, a.mat_name,
                    	  		sum(a.item_qty) item_qty, 
                    			sum(a.unit_price * a.item_qty) amt
                    		  from po_items a 
                    		where a.vendor_name in ('杭州天元诚达装饰材料有限公司', '杭州添丽装饰纸有限公司','英特普莱特（中国）装饰材料有限公司')
                    	group by a.vendor_name, a.company, a.mat_name
                    	  ) a
                  ")
head(df1)

ggplot(data = df1, aes(x=company, y= item_qty)) + 
    geom_boxplot(aes(fill=vendor_name)) +
    scale_fill_brewer("供应商", palette="Accent") +
    theme(text = element_text(family = "STSongti-SC-Black")) + 
    # theme(plot.title = element_text(size=26, face="bold", hjust=0, color="#666666")) +
    theme(axis.title = element_text(size=10,  face="bold", color="#666666")) +
    # theme(axis.title.y = element_text(angle=0, vjust = 0.5)) +
    theme(legend.title = element_text(size=8)) +
    theme(legend.text = element_text(size=6)) +
    theme(legend.position = "bottom") + 
    xlab("工厂") + ylab("采购量")


# 高密度板的采购量
df1 <- dbGetQuery(con, "
                  select a.company, a.vendor_name, sum(a.item_qty) qty
                      from po_items a 
                     where 1 = 1 
                       and a.mat_name like '%高密度板%'
                     group by a.company, a.vendor_name
                     order by a.company, a.vendor_name; 
                ")

# 高密度板的采购量 热度图：供应商 ~ 工厂
ggplot(data=df1, aes(x = company, y = vendor_name, z=qty)) +
    stat_summary_2d(fun=function(x) x/10000)  + 
    theme(text = element_text(family = "STSongti-SC-Black")) + 
    # theme(plot.title = element_text(size=26, face="bold", hjust=0, color="#666666")) +
    theme(axis.title = element_text(size=8,  face="bold", color="#666666")) +
    # theme(axis.title.y = element_text(angle=0, vjust = 0.5)) +
    theme(legend.title = element_text(size=8)) +
    theme(legend.text = element_text(size=6)) +
    theme(legend.position = "bottom") + 
    scale_fill_distiller("采购量", palette=2, direction=1) +
    xlab(label = "工厂") +
    ylab(label = "供应商")


