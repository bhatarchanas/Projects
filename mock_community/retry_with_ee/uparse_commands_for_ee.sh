#!/bin/bash

# Call this script to obtain the correct orientations of the reads from PacBio (need to change the input and output files based on requirements)
#ruby get_correct_orientation.rb

# For filtering the low quality reads, -fastq_qmax 50 says that 50 is the maximum quality possible, -fastq_maxee_rate 1.0 says that the reads which have expected error more than 1.0 are to be removed. 
usearch -fastq_filter BEI_Mock_Oriented_trimmed.fastq -fastq_qmax 50 -fastqout BEI_Mock_Oriented_Filtered.fastq -fastq_maxee 1.0 -eeout

# For dereplication, -sizeout is the number of reads that are collapsed into one read, minseqlength option can be used to specify the minimum sequence length to be included in the output. 
usearch -derep_fulllength BEI_Mock_Oriented_Filtered.fastq -fastaout BEI_Mock_Oriented_Filtered_Derep.fasta -fastqout BEI_Mock_Oriented_Filtered_Derep.fastq -sizeout -minseqlength 64

# For sorting the reads based on the number of reads which were assigned to each cluster in the previous step.
usearch -sortbysize BEI_Mock_Oriented_Filtered_Derep.fasta -fastaout BEI_Mock_Oriented_Filtered_Derep_Sorted.fasta

# For clustering the OTU's, -otus option stands for the name of the output file in fasta format, -uparseout stands for the name of the file from uparse, -sizein and -sizeout says that size annotation is present in the input file and is required in the output file.
usearch -cluster_otus BEI_Mock_Oriented_Filtered_Derep_Sorted.fasta -otus BEI_Mock_OTU.fasta -id 0.9 -uparseout BEI_Mock_uparse_out.up -relabel OTU_ -sizein -sizeout

# For filtering the chimeric reads, using the gold database, -nonchimeras needs the name of the file without the chimeric reads                              
usearch -uchime_ref BEI_Mock_OTU.fasta -db gold.fa -strand plus -uchimeout BEI_uchime_results.uchime -nonchimeras BEI_Mock_OTU_nonchimera.fasta

# Call this script for converting the format of the fasta file for making it suitable for creating a OTU table, adds barcodelable=Mock_community to the header (need to change the input and output files based on requirements)
ruby fastq_strip_barcode_relabel_mod.rb

# For mapping the reads to the OTUS's, using the gold db, -id 0.97 says that we want 97% similarity between the reads and the reference sequence in order for mapping to occur
usearch -usearch_global BEI_Mock_Oriented_edit.fastq -db BEI_Mock_OTU_nonchimera.fasta -strand plus -id 0.97 -uc BEI_readmap.uc

# For converting the uc file into an OTU table in txt
python drive5_py/uc2otutab.py BEI_readmap.uc > BEI_OTU_Table

# For assigning taxonomy, .tt, .fa for db and .tc files are from the download link in utax 
usearch -utax BEI_Mock_OTU_nonchimera.fasta -db rdp_16s.fa -taxconfs rdp_16s_fl.tc -tt rdp_16s.tt -utaxout BEI_taxonomy_results.txt
