
import khmer
import itertools as it
import heapq
import os
import sys

k = int(sys.argv[1])
num_repeats = int(sys.argv[2])
table_files_list = sys.argv[3]
table_files = [line.strip() for line in open(table_files_list, "r")]

# Coding kmers with integers
# kmer_code_to_string = {}
# kmer_string_to_code = {}

# for code, kmer in enumerate(it.product("ACTG", repeat=k)):
    # kmer_str = "".join(kmer)
    # kmer_code_to_string[code] = kmer_str
    # kmer_string_to_code[kmer_str] = code

out_filename = os.path.splitext(os.path.basename(table_files_list))[0]
outfile = open(out_filename + ".csv", "w")

# Monitor progress
i = 0
num_kmers = 4**k

# Yield the counts of each possible kmer in the hash table.
def generate_kmer_counts(k, ht, alpha="ACTG"):
    global i
    global num_kmers
    for kmer in it.product(alpha, repeat=k):
        kmer_str = "".join(kmer)
        i += 1
        if not i % 1000000:
            print "{0:.2f}% complete.".format(float(i)/num_kmers * 100)
        yield (ht.get(kmer_str), kmer_str)

# Get most abundant kmers in first sample
# Construct presence-absence matrix for those kmers over all samples
for i, file in enumerate(table_files):
    sample_name = os.path.splitext(os.path.basename(file))[0]
    print "Loading sample %d of %d: %s" % (i+1, len(table_files), sample_name)
    ht = khmer.load_counting_hash(file)

    if i == 0:
        print "Counting first sample:", sample_name
        kmer_counts = generate_kmer_counts(k, ht)

        repeat_list = [kmer_str for (_, kmer_str) in heapq.nlargest(num_repeats, kmer_counts)]
        pres_abs = ["1" for _ in repeat_list]
    else:
        pres_abs = [str(int(ht.get(kmer_str) > 0)) for kmer_str in repeat_list]

    del ht
    print "Sample has {0:.2f}% abundance.".format(float(sum(map(int, pres_abs)))/num_repeats * 100)
    outfile.write("%s,%s\n" % (sample_name, ",".join(pres_abs)))
       
outfile.close()

