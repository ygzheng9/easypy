# -*- coding: utf-8 -*-

"""
从 当当网 把 top 500 的书籍抓取下来

1. 根据 特定url 获取 html 信息；
2. 通过 re 模块，解析 html 信息，获取里面的 书籍名称，作者，ISBN 等信息；
3. 把获取到的信息，保存到本地文件中；
4. 改变 url 的参数，获取下一页信息，直到 top 500 全部；
"""

import requests
from requests import exceptions

import re
import json


def get_one_page(url):
    try:
        response = requests.get(url)
        if response.status_code == 200:
            return response.text
        return None
    except exceptions.RequestException:
        return None


def parse_one_page(html):
    pattern = re.compile(
        '<li>.*?list_num.*?>(.*?)</div>.*?pic.*?src="(.*?)".*?/></a>.*?name"><a.*?title="(.*?)">.*?tuijian">(.*?)</span>.*?publisher_info.*?title="(.*?)".*?biaosheng.*?<span>(.*?)</span>.*?</li>', re.S)
    items = re.findall(pattern, html)
    for item in items:
        yield {
            'index': item[0],
            'image': item[1],
            'title': item[2],
            'tuijian': item[3],
            'author': item[4],
            'times': item[5],
        }


def write_content_to_file(content):
    with open('book.txt', 'a', encoding='UTF-8') as f:
        f.write(json.dumps(content, ensure_ascii=False) + '\n')
        f.close()


def main(page):
    url = "http://bang.dangdang.com/books/fivestars/01.00.00.00.00.00-recent30-0-0-1-" + \
        str(page)
    html = get_one_page(url)

    for item in parse_one_page(html):
        print(item)
        write_content_to_file(item)


if __name__ == "__main__":
    for i in range(1, 5):
        main(i)
