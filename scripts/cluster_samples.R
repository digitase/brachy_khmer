
infile <- commandArgs(TRUE)[1]
outfile <- commandArgs(TRUE)[2]
x <- read.table(infile, sep=",", row.name=1)
png(outfile)
plot(hclust(dist(x)))

