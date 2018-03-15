import pyodbc
import textwrap
import copy
import xlsxwriter


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
