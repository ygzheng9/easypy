#!/usr/local/bin/python3

# -*- coding: utf-8 -*-

# 显示群里朋友的地区信息

"""
0. 使用 wxpy；
1. 扫码登录微信；
2. 根据 名称 查找 群；
3. 获取 群 里所有 朋友；
4. 读取 朋友 的 地区信息（province, city）
5. 按照 province+city 汇总人数
"""

# 导入模块
from wxpy import *

# 初始化机器人，扫码登陆
bot = Bot()


def get_members(group_name):
    print(group_name)
    print(bot.groups().search(group_name)[0])
    group = bot.groups().search(group_name)[0]
    # 使用此方法用来更新群聊成员的详细信息 (地区、性别、签名等)
    group.update_group(True)
    # 获取该群聊组的全部成员对象
    members = group.members
    return members


def clean_members(members):
    # 用来存放群聊里出现的全部的省份跟城市的信息
    member_clean = []
    for member in members:
        # .province跟.city分别获取群成员对象的省份跟城市
        member_info = member.province + member.city
        # 可能有的成员没有设置自己的地区跟城市，获取到的member_info可能为空
        member_info_clean = member_info.replace(' ', '')

        if not member_info_clean == '':
            member_clean.append(member_info_clean)

    return member_clean


def result(member_clean):
    member_dict = {}
    for m in member_clean:
        # 统计某个省份跟地区在member_clean列表里面的人数
        if member_clean.count(m):
            member_dict[m] = member_clean.count(m)
            # 把member_clean列表里，向member_dict字典里添加过的省份地区删除掉
            member_clean = [value for value in member_clean if value != m]

    return member_dict


# 改成想要统计的群聊名字，很久没有聊天记录的群最好先发条消息
group_n = '以废旧GBSer的名义相聚'
members = get_members(group_n)
member_clean = clean_members(members)
member_dict = result(member_clean)
print(member_dict)
