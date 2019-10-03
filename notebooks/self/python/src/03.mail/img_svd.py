from PIL import Image
import numpy as np
import matplotlib.pyplot as plt


def rebuild_img(u, sigma, v, p):
    """
    u：矩阵U
    sigma：矩阵sigma
    v：矩阵V
    p：奇异值的百分比
    """
    # a是sigma矩阵的空壳，
    # a 的行和列满足和 u v 的乘法；使用少量数据的含义是，a 中对角线数据只有少量的非零
    a = np.zeros((len(u), len(v)))

    # sigma 中的数值是从大到小排列的，这是 svd 返回值的特性；
    # 按照个数取前 i 个
    k = len(sigma) * p
    i = 0
    while i <= k:
        a[i, i] = sigma[i]
        i += 1

    print('{}: {} / {}'.format(p, i, len(sigma)))

    # 矩阵计算
    b = np.dot(np.dot(u, a), v)
    b = np.clip(b, 0, 255)
    return np.rint(b).astype("uint8")


def rebuild_img2(u, sigma, v, p):
    # sigma 中的数值是从大到小排列的，这是 svd 返回值的特性；
    # 按照个数取前 k 个
    k = round(len(sigma) * p + 1)
    print('rebuild_img2: {} -> ({} / {})'.format(p, k, len(sigma)))

    # 矩阵计算, 只取前 k 个特征值
    s = np.diag(sigma[:k])
    a = np.dot(np.dot(u[:, :k], s), v[:k, :])
    a = np.clip(a, 0, 255)
    return np.rint(a).astype("uint8")


def svd_use_cnt(p):
    b = np.array(Image.open('./fire.jpeg', 'r'))

    # img_fn = rebuild_img
    img_fn = rebuild_img2

    # RGB 对应的三元色
    u, sigma, v = np.linalg.svd(b[:, :, 0])
    R = img_fn(u, sigma, v, p)
    u, sigma, v = np.linalg.svd(b[:, :, 1])
    G = img_fn(u, sigma, v, p)
    u, sigma, v = np.linalg.svd(b[:, :, 2])
    B = img_fn(u, sigma, v, p)

    img = np.stack((R, G, B), 2)
    plt.figure("beauty")
    plt.imshow(img)
    plt.axis('off')
    plt.show()  # 绘图输出


def svd_demo():
    # 1%，明显轮廓
    svd_use_cnt(0.01)

    # 5%，清晰
    svd_use_cnt(0.05)

    # 10%，非常清晰
    svd_use_cnt(0.1)

    # 20% 肉眼没有差别
    svd_use_cnt(0.2)
    svd_use_cnt(0.3)


if __name__ == "__main__":
    svd_demo()

    print(round(3.1 + 1))

    print('done.')
