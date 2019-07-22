import numpy as np
import cv2 as cv
from sympy import solve,Symbol # 导入合适的就够了
import os

def lsb2zero(image):  # 位平面置0
    w, h = image.shape
    myzeros = np.zeros((h, w), dtype=int)
    for i in range(w):
        for j in range(h):
            myzeros[i][j] = image[i][j] - np.mod(image[i][j], 2)  # 置零
    return myzeros

def cal(img):
    img = np.array(img, dtype=int)  # 数据转换
    # print(img.shape)
    myzeros = lsb2zero(img)  # 位平面置0
    H = np.zeros(256, dtype=int)
    H2 = np.zeros(256, dtype=int)
    G = np.zeros(256, dtype=int)
    G2 = np.zeros(256, dtype=int)
    d = 0
    d2 = 0
    w, h = img.shape
    img = img.flatten()  # 将矩阵变成一维数组
    myzeros = myzeros.flatten()  # 将矩阵变成一维数组
    for i in range(0, w*h - 1):
        d = img[i] - img[i+1]
        if d >= 0:
            H[d] = H[d] + 1
        else:
            H2[np.abs(d)] = H2[np.abs(d)] + 1

    for i in range(0, w*h - 1):
        d = myzeros[i] - myzeros[i+1]
        # print(d,type(d))
        if d >= 0:
            G[d] = G[d] + 1
        else:
            G2[np.abs(d)] = G2[np.abs(d)] + 1

    return list(H), list(H2), list(G), list(G2)

def Process(H,H2,G,G2):
    length = len(H)
    for i in range(length):
        H[i] = (H[i]+H2[i])//2
        G[i] = (G[i]+G2[i])//2
    return H, G

def mysolve(img):     # 求解方案1
    h, H2, g, G2 = cal(img)
    N = 256
    # N = img.shape[0]
    a = np.zeros((N, N), dtype=float)
    # h,g = Process(h,H2,g,G2)
    # h = np.array(h) + np.array(H2)
    # g = np.array(g) + np.array(G2)
    a[0][0] = h[0] / g[0]
    a[0][1] = (g[0] - h[0]) / (2 * g[0])
    # 递推公式
    for i in range(1, 127):
        if g[2 * i] != 0:
            a[2 * i][2 * i] = h[2 * i] / g[2 * i]
        if g[2 * i] != 0:
            a[2 * i][2 * i - 1] = (h[2 * i - 1] - a[2 * i - 2][2 * i - 1] * g[2 * i - 2]) / g[2 * i]
        a[2 * i][2 * i + 1] = 1 - a[2 * i][2 * i - 1] - a[2 * i][2 * i]

    alpha = np.zeros(256, dtype=float)
    beta = np.zeros(256, dtype=float)
    gamma = np.zeros(256, dtype=float)

    for i in range(0, 5):
        if a[2 * i][2 * i + 1] != 0:
            alpha[i] = a[2 * i + 2][2 * i + 1] / a[2 * i][2 * i + 1]
        if a[2 * i][2 * i - 1] != 0:
            beta[i] = a[2 * i + 2][2 * i + 3] / a[2 * i][2 * i - 1]
        if g[2 * i + 2] != 0:
            gamma[i] = g[2 * i] / g[2 * i + 2]
    # 求解方程组
    i = 1
    p = Symbol('p')
    d1 = 1 - gamma[i]
    # print(d1)
    d2 = alpha[i] - gamma[i]
    d3 = beta[i] - gamma[i]
    delta = (d3 - 4 * d1 - d2) ** 2 - 4 * 2.0 * d1 * 2.0 * d2
    res = solve(2 * d1 * p ** 2 + (d3 - 4 * d1 - d2) * p + 2.0 * d2, p)
    # print(res)
    # print("a:" + str(2.0 * d1))
    # print("b:" + str(d3 - 4 * d1 - d2))
    # print("c:" + str(2.0 * d2))
    # print("delta:" + str(delta))
    result = min(np.abs(res))
    # print(result)
    return result

# 开始计算
# name = 'lsb.bmp'
# img = cv.imread(name, 0)
# print(name)
path = '/root/myscript/matlab/work/crack/hide/0/'
extent = '.bmp'
file_names = [path + str(i) + extent for i in range(1,201)]
i = 0
res = []
fid = open('result.txt','w')
for name in file_names:
    img = cv.imread(name,0)
    result = mysolve(img)
    res.append(result)
    fid.write(name + ' ' + str(result) + '\n')
    print(name)

# print(res)
fid.close()
