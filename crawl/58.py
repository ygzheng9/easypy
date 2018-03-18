import time
import sys
from multiprocessing import Pool

import requests
from lxml import etree
# import pymongo

start_url = 'http://cs.58.com/sale.shtml'
url_host = 'http://cs.58.com'


def get_channel_urls(url):
    '''
    获取大类别的链接
    '''
    html = requests.get(url)
    selector = etree.HTML(html.text)
    infos = selector.xpath('//div[@class="lbsear"]/div/ul/li')

    for info in infos:
        class_urls = info.xpath('ul/li/b/a/@href')
        for class_url in class_urls:
            print(url_host + class_url)


# get_channel_urls(start_url)

headers = {
    'User-Agent':
    'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.87 Safari/537.36',
    'Connection':
    'keep-alive'
}


def get_links_from(channel, pages):
    # 拼接链接，第几页
    list_view = '{}pn{}/'.format(channel, str(pages))
    try:
        html = requests.get(list_view, headers=headers)
        time.sleep(2)
        selector = etree.HTML(html.text)
        if selector.xpath('//tr'):
            infos = selector.xpath('//tr')
            for info in infos:
                if info.xpath('td[2]/a/@href'):
                    url = info.xpath('td[2]/a/@href')[0]
                    get_info(url)
                else:
                    pass
        else:
            pass
    except requests.exceptions.ConnectionError:
        pass


def get_info(url):
    html = requests.get(url, headers=headers)
    selector = etree.HTML(html.text)
    try:
        title = selector.xpath('//h1/text()')[0]
        if selector.xpath('//span[@class="price_now"]/i/text()'):
            price = selector.xpath('//span[@class="price_now"]/i/text()')[0]
        else:
            price = "无"
        if selector.xpath('//div[@class="palce_li"]/span/i/text()'):
            area = selector.xpath('//div[@class="palce_li"]/span/i/text()')[0]
        else:
            area = "无"
        view = selector.xpath('//p/span[1]/text()')[0]
        if selector.xpath('//p/span[2]/text()'):
            want = selector.xpath('//p/span[2]/text()')[0]
        else:
            want = "无"
        info = {
            'tittle': title,
            'price': price,
            'area': area,
            'view': view,
            'want': want,
            'url': url
        }
        # tongcheng.insert_one(info)
        print(info)
    except IndexError:
        pass


def get_all_links_from(channel):
    # 为了演示，只取前3页
    for num in range(1, 3):
        get_links_from(channel, num)


# channel_list = get_channel_urls(start_url)
channel_list = ['http://cs.58.com/shouji/', 'http://cs.58.com/diannao/']

sys.path.append("..")
if __name__ == '__main__':
    pool = Pool()
    pool.map(get_all_links_from, channel_list)