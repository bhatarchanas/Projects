require 'bio'

# Loops through a folder and gets rid of all the seqs which are lesser than a particular length

file_num = 0
counter = 0 
Dir.glob("for_final_alignment/PG/*_core_out.fasta") do |f|
	file_num += 1
	out_FH = File.open("for_final_alignment/PG/"+File.basename(f, ".fasta")+"_filtered_out.txt", "w")
	ff = Bio::FlatFile.auto(f)
	ff.each_entry do |entry|
		if entry.seq.size > 100  
			out_FH.puts(entry.definition)
			out_FH.puts(entry.seq)
		else
			counter += 1
		end
	end
	puts f, counter
end

puts counter/file_num

