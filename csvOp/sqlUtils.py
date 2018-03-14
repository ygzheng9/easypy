# 根据数据文件，生成 sql 脚本


def genSQL(inFile, insFn):
    """
    inFile: 输入的数据文件；
    insFn：一个 function，参数是 columns，返回值是 sql 语句
    """

    # 结果列表
    cmdList = []
    # 当前行是否为第一行
    isFirstLine = True
    # 读取数据文件
    with open(inFile, 'r', encoding="utf-8") as f:
        for line in f.readlines():
            # 第一行为表头，跳过
            if isFirstLine:
                isFirstLine = False
                continue

            # 只能按照 tab 分割，因为单元格内有  空格
            raws = line.split("\t")

            # 去处每一个的空格
            # columns = list(map(lambda s: s.strip(), raws))
            columns = [s.strip() for s in raws]

            # 如果是空行
            if (len(columns) == 0):
                continue

            sqlCmd = insFn(columns)

            # 拼接 sql,注意是否需要引号，最后的换行符
            # sqlCmd = f"insert CusDeliverAdd (cCusCode, cAddCode, cDeliverAdd, cDeliverUnit, bDefault, cLinkPerson) \
            #         values ('{columns[0]}', '{columns[1]}', '{columns[2]}', '{columns[3]}', {columns[4]}, '{columns[5]}'); \n "

            cmdList.append(sqlCmd)

    # 结果写入文件
    outFile = "outfile.txt"
    with open(outFile, "w", encoding="utf-8") as f:
        f.writelines(cmdList)

    print(f'total process: {len(cmdList)}, please check {outFile} ')
