library(XML)
library("jiebaR")

library(wordcloud2)
library(RCurl)
library(stringr)
library(plyr)
library(dplyr)

url<-"https://movie.douban.com/subject/25765735/reviews?rating=&start=0"
baseurl<-"https://movie.douban.com/subject/25765735/reviews"


############### 建立影评网址抓取函数

#豆瓣影评的网址遍历过程

# 每一页有 20 条评论，取前 pages 页
pages <- 2
urln <- paste0(baseurl,"?rating=&start=", 20 * (seq(0:pages) - 1))
urln

# #### old way - begin
# getCommentURL <- function(urln){                 
#     rd <- getURL(urln,.encoding="UTF-8")  #获取网页
#     
#     rdhtml <- htmlParse(rd, encoding="UTF-8")   #解析网页
#     root <- xmlRoot(rdhtml)  #获取根节点
#     page <- getNodeSet(root,"//div[@class='main review-item']/div[@class='main-bd']/h2/a")
#     
#     #获取目标节点内的属性值（这里是评论网址）
#     pagevalue <- unique(laply(page, xmlGetAttr, name='href')) 
# }
# 
# #使用向量化函数进行循环处理
# pagefull <- sapply(urln, getCommentURL) 
# #### old way - end

# 打开 url，根据 selector 找到 nodes，对 nodes 调用 fn，并返回结果 
crawl_url <- function(url, selector, fn) {
    # url <- "https://movie.douban.com/subject/25765735/reviews?rating=&start=20"
    # selector <- selector1 
    # fn <- fn1
    
    rd <- getURL(url, .encoding="UTF-8")  #获取网页
    
    rdhtml <- htmlParse(rd, encoding="UTF-8")   #解析网页
    root <- xmlRoot(rdhtml)  #获取根节点
    nodes <- getNodeSet(root, selector)
    
    #获取目标节点内的
    fn(nodes)
}

getHref <- function(nodes) {
    unique(lapply(nodes, xmlGetAttr, name='href')) 
}
selector1 <- "//div[@class='main review-item']/div[@class='main-bd']/h2/a"

pagefull <- lapply(urln, crawl_url, selector=selector1, fn=getHref)
pagefull

#转换列表为向量
pagefullnew <- unlist(pagefull, use.names = F)
pagefullnew

# 建立评论区评论文本获取函数
getText <- function(nodes) {
    laply(nodes, xmlValue, trim=T)
}
selector2 <- "//div[@class='review-content clearfix']/p"

fn2 <- function(url) {
    crawl_url(url, selector2, getText)
}
valuefull <- sapply(pagefullnew, crawl_url, selector = selector2, fn = getText)

#转换列表为向量
valuefullnew <- unlist(valuefull, use.names =F)


# 文本分词处理过程
# jieba 分词
mixseg = worker()
split <- function(msg) {
    mixseg <= msg
}

# 分词的向量处理，注意：user.names = FALSE 否则会把拆分前的 string 保留下来
allwords <- unlist(sapply(myrevieww, split), use.names=FALSE) 
thewords <- allwords[nchar(allwords) > 1]


# 建立关于影评的停止词
invalid.words <- c("电影", "演员", "导演", "我们", "他们", "一个", "没有",
                   
                   "所以", "可以", "影片", "但是", "因为", "什么", "自己",
                   
                   "这个", "故事", "最后", "这样", "觉得", "为了", "一部",
                   
                   "这部", "片子", "其实", "当然", "时候", "看到", "已经",
                   
                   "这种", "知道", "这些", "一样", "如果", "观众", "人物",
                   
                   "开始", "那么", "那个", "可能", "情节", "结局", "结尾",
                   
                   "风格", "节奏", "剧情", "有点", "终于", "之后", "怎么",
                   
                   "一种", "出现", "作品", "地方", "本片", "一些", "一定",
                   
                   "之前", "还是", "虽然", "这么", "角色", "这么", "不过",
                   
                   "类型", "以为", "显得", "还是", "算是", "东西", "有些", 
                   "金刚", "战警", "就是")

# 过滤掉词
theflags <- thewords %in% invalid.words
thewords <- thewords[!theflags]

reviewdata <- freq(thewords) %>% 
    as.data.frame(stringsAsFactors = FALSE) %>% 
    arrange(desc(freq))

head(reviewdata)

# 使用文字云包处理
wordcloud2(reviewdata[1:1000,], color = "random-light", minSize=.5, size=1, 
           backgroundColor = "dark", minRotation = -pi/6, maxRotation = -pi/6,
           fontFamily ="微软雅黑")


# 导出词频结果
getwd()
setwd("~/Documents/playground/easypy/notebooks/self/r")
write.table(reviewdata,file="reviewdata.csv", sep =",", row.names =FALSE)


####################################
## 读取 word
# word <- system.file(package = "officer")
# word
library(officer)

# 获取目录下所有文件，并生成完整的路径+文件名
getAllFiles <- function(path) {
    file_names <- list.files(path)
    file_names
    
    # 只保留 word 文档
    remains <- file_names[which(grepl("docx$|doc$", file_names))]
    remains
    
    # 带完整路径的文件名
    full_name <- function(name) {
        paste0(path, "/", name)
    }

    unlist(lapply(remains, full_name), use.names = F)
}

# 提取一个文件中的信息
extractContent <- function(full_name) {
    # 打开文件
    doc <- read_docx(full_name)
    
    ##---------------提取所有段落--------------##
    content <- docx_summary(doc) 
    par_data <- content[which(content$content_type == "paragraph"), ]
    # head(par_data, 20)
    
    # 只需要 text 列
    par_data[, "text"]
}

# 参数：需要拆分的句子，stop word list
drawCloud <- function(textList, stop_words) {
    # 文本分词处理过程
    # jieba 分词
    mixseg = worker()
    split <- function(msg) {
        mixseg <= msg
    }
    
    # 分词的向量处理，注意：user.names = FALSE 否则会把拆分前的 string 保留下来
    allwords <- unlist(sapply(textList, split), use.names=FALSE) 
    thewords <- allwords[nchar(allwords) > 1]
    
    # 过滤掉词
    theflags <- thewords %in% stop_words
    thewords <- thewords[!theflags]
    
    # 统计出现的次数，并且从大到小排序
    wordFreq <- freq(thewords) %>% 
        as.data.frame(stringsAsFactors = FALSE) %>% 
        arrange(desc(freq))
    
    # head(wordFreq)
    
    # 取前 60% 的词
    totalRow <- dim(wordFreq)[1]
    remain <- ceiling(totalRow * 0.62)
    
    # 使用文字云包处理
    wordcloud2(wordFreq[1:remain, ], color = "random-light", minSize=.5, size=1, 
               backgroundColor = "dark", minRotation = -pi/6, maxRotation = -pi/6,
               fontFamily ="微软雅黑")
}

# 根据目录，获取指定类型的文件清单;
# 对每一个文件，读取文件内容；
# 进行分词，然后画词云
parseMemo <- function(path, stop_words) {
    # 获取指定目录下的所有文件，包含了文件名过滤
    files <- getAllFiles(path)
    
    # 对每个文件，提取信息
    allText <- unlist(lapply(files, extractContent), use.names = F)
    
    drawCloud(allText, stop_words)
}

# 文件目录
path = "~/Documents/project/Support/圣象/itsp2/20.战略理解与现状诊断/10.访谈/12.访谈纪要&会议纪要"

# 建立关于影评的停止词
stop_words <- c("IBM", "400", "类型", "以为", "显得", "还是", "算是", "东西", "有些", 
                   "金刚", "战警", "就是")

parseMemo(path, stop_words)








