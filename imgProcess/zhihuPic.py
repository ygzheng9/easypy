import re
from selenium import webdriver
import time
import urllib.request
from selenium.webdriver.chrome.options import Options
import os
"""
打开一个网页，把里面的图片存下来
"""

driverFile = "C:/Program Files (x86)/Google/Chrome/Application/chrome.exe"
os.environ["webdriver.chrome.driver"] = driverFile

chrome_options = Options()
# chrome_options.add_argument('--headless')
# chrome_options.add_argument('--disable-gpu')
chrome_options.binary_location = driverFile
chrome = webdriver.Chrome(chrome_options=chrome_options)

chrome.maximize_window()
chrome.get("https://www.zhihu.com/question/29134042")

i = 0
while i < 10:
    chrome.execute_script("window.scrollTo(0, document.body.scrollHeight)")
    time.sleep(2)
    try:
        chrome.find_element_by_css_selector(
            'button.QuestionMainAction').click()
        print("page" + str(i))
        time.sleep(1)
    except:
        break

result_raw = chrome.page_source
content_list = re.findall("img src=\"(.+?)\" ", str(result_raw))

n = 0
while n < len(content_list):
    i = time.time()
    local = f"pic/{i}.jpg"
    urllib.request.urlretrieve(content_list[n], local)
    print("编号： " + str(i))
    n = n + 1
