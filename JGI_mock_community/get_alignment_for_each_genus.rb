require 'bio'
require 'spreadsheet'

##### NOTES:
# The input excel file is the taxonomic results from utax in a spreadsheet format.
# Each taxa level is one column along with the confidence, eg. Proteobacteria(100.0)
# The file is sorted based on genus (A -> Z sorting)
# Further down the script, an input FASTA file is used for extraction of seqs in samtools
# This FASTA file ONLY has seqs lesser than 1700 in length

##### folder in whcih all the outputs are to e stored
folder = "JGI_12/"
 
#### Opening the spreadsheet and using sheet1 as the worksheet
taxa_file = Spreadsheet.open(folder+"taxa_sorted_1.xls")
sheet1 = taxa_file.worksheet('Sheet1') # can use an index or worksheet name

#### Obtaining an array with all the genuses and the confidences and otus with sizes
genus_array = []
otu_array = []
sheet1.each do |row|
  	break if row[0].nil? # if first cell empty
  	genus_array.push(row[6]) # looks like it calls "to_s" on each cell's Value
	otu_array.push(row[0])
end
#puts genus_array
#puts otu_array

#### Obtaining an array with only genus and otus
genus_array_split = []
otu_array_split = []
for each_genus in (0..genus_array.size-1)
	#puts each_genus
	var = genus_array[each_genus].split("(")[0]
	genus_array_split.push(var)
	var_2 = otu_array[each_genus].split(";")[0]
	otu_array_split.push(var_2)
end
#puts genus_array_split
#puts otu_array_split

#### Creating a hash with the genus name as the key and an array as the value
#### The array has all the OTUs corresponding to that genus
genus_count_hash = Hash.new(0)
array_of_otus = []
#genus_array_split.each {| v | genus_count_hash.store(v, genus_count_hash[v]+1)}
(0..genus_array_split.size-1).each do |each_genus|
	if genus_count_hash.has_key?(genus_array_split[each_genus])
		genus_count_hash[genus_array_split[each_genus]] = array_of_otus.push(otu_array_split[each_genus])
	else
		genus_count_hash[genus_array_split[each_genus]] = array_of_otus.push(otu_array_split[each_genus])
	end
	if genus_array_split[each_genus] != genus_array_split[each_genus+1]
		array_of_otus = []
	end
end
#puts genus_count_hash

#### Getting rid of all the genuses which have only one occurance
genus_count_hash.each do |key, value|
	if value.size == 1
		genus_count_hash.delete(key)
	end
end
#puts genus_count_hash

#### Get the headers of the seqs corresponsing to each OTU
# cat command merges the files which belong to the same genus
seq_headers = {}
genus_count_hash.each do |key, value|
	array_of_headers = []
	for each_otu in (0..value.size-1)
		#puts "grep -P \"#{value[each_otu]}\$\" JGI_12_retry/JGI_Mock_uparse_out_12_retry.up | cut -f 1 | cut -d ";" -f 1"
		`grep -P \"#{value[each_otu]}\$\" JGI_12/JGI_Mock_uparse_out_12.up | cut -f 1 | cut -d ";" -f 1 > JGI_12/#{value[each_otu]}_#{key}_select.txt`
		`cat JGI_12/\*#{key}_select.txt > JGI_12/OTU_#{key}_all.txt`
	end
end

####
fasta_file = Bio::FlatFile.auto("JGI_12/JGI_Mock_Oriented_12.fasta")
Dir.foreach(folder) do |file|
	array_of_headers = []
	if file.start_with?("OTU_")&& if file.end_with?("_all.txt")
		genus = file.split("_")[1]
		#puts genus
		file_fh = File.open(folder+file)
		file_fh.each_line do |line|
			array_of_headers.push(line.chomp)
			seq_headers[genus] = array_of_headers
		end
	end
	end
end
#puts seq_headers

#### Check for the presence of a header in the fasta file created by comparing with the hash. If there, print into a new output file. 
fasta_file = Bio::FlatFile.auto("JGI_12/JGI_Mock_Oriented_12.fasta")
seq_headers.each do |key, value|
	otu_file = File.open(folder+"final_"+key+"_filtered.txt", "w")
	puts key
	#puts value
  	(0..value.size-1).each do |header|
		#puts value[header]
		fasta_file = Bio::FlatFile.auto("JGI_12/JGI_Mock_Oriented_12.fasta")
		fasta_file.each do |entry|
			#puts entry.definition
			if value[header].eql?(entry.definition)
				#puts entry.naseq.size
				otu_file.puts(entry.definition)
			end
		end
	end
end


##### Extract the seqs belonging to each OTU using samtools. 
Dir.foreach(folder) do |file|
	if file.start_with?("final_")&& if file.end_with?("_filtered.txt")
		file_basename = File.basename(file, ".txt")
		input = folder+file
		output = folder+file_basename+"_subset.fasta"
		puts input, output
		`samtools faidx JGI_12/JGI_Mock_Oriented_12.fasta`
		`xargs samtools faidx JGI_12/JGI_Mock_Oriented_12.fasta < #{input} > #{output}`
	end
	end
end

##### Align the seuences using einsi in maaft
Dir.foreach(folder) do |file|
	if file.start_with?("final_") && if file.end_with?("_subset.fasta")
		file_basename = File.basename(folder+file, ".fasta")
		#puts "Im here", file_basename
		input = folder+file_basename+".fasta"
		output = folder+file_basename+"_aligned.fasta"
		puts input, output
		`einsi #{input} > #{output}`
	end 
	end
end



