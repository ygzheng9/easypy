#function:给pdf添加水印
import os
from PyPDF2 import PdfFileWriter, PdfFileReader
from reportlab.pdfgen import canvas


#所有路径为绝对路径
def add_watermark(pdf_file_in, pdf_file_mark, pdf_file_out):
    input_stream = open(pdf_file_in, 'rb')
    pdf_input = PdfFileReader(input_stream)

    # PDF文件被加密了
    if pdf_input.getIsEncrypted():
        print('该PDF文件被加密了.')
        # 尝试用空密码解密
        try:
            pdf_input.decrypt('')
        except Exception:
            print('尝试用空密码解密失败.')
            return False
        else:
            print('用空密码解密成功.')

    # 获取PDF文件的页数
    pageNum = pdf_input.getNumPages()
    #读入水印pdf文件
    pdf_watermark = PdfFileReader(open(pdf_file_mark, 'rb'))

    # 给每一页打水印
    pdf_output = PdfFileWriter()
    for i in range(pageNum):
        page = pdf_input.getPage(i)
        page.mergePage(pdf_watermark.getPage(0))
        page.compressContentStreams()  #压缩内容
        pdf_output.addPage(page)

    # 保存到文件
    destFile = open(pdf_file_out, "wb")
    pdf_output.write(destFile)


filePath = "E:/99.localDev/stats/watermark/"

add_watermark(f"{filePath}orig.pdf", f"{filePath}mark.pdf",
              f"{filePath}dest.pdf")
