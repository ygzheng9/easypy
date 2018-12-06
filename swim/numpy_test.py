import numpy as np

a = np.array([1, 2, 3, 4, 5, 6, 7, 8, 9])

d = a.reshape(3, -1, order="F")

d
