import pyodbc
import textwrap
import copy

# # 创建数据库连接
# server = 'serveru8'
# database = 'UFDATA_128_2012'
# username = 'sa'
# password = 'P@ss12345'
# cnxn = pyodbc.connect('DRIVER={SQL Server};SERVER=' + server + ';DATABASE=' +
#                       database + ';UID=' + username + ';PWD=' + password)
# cursor = cnxn.cursor()


# 读取单层 BOM 数据
def loadBOM(cursor):
    # 委外，采购，领用（自制）
    sqlCmd = textwrap.dedent("""
        select m1.cInvCode childInv, m1.cInvName childName,
            case when ((m1.bProxyForeign = 1) or (m1.bPurchase = 1) or (o.WIPType = 3 )) then 1 else 0 end 'matType',
            -- m1.bProxyForeign, m1.bPurchase,
            m2.cInvCode parentInv, m2.cInvName parentName, a.BaseQtyN baseQty, a.BaseQtyD
        from bom_opcomponent a
        inner join bom_opcomponentopt o on o.OptionsId = a.OpComponentId
        inner join bom_parent p on p.BomId = a.BomId
        inner join  bom_bom c on c.BomId = a.BomId and c.Status = 3
        inner join bas_part a1 on a1.PartId = a.ComponentId
        inner join Inventory m1 on m1.cInvCode = a1.InvCode
        inner join bas_part p1 on p1.PartId = p.ParentId
        inner join Inventory m2 on m2.cInvCode = p1.InvCode;
    """)
    cursor.execute(sqlCmd)
    boms = cursor.fetchall()

    return boms


# 根据母件号，取得一层子件
def getNextLevel(invCode, boms):
    subs = list(filter(lambda b: b.parentInv == invCode, boms))
    return subs


# 单层 BOM 的下一层
class oneLevel:
    def __init__(self):
        self.invCode = ''  # 料号
        self.baseQty = 0  # 相对于根母件的耗量


# 展开母件，到 采购、委外、自制领用 停止
def findAllSubs(invCode, boms):
    # 下级子件，
    results = []

    # 使用的 stack
    # 当前料号，bom耗量
    stack = []
    a = oneLevel()
    a.invCode = invCode
    a.baseQty = 1

    stack.append(a)

    # 设置最大单层子件数
    maxCount = 1000
    idx = 0

    while True:
        idx = idx + 1

        # stack 为空，表示已经处理完毕
        if ((idx >= maxCount) or len(stack)) == 0:
            break

        # 取出第一个
        current = stack.pop()
        nextLevels = getNextLevel(current.invCode, boms)
        # print(f"{current.invCode} -- {len(nextLevels)}")
        # for s in nextLevels:
        #     print(f"{s.matType} - {s.childInv}")

        for s in nextLevels:
            t = oneLevel()
            t.invCode = s.childInv
            t.baseQty = current.baseQty * float(s.baseQty)

            # 1 代表：采购或委外，自制领用，不需要再展开
            # 其余：还需要展开下一级
            if s.matType == 1:
                results.append(t)
            else:
                stack.append(t)

    if len(results) == 0:
        # 如果没有下级，那么把自身加入到结果中
        a = oneLevel()
        a.invCode = invCode
        a.baseQty = 1
        results.append(a)

    return results


# # 加载 BOM 基础数据
# boms = loadBOM(cursor)

# # 展开母件的子件
# subs = findAllSubs('D13-C12040000-000', boms)

# print(f"results: {len(subs)}")

# for s in subs:
#     print(f"{s.invCode, s.baseQty}")
