# 加载quantmod包
if(!require(quantmod)){
  install.packages("quantmod")
}
# 股票行情匹配函数
Quote = function(code){
  index = match(code,universes)
  temp = lapply(universes,get)
  return(temp[[index]])
}
# 基本配置
universes <<- c("000001.SZ","QIHU","MOMO")
from = "2015-01-04"
to = Sys.Date() # 结束时间设为当前日期
src= "yahoo" # 来源雅虎财经

# 行情加载 速度有点慢，耐心等待
quantmod::getSymbols(universes,from=from,to=to,src=src)

# 绘制行情
quantmod::chartSeries(Quote("MOMO"),up.col='red',dn.col='green',TA="addVo(); addADX();addMACD(); addSMA(n=10);addBBands(n=14,sd=2,draw=\"bands\")")
