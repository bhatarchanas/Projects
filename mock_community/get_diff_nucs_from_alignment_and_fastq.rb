require 'bio'

# Get the nucleotides which differ between the query and the subject, and map to the fastq file to get to the quality of that base
# Input file 1- csv file got from blastn and specifying the output fields that I wanted
# Output file 1- Identifty, alignment length, OTU in which nucs differ, position at which nucs differ, the actual nuc in the query and the subject
# Input file 2- One representative seq from each OTU, fatsq format
# Input file 3 == Output file 1
# Output file 2-ID, Position, Nucleotide_which differ_in_sub, Nucleotides_which_differ_in_que & Quality

file_out_1 = File.open("Blast_OTU_vs_HMP_parsed.csv", "w")
file_out_1.puts("Identity\tAlignment_length\tE-score\tOTU_in_which_nucs_differ\tPosition_at_which_different\tNucs_which_differ_in_sub\tNucs_which_differ_in_que")
fh_1 = File.open("blast_OTU_vs_HMP.csv", "r")

# Hash to keep track of the first hit
seen = {}
# Hash with the subject and the query sequences
seqs = {}

fh_1.each_line do |line|  
                                                                                                                           
	if line =~ /OTU_/

    		if !seen[line.split(",")[1]]

			# Array with positions which are different 
			pos_array = []

      			blast_array = line.split(",")
      			seen[blast_array[1]] = true

			seqs[blast_array[1]] = [blast_array[5].chomp,blast_array[6].chomp]
      			
			sub_HMP_array = blast_array[5].split("")
      			que_OTU_array = blast_array[6].split("")
      			
      			(0..sub_HMP_array.length-1).each do |ind|
        			if sub_HMP_array[ind] != que_OTU_array[ind]
        				file_out_1.puts(blast_array[2] + 
                      				"\t" + blast_array[3] + 
                      				"\t" + blast_array[4] + 
                      				"\t" + "#{blast_array[1]} \t #{ind} \t #{sub_HMP_array[ind]} \t #{que_OTU_array[ind]}" ) 
			
					#puts ind
					pos_array.push(ind)
					seqs[blast_array[1]][2] = pos_array
				end
			end
    		end
  	end
end
#puts seqs

#############################################################################################################################################################
# Hash that stores the new fastq seqs with the gaps
new_fastq_hash = {}

Bio::FlatFile.auto("fastq_seqs_filtered_based_on_OTU.fastq") do |fh_orignal_fq|
	fh_orignal_fq.each_entry do |entry_original_fq|
    		#Split fq sequence string and quality into arrays
    		seq_array = entry_original_fq.sequence_string.split("")
    		qual_array = entry_original_fq.quality_string.split("") 
		otu_num = entry_original_fq.entry_id.split(";")[0]		
		#puts "OTU_NUM: #{otu_num}"

    		#Seqs is a hash containing 
    		# hit_name(string) -> [subject(string), query(string), [pos1, pos2,.. posN]]
    		seqs.keys.each do |hit|
			otu_num_in_hit = hit.split(";")[0]
			#puts "OTU_NUM)IN_HIT: #{otu_num_in_hit}"
      			ind_for_ori_fastq_hash = 0
      			#new_fastq_hash[hit] = [[], []]
      	
      			#Split query sequence string into array of nucleotides 
      			query_array = seqs[hit][1].split("")

			# Check if the its the same OTU seqs 
			if otu_num_in_hit == otu_num
				#puts "True, #{otu_num_in_hit} is #{otu_num}"
				new_fastq_hash[hit] = [[], []]

      				(0..query_array.length-1).each do |ind|

        				if query_array[ind] != "-"
          					new_fastq_hash[hit][0].push(seq_array[ind_for_ori_fastq_hash])
						#puts "In if loop printing the seq in hash", new_fastq_hash[hit][0]
          					new_fastq_hash[hit][1].push(qual_array[ind_for_ori_fastq_hash])
          					ind_for_ori_fastq_hash += 1
        				else
						#puts "I just added a - in #{otu_num_in_hit}"
          					new_fastq_hash[hit][0].push("-")	
          					new_fastq_hash[hit][1].push("!")	
        				end
				end
      		
			end
    		end	
  	end
end

#puts new_fastq_hash
#############################################################################################################################################################

# Open a new file to write
file_out_2 = File.open("Blast_OTU_vs_HMP_quality_of_diff_nucs.csv", "w")
file_out_2.puts("ID\tPosition\tNucleotide_which differ_in_sub\tNucleotides_which_differ_in_que\tQuality")

# Loop over the keys in the newly created hash with modified sequences
new_fastq_hash.keys.each do |modified_seq|
	
	# Get the modified sequence array
      	seq_array = new_fastq_hash[modified_seq][0]
	
	# Check if the positions array of seqs hash is empty, if yes, move to next iteration
	if seqs[modified_seq][2].nil?
		puts "Im here"
		next
	# If not
	else
		# Loop through each position which had the different nucleotides (OTUvsHMP)
		(0..(seqs[modified_seq][2]).length-1).each do |position_diff|
			# Loop through the modified fastq aeq array
			(0..seq_array.length-1).each do |ind|
				# if the index of modified fastq array is same as the position which had the different nucleotides (OTUvsHMP), write to file
				if seqs[modified_seq][2][position_diff] == ind
					file_out_2.puts("#{modified_seq}\t#{ind}\t#{seqs[modified_seq][0][ind]}\t#{seqs[modified_seq][1][ind]}\t#{new_fastq_hash[modified_seq][1][ind]}")
				end
			end
		end
	end	
end

