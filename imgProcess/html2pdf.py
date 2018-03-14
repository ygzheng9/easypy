import requests
from bs4 import BeautifulSoup

# import pdfkit

# def parse_url_to_html(url):
#     resp = requests.get(url)
#     soup = BeautifulSoup(resp.content, "html.parser")
#     body = soup.find_all(class_="x-wiki-content")[0]
#     html = str(body)
#     with open("a.html", 'wb') as f:
#         f.write(html)


def get_url_list():
    """
    获取所有 url 目录列表
    """
    resp = requests.get(
        "https://www.liaoxuefeng.com/wiki/0014316089557264a6b348958f449949df42a6d3a2e542c000"
    )
    soup = BeautifulSoup(resp.content, "html.parser")

    menu_tag = soup.find_all(class_="uk-nav uk-nav-side")[1]
    urls = []
    for li in menu_tag.find_all("li"):
        url = "http://www.liaoxuefeng.com" + li.a.get("href")
        urls.append(url)
    return urls


# def save_pdf(htmls):
#     """
# 	把所有 html 转成 pdf
# 	"""

#     options = {
#         'page-size': 'Letter',
#         'encoding': 'UTF-8',
#         'custom-header': [('Accept-Encoding', 'gzip')]
#     }

#     pdfkit.save_pdf(htmls, file_name, options=options)

print(get_url_list())