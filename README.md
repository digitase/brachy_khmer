# `brachy_khmer`
## Exploring k-mer spectra analysis for read-level sample clustering in *Brachypodium*

Repository for BIOL3157 ASE, ANU, S2 2014

#### NOTE
For a more comprehensive summary of the workflow, see the IPython Notebook `doc/brachy_khmer.ipnb`

Also see the project report in `doc/`

### Brief usage for individual scripts

    sim_subgenomes.sh   
        Simulate reads from sequencing subgenomes 
    Arguments:
        REF_FILE = reference REFNAME.fa.gz file
        TOTAL_READ_NUM = n/2, the number of read pairs to simulate
        READ_LEN = L, the read length in bp
        SEQ_ERROR = sequencing error rate, -e parameter of wgsim e.g. 0.02
        SUBGENOME_NUM = number of subgenomes to simulate e.g. 2
        READ_PROPORTIONS = SUBGENOME_NUM arguments, fraction of reads from 
            each subgenome in final merged reads file e.g. 0.5 0.5 for 50/50 split
        MUTATION_RATES = SUBGENOME_NUM arguments, polymorphism rate for 
            each subgenome, -r parameter of wgsim e.g. 0.05, 0.005
    Output:
        Interleaved paired end .il.fq.gz file with name 
            REFNAME.-SEQ_ERROR-READ_PROPORTIONS-MUTATION_RATES-.il.fq.gz
    
    auto_hash_and_count.sh 
        Hashes and determines kmer abundance of a reads file. 
    Arguments:
        SEQ_FILE = reads READSNAME.il.fq.gz file, possibly from sim_subgenomes.sh 
        N_TABLES = number of hash tables to use
        TABLE_SIZE = min size of each table (bytes) e.g. 2e9
            Approximate memory usage will be N_TABLE*TABLE_SIZE
        K_VALUES = list of k-values to hash at e.g. 10 13 15 17
    Outputs:
        for each K_VALUE in K_VALUES, outputs
             READSNAME.k$K_VALUE.htable = the binary hash kmer table
             READSNAME.k$K_VALUE.htable.info = contains the false positive rate
             READSNAME.k$K_VALUE.hist = tab delimited text file with columns:
                 (1) k-mer abundance, 
                 (2) k-mer count, 
                 (3) cumulative count, 
                 (4) fraction of total distinct k-mers. 
                    See http://khmer.readthedocs.org/en/v1.1/scripts.html for more details.                
             READSNAME.kK_VALUE.log = detailed script output and timing info
    
    plot_hist.py 
        Plots log10(kmer frequency) vs. abundance
    Arguments:
        xlim_max = x axis max limit
        ylim_max = y axis max limit
        filenames = list of .hist files from auto_hash_and_count.sh 
    Outputs:
        SAMPLES.png, where SAMPLES is the concatenated basename of all input filenames.
    
    repeat_pres_abs.py 
        Load list of .htables, determine kmer repeat profile.
    Arguments:
        table_files_list = text file, two columns, whitespace delimited.
            First column = path to .htable file
            Second column = number of read pairs in the corresponding library            
        k = k value that was used to generate the .htable files
        skip = ignore the top $skip most abundant kmers
        num_repeats = use the next $num_repeats most abundant kmers as the reference set
    Outputs:
        CSV file with counts matrix.        
            $BASENAME.skip$skip.N$num_repeats.pres_abs.csv, 
                where BASENAME is the basename of $table_files_list.
            Each row corresponds to a sample in $table_files_list, 
                each of the $num_repeats columns contains the count for a k-mer 
                    in the reference set, normalised by the library read count.

    cluster_samples.R
        Plot dendrogram from counts matrix.
    Arguments:
        infile = counts matrix .csv file from repeat_pres_abs.py 
        outfile = the name of the .png file to output
    Outputs:
        outfile, the dendrogram in .png format
        
    

