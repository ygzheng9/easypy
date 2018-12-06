from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.wait import WebDriverWait
from selenium.webdriver.chrome.options import Options
import os

# driverFile = "C:/Program Files (x86)/Google/Chrome/Application/chromedriver.exe"
# browser = webdriver.Chrome(driverFile)

driverFile = "C:/Program Files (x86)/Google/Chrome/Application/chrome.exe"
os.environ["webdriver.chrome.driver"] = driverFile

chrome_options = Options()
chrome_options.add_argument('--headless')
chrome_options.add_argument('--disable-gpu')
chrome_options.binary_location = driverFile
browser = webdriver.Chrome(chrome_options=chrome_options)

try:
    browser.get('https://www.baidu.com')
    input = browser.find_element_by_id('kw')
    input.send_keys('Python')
    input.send_keys(Keys.ENTER)
    wait = WebDriverWait(browser, 10)
    wait.until(EC.presence_of_element_located((By.ID, 'content_left')))
    print(browser.current_url)
    print(browser.get_cookies())
    print(browser.page_source)
finally:
    browser.close()
    print("finished. ")