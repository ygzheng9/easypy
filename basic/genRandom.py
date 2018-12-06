import random
"""
生成随机数
"""

temp = [i + 1 for i in range(35)]

random.shuffle(temp)

i = 0
list = []

while i < 7:
    list.append(temp[i])
    i = i + 1

list.sort()
print(list)
