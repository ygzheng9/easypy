import pyodbc
import textwrap

# 创建数据库连接
server = 'serveru8'
database = 'UFDATA_128_2012'
username = 'sa'
password = 'P@ss12345'
cnxn = pyodbc.connect('DRIVER={SQL Server};SERVER=' + server + ';DATABASE=' +
                      database + ';UID=' + username + ';PWD=' + password)
cursor = cnxn.cursor()

# # 直接查询，可以设置参数
# sqlCmd = textwrap.dedent("""
# select c.cInvCode, SUM(iQuantity) qty
#   from CurrentStock c
#  where 1 = 1
#    and c.cWhCode in ('01', '02')
#    and c.cInvCode = ?
#   group by  c.cInvCode;
# """)

# cursor.execute(sqlCmd, 'D18-C15430058-000')

# # 根据列名，取出结果
# print("resultls: ", cursor.rowcount)
# for row in cursor:
#     print(row.cInvCode, row.qty)


# 读取单层 BOM 数据
def loadBOM(cursor):
    # 创建数据库连接
    # server = 'serveru8'
    # database = 'UFDATA_128_2012'
    # username = 'sa'
    # password = 'P@ss12345'
    # cnxn = pyodbc.connect('DRIVER={SQL Server};SERVER=' + server + ';DATABASE='
    #                       + database + ';UID=' + username + ';PWD=' + password)
    # cursor = cnxn.cursor()

    sqlCmd = textwrap.dedent("""
        select m1.cInvCode childInv, m1.cInvName childName,
            case when ((m1.bProxyForeign = 1) or (m1.bPurchase = 1)) then 1 else 0 end 'matType',
            -- m1.bProxyForeign, m1.bPurchase,
            m2.cInvCode parentInv, m2.cInvName parentName
        from bom_opcomponent a
        inner join bom_parent p on p.BomId = a.BomId
        inner join  bom_bom c on c.BomId = a.BomId and c.Status = 3
        inner join bas_part a1 on a1.PartId = a.ComponentId
        inner join Inventory m1 on m1.cInvCode = a1.InvCode
        inner join bas_part p1 on p1.PartId = p.ParentId
        inner join Inventory m2 on m2.cInvCode = p1.InvCode;
    """)
    cursor.execute(sqlCmd)
    boms = cursor.fetchall()

    for bom in boms:
        print(f"{bom.childInv, bom.parentInv}")


loadBOM(cursor)
