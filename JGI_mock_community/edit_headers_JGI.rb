require 'bio'

# The headers in the JGI files had a space in it. So, this script gets rid of everything after the space.
# Input - Fasta file with original headers
# Output - Fasta file with edited headers

file = Bio::FlatFile.auto("JGI_data/JGI_Mock_78.fastq")
out_file = File.open("JGI_78/JGI_Mock_78.fastq", "w")

file.each do |entry|
	header_edit = entry.definition.to_s.split(" ")[0]
	out_file.puts("@"+header_edit)
    	out_file.puts(entry.naseq.to_s.upcase)
    	out_file.puts("+")
    	out_file.puts(entry.quality_string)
end
