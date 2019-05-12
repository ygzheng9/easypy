
library(wordcloud2)
library(wordcloud)
library(jiebaR)

setwd("~/Documents/playground/easypy/notebooks/julia/self/r")

# 英文
wordcloud2(demoFreq, size = 1,shape = 'star')  
wordcloud2(demoFreq, size = 2, minRotation = -pi/2, maxRotation = -pi/2) 
wordcloud2(demoFreq, size = 2, minRotation = -pi/6, maxRotation = -pi/6, rotateRatio = 1)

letterCloud(demoFreq, word ="R", wordSize = 2,color = 'random-dark')

# 中文
wordcloud2(demoFreqC, size = 2, fontFamily = "微软雅黑",  color = "random-light", backgroundColor = "grey")  


# 读文件
data <- read.csv('c:/data.csv', sep="," ,header = T)  
#检查数据，查看是否存在乱码的情况  
head(data)

#绘制文字云，其中data就是我们读取的数据，size是对应文字大小，shape是绘制形状  
wordcloud2(data, size = 1, shape='cardioid',color = 'random-dark', backgroundColor = "white",fontFamily = "微软雅黑")



# 图片背景, 必须是黑白图片
batman = system.file("../dataset/horse.png",package = "wordcloud2")

wordcloud2(demoFreq, figPath = batman, size = 1)

wordcloud2(demoFreqC, figPath='../dataset/pd.png') 

#导入包里面的图片
log<-system.file("examples/t.png",package="wordcloud2")   

#size的大小可以说是调节图片形状的边缘模糊度，值越小表现越清晰
wordcloud2(demoFreqC, fontFamily = "微软雅黑",  size = 1,figPath =log) 


# 
#读入数据分隔符是‘\n’，字符编码是‘UTF-8’，what=''表示以字符串类型读入
f <- scan('../dataset/wordcloud2.txt',sep='',what='',encoding="UTF-8")

#使用qseg类型分词，并把结果保存到对象seg中
seg <- qseg[f] 

#去除字符长度小于2的词语
seg <- seg[nchar(seg)>1] 

seg <- table(seg) #统计词频
seg <- seg[!grepl('[0-9]+',names(seg))] #去除数字
seg <- seg[!grepl('a-zA-Z',names(seg))] #去除字母
length(seg) #查看处理完后剩余的词数
seg <- sort(seg, decreasing = TRUE)[1:100] #降序排序，并提取出现次数最多的前100个词语
seg #查看100个词频最高的
View(seg)
data=data.frame(seg)
data

wordcloud(data$seg , data$Freq, fontFamily = "微软雅黑",  colors = rainbow(100), random.order=F)

x11()
dev.off()
