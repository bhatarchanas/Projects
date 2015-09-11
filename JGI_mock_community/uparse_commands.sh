#!/bin/bash

# Call this script to obtain the correct orientations of the reads from PacBio (need to change the input and output files based on requirements)
ruby get_correct_orientation.rb

# For filtering the low quality reads, -fastq_qmax 50 says that 50 is the maximum quality possible, -fastq_maxee_rate 1.0 says that the reads which have expected error more than 1.0 are to be removed. 
usearch -fastq_filter JGI_78/JGI_Mock_Oriented_78.fastq -fastq_qmax 50 -fastqout JGI_78/JGI_Mock_Oriented_Filtered_78.fastq -fastq_maxee 1.0 -eeout

# For dereplication, -sizeout is the number of reads that are collapsed into one read, minseqlength option can be used to specify the minimum sequence length to be included in the output. 
usearch -derep_fulllength JGI_78/JGI_Mock_Oriented_Filtered_78.fastq -fastaout JGI_78/JGI_Mock_Oriented_Filtered_Derep_78.fasta -fastqout JGI_78/JGI_Mock_Oriented_Filtered_Derep_78.fastq -sizeout -minseqlength 64

# For sorting the reads based on the number of reads which were assigned to each cluster in the previous step.
usearch -sortbysize JGI_78/JGI_Mock_Oriented_Filtered_Derep_78.fasta -fastaout JGI_78/JGI_Mock_Oriented_Filtered_Derep_Sorted_78.fasta

# For clustering the OTU's, -otus option stands for the name of the output file in fasta format, -uparseout stands for the name of the file from uparse, -sizein and -sizeout says that size annotation is present in the input file and is required in the output file.
usearch -cluster_otus JGI_78/JGI_Mock_Oriented_Filtered_Derep_Sorted_78.fasta -otus JGI_78/JGI_Mock_OTU_78.fasta -uparseout JGI_78/JGI_Mock_uparse_out_78.up -relabel OTU_ -sizein -sizeout

# For filtering the chimeric reads, using the gold database, -nonchimeras needs the name of the file without the chimeric reads                              
usearch -uchime_ref JGI_78/JGI_Mock_OTU_78.fasta -db gold.fa -strand plus -nonchimeras JGI_78/JGI_Mock_OTU_nonchimera_78.fasta -uchimeout JGI_78/JGI_uchime_results.uchime

# Call this script for converting the format of the fasta file for making it suitable for creating a OTU table, adds barcodelable=Mock_community to the header (need to change the input and output files based on requirements)
ruby drive5_py/fastq_strip_barcode_relabel_mod.rb

# For mapping the reads to the OTUS's, using the gold db, -id 0.97 says that we want 97% similarity between the reads and the reference sequence in order for mapping to occur
usearch -usearch_global JGI_78/JGI_Mock_Oriented_edit_78.fastq -db JGI_78/JGI_Mock_OTU_nonchimera_78.fasta -strand plus -id 0.97 -uc JGI_78/JGI_readmap_78.uc

# For converting the uc file into an OTU table in txt
python drive5_py/uc2otutab.py JGI_78/JGI_readmap_78.uc > JGI_78/JGI_OTU_Table_78.txt

# For assigning taxonomy, .tt, .fa for db and .tc files are from the download link in utax 
usearch -utax JGI_78/JGI_Mock_OTU_nonchimera_78.fasta -db rdp_16s.fa -taxconfs rdp_16s_fl.tc -tt rdp_16s.tt -utaxout JGI_78/JGI_taxonomy_results_78.txt
