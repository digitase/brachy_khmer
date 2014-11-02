# Plot .hist outputs from khmer
# AUTHOR: Ben Bai (u5205339@anu.edu.au)
# DATE: Oct 2014
import os
import sys
import numpy as np
import matplotlib
import matplotlib.pyplot as plt

xlim_max = int(sys.argv[1])
ylim_max = int(sys.argv[2])
filenames = sys.argv[3:]

sample_names = [os.path.splitext(os.path.basename(filename))[0] for filename in filenames]

for filename, sample_name in zip(filenames, sample_names):
    hist = np.loadtxt(filename, dtype=float, delimiter=" ")
    plt.plot(hist[:, 0], np.log10(hist[:, 1]), label=sample_name)

plt.legend(loc='best')
# plt.suptitle("\n".join(sample_names))
plt.xlabel("Kmer abundance")
plt.ylabel("log10(Frequency)")

# If we are looking at the graph interactively, we won't have axis limits
save_fig = True

try:
    plt.xlim(0, xlim_max)
    plt.ylim(0, ylim_max)
except IndexError:
    save_fig = False

if save_fig:
    plt.savefig(".".join(sample_names) + ".png", bbox_inches='tight')

plt.draw()
plt.show()

