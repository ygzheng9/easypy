from PIL import Image
import numpy as np


def reverse():
    """
    反色效果
    """
    a = np.array(Image.open('1.jpg'))
    b = [255, 255, 255] - a
    im = Image.fromarray(b.astype('uint8'))
    im.save('2.jpg')


def draw():
    """
    手绘效果
    """
    a = np.asarray(Image.open('3.jpg').convert('L')).astype('float')

    depth = 10.  # (0-100)
    grad = np.gradient(a)  # 取图像灰度的梯度值
    grad_x, grad_y = grad  # 分别取横纵图像梯度值
    grad_x = grad_x * depth / 100.
    grad_y = grad_y * depth / 100.
    A = np.sqrt(grad_x**2 + grad_y**2 + 1.)
    uni_x = grad_x / A
    uni_y = grad_y / A
    uni_z = 1. / A

    vec_el = np.pi / 2.2  # 光源的俯视角度，弧度值
    vec_az = np.pi / 4.  # 光源的方位角度，弧度值
    dx = np.cos(vec_el) * np.cos(vec_az)  # 光源对x 轴的影响
    dy = np.cos(vec_el) * np.sin(vec_az)  # 光源对y 轴的影响
    dz = np.sin(vec_el)  # 光源对z 轴的影响

    b = 255 * (dx * uni_x + dy * uni_y + dz * uni_z)  # 光源归一化
    b = b.clip(0, 255)

    im = Image.fromarray(b.astype('uint8'))  # 重构图像
    im.save('4.jpg')


def transPNG(srcImageName, dstImageName):
    """
    通过改变 alpha 使图片透明
    """
    img = Image.open(srcImageName)
    img = img.convert("RGBA")
    datas = img.getdata()
    newData = list()
    for item in datas:
        if item[0] > 220 and item[1] > 220 and item[2] > 220:
            newData.append((255, 255, 255, 0))
        else:
            newData.append(item)

    img.putdata(newData)
    img.save(dstImageName, "PNG")


draw()