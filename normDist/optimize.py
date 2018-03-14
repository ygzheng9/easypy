from scipy.optimize import fmin
import numpy as np


def f(x):
    return x**2 - 4 * x + 8


print(fmin(f, 0))


def myfunc(p):
    x, y = p
    return x**2 + y**2 + 8


p = (1, 1)
print(fmin(myfunc, p))
