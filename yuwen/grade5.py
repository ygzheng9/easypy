# coding=utf8

import pinyin

# 每行一个词，空行表示结束
inFile = r"/Users/ygzheng/Documents/playground/easypy/yuwen/grade5-26-40"

# 所有词的列表
words = []
with open(inFile, 'r', encoding="utf-8") as f:
    for line in f.readlines():
        # 空行表示结束
        if len(line) == 0:
            break

        # 把词转成拼音，并用空格分开，并且去掉换行符
        p = pinyin.get(line,  delimiter=" ").strip("\n")
        words.append(p)

# 一行是 4 个词，中间用两个 tab 区分
oneline = ""
i = 0
for w in words:
    if i == 0:
        oneline = w
    else:
        oneline = oneline + " \t\t" + w

    i = i + 1

    if i == 4:
        print(oneline)
        # 空三行
        for x in range(1, 4):
            print()
        # 重新计数
        i = 0
