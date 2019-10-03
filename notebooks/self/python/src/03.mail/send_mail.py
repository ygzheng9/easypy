from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from email.mime.image import MIMEImage
from email.mime.application import MIMEApplication
# from email.mime.base import MIMEBase
from email.header import Header
# from email import encoders
import smtplib
# import time
# import datetime


def sent_mail():
    smtpserver = 'smtp.qq.com'
    user = 'yonggang.zheng@qq.com'
    pwd = 'bababa'
    receivers = ['ygzheng9@gmail.com', 'yonggang.zheng@qq.com']  # 收件人
    date = '2019-10-02'

    # 邮件正文中的图片
    msg = MIMEMultipart()
    msg.attach(MIMEText('<p><img src="cid:1"></p>', 'html', 'utf-8'))
    fp1 = open('./ABCD.png', 'rb')
    msgImage1 = MIMEImage(fp1.read())
    fp1.close()
    msgImage1.add_header('Content-ID', '<1>')
    msg.attach(msgImage1)

    # 添加附件
    att = MIMEApplication(open('./att.xlsx', 'rb').read())
    att.add_header('Content-Disposition', 'attachment',
                   filename=Header('日报'+date+'.xlsx', 'utf-8').encode())
    msg.attach(att)

    # 添加收件发件人信息
    title = '日报_'+date
    msg['From'] = "{}".format(user)
    msg['To'] = ",".join(receivers)
    msg['Subject'] = title

    # 发送邮件
    smtp = smtplib.SMTP()
    smtp.connect(smtpserver)
    # smtp.starttls()
    smtp.login(user, pwd)
    smtp.sendmail(user, receivers, msg.as_string())
    print('发送成功')
    smtp.close()
    # time.sleep(10)


if __name__ == "__main__":
    sent_mail()

    print('done.')
