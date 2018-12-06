import os
from datetime import datetime as dt
"""
task.txt 第一行是 每天要做的事；之后7行分别是每天单独的事；
根据当前日期，生成今天要做的事：每天要做的 + 当前独特的；
"""

# 获取当前星期几
WeekDays = [
    'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday',
    'Saturday'
]
Year, WeekNumber, WeekDay = dt.now().isocalendar()
today = WeekDays[WeekDay]

# 读取任务文件
with open(r'tasks.txt', 'r', encoding="utf-8") as taskFile:
    lines = taskFile.readlines()
    Tasks = []
    for line in lines:
        Tasks.append(line.strip().split(', '))

    taskFile.close()

# 生成星期和任务对应的字典
# zip 按照顺序合并两个 list，
# dict 把 (a, b) 变成 {a: b}
taskDic = dict(zip(['Month'] + WeekDays, Tasks))

# 将todolist写入文件：每天的单独事项，每月的事（月中每一天都要做的）
ToDoList = taskDic['Month'] + taskDic[today]

# 每天的任务写入文件
with open(r'ToDoList.md', 'w', encoding="utf-8") as outfile:
    outfile.write(
        f"# 今日任务 \n #### Date: {dt.now().strftime('%Y-%m-%d')} {today} \n")

    for todo in ToDoList:
        outfile.write('-[ ] **' + todo + '**  \n')

    outfile.close()
