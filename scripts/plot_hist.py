
import sys
import numpy as np
import matplotlib
import matplotlib.pyplot as plt

filename = sys.argv[1]

hist = np.loadtxt(filename, dtype=float, delimiter=" ")

plt.plot(hist[:, 0], hist[:, 1])
plt.draw()
plt.show()




