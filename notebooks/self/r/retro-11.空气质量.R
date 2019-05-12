library(RCurl)

library(httr)

library(XML)

library(tidyverse)
library(rvest)

##############
# 从 page 中抓取 table, 必须是 服务器端渲染的，js 渲染的不行
library("rvest")

getServerTable <- function(url) {
    # 打开 url，获取 table nodes
    tbls <- read_html(url) %>%
        html_nodes("table")

    head(tbls)
    tbls[3:4]

    # 把 table nodes 读取到 data.frame 中
    tbls_ls <- html_table(tbls[3:4], fill = TRUE)
    str(tbls_ls)

    # 取第一个 data.frame
    tbl <- tbls_ls[[1]]
    str(tbl)
}

url <- "http://www.bls.gov/web/empsit/cesbmart.htm"
getServerTable(url)

###############
library(rvest)
library(jsonlite)

# 直接调用 api
my_url <-
    "https://www.kroger.com/cl/api/coupons?couponsCountPerLoad=418&sortType=relevance&newCoupons=false" #hidden api
pagesource <- read_html(my_url)
content <- pagesource %>% html_node("p") %>% html_text()
data <- fromJSON(content)
mydata <- data$data$coupons

glimpse(mydata)

head(mydata)

##############
#  使用 v8 引擎，js 渲染的信息
#Loading both the required libraries
library(rvest)
library(V8)

#URL with js-rendered content to be scraped
link <- 'https://food.list.co.uk/place/22191-brewhemia-edinburgh/'
#Read the html page content and extract all javascript codes that are inside a list
emailjs <-
    read_html(link) %>% html_nodes('li') %>% html_nodes('script') %>% html_text()

# Create a new v8 context
ct <- v8()

#parse the html content from the js output and print it as text
read_html(ct$eval(gsub('document.write', '', emailjs))) %>%
    html_text()

##################
library(splashr)
library(magick)

# 直接把网页保存成图片，
splash_container <- start_splash()
splash_active()

stop_splash(splash_container)

killall_splash()

# 把网站转成图片
png1 <- render_png(url = "https://analytics.usa.gov/", wait = 5)
# 通过 preview 查看图片
image_browse(png1)

# TODO: 但是 js 没有执行
url <-
    "https://www.aqistudy.cn/historydata/daydata.php?city=大连&month=201601"
pg <- render_html(url = allurl[1])

pg %>% html_text

# 没有行，只有表头，因为是 js 渲染的，而 js 没有执行
first_tbl <-
    html_nodes(pg, "table") %>% html_table(nd,
                                           header = T,
                                           trim = T,
                                           fill = T) %>% .[[1]]
first_tbl

##################
# 通过 chrome 执行 js

# 执行 shell 命令
system("ls")

library(RSelenium)
library(rvest)

# 启动 docker 服务
# system('docker run -d -p 4445:4444 selenium/standalone-chrome')

# 连接到 docker 服务
remDr <-
    remoteDriver(remoteServerAddr = "localhost",
                 port = 4445L,
                 browserName = "chrome")

# 和 service 建立连接
remDr$open()
remDr$getStatus()

# 断开连接
remDr$close()

remDr$closeServer()

# 完整页面的截屏
saveFullPage <- function(url) {
    url <- "https://www.aqistudy.cn/historydata/daydata.php?city=大连&month=201901"
    remDr$navigate(url)

    # 模拟滚动，这样截图就是完整的页面，而不是当前窗口大小
    # Get the actual page dimensions using javascript
    width  = remDr$executeScript("return Math.max(document.body.scrollWidth, document.body.offsetWidth, document.documentElement.clientWidth, document.documentElement.scrollWidth, document.documentElement.offsetWidth);")
    height = remDr$executeScript("return Math.max(document.body.scrollHeight, document.body.offsetHeight, document.documentElement.clientHeight, document.documentElement.scrollHeight, document.documentElement.offsetHeight);")

    # 把窗口变大，这样截屏时，就是完整的信息
    # +100 是为了不显示滚动条
    # Add some pixels on top of the calculated dimensions for good
    # measure to make the scroll bars disappear
    # wd.manage.window.resize_to(width+100, height+100)
    remDr$setWindowSize(width = width[[1]] + 100, height = height[[1]] + 100)

    # 在 rstudio 中打开
    # remDr$screenshot(display = TRUE)

    # 保存到工作目录的文件中
    setwd("~/Documents/playground/easypy/notebooks/self/r")
    remDr$screenshot(file="full_page.png", display = FALSE)

    # getwd()
}

remDr$navigate("https://www.aqistudy.cn/historydata/daydata.php?city=大连&month=201601")
img <- remDr$screenshot(display = FALSE)


# 根据 url，渲染 html，执行 js，并取得 table 信息，并转化成 data.frame
extractTable <- function(url) {
    remDr$navigate(url)

    # 取得 页面 的 文本
    html <- remDr$getPageSource()[[1]]

    # 转化成 rvest 对象
    pg <- read_html(html)
    # pg %>% html_text

    # 读取第一个表格
    html_nodes(pg, "table") %>%
        html_table(header = T,
                   trim = T,
                   fill = T) %>%
        .[[1]]
}

# 打开网页，并且执行 js
url <-
    "https://www.aqistudy.cn/historydata/daydata.php?city=大连&month=201601"

extractTable(url)

##################

# 构造月度url地址（网站是按照月度数据存储的，需要按月爬取）
urlbase <- "https://www.aqistudy.cn/historydata/"
url <- "https://www.aqistudy.cn/historydata/monthdata.php?city=大连"

# No encoding supplied: defaulting to UTF-8.
page <- GET(url)
html <- content(page, "text")

rdhtml <- htmlParse(html, encoding = "UTF-8")
otherpage <- getNodeSet(rdhtml, "//a")
allurl <- lapply(otherpage, xmlGetAttr, name = 'href') %>%
    grep("2016", ., value = T) %>%
    sub("麓贸脕卢", "大连", .)

#以上还是编码出了问题，不知道那个乱码是什么鬼！只能强行替换了！
allurl <- paste0(urlbase, allurl)

# 以上过程也可先通过观察大连市的月度空气质量url地址规律，然后通过paste函数直接生成。
# allurl<-paste0("https://www.aqistudy.cn/historydata/daydata.php?city=大连&month=",201601:201612)

# 编写单次爬取函数，使用for循环遍历网址进行数据获取（原谅我又用了for循环）
mytable <- data.frame()

for (i in allurl) {
    # print(i)
    # 为了防止被屏蔽，随机间歇
    Sys.sleep(sample(1:5, 1))

    # 这里是循环，并且修改了外面的变量
    mytable <- rbind(mytable, extractTable(i))
}

dim(mytable)
str(mytable)

# 使用动态表格查看数据
library("DT")
datatable(mytable)

# 备份数据
mytableb <- mytable

# 调整时间变量
# 第一列名字是中文，改成英文
names(mytable)[1] <- "date"
head(mytable)

mytable$date <- as.Date(mytable$date)

# AQI指数年度分布日力图
library(openair)
calendarPlot(mytable, pollutant = "AQI", year = 2016)

# PM2.5指数年度分布日力图
calendarPlot(mytable, pollutant = "PM2.5", year = 2016)

######################
# 接下来使用ggplot函数制作同样的日力图
library(plyr)

dat <- mytable

# 这次使用lubridate包来处理时间日期变量（超级好用）
library(lubridate)

dat$month <- as.numeric(as.POSIXlt(dat$date)$mon + 1)

dat$monthf <- factor(
    dat$month,
    levels = as.character(1:12),
    labels = c(
        "Jan",
        "Feb",
        "Mar",
        "Apr",
        "May",
        "Jun",
        "Jul",
        "Aug",
        "Sep",
        "Oct",
        "Nov",
        "Dec"
    ),
    ordered = TRUE
)

dat$weekday <- as.POSIXlt(dat$date)$wday
dat$weekdayf <- factor(
    dat$weekday,
    levels = rev(0:6),
    labels = rev(c(
        "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"
    )),
    ordered = TRUE
)

dat$week <- as.numeric(format(dat$date, "%W"))
dat <-
    ddply(dat, .(monthf), transform, monthweek = 1 + week - min(week))

dat <- dat %>%
    group_by(monthf) %>%
    mutate(monthweek2 = 1 + week - min(week))

dat[is.na(dat$monthf),]
dat[which(dat$monthweek != dat$monthweek2),]

dat$monthf <- forcats::fct_explicit_na(dat$monthf)


# head(dat[, c("date", "monthweek", "monthweek2")], 30)

print(n = 30, dat[, c("date", "monthweek", "monthweek2")])

# AQI指数为污染级别以上的天数分布
ggplot(dat, aes(monthweek, weekdayf, fill = AQI)) +
    geom_tile(colour = 'white') +
    facet_wrap( ~ monthf, nrow = 3) +
    scale_fill_gradient(
        space = "Lab",
        limits = c(100, max(dat$AQI)),
        low = "yellow",
        high = "red"
    ) +
    labs(
        title = "大连市2016年空气日历热图",
        subtitle = "AQI指数为污染级别以上的天数分布（AQI>=100）",
        x = "Week of Month",
        y = ""
    ) +
    theme(text = element_text(family = "MicrosoftYaHei"))

# PM2.5指数为污染级别以上的天数分布
ggplot(dat, aes(x = monthweek, y = weekdayf, fill = PM2.5)) +
    geom_tile(colour = 'white') +
    facet_wrap( ~ monthf , nrow = 3) +
    scale_fill_gradient(
        space = "Lab",
        limits = c(75, max(dat$PM2.5)),
        low = "yellow",
        high = "red"
    ) +
    labs(
        title = "大连市2016年气温日历热图",
        subtitle = "PM2.5指数为污染级别以上的天数分布（PM2.5>=75）",
        x = "Week of Month",
        y = ""
    ) +
    theme(text = element_text(family = "MicrosoftYaHei"))

####################
#  接下来呢，我们做一些详细的统计工作，具体就是从时间细分维度来查看季度、月度、周度等平均AQI、PM2.5指数分布情况
str(mytable)

data3 <- mytable[, c(1, 2, 3, 4, 5)]

data3 <-
    transform(
        data3,
        Quarter = quarter(date),
        Month = month(date),
        Week = week(date)
    )

colnames(data3)[3] <- "Air"

colnames(data3)

data3$Air <- factor(
    data3$Air,
    levels = c("重度污染", "中度污染", "轻度污染", "良", "优"),
    labels = c("重度污染", "中度污染", "轻度污染", "良", "优"),
    ordered = T
)

#  首选查看五个污染级别在2016年度出现的频率：

# 按照 Air 的值统计数量（列为 freq），并且按 freq 降序排列
countd <- count(data3$Air) %>% arrange(-freq)

# 横纵坐标互换了；
# 每个柱子的 lable 的位置有默认值，这里只是通过 vjust/hjust 做微调
ggplot(countd, aes(x = reorder(x, freq), y = freq)) +
    geom_bar(fill = "#0C8DC4", stat = "identity") +
    labs(title = "大连市2016年度空气质量分布",
         subtitle = "污染级别频率分布图",
         caption = "https://www.aqistudy.cn/") +
    geom_text(aes(label = freq),
              hjust = 1,
              vjust = 0.5 ,
              colour = "red") +
    coord_flip() +
    theme_bw() +
    theme(
        text = element_text(family = "MicrosoftYaHei"),
        panel.border = element_blank(),
        panel.grid.major = element_line(linetype = "dashed"),
        panel.grid.minor = element_blank(),
        plot.caption = element_text(hjust = 0, size = 10),
        axis.title = element_blank()
    )

## 基于季度空气质量平均水平分布图：
Quarter <- aggregate(AQI~Quarter, data = data3, FUN = mean)
Quarter

ggplot(Quarter, aes(x = reorder(Quarter, -AQI), y = AQI)) +
    geom_bar(fill = "#0C8DC4", stat = "identity") +
    labs(title = "大连市2016年度空气质量分布",
         subtitle = "AQI污染指数季度指标平均分布图",
         caption = "https://www.aqistudy.cn/") +
    geom_text(aes(label = round(AQI)),
              vjust = 1.5,
              colour = "white",
              size = 8) +
    theme_bw() +
    theme(
        text = element_text(family = "MicrosoftYaHei"),
        panel.border = element_blank(),
        panel.grid.major = element_line(linetype = "dashed"),
        panel.grid.minor = element_blank(),
        plot.caption = element_text(hjust = 0, size = 10),
        axis.title = element_blank()
    )

# 基于月度空气质量平均水平分布图：
Month <- aggregate(AQI~Month, data=data3, FUN=mean)

Month

# reorder(Month, -AQI)  含义是：按照 AQI 降序，排列 Month
# factor(Month) 含义是：把数字的 1，2，3，4 变成 factor

ggplot(Month, aes(x = reorder(Month, -AQI), AQI)) +
    geom_bar(fill = "#0C8DC4", stat = "identity") +
    labs(title = "大连市2016年度空气质量分布",
         subtitle = "AQI污染指数月度指标平均分布图",
         caption = "https://www.aqistudy.cn/") +
    geom_text(aes(label = round(AQI)),
              vjust = 1.5,
              colour = "white",
              size = 6) +
    theme_bw() +
    theme(
        text = element_text(family = "MicrosoftYaHei"),
        panel.border = element_blank(),
        panel.grid.major = element_line(linetype = "dashed"),
        panel.grid.minor = element_blank(),
        plot.caption = element_text(hjust = 0, size = 10),
        axis.title = element_blank()
    )

## 每周情况
## AQI~Week 含义是 AQI by Week，后面的 mean 的参数是 AQI
Week <- aggregate(AQI~Week, data = data3,FUN = mean)
Week
head(data3)

ggplot(Week, aes(x = factor(Week, order = T), y = AQI, group = 1)) +
    geom_line(col = "#0C8DC4") +
    labs(title = "大连市2016年度空气质量分布",
         subtitle = "AQI污染指数周度指标平均分布图",
         caption = "https://www.aqistudy.cn/") +
    geom_text(
        aes(label = ifelse(Week > 100, Week, "")),
        vjust = 1.5,
        colour = "white",
        size = 6
    ) +
    theme_bw() +
    theme(
        text = element_text(family = "MicrosoftYaHei"),
        panel.border = element_blank(),
        panel.grid.major = element_line(linetype = "dashed"),
        panel.grid.minor = element_blank(),
        plot.caption = element_text(hjust = 0, size = 10),
        axis.title = element_blank()
    )

####################
## factor
gss_cat %>%
    count(race)

ggplot(gss_cat, aes(race)) +
    geom_bar() +
    scale_x_discrete(drop = FALSE)

# 和 SQL 很像，group by + summarise
relig_summary <- gss_cat %>%
    group_by(relig) %>%
    summarise(
        age = mean(age, na.rm = TRUE),
        tvhours = mean(tvhours, na.rm = TRUE),
        n = n()
    )

relig_summary

# 图不方便看，因为 y 轴 没有顺序
ggplot(relig_summary, aes(x = tvhours, y = relig)) + geom_point()

# 对 y 轴排序
ggplot(relig_summary, aes(x = tvhours, y = fct_reorder(relig, tvhours))) +
    geom_point()

#  或者，先改变 数据，再 ggplot
relig_summary %>%
    mutate(relig = fct_reorder(relig, tvhours)) %>%
    ggplot(aes(tvhours, relig)) +
    geom_point()


rincome_summary <- gss_cat %>%
    group_by(rincome) %>%
    summarise(
        age = mean(age, na.rm = TRUE),
        tvhours = mean(tvhours, na.rm = TRUE),
        n = n()
    )

ggplot(rincome_summary, aes(age, rincome)) + geom_point()

# 这个 reorder 无意义，因为 y 轴本身是 数值，有大小，再排序后，坐标轴刻度就乱了
ggplot(rincome_summary, aes(age, fct_reorder(rincome, age))) + geom_point()


# 把 ""Not applicable"" 放到最后
ggplot(rincome_summary, aes(age, fct_relevel(rincome, "Not applicable"))) +
    geom_point()


# count 也是 group_by，并且增加了一列，列名为 n
by_age <- gss_cat %>%
    filter(!is.na(age)) %>%
    group_by(age) %>%
    count(marital) %>%
    mutate(prop = n / sum(n))

# 和上面是一个效果
gss_cat %>%
    filter(!is.na(age)) %>%
    group_by(age, marital) %>%
    summarise(cnt = n()) %>%
    mutate(prop = cnt / sum(cnt))

by_age


a <- matrix(1:9, nrow=3)

