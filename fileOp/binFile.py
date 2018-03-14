import binascii
import struct

# 这是 二进制 的 ascii 表示
origInput = "5B7F888489FEDA"
binInput = binascii.a2b_hex(origInput)

# with open("test.bin", "wb") as outFile:
#     outFile.write(binInput)
#     outFile.close()

fmt = "idh"
#计算格式占内存大小
print(f"{fmt} size: {struct.calcsize(fmt)}")

# 按照 fmt，把 文本 按照 二进制形式，写入文件
with open("debug.bin", "wb") as f1:
    f1.write(struct.pack("idh", 12345, 67.89, 15))
    print("writ complete. ")

# 从二进制文件读取信息
with open("debug.bin", "rb") as f2:
    (a, b, c) = struct.unpack("idh", f2.read(8 + 8 + 2))
    print(a, b, c)
