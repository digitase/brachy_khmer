infile <- commandArgs(TRUE)[1]
x <- read.table(infile, sep=",", row.name=1)
plot(hclust(dist(x)))

