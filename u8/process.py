import xlrd

import pyodbc
import textwrap
import copy
import xlsxwriter

import bom

# 日计划开始的列号，从 0 开始
START_COLUMN = 3

# 日计划的数据列数
TOTAL_COLUMN = 20


def setupDB():
    # 创建数据库连接

    # server = 'serveru8'
    # database = 'UFDATA_128_2012'
    # password = 'P@ss12345'

    server = 'server05'
    database = 'UFDATA_001_2012'
    username = 'sa'
    password = 'Z&9I^0x)9D*6'

    cnxn = pyodbc.connect('DRIVER={SQL Server};SERVER=' + server + ';DATABASE='
                          + database + ';UID=' + username + ';PWD=' + password)
    cursor = cnxn.cursor()

    return cursor


class StockInfo:
    # 现存量需要检查的仓库
    def __init__(self):
        self.whCode = ''  # 仓库编码
        self.whName = ''  # 仓库名称


def getWarehouses(workbook):
    # 从文件中读取 仓库设置
    warehouseSheet = workbook.sheet_by_name("Sheet1")

    nrows = warehouseSheet.nrows
    results = []
    for idx in range(nrows):
        row_data = warehouseSheet.row_values(idx)

        if (len(f'${row_data[0]}')) == 0:
            break
        else:
            if idx == 0:
                continue
            if row_data[2] == 'Y':
                w = StockInfo()
                # 代码是两位，不足两位，左边补零
                t = "00" + '%d' % row_data[0]
                w.whCode = t[-2:]
                w.whName = row_data[1]
                results.append(w)

    return results


class CurrentStock:
    # 现存量
    def __init__(self):
        self.invCode = ""  # 料号
        self.qty = 0  # 现存量


def getCurrentStock(warehouses, cursor):
    # 根据 设置的仓库，读取 现存量

    # 拼接 in 条件
    cond = "''"
    for w in warehouses:
        cond = f"{cond}, '{w.whCode}'"

    # 现存量查询
    sqlCmd = textwrap.dedent(f"""
            select c.cInvCode, SUM(iQuantity) qty
            from CurrentStock c
            where 1 = 1
            and c.cWhCode in ({cond})
            group by  c.cInvCode;
    """)

    results = []
    cursor.execute(sqlCmd)
    for i in cursor.fetchall():
        if i.qty != 0:
            t = CurrentStock()
            t.invCode = i.cInvCode
            t.qty = i.qty
            results.append(t)

    return results


def getOpenStock(cursor):
    # 取得 到货未入库 的 采购量，委外量
    # d.cBusType,
    sqlCmd = textwrap.dedent("""
        with dtl as (
        select h.dDate, h.cBusType, h.cCode, d.cInvCode, d.iQuantity, d.fValidInQuan, (d.iQuantity - d.fValidInQuan) avlQty
        from PU_ArrivalVouchs d
        inner join PU_ArrivalVouch h on h.ID = d.ID
        where 1 = 1
        and d.iQuantity <> d.fValidInQuan
        and h.dDate >= '2017-06-01'
        )
        select d.cInvCode, SUM(avlQty) avlQty
        from dtl d
        group by d.cInvCode
        having SUM(avlQty) <> 0;
    """)

    results = []
    cursor.execute(sqlCmd)
    for i in cursor.fetchall():
        if i.avlQty != 0:
            t = CurrentStock()
            t.invCode = i.cInvCode
            t.qty = i.avlQty
            results.append(t)

    return results


def getMiddleStock(cursor):
    # 生产备料仓 和 生产订单子件需求 的差异
    # print("tobe done")
    sqlCmd = """
        -- 生产订单子件需求 - 备料仓库存
    with po as (
        select a.invCode, sum(a.Qty - a.IssQty) qty
        from v_mom_moallocate a
        inner join v_mom_orderdetail_rpt d on d.ModID = a.ModID
        inner join v_mom_order_rpt h  on h.MoID = d.MoID
        inner join inventory i on i.cInvCode = d.invCode
            where 1 =  1
                -- and h.MoCode = '0000010537'
                and d.Status = '3'  -- 审核
        group by a.invCode
        ),
        inv as (
        select  a.cInvCode invCode, SUM(a.iQuantity) qty
            from currentstock a
        where a.cWhCode = '07'
            and a.iQuantity <> 0
        group by a.cInvCode
        ),
        cmb as (
        select a.invCode, (a.qty) qty
            from po a
        union all
        select b.invCode, (-1 * b.qty) qty
            from inv b
        ),
        cmb2 as (
        select invCode, SUM(qty) diff
            from cmb
        group by InvCode
            having SUM(qty) <> 0
        )
        select a.InvCode invCode, a.diff qty
            from cmb2 a
        inner join Inventory i on i.cInvCode = a.InvCode
    """

    results = []
    cursor.execute(sqlCmd)
    for i in cursor.fetchall():
        if i.qty != 0:
            t = CurrentStock()
            t.invCode = i.invCode
            t.qty = i.qty
            results.append(t)

    return results


def saveCurrentStock(workbook, currentStock):
    # 保存到文件：现存量
    worksheet = workbook.add_worksheet("现存量")
    worksheet.write("A1", "料号")
    worksheet.write("B1", "现存量")

    i = 1
    for s in currentStock:
        if s.qty != 0:
            i = i + 1
            worksheet.write(f'A{i}', s.invCode)
            worksheet.write(f'B{i}', s.qty)


def saveOpenStock(workbook, openStock):
    # 保存到文件：未入库量
    worksheet = workbook.add_worksheet("到货未入库量")
    worksheet.write("A1", "料号")
    worksheet.write("B1", "未入库量")

    i = 1
    for s in openStock:
        if s.qty != 0:
            i = i + 1
            worksheet.write(f'A{i}', s.invCode)
            worksheet.write(f'B{i}', s.qty)


def saveMiddleStock(workbook, midStock):
    # 保存到文件：未入库量
    worksheet = workbook.add_worksheet("备料仓差异")
    worksheet.write("A1", "料号")
    worksheet.write("B1", "备料仓差异量")

    i = 1
    for s in midStock:
        if s.qty != 0:
            i = i + 1
            worksheet.write(f'A{i}', s.invCode)
            worksheet.write(f'B{i}', s.qty)


def mergeStock(currStock, openStock, middleStock):
    # 现存量，未入库量，库存合并
    # 取得料号
    getInvCode = lambda s: s.invCode
    currInvs = list(map(getInvCode, currStock))
    openInvs = list(map(getInvCode, openStock))
    midInvs = list(map(getInvCode, middleStock))

    # 取得不重复的料号
    distInvs = list(set(currInvs + openInvs + midInvs))

    results = []
    for inv in distInvs:
        a = CurrentStock()
        a.invCode = inv

        for i in currStock:
            if i.invCode == inv:
                a.qty += i.qty
                break

        for i in openStock:
            if i.invCode == inv:
                a.qty += i.qty
                break

        # 注意：这里是减号
        for i in middleStock:
            if i.invCode == inv:
                a.qty -= i.qty
                break

        results.append(a)

    return results


def saveMergedStock(workbook, mergedStock):
    # 保存到文件：未入库量
    worksheet = workbook.add_worksheet("总可用量")
    worksheet.write("A1", "料号")
    worksheet.write("B1", "总可用量")

    i = 1
    for s in mergedStock:
        if s.qty != 0:
            i = i + 1
            worksheet.write(f'A{i}', s.invCode)
            worksheet.write(f'B{i}', s.qty)


class PlanItem:
    def __init__(self):
        self.invCode = ''  # 计划的料号
        self.currQtys = []  # 每天的计划数据
        self.accQtys = []  # 累计到今天的数据

        self.subs = []  # invCode 的 下一层 bom.OneLevel

        # 下层子件的累计需求，每个元素代表每一天的需求，每一天的需求还是一个 list（下层子件的需求），
        self.accSubsReq = []


def getHeader(workbook):
    # 取得计划的表头，后续写入缺料表
    warehouseSheet = workbook.sheet_by_name("Sheet2")

    #  表头有两行
    header = []
    for idx in range(2):
        row_data = warehouseSheet.row_values(idx)
        row = []
        for i in range(TOTAL_COLUMN):
            col = START_COLUMN + i
            row.append(str(row_data[col]))

        header.append(row)

    return header


def calcAccReq(workbook):
    # 从文件中读取 每天的计划，折算成累计的计划
    warehouseSheet = workbook.sheet_by_name("Sheet2")

    nrows = warehouseSheet.nrows
    results = []
    # 第一列 A：料号；从第四列 D 开始，当天计划信息
    # 从 第三行 开始
    # 之前行 直接复制
    for idx in range(2, nrows):
        row_data = warehouseSheet.row_values(idx)
        # print(f"row_data: {len(row_data)}")

        # 第一列为空，则跳出循环
        invCode = row_data[0]
        if len(invCode) == 0:
            break

        p = PlanItem()
        # 当前料号
        p.invCode = invCode

        # 计划数据：
        for i in range(TOTAL_COLUMN):
            col = START_COLUMN + i
            try:
                qty = float(row_data[col])
            except ValueError:
                qty = 0

            p.currQtys.append(qty)
            p.accQtys.append(qty)

        # 计算累计量
        cnt = len(p.currQtys)
        for i in range(1, cnt):
            p.accQtys[i] = p.currQtys[i] + p.accQtys[i - 1]

        results.append(p)

    results.sort(key=lambda a: a.invCode)
    return results


def saveAccReq(workbook, planItems):
    # 把母件的累计需求，保存到文件
    if len(planItems) == 0:
        print("累计需求：无数据传入")
        return

    # 计划天数
    dayCnt = len(planItems[0].accQtys)
    if dayCnt == 0:
        print("累计需求：无累计需求")
        return

    worksheet = workbook.add_worksheet("母件累计需求")
    worksheet.write("A1", "料号")
    for c in range(1, dayCnt + 1):
        worksheet.write(0, c, f"D{c}")

    offsetCol = 1
    row = 1
    for p in planItems:
        # 第一列 料号
        worksheet.write(row, 0, p.invCode)

        # 后面每一列，是累计需求量
        for c in range(dayCnt):
            worksheet.write(row, c + offsetCol, f"{p.accQtys[c]}")

        row += 1


def loadBOMData(cursor):
    # 加载 BOM 信息
    return bom.loadBOM(cursor)


def saveBOMData(workbook, planItems, invInfos):
    # 保存 bom 信息
    worksheet = workbook.add_worksheet("BOM")

    # 写入表头
    worksheet.write(0, 1, '子件料号')
    worksheet.write(0, 2, '子件名称')
    worksheet.write(0, 3, '用量')
    worksheet.write(0, 4, '规格')
    worksheet.write(0, 5, '外购')
    worksheet.write(0, 6, '自制')
    worksheet.write(0, 7, '委外')
    worksheet.write(0, 8, '最小起订量')
    worksheet.write(0, 9, '提前期')
    worksheet.write(0, 10, 'MCCode')

    row = 1
    for p in planItems:
        # 每一颗母件
        invCode = p.invCode
        worksheet.write(row, 0, invCode)
        for i in invInfos:
            if i.invCode == invCode:
                worksheet.write(row, 1, i.invName)
                worksheet.write(row, 2, i.invStd)
                break

        # 对该母件的所有子件
        for part in p.subs:
            # 子件的基础数据
            for s in invInfos:
                if s.invCode == part.invCode:
                    # 母件下一行
                    row = row + 1
                    # 从 第二列 开始
                    worksheet.write(row, 1, s.invCode)
                    worksheet.write(row, 2, s.invName)
                    worksheet.write(row, 3, part.baseQty)
                    worksheet.write(row, 4, s.invStd)
                    worksheet.write(row, 5, s.purchase)
                    worksheet.write(row, 6, s.selfMade)
                    worksheet.write(row, 7, s.outsourcing)
                    worksheet.write(row, 8, s.moq)
                    worksheet.write(row, 9, s.leadtime)
                    worksheet.write(row, 10, s.mcCode)
                    break

        row += 1


def expandOneLevel(inputItems, boms):
    # 循环1：每天的计划
    # 循环2：一天计划中，循环每颗料；展开BOM，计算子件需求；
    # 一天内，所有料的，所有子件需求，再按子件料号汇总；
    # 和当前库存差异；

    planItems = copy.copy(inputItems)
    # 取得母件的下级子件
    invCnt = len(planItems)
    for i in range(invCnt):
        invCode = planItems[i].invCode
        planItems[i].subs = bom.findAllSubs(invCode, boms)
        # print(f"{invCode}: subs {len(planItems[i].subs)}")

    # 根据下级子件，计算每天的子件需求量（累计量）
    dayCnt = len(planItems[0].accQtys)
    for i in range(invCnt):
        # 对每一个母件
        item = planItems[i]

        item.accSubsReq = []
        for d in range(dayCnt):
            # 对母件每一天的累计需求量
            accReq = item.accQtys[d]

            # 该母件的每个子件的耗量 * 母件的累计需求
            oneDay = []
            for s in item.subs:
                a = bom.oneLevel()
                a.invCode = s.invCode
                a.baseQty = s.baseQty * accReq
                oneDay.append(a)

            # 每天都有子件需求
            item.accSubsReq.append(oneDay)
            # print(f"{item.invCode}: day {d}")

    return planItems


def sumbyMat(planItems):
    # 参数：按照日累计需求，展开单层BOM的需求量
    # 按照子件汇总（合并母件），按天显示子件总需求

    # 首先找到所有母件的所有子件
    getInv = lambda s: s.invCode
    allInvs = []
    for i in planItems:
        # 每个母件的 子件料号
        invs = list(map(getInv, i.subs))
        allInvs += invs

    # 所有母件的子件料号
    distInvs = list(set(allInvs))
    distInvs.sort()

    # 按天，汇总这些子件的需求（忽略掉母件）
    dayCnt = len(planItems[0].accQtys)
    # 每一天的子件汇总需求
    allDays = []
    for d in range(dayCnt):
        # 对于每一天
        oneDay = []
        for inv in distInvs:
            # 这一天，所有子件的需求
            mat = bom.oneLevel()
            mat.invCode = inv
            mat.baseQty = 0

            # 累计所有母件中，该子件的需求
            for i in planItems:
                subs = i.accSubsReq[d]
                for m in subs:
                    if inv == m.invCode:
                        mat.baseQty += m.baseQty
                        break

            oneDay.append(mat)

        # 每天的子件汇总需求，合并到总需求中
        allDays.append(oneDay)

    return allDays


def saveMatReq(workbook, items):
    # 保存子件的需求（相对于母件的累计需求）
    # 计划天数
    dayCnt = len(items)
    if dayCnt == 0:
        print("保存子件需求：无子件可保存")
        return

    worksheet = workbook.add_worksheet("子件总需求")
    worksheet.write("A1", "料号")
    for c in range(1, dayCnt + 1):
        worksheet.write(0, c, f"D{c}")

    # 取得物料号
    invList = list(map(lambda s: s.invCode, items[0]))
    invList.sort()

    offsetRow = 1
    offsetCol = 1
    for r in range(len(invList)):
        # 每行一个料号
        rowIdx = r + offsetRow
        # 第一列 料号
        inv = invList[r]
        worksheet.write(rowIdx, 0, inv)

        # 后面每一列，是累计需求量
        for c in range(dayCnt):
            for b in items[c]:
                if inv == b.invCode:
                    worksheet.write(rowIdx, c + offsetCol,
                                    "%.2f" % (b.baseQty))
                    break


def calcInvDiff(dailyItems, totalStocks):
    # 现有库存，和每天子件需求 的差异
    # dailyItems: 每天的子件总需求 [[{invCode, baseQty}]]
    # totalStocks: 当前可用库存 [{invCode, qty}]

    if len(dailyItems) == 0:
        return

    # 子件清单
    allInvs = list(map(lambda s: s.invCode, dailyItems[0]))
    allInvs.sort()

    allDays = []
    for invReqs in dailyItems:
        # 每天, dailyItems 中是 每一天的需求
        oneDay = []
        for i in invReqs:
            oneInv = CurrentStock()
            oneInv.invCode = i.invCode
            oneInv.qty = -1 * float(i.baseQty)

            for s in totalStocks:
                # totalStocks 是可用库存
                if i.invCode == s.invCode:
                    oneInv.qty += float(s.qty)
                    break

            oneDay.append(oneInv)

        allDays.append(oneDay)

    return allDays


def saveInvDiff(workbook, items, totalStocks, invInfos, headers):
    # 差异保存
    # items: 每天每个子件的库存差异 [[{invCode, qty}]]
    # totalStocks； 总可用库存 [{invCode,qty}]
    # invInfos: 物料基本细信息
    # headers: 计划的表头，两行，20 列

    # 保存子件的需求（相对于母件的累计需求）
    # 计划天数
    dayCnt = len(items)
    if dayCnt == 0:
        print("保存库存差异：无数据可保存")
        return

    offsetRow = 2
    offsetCol = 10

    worksheet = workbook.add_worksheet("子件库存缺口")
    worksheet.write(0, 0, "料号")
    worksheet.write(0, 1, '名称')
    worksheet.write(0, 2, '规格')
    worksheet.write(0, 3, '外购')
    worksheet.write(0, 4, '自制')
    worksheet.write(0, 5, '委外')
    worksheet.write(0, 6, '最小起订量')
    worksheet.write(0, 7, '提前期')
    worksheet.write(0, 8, 'MCCode')
    worksheet.write(0, 9, "现有库存")

    line1 = headers[0]
    line2 = headers[1]
    hCnt = len(line1)

    for h in range(hCnt):
        worksheet.write(0, h + offsetCol, line1[h])
        worksheet.write(1, h + offsetCol, line2[h])

    # for c in range(dayCnt):
    #     worksheet.write(0, c + offsetCol, f"D{c + 1}")

    # 取得物料号
    invList = list(map(lambda s: s.invCode, items[0]))
    invList.sort()

    for r in range(len(invList)):
        # 每行一个料号
        rowIdx = r + offsetRow
        # 第一列 料号
        inv = invList[r]
        worksheet.write(rowIdx, 0, inv)

        for s in invInfos:
            if s.invCode == inv:
                worksheet.write(rowIdx, 1, s.invName)
                worksheet.write(rowIdx, 2, s.invStd)
                worksheet.write(rowIdx, 3, s.purchase)
                worksheet.write(rowIdx, 4, s.selfMade)
                worksheet.write(rowIdx, 5, s.outsourcing)
                worksheet.write(rowIdx, 6, s.moq)
                worksheet.write(rowIdx, 7, s.leadtime)
                worksheet.write(rowIdx, 8, s.mcCode)
                break

        # 第二列：总可用库存
        for s in totalStocks:
            if s.invCode == inv:
                worksheet.write(rowIdx, 9, s.qty)
                break

        # 后面每一列，是库存缺口
        for c in range(dayCnt):
            for b in items[c]:
                if inv == b.invCode:
                    worksheet.write(rowIdx, c + offsetCol, "%.2f" % (b.qty))
                    break


class MatInfo:
    # 物料基本信息
    def __init__(self):
        self.invCode = ''  # 物料编码
        self.invName = ''  # 物料名称
        self.invStd = ''  # 规格型号
        self.purchase = 0  # 外购
        self.selfMade = 0  # 自制
        self.outsourcing = 0  # 委外
        self.moq = 0  # 最小起订量
        self.leadtime = 0  # 采购提前期
        self.mcCode = ''  # 物管员编码


def getInvInfo(cursor):
    # 获取物料基本信息
    sqlCmd = textwrap.dedent("""
        select i.cInvCode invCode, i.cInvName invName, i.cInvStd invStd,
               i.bPurchase purchase , i.bSelf selfMade, i.bProxyForeign outsourcing,
               i.fMinSupply moq, i.iInvAdvance leadtime, c.MC_CDE mcCode
          from inventory i
        left join  DJPlan..T_INV_CLASS c on c.INV_CLASS = i.cInvCCode
    """)

    results = []
    cursor.execute(sqlCmd)
    for i in cursor.fetchall():
        results.append(i)

    return results


#######################################
def foo():
    cursor = setupDB()

    inFile = "1.xlsx"
    inWorkbook = xlrd.open_workbook(inFile)

    whList = getWarehouses(inWorkbook)
    currStock = getCurrentStock(whList, cursor)
    openStock = getOpenStock(cursor)
    midStock = getMiddleStock(cursor)
    mergedStock = mergeStock(currStock, openStock, midStock)

    headers = getHeader(inWorkbook)
    planItems = calcAccReq(inWorkbook)
    print("finished: calcAccReq")

    boms = loadBOMData(cursor)
    print("finished: loadBOM")

    subs = expandOneLevel(planItems, boms)
    print("finished: expandOneLevel")

    mats = sumbyMat(subs)
    print("finished: sumbyMat")
    # print(f"mats: {len(mats)}")

    diffs = calcInvDiff(mats, mergedStock)
    print("finished: calcInvDiff")

    invInfos = getInvInfo(cursor)
    # print(f"diffs: {len(diffs)}")

    # 保存到文件
    outWorkbook = xlsxwriter.Workbook(f'{inFile}_out.xlsx')

    saveCurrentStock(outWorkbook, currStock)
    saveOpenStock(outWorkbook, openStock)
    saveMiddleStock(outWorkbook, midStock)
    saveMergedStock(outWorkbook, mergedStock)

    saveAccReq(outWorkbook, planItems)
    saveBOMData(outWorkbook, subs, invInfos)

    saveMatReq(outWorkbook, mats)
    saveInvDiff(outWorkbook, diffs, mergedStock, invInfos, headers)

    outWorkbook.close()

    print("done")


def test():
    # cursor = setupDB()
    # mats = getInvInfo(cursor)

    # for m in mats:
    #     print(f"{m.invCode} - {m.mcCode}")

    inFile = "1.xlsx"
    inWorkbook = xlrd.open_workbook(inFile)
    header = getHeader(inWorkbook)
    for h in header:
        for i in h:
            print(i)


###############################
foo()

# test()