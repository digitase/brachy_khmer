#!/bin/bash

SEQ_FILE=$1
N_TABLES=$2
TABLE_SIZE=$3

args=("$@")
k_values=(${args[@]:3}) # Get array of k values
seq_basename=$(basename "$SEQ_FILE" ".il.fq.gz")
log_file="$seq_basename.log"

# Clear the log file
: > "$log_file"

for k in ${k_values[@]}; do

    table_file="$seq_basename.k$k.htable" 
    hist_file="$seq_basename.k$k.hist"

    # Count kmers
    {
    echo "Hashing for k=$k" 
    time load-into-counting.py --ksize "$k" --n_tables "$N_TABLES" --min-tablesize "$TABLE_SIZE" "$table_file" "$SEQ_FILE" 
    } >> "$log_file" 2>&1

    # Get kmer distribution
    {
    printf "\nCreating histogram for k=$k\n" 
    time abundance-dist.py --no-zero --squash "$table_file" "$SEQ_FILE" "$hist_file"
    printf "\n"
    } >> "$log_file" 2>&1

done
