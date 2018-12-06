# 原始数据：user, item, favorate
# 形成 user 和 item 的 matrix
# 计算 user 的相似度；
# 输入：target user；k 最相近的 5 个user；最推荐的 p 个 items；
# 输出：对于 target_user 的相似度，从高到低排序，取前 k 个 user；
# 取出 target_user 的 items，记为 A；再取出这 k 个 user 的产品，记为 B；计算 C = B - A，表示 target 可能感兴趣的 item；
# 对于 C 中的每一个 item，如果 第i个 user 有记录，把 target 和 i 的相似度作为权重，乘以 i对C 的数量，最后再累加，得到 item 的总数值 m；
# C 按 m 降序，取前面 p 个，输出；


import numpy as np
import pandas as pd
from sklearn.metrics.pairwise import pairwise_distances


def loadData(filename="./ml-100k/u.data"):
    """
    filename: 文件名，格式为 userid,itemid,value
    return:
        data_matrix, 行是 userid，列是 itemid，值是 value
    """
    # 读入u.data数据文件
    header = ['user_id', 'item_id', 'rating', 'timestamp']
    df = pd.read_csv(filename, sep='\t', names=header)

    # 构建 matrix，原始数据中的每一行格式为：(userid, itemid, value)；
    # userid, itemid 是矩阵中的坐标，不是业务上的id；--> 对业务数据进行排序后的排序号
    # 查看用户和电影的数量
    n_users = df.user_id.unique().shape[0]
    n_items = df.item_id.unique().shape[0]
    print('Number of users = {} | Number of movies = {}'.format(n_users, n_items))

    # 生成矩阵，
    # 坐标值是文件的前两列，第三列是数值
    data_matrix = np.zeros((n_users, n_items))
    for line in df.itertuples():
        data_matrix[line[1]-1, line[2]-1] = line[3]

    return data_matrix


def calcDistance(dataMatrix):
    """
    根据数据矩阵，计算 row 的距离
    """

    # 计算距离
    # 返回的值是：1 - cosine，越小越相似
    minus = pairwise_distances(dataMatrix, metric="cosine")
    row_similarity = 1 - minus

    # col_similarity = pairwise_distances(data_matrix.T, metric="cosine")
    return row_similarity


# 相似user信息
class UserInfo(object):
    def __init__(self, userID, similarity):
        # 相似客户ID，相似度
        self.userID = userID
        self.similarity = similarity


def getNearestK(distMatrix, targetID, k):
    """
    取得和 targetID 最接近的 k 个值
    disMatrix: 距离矩阵；
    targetID: userID，下标，从 0 开始；
    k: 相似度最高的 k 个 user
    return: 最相近的 k 个 userID
    """
    # 取出 targetID 所有的相似值
    target = distMatrix[targetID, :]

    # 相似度去重，从大到小排序
    uniq = np.unique(target)
    uniq[::-1].sort()
    # uniq.sort()

    # 取相似度最大的 k 个
    # 相似度最大的是1，是自身，需要去掉
    topK = uniq[1:k+1]
    similarK = []
    for i in topK:
        # 根据相似度的值，在 距离矩阵 中，反找到对应的坐标
        where = np.where(target == i)

        # target 是 一维的，但是相似度一样的可能有多个
        for w in where[0]:
            info = UserInfo(userID=w, similarity=i)
            similarK.append(info)

    return similarK


def getItems(dataMatrix):
    def byID(userID):
        """
        根据 user 取出 items
        dataMatrix: (user, item) 矩阵，不是距离矩阵；
        userID: 是下标，从0开始；
        return: 数据矩阵中，不为零的，纵坐标
        """
        a = dataMatrix[userID, :]
        v = np.where(a > 0)
        return v[0]

    return byID


# 产品信息
class ItemInfo(object):
    def __init__(self, itemID, score, userList):
        # 产品ID，综合得分，购买该产品的客户(相似客户中)
        self.itemID = itemID
        self.score = score
        self.userList = userList


def getNewItems(dataMatrix, distMatrix, targetID, k, m):
    """
    dataMatrix: (user, item) 矩阵，非距离矩阵；
    distMatrix: 距离矩阵

    targetID： 目标客户ID；
    k: 最相近的 k 个客户；
    m: 返回前 m 个商品

    return: 相似客户买了，但是目标客户没有买的前 m 个商品
    """
    # 取得最相近的 k 个 user
    simList = getNearestK(distMatrix, targetID, k)
    similarIDs = [s.userID for s in simList]

    # 根据 客户ID，取得 items 的函数
    getByID = getItems(dataMatrix)

    # 目标客户的商品
    exists = getByID(targetID)

    # 相似客户的商品
    a = []
    for sID in similarIDs:
        b = getByID(sID)
        a.extend(b)

    # 相似客户买了的商品，但是目标客户没有买
    items = list(set(a) - set(exists))

    # 计算新商品的可能性：sum(客户相似度 * 客户购买量)

    pool = []
    # 每一个可能的产品
    for itmID in items:
        # 该 item 的总得分
        score = 0
        # 购买该 item 的客户(相似客户中)
        simList = []
        # 每一个相似的客户
        for sID in similarIDs:
            val = dataMatrix[sID][itmID]

            # 如果购买了
            if val > 0:
                simList.append(sID)

                # 取得相似度
                weight = distMatrix[targetID, sID]
                # 加权
                score = score + weight * val

        # 生成一个对象
        info = ItemInfo(itmID, score, simList)
        pool.append(info)

    # 按 score 从大到小排序
    pool.sort(key=lambda a: a.score, reverse=True)

    # 返回前 m 个对象
    return pool[:m]


if __name__ == "__main__":
    dataMatrix = loadData()
    rowDistance = calcDistance(dataMatrix)

    # 目标客户
    targetID = 237

    # 最相近的 5 个客户
    k = 5

    # 排名最靠前的 10 个商品
    m = 10

    simIDs = getNearestK(rowDistance, targetID, k)
    for s in simIDs:
        print(s.userID, s.similarity)

    # sids = [s.userID for s in simIDs]
    # print(sids)

    items = getNewItems(dataMatrix, rowDistance, targetID, k, m)
    for i in items:
        print(i.itemID, i.score, i.userList)
