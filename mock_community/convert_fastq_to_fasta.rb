require 'bio'

# Input - Fastq file 
# Output - Fasta file

file = Bio::FlatFile.auto("trimmed/BEI_Mock_Oriented_trimmed.fastq")
out_file = File.open("trimmed/BEI_Mock_Oriented_trimmed.fasta", "w")

file.each do |entry|
	out_file.puts(">"+entry.entry_id)
	out_file.puts(entry.sequence_string)
end
