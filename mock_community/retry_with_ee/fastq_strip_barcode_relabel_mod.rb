require 'bio'

output_file = File.open("BEI_Mock_Oriented_edit.fastq", "w")

file = Bio::FlatFile.auto("BEI_Mock_Oriented_trimmed.fastq")
file.each do |entry|
  #puts entry.methods.sort
  output_file.puts("@"+entry.definition.to_s+";barcodelabel=Mock_Community;", entry.sequence_string, "+", entry.quality_string)
  #output_file.puts(entry.seq.to_s)
  #output_file.puts("+")
  #output_file.puts(entry.quality_scores.to_s)
end 
