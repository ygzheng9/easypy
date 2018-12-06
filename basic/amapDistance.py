
"""
根据 高德地图 获取 两地距离

1. 通过 api，根据 城市名称，获取 经纬度坐标；
2. 通过 api，根据 两个经纬度坐标，计算 两地距离；  ==> api 封装了所有的计算逻辑
"""


import requests
import json

# 参数：高德密钥
developer_key = 'dcfb4c89564fe0418e858d613ed5258a'


def get_coord(county):                                     # 设置函数，返回字典
    result = {}
    url = 'http://restapi.amap.com/v3/config/district'     # 高德API
    params = {'key': developer_key,                  # 参数：高德密钥
              'keywords': county,
              'subdistrict': 0}         # 0：不返回下级行政区
    try:
        res = requests.get(url, params)
        jd = json.loads(res.text)

        print(jd)

        result['county'] = county
        result['coord'] = jd['districts'][0]['center']
        return result
    except:
        result['county'] = county
        result['coord'] = '未获取经纬度'
        return result


def get_distance():
    url = 'http://restapi.amap.com/v3/distance'            # 一个新的API
    params = {'key': developer_key,
              'origins': '127.499023,50.249585',         # 黑河市坐标
              'destination': '98.497292,25.01757',       # 腾冲市坐标
              'type': 1}

    res = requests.get(url, params)
    jd = json.loads(res.text)

    print(jd)

    distance = jd['results'][0]['distance']
    return distance


distance = get_distance()
print(distance)
