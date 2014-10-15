#!/bin/bash

REF_FILE=$1
TOTAL_READ_NUM=$2
READ_LEN=$3
SUBGENOME_NUM=$4

ref_basename=$(basename "$REF_FILE" ".fa.gz")
args=("$@")
read_proportions=(${args[@]:4:$SUBGENOME_NUM})
mutation_rates=(${args[@]:4+$SUBGENOME_NUM:$SUBGENOME_NUM})

# Array concatenation with delimiter
# Source: Nicholas Sushkin, http://stackoverflow.com/questions/1527049/bash-join-elements-of-an-array
function join { local IFS="$1"; shift; echo "$*"; }

# Add subgenome proportions and rates to filename
all_props=$(join , "${read_proportions[@]}")
all_rates=$(join , "${mutation_rates[@]}")
out_read_file="$ref_basename.-${all_props}-${all_rates}-.il.fq.gz"
: > $out_read_file

echo "Output file: $out_read_file"

# Simulate the proportional number of reads for each subgenome

tmp1="$RANDOM.tmp"
tmp2="$RANDOM.tmp"

for (( n=0; n<SUBGENOME_NUM; n++ ))
do
    # Calculate number of reads to simulate of the total read number
    read_num=$(bc <<< "${read_proportions[$n]} * $TOTAL_READ_NUM / 1")

    echo "Simulating $read_num read pairs at mutation rate ${mutation_rates[$n]} for subgenome $n"

    # Discard details about location of mutations to /dev/null
    # Usage:   wgsim [options] <in.ref.fa> <out.read1.fq> <out.read2.fq>
    wgsim -N $read_num -1 $READ_LEN -2 $READ_LEN -r "${mutation_rates[$n]}" "$REF_FILE" $tmp1 $tmp2 >/dev/null
    pairs join $tmp1 $tmp2 | gzip >> "$out_read_file"
done

rm $tmp1 $tmp2

