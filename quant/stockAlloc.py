
import copy

'''
初始：总金额，平均分配；
根据股票的当前价格，计算每只股票的股数；
对股数进行四舍五入，根据四舍五入后的新股数，重新计算总金额，并记录下和初始金额的差异；
第二天，根据股票的价格，与昨天的股数，计算总金额；
如果总金额和昨天的总金额，差异在 3%（可以设置参数） 以内，不做任何调整；
如果超过 3% ，重新分配金额；
每月第一个交易日，再有 2w 资金进入，重新调整股票；
如果股票停牌，则只调整不停牌的股票；
'''

# 股票日价格数据
# [StockInfo]
stockList = []

# 每一天的组合记录
# [DailyLog]
txHistory = []

# 总投入
# global totalAmt 
totalAmt = 0 


class PriceInfo:
    def __init__(self, bizDate, price):
        self.bizDate = bizDate 
        self.price = float(price) 
    
    def toString(self): 
        return f"{self.bizDate}, {self.price}"

class StockInfo: 
    def __init__(self, stockCode, priceList):
        self.stockCode = stockCode 
        # [PriceInfo]
        self.priceList = priceList


def loadFile(fileName):
    '''
    从文件中加载价格数据
    '''
    priceList = []
    with open(fileName, "r", encoding="utf-8") as inFile: 
        for line in inFile.readlines():
            items = line.split(",")
            # print(f"{len(items)}, {items[0]}, {items[1]}")
            if len(items) >= 2:
                p = PriceInfo(items[0], items[1])
                # print(p.toString())
                priceList.append(p)
    
    priceList.sort(key=lambda a: a.bizDate)
    return priceList


def loadData(stockPool):
    '''
    循环加载每只股票的数据
    '''
    for s in stockPool:
        fileName = f"{s}.txt"
        priceList = loadFile(fileName)
        stock = StockInfo(s, priceList)
        stockList.append(stock)

def getAllTxDate(stockList): 
    '''
    根据所选股票的交易记录，获取交易日；之后对每个交易日进行循环，而不仅是下一天，因为有停牌
    '''

    allDays = []
    for s in stockList:
        for p in s.priceList:
            # print(p.bizDate)
            allDays.append(p.bizDate)
    
    distDays = list(set(allDays))
    distDays.sort()

    return distDays

# 每天，每只股票，价格，持有股数
class stockTick: 
    def __init__(self, stockCode, date, price): 
        self.stockCode = stockCode
        self.bizDate= date 
        self.price = float(price)
        self.shares = 0  
        self.avail = True 

# 每一天，组合信息
class DailyLog: 
    def __init__(self, date):
        # 交易日
        self.bizDate = date

        # 是否重组
        self.shuffled = False 

        # 重新分配后的总金额，和上一天总金额的差异
        self.amtDiff = 0    

        #  [stockTick]
        self.stockList = []

        # [stockTick]
        self.stockDiff = []


    def getAmtInfo(self): 
        amt = 0 
        for s in self.stockList: 
            amt += s.price * s.shares
        
        transAmt = 0
        for s in self.stockDiff: 
            transAmt += abs(s.shares) * s.price    

        fee = transAmt * 0.005
        
        return amt, transAmt, fee  

    def toString(self):
        l = "" 
        amt = 0 
        for s in self.stockList: 
            amt += s.price * s.shares
            l += f"B, {self.bizDate}, {s.stockCode}, {s.price}, {s.shares}, {s.avail}, {s.bizDate}\n"

        b = ""
        transAmt = 0
        for s in self.stockDiff: 
            b += f"C, {self.bizDate}, {s.stockCode}, {s.price}, {s.shares}\n"
            transAmt += abs(s.shares) * s.price

        fee = transAmt * 0.005
        a = f"A, {self.bizDate}, {self.shuffled}, {amt}, {transAmt}, {fee}, {self.amtDiff}\n"

        return a + l + b

def getLastSnapshot(): 
    # 返回上一个交易日的 snapshot
    last = len(txHistory) - 1
    if last >= 0: 
        return txHistory[last]
    
    # 返回一个 dummy 
    return DailyLog("1990-01-01")


def getStockPrice(stockCode, date, lastSnapshot): 
    # 如果这天有价格，表示可以交易，否则就是停牌，不能交易
    # print(f"getStockPrice: {stockCode}")
    for s in stockList: 
        # print(f"\t{s.stockCode}")
        if s.stockCode == stockCode:
            found = False 

            # print(f"\t{stockCode}, {date}")
 
            for i in s.priceList: 
                if i.bizDate == date: 
                    found = True 
                    # 找到了这支股票，这天的价格
                    return stockTick(stockCode, date, i.price)

            if not found: 
                # 这支股票，这天没有价格，也即：停牌了，取前一天的价格
                for i in lastSnapshot.stockList: 
                    if i.stockCode == stockCode: 
                        t = stockTick(i.stockCode, i.bizDate, i.price)
                        t.avail = False
                        return t 
    
    # 股票都没有找到，返回价格为零的记录
    t = stockTick(stockCode, date, 0)
    t.avail = False 
    return t


def getAvailStock(bizDate, stockPool, lastSnapshot): 
    '''
    取得 bizDate 这天能交易的股票，逻辑是：判断能否取到价格，如果能取到，则可以交易，否则，不可以交易
    '''
    # print(f"getAvailStock: {bizDate}")

    availStocks = [] 
    for s in stockPool: 
        p = getStockPrice(s, bizDate, lastSnapshot)
        if p.avail:  
            availStocks.append(p)

    return availStocks 


def needShuffle(availStocks, lastSnapshot, amt): 
    '''
    判断是否需要重新分配金额,
    比较：最新的价格 * 手上现有的股数，与昨天的总金额；
    只处理没有停牌的股票；
    如果停牌的股票又被放出来了，则取停牌前最后一天的价格，作为上一天的价格； 
    amt: 新注入的资金，只要有，就需要重新配平
    '''

    # 如果上一个交易日没有股票，也即：第一天
    if len(lastSnapshot.stockList) == 0: 
        return amt, True 

    newAmt = 0
    oldAmt = 0 
    for s in availStocks: 
        for i in lastSnapshot.stockList:
            if s.stockCode == i.stockCode: 
                # print(f"{s.price}, {i.price}, {i.shares}")
                newAmt += s.price * i.shares 
                oldAmt += i.price * i.shares 
                break  

    # 计算总金额变化比例
    pect = 100 
    # TODO: 为什么会是 0 ？
    if oldAmt != 0: 
        pect = abs(newAmt - oldAmt) / oldAmt * 100 

    # 如果超过 3%，需要重新分配，或者有新资金注入
    # 可重新分配的金额  = 新金额 
    if pect >= 3 or amt > 0: 
        return newAmt + amt, True
    
    return newAmt + amt, False 


def oneDay(bizDate, stockPool): 
    # 上一个交易日的组合
    lastSnapshot = getLastSnapshot() 
    # print(f"{bizDate}, {lastSnapshot.bizDate}, {len(lastSnapshot.stockList)}")

    # bizDate 这天，可以交易的股票
    availStocks = getAvailStock(bizDate, stockPool, lastSnapshot)
    # print(f"{bizDate}, {len(availStocks)}")

    # 初始资金
    newDeposit = 0
    if len(lastSnapshot.stockList) == 0: 
        newDeposit = 100000
    else: 
        # 以后每月的第一天，重新注入资金
        a = bizDate[:7]
        b = lastSnapshot.bizDate[:7]
        if a != b: 
            newDeposit = 20000

    # 总投入
    global totalAmt 
    totalAmt += newDeposit

    # 是否需要重新配平
    amt, r = needShuffle(availStocks, lastSnapshot, newDeposit)
    
    if r:
        # 需要重新配平
        doAllocate(bizDate, availStocks, lastSnapshot, amt)
    else:
        # 不需要重新配平，只需要更新价格，不需要调整其它信息
        today = DailyLog(bizDate)

        for l in lastSnapshot.stockList: 
            found = False 
            for s in availStocks: 
                if l.stockCode == s.stockCode:
                    # 更新最新价格 
                    found = True 
                    t = copy.copy(l) 
                    t.avail = True 
                    t.price = s.price
                    today.stockList.append(t)
                    break 

            # 停牌了，使用上一次的信息
            if not found:
                t = copy.copy(l) 
                t.avail = False
                today.stockList.append(l) 

        txHistory.append(today)


def doAllocate(bizDate, availStocks, lastSnapshot, avilAmt):
    '''
    对总金额，进行重新分配
    '''
  
    # 可以交易的股票数据，以及每只股票的理论金额
    stockCnt = len(availStocks)
    eachAmt = avilAmt
    if stockCnt != 0 : 
        eachAmt = avilAmt / stockCnt 

    # 对可交易的股票，重新分配，股数四舍五入
    stockShares = [] 
    for s in availStocks: 
        t = s 
        t.shares = round(eachAmt / s.price)    
        # print(f"{bizDate}, {t.shares}, {eachAmt}, {s.price}")
        stockShares.append(t)

    # 计算重新分配后的总金额差异
    amt = 0
    for s in stockShares: 
        amt += s.price * s.shares
    diff = avilAmt - amt 

    # 记录下这一天的组合信息
    oneDay = DailyLog(bizDate)
    oneDay.amtDiff = diff
    oneDay.shuffled = True 

    # 今天可以交易的股票
    for s in stockShares: 
        # print(f"{bizDate}, {s.shares}")
        oneDay.stockList.append(s) 

        # 不是第一天
        if len(lastSnapshot.stockList) > 0: 
            # 计算前后的股数差异
            for i in lastSnapshot.stockList: 
                if s.stockCode == i.stockCode: 
                    t = copy.copy(s) 
                    t.shares = s.shares - i.shares
                    oneDay.stockDiff.append(t)
                    break 
        else: 
            # 第一天
            oneDay.stockDiff.append(s)


    # 今天停牌的股票，也需要加入到 list 中
    for l in lastSnapshot.stockList: 
        found = False 
        for s in availStocks: 
            if s.stockCode == l.stockCode: 
                found = True 
                break 
        # 没找到价格，也即：停牌了        
        if not found: 
            t = copy.copy(l)
            t.avail = False 
            oneDay.stockList.append(t)

    txHistory.append(oneDay)
    




def run(): 
    # 选出的股票池
    stockPool = ["601006", "002301", "002397", "600337", "300676"]
    # stockPool = ["300676"]
    

    # 股票日价格数据
    # [StockInfo]
    loadData(stockPool)

    allTxDays = getAllTxDate(stockList)
    # print(f"days: {len(allTxDays)}")
    # for d in allTxDays:
    #     print(d)

    for d in allTxDays: 
        oneDay(d, stockPool)

    global totalAmt 
    
    with open("test_out.txt", "w", encoding="utf-8") as outputFile: 
        for t in txHistory:
            outputFile.write(t.toString() + "\n")

        allIn = 100000
        lastMonth = ''
        thisMonth = ''
        for t in txHistory:
            thisMonth = t.bizDate[:7]

            if t.shuffled: 
                # 不是初始，每个月增加 20000 的投入
                if lastMonth != "" and lastMonth != thisMonth:
                    allIn += 20000

                amt, transAmt, fee = t.getAmtInfo()
                m = f"{t.bizDate}, {amt}, {allIn}, {transAmt}, {fee} \n"
                outputFile.write(m)

            lastMonth = thisMonth     

        outputFile.write(f"{totalAmt}")        


run() 


# a = PriceInfo("2018-03-21", 123)
# print(a.toString())