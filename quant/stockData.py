# -*- coding:utf-8 -*-
import requests
from bs4 import BeautifulSoup
import os
import time


def getURL(stockCode, year, quarter): 
    '''
    接受股票代码，返回对应的 url
    '''
    url = f"http://money.finance.sina.com.cn/corp/go.php/vMS_MarketHistory/stockid/{stockCode}.phtml?year={year}&jidu={quarter}"
    # print(f"url: {url}")
    return url


def creatSoup(url):
    '''
    该函数返回一个url的soup对象
    :param url:一个页面的链接
    '''
    # 获取网页，得到一个response对象
    response = requests.get(url)
    # 指定自定义编码，让文本按指定的编码进行解码，因为网站的charset = gb2312
    response.encoding = 'gb2312'
    # 使用解码后的数据创建一个soup对象，指定HTML解析器为Python默认的html.parser
    return BeautifulSoup(response.text, 'html.parser')


class DailyInfo: 
    def __init__(self, bizDate, openPrice, highPrice, closePrice, lowPrice, txQty, txAmt):
        # 交易日期
        self.bizDate = bizDate
        # 开盘价，最高价，收盘价，最低价
        self.openPrice = openPrice
        self.highPrice = highPrice
        self.closePrice = closePrice
        self.lowPrice = lowPrice
        # 交易量
        self.txQty= txQty
        # 交易金额
        self.txAmt = txAmt   

    def toString(self): 
        return f"{self.bizDate}, {self.openPrice}, {self.highPrice}, {self.closePrice}, {self.lowPrice}, {self.txQty}, {self.txAmt}"



def getStockPrice(stockCode):
    '''
    解析表格中的数据，一只股票存成一个文件。
    '''

    # 最终结果
    results = [] 

    for year in range (2017, 2019): 
        for quarter in range(1, 5): 
            url = getURL(stockCode, year, quarter) 

            # 调用函数，创建soup对象
            soup = creatSoup(url)
            # 数据在表格中
            table = soup.find(id="FundHoldSharesTable")
            # 没找到 table，含义是这个期间没有数据
            if table is None: 
                break 
            
            isHeader = True
            for tr in table.findAll("tr"):
                # 第一行，表头，跳过
                if isHeader: 
                    isHeader = False 
                    continue

                # 从第二行开始，是数据
                tds = tr.findAll("td")
                # 取得每个 td 中的数据，并剔除空格
                items = [ i.getText().strip() for i in tds]
                # 如果是表头，则跳过
                if items[0] == "日期": 
                    continue 

                oneDay = DailyInfo(items[0], items[1], items[2], items[3], items[4], items[5], items[6]) 
                
                results.append(oneDay)
            
            print(f"finished: {stockCode} - {year} - {quarter}")
            time.sleep(1)

    print(f"results: {len(results)}")

    # TODO: 按交易日期排序
               
    # 保存到文件
    with open(f"{stockCode}.txt", 'w', encoding="utf-8") as outputFile:
        for i in results: 
            outputFile.write(i.toString() + "\n")

    print("done.")




def getBatch(): 
    '''
    一次性获取多只股票的价格，存成不同的文件
    '''
    pool = ["601006", "002301", "002397", "600337", "300676"]

    # TODO: 300676 的 2017 年 3、4 季度数据没有抓到？

    for stock in pool: 
        getStockPrice(stock)


getBatch() 