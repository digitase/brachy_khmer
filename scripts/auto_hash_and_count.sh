#!/bin/bash

SEQ_FILE=$1
N_TABLES=$2
TABLE_SIZE=$3

args=("$@")
k_values=(${args[@]:3})
seq_basename=$(basename "$SEQ_FILE" ".il.fq.gz")
log_file="$seq_basename.log"

: > "$log_file"

for k in ${k_values[@]}; do

    table_file="$seq_basename.k$k.htable" 
    hist_file="$seq_basename.k$k.hist"
    echo $k
    continue

    {
    echo "Hashing for k=$k" 
    time load-into-counting.py --ksize "$k" --n_tables "$N_TABLES" --min-tablesize "$TABLE_SIZE" "$table_file" "$SEQ_FILE" 
    } >> "$log_file" 2>&1

    {
    printf "\nCreating histogram for k=$k\n" 
    time abundance-dist.py --no-zero --squash "$table_file" "$SEQ_FILE" "$hist_file"
    printf "\n"
    } >> "$log_file" 2>&1

done


# ben@north1ws:~/bd21_fake_reads$ time abundance-dist.py --no-zero bd21_both_nomut.kh bd21_both_nomut.fq bd21_both_nomut.hist




# # Generate simulated paired end read files from reference genome, with mutation rate and sequencing error
# wgsim -N 20000000 -1 100 -2 100 /fast/refseqs/bd21/Bdistachyon_MIPS_1_2.fa >(gzip >bd21_R1.fq.gz) >(gzip >bd21_R2.fq.gz) >bd21.geno
# pairs join bd21_R1.fq.gz bd21_R2.fq.gz > bd21_both.fq

# # Same as above, but no mutation rate
# wgsim -r 0.0 -N 20000000 -1 100 -2 100 /fast/refseqs/bd21/Bdistachyon_MIPS_1_2.fa >(gzip >bd21_R1_nomut.fq.gz) >(gzip >bd21_R2_nomut.fq.gz) > bd21_nomut.geno
# pairs join bd21_R1_nomut.fq.gz bd21_R2_nomut.fq.gz > bd21_both_nomut.fq

# # Hashing mut
# load-into-counting.py -k 23 -N 8 -x 1e9 bd21_both.kh bd21_both.fq

    # || You are running khmer version 1.1
    # || You are also using screed version 0.7

    # - kmer size =    23            (-k)
    # - n tables =     8             (-N)
    # - min tablesize = 1e+09        (-x)

    # Estimated memory usage is 8e+09 bytes (n_tables x min_tablesize)
    # fp rate estimated to be 0.073

# # Hashing no mut
# load-into-counting.py -k 23 -N 8 -x 1e9 bd21_both_nomut.kh bd21_both_nomut.fq

    # - kmer size =    23            (-k)
    # - n tables =     8             (-N)
    # - min tablesize = 1e+09        (-x)

    # Estimated memory usage is 8e+09 bytes (n_tables x min_tablesize)
    # fp rate estimated to be 0.072

# # histogram the hash

# ben@north1ws:~/bd21_fake_reads$ time abundance-dist.py --no-zero bd21_both.kh bd21_both.fq bd21_both.hist

# hashtable from bd21_both.kh
# K: 23
# HT sizes: [1000000007L, 1000000009L, 1000000021L, 1000000033L, 1000000087L, 1000000093L, 1000000097L, 1000000103L]

# real    52m8.446s
# user    49m16.121s
# sys     0m49.099s

# # and for the nomut one

# ben@north1ws:~/bd21_fake_reads$ time abundance-dist.py --no-zero bd21_both_nomut.kh bd21_both_nomut.fq bd21_both_nomut.hist

# hashtable from bd21_both_nomut.kh
# K: 23
# HT sizes: [1000000007L, 1000000009L, 1000000021L, 1000000033L, 1000000087L, 1000000093L, 1000000097L, 1000000103L]

# real    53m57.568s
# user    50m32.286s
# sys     1m0.532s

# # Subgenomes simulation
# # Generate subgenome with default mutation rate 0.001
# ben@north1ws:~/bd21_fake_reads/subgenome/subgenome_default_mut$ time wgsim -N 20000000 -1 100 -2 100 /fast/refseqs/bd21/Bdistachyon_MIPS_1_2.fa >(gzip >bd21_R1.fq.gz) >(gzip >bd21_R2.fq.gz) >bd21_sub_defmut.geno
# [wgsim] seed = 1409190998
# [wgsim_core] calculating the total length of the reference sequence...
# [wgsim_core] 83 sequences, total length: 271923306

# real    7m51.952s
# user    4m14.696s
# sys     0m4.716s

# ben@north1ws:~/bd21_fake_reads/subgenome/subgenome_default_mut$ pairs join bd21_R1.fq.gz bd21_R2.fq.gz > bd21_sub_defmut.il.fq

# # and a subgenome with higher mutation rate 0.005
# ben@north1ws:~/bd21_fake_reads/subgenome/subgenome_hyper_mut$ time wgsim -N 20000000 -r 0.005 -1 100 -2 100 /fast/refseqs/bd21/Bdistachyon_MIPS_1_2.fa >(gzip >bd21_R1.fq.gz) >(gzip >bd21_R2.fq.gz) >bd21_sub_hypermut.geno
# [wgsim] seed = 1409191130
# [wgsim_core] calculating the total length of the reference sequence...
# [wgsim_core] 83 sequences, total length: 271923306

# real    7m57.934s
# user    4m13.848s
# sys     0m4.856s
# ben@north1ws:~/bd21_fake_reads/subgenome/subgenome_hyper_mut$ pairs join bd21_R1.fq.gz bd21_R2.fq.gz > bd21_sub_hypermut.il.fq

# # combine and subsample 20m pairs
# cat subgenome_default_mut/bd21_sub_defmut.il.fq subgenome_hyper_mut/bd21_sub_hypermut.il.fq > bd21_sub.il.fq

# ben@north1ws:~/bd21_fake_reads/subgenome$ time python ../../_scripts/sample_blocks.py bd21_sub.il.fq 20000000 8 > bd21_sub_20m.il.fq           

# real    2m29.052s
# user    2m1.312s
# sys     0m24.030s

