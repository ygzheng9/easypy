import os
"""
读取指定目录下，指定扩展名的文件；
把这些文件内容，合并到一个文件中；
"""

baseDir = "E:/99.localDev/qtProj/DJPlan5.6/"
# baseDir = "E:/99.localDev/stats/normDist/"

print(f"baseDir: {baseDir}")

# 获取目录下所有文件名
allFileNames = os.listdir(baseDir)
# print(allFileNames)

# 最终输出的文件
outputFile = open('allFile.bak', 'w', encoding="utf-8")

# 对每个文件名，先打印出来；
# 如果类型是 py / cpp，就逐行复制出来
for fileName in allFileNames:
    if fileName[-3:] == '.py' or fileName[-4:] == '.cpp':
        outputFile.write("\n\n\n=== " + fileName + " \n")

        # 打开文件，逐行复制出来
        oneFile = open(baseDir + fileName, 'r', encoding="utf-8")
        try:
            for line in oneFile:
                outputFile.write(line)

            print(f"ok: {fileName}")

        except:
            print(f"failed: {fileName}")

    else:
        print(f"skipped: {fileName}")

# 保存最后输入的文件
outputFile.close()

print("completed.")