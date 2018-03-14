import sqlUtils


def genIns(columns):
    if (len(columns) != 7):
        print(len(columns), columns)

    sqlCmd = f"insert T_PROJ (PROJ_GRP, PROJ_CDE, RMK, VTYPE, PROJ_TYPE, APPLY_DTE,CLS_IND) \
                    values ('{columns[0]}', '{columns[1]}', '{columns[2]}', '{columns[3]}', '{columns[4]}', '{columns[5]}', '{columns[6]}'); \n "

    return sqlCmd


sqlUtils.genSQL("proj.txt", genIns)