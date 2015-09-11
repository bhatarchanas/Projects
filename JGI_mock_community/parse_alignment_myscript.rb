require 'bio'

# Getting the specie name of the blast hit is being a pain. This script parses a csv blast file and gets the specie name using the 16s reference from NCBI
# Input file 1 = Blast csv file (fh)
# Input file 2 = 16sMicrobial_ncbi.fasta which is the 16s reference in NCBI (fh_2)
# Output = csv file with OTU_num, Query_ID, Identity and Alignment_length
# Output 2 = csv file with the OTU number and the specie name 

file_out = File.open("JGI_78/blast_parsed_78.csv", "w")
file_out.puts("OTU_num\tQuery_id\tIdentity\tAlignment_length")

fh = File.open("JGI_78/blast.csv", "r")

seen = {}
query_array = []
otu_array = []
fh.each_line do |line|   
	#puts "count in do loop", counter
	#puts "line from fh", line
  	if line =~ /OTU_/
		line_split = line.split(",")
    		#puts line	
    		if !seen[line_split[0]]
      			file_out.puts(line_split[0] + "\t" + line_split[1] + "\t" + line_split[2] + "\t" + line_split[3]) 
			query_array.push(line_split[1])
			otu_array.push(line_split[0])
      			seen[line_split[0]] = true
    		end
  	end  
end 
#puts query_array.size


fh_2 = Bio::FlatFile.auto("16sMicrobial_ncbi.fasta")
file_out_2 = File.open("JGI_78/blast_specie_name_78.csv", "w")
seen_2 = {}
fh_2.each do |entry|
	for each_qid in 0..query_array.size-1
		#puts query_array[each_qid]
		if entry.definition.include?query_array[each_qid]
			#if !seen_2[query_array[each_qid]]
				file_out_2.puts(otu_array[each_qid] + "\t" + entry.definition)
				#seen_2[query_array[each_qid]] = true
			#end
		end
	end
end



