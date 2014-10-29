
import khmer
import itertools as it
import heapq
import os
import sys

table_files_list = sys.argv[1]
k = int(sys.argv[2])
skip = int(sys.argv[3])
num_repeats = int(sys.argv[4])

table_files = [line.strip() for line in open(table_files_list, "r")]

out_file_basename = os.path.splitext(os.path.basename(table_files_list))[0]
out_filename = "{0}.skip{1}.N{2}.pres_abs.csv".format(out_file_basename, skip, num_repeats)

outfile = open(out_filename, "w")

# Monitor progress
j = 0
num_kmers = 4**k

# Yield the counts of each possible kmer in the hash table.
def generate_kmer_counts(k, ht, alpha="ACTG"):
    global j
    global num_kmers
    for kmer in it.product(alpha, repeat=k):
        kmer_str = "".join(kmer)
        j += 1
        if not j % 1000000:
            print "{0:.2f}% complete.".format(float(j)/num_kmers * 100)
        yield (ht.get(kmer_str), kmer_str)

# Get most abundant kmers in first sample
# Construct presence-absence matrix for those kmers over all samples
pc_pres = []
for i, line in enumerate(table_files):
    filename, num_read_pairs = line.strip().split()
    num_read_pairs = int(num_read_pairs)
    sample_name = os.path.splitext(os.path.basename(filename))[0]
    
    print "Loading sample {0} of {1} ({2} read pairs): {3}".format(i+1, len(table_files), num_read_pairs, sample_name)
    ht = khmer.load_counting_hash(filename)

    if i == 0:
        print "Counting first sample: {0}".format(sample_name)
        kmer_counts = list(generate_kmer_counts(k, ht))

        print "Heapifying..."
        heapq.heapify(kmer_counts)        
        # Discard most abundant kmers
        
        print "Discarding top {0} most abundant kmers.".format(skip)
        for s in range(skip):
            heapq.heappop(kmer_counts)
            
        print "Analysing next {0} most abundant kmers.".format(num_repeats)            
        repeat_list = heapq.nlargest(skip+num_repeats, kmer_counts)
        # print "These are (count, kmer):", repeat_list
        pres_abs = [str(count/float(num_read_pairs)) for (count, _) in repeat_list]
    else:
        pres_abs = [str(ht.get(kmer_str)/float(num_read_pairs)) for (_, kmer_str) in repeat_list]

    del ht
    print "\tSample has {0:.2f} total normalised counts.".format(sum(map(float, pres_abs)))
    sample_pc_pres = (num_repeats-pres_abs.count("0.0"))/float(num_repeats) * 100
    print "\tSample has {0:.2f}% presence.".format(sample_pc_pres)
    pc_pres.append(sample_pc_pres)
    outfile.write("%s,%s\n" % (sample_name, ",".join(pres_abs)))

print "Mean sample presence proportion is {0:.2f}%".format(sum(pc_pres)/len(pc_pres))       
outfile.close()
print "Output matrix saved to", out_filename


