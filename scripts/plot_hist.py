
import os
import sys
import numpy as np
import matplotlib
import matplotlib.pyplot as plt

filename = sys.argv[1]
sample_name = os.path.splitext(os.path.basename(filename))[0]
hist = np.loadtxt(filename, dtype=float, delimiter=" ")

plt.plot(hist[:, 0], np.log10(hist[:, 1]))
plt.suptitle(sample_name)
plt.xlabel("Kmer abundance")
plt.ylabel("log10(Frequency)")

# If we are looking at the graph interactively, we won't have axis limits
save_fig = True

try:
    plt.xlim(0, int(sys.argv[2]))
    plt.ylim(0, int(sys.argv[3]))
except IndexError:
    save_fig = False

if save_fig:
    plt.savefig(sample_name + ".png", bbox_inches='tight')

plt.draw()
plt.show()






