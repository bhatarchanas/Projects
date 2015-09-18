require 'bio'

##### NOTES
# Input file 1- csv file, blast output
# Input file 2- 16sMicrobial_ncbi.fasta (NCBI's 16s reference in FASTA format)
# Input file 3- Oriented and filetred for seqs < 1700 
# Description - Takes the csv file, gets the ref ID for the best hit of each OTU, gets seq corresponding to that ID and stored it all in a hash.
# The seqs corresponding to each OTU is then grabbed, put in a file with the first sequence being the one from the ref DB.
# These seqs are then aligned using einsi maaft. 

#### Getting a hash with the OTU number as the key and the ref ID as the value
blast_fh = File.open("JGI_12_blast/JGI_12_blast_hit_table.csv", "r")
otu_hit_hash = {}
blast_fh.each_line do |line|   
	#puts "count in do loop", counter
	#puts "line from fh", line
  	if line =~ /OTU_/
		line_split = line.split(",")
    		#puts line	
    		if !otu_hit_hash[line_split[0].split(";")[0]]
      			otu_hit_hash[line_split[0].split(";")[0]] = line_split[1]
    		end
  	end  
end 
#puts otu_hit_hash

#### Making sure the value in that hash has only one ref ID. If it doesnt, split it, get only one and then store it in the hash
otu_hit_hash.each do |key, value|
	#puts query_array[each_qid]
	if value.include?(";")
		#puts key, value
		value = value.split(";")[0]
		otu_hit_hash[key] = value
		#puts query_array[each_qid]
	end
end
#puts otu_hit_hash

#### Creating another hash with the OTU num as key and an array as value
# Array has definition line in 0th index and seq in 1st index
otu_def_hash = {}
ncbi_fh = Bio::FlatFile.auto("16sMicrobial_ncbi.fasta")
ncbi_fh.each do |entry|
	otu_hit_hash.each do |key, value|
		#puts query_array[each_qid]
		if entry.definition.include?value
			otu_def_hash[key] = [entry.definition, entry.naseq]
		end
	end
end
#puts otu_def_hash

##### folder in which all the outputs are to be stored
folder = "JGI_12_blast/"

##### Array having all the OTUs whose sequences need to be extracted
otus=[20,27,13,30,9,24,21,10,19,48,64,65,15,14,36,62,74,1,29,33,51,5,8,63,67,92,2,32,39,61,7,42,87,28,56,53,16,31,52,68,91,3,37,80,79,106,118,17,22,38,46,55,57,72,77,82,117,126,12,23,34,41,54,73,76,89,90]

##### Get the headers of the seqs corresponsing to each OTU
for each_otu in (0..otus.size-1)
	#puts "grep -P \"OTU_#{otus[each_otu]}\$\" JGI_12/JGI_Mock_uparse_out_12.up | cut -f 1 | cut -d \";\" -f 1 > JGI_12_blast/OTU_#{otus[each_otu]}.txt"
	`grep -P "OTU_#{otus[each_otu]}\$" JGI_12/JGI_Mock_uparse_out_12.up | cut -f 1 | cut -d ";" -f 1 > JGI_12_blast/OTU_#{otus[each_otu]}_list.txt`
end

##### Extract the seqs belonging to each OTU using samtools
Dir.foreach('JGI_12_blast') do |file|
	if file.start_with?("OTU_") && if file.end_with?("_list.txt")
		file_basename = File.basename(file, ".txt")
		#puts "Base", file_basename
		input = folder+file
		output = folder+file_basename+"_subset.fasta"
		#puts input, output
		`samtools faidx JGI_12/JGI_Mock_Oriented_12.fasta`
		`xargs samtools faidx JGI_12/JGI_Mock_Oriented_12.fasta < #{input} > #{output}`
	end
	end
end

=begin
##### To check if all the seqs were extracted from samtools 
Dir.foreach('JGI_12_blast') do |file|
	input = folder+file
	if file.start_with?("OTU_") && if file.end_with?("_list.txt")
		`wc -l #{input} >> Count_list.txt`
	end
	end
	if file.start_with?("OTU_") && if file.end_with?("_subset.fasta")
		`grep ">" #{input} /dev/null -c >> Count_subset.txt`
	end
	end
end
=end

##### Add the otu hit seq from ncbi fasta db with the seqs corresponding to each otu
Dir.foreach('JGI_12_blast') do |file|
	if file.start_with?("OTU_") && if file.end_with?("_subset.fasta")
		file_name = folder+file
		file_basename = File.basename(file, ".fasta")
		#puts file_basename
		otu_def_hash.each do |key, value|
			if file_basename.include?(key)
				#puts file
				file_fh = Bio::FlatFile.auto(file_name)
				out_fh = File.open(folder+file_basename+"_final.fasta", "w")
				out_fh.puts(">"+otu_def_hash[key][0])
				out_fh.puts(otu_def_hash[key][1])
				file_fh.each do |entry|
					#puts key
					#puts entry.definition
					out_fh.puts(">"+entry.definition)
					out_fh.puts(entry.naseq)
				end
			end
		end
	end
	end
end

##### Align the seuences using einsi in maaft
Dir.foreach('JGI_12_blast') do |file|
	if file.start_with?("OTU_") && if file.end_with?("_final.fasta")
		file_basename = File.basename(file, ".fasta")
		#puts "Im here", file_basename
		input = folder+file
		output = folder+file_basename+"_aligned.fasta"
		#puts input, output
		#`einsi #{input} > #{output}`
	end 
	end
end



