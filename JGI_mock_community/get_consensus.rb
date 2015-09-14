require 'bio'

##### Files to read and write
fastq_file = Bio::FlatFile.auto("JGI_12/JGI_Mock_Oriented_12.fastq")
out_file = File.open("JGI_12/JGI_Mock_Oriented_12.fasta", "w")
out_file_2 = File.open("JGI_12/JGI_consensus.fasta", "w")

##### folder in whcih all the outputs are to e stored
folder = "JGI_12/"

##### Array having all the OTUs whose sequences need to be extracted
otus=[20,27,13,30,9,24,21,10,19,48,65,66,15,14,36,63,75,1,29,33,51,5,8,64,68,93,2,32,39,62,7,42,88,28,56,53,16,31,52,69,92,3,37,80,81,107,119,17,22,38,46,55,58,73,78,83,118,127]

##### Get the headers of the seqs corresponsing to each OTU
otu_headers = {}
for each_otu in (0..otus.size-1)
	array_of_headers = []
	#puts "grep -P \"OTU_#{otus[each_otu]};\" JGI_12/JGI_readmap_12.uc | cut -f9 | cut -d \";\" -f1 > JGI_12/OTU_#{otus[each_otu]}.txt"
	result = `grep -P \"OTU_#{otus[each_otu]};\" JGI_12/JGI_readmap_12.uc | cut -f9 | cut -d \";\" -f1`
	result.gsub!(/\n/, ",")
	array_of_headers.push(result)
	#puts array_of_headers
	otu_headers["OTU_"+otus[each_otu].to_s] = array_of_headers
end
#puts otu_headers

#### To convert fastq file to fasta
fastq_file.each do |entry|
	if entry.sequence_string.size < 1700
		out_file.puts(">"+entry.entry_id)
		out_file.puts(entry.sequence_string)
	end
end

#### Check for the presence of a header in the fasta file created by comparing with the hash. If there, print into a new output file. 
otu_headers.each do |key, value|
	otu_file = File.open(folder+key+".txt", "w")
	puts key
  	value.each do |header|
  		array_of_headers = header.split(",")
		#puts array_of_headers
		fasta_file = Bio::FlatFile.auto("JGI_12/JGI_Mock_Oriented_12.fasta")
		fasta_file.each do |entry|
			if array_of_headers.include?(entry.definition)
				#puts entry.naseq.size
				otu_file.puts(entry.definition)
			end
		end
	end
end

##### Extract the seqs belonging to each OTU using samtools. 
Dir.foreach('JGI_12') do |file|
	file_basename = File.basename(folder+file, ".txt")
	if file.start_with?("OTU_") && if file.end_with?(".txt")
		#puts file
		#file_fh = File.open(folder+file, "r")
		input = folder+file
		output = folder+file_basename+"_subset.fasta"
		#puts input, output
		#`samtools faidx JGI_12/JGI_Mock_Oriented_12.fasta`
		#`xargs samtools faidx JGI_12/JGI_Mock_Oriented_12.fasta < #{input} > #{output}`
	end
	end
end

##### Align the seuences using einsi in maaft
Dir.foreach('JGI_12') do |file|
	file_basename = File.basename(folder+file, ".fasta")
	if file.start_with?("OTU_") && if file.end_with?("_subset.fasta")
		#puts "Im here", file_basename
		input = folder+file_basename+".fasta"
		output = folder+file_basename+"_aligned.fasta"
		#puts input, output
		#`einsi #{input} > #{output}`
	end 
	end
end

##### Generate the consensus sequence for each OTU using bioruby
Dir.foreach('JGI_12') do |file|
	file_basename = File.basename(folder+file, ".fasta")
	if file.start_with?("OTU_") && if file.end_with?("_aligned.fasta")
		out_file_2.puts(">"+file+";size=10;")
		aln = Bio::Alignment.readfiles(folder+file)
		out_file_2.puts(aln.consensus_string(threshold=0.6, :gap_mode=>0).upcase)
	end
	end
end


