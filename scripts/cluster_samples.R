# Cluster kmer counts matrix and plot dendrogram
# AUTHOR: Ben Bai (u5205339@anu.edu.au)
# DATE: Oct 2014

infile <- commandArgs(TRUE)[1]
outfile <- commandArgs(TRUE)[2]
x <- read.table(infile, sep=",", row.name=1)

hc <- hclust(dist(x))
hcd <- as.dendrogram(hc)

# Specific function to get colored labels for samples with "bd_1" or "bd_6" in name
# Used in the demo.
# TODO Make this generic.
# Modified from source: 
# http://rstudio-pubs-static.s3.amazonaws.com/1876_df0bf890dd54461f98719b461d987c3d.html
colLab <- function(n) {
    if (is.leaf(n)) {
        a <- attributes(n)
        if (any(grep("^bd_1", a$label))) {
            labCol <- "red"
        } else if (any(grep("^bd_6", a$label))) {
            labCol <- "blue"
        } else {
            labCol <- "black"
        }
        attr(n, "nodePar") <- c(a$nodePar, lab.col = labCol)
    }
    return(n)
}

hcd <- dendrapply(hcd, colLab)

png(outfile)
plot(hcd)
# dev.off()

