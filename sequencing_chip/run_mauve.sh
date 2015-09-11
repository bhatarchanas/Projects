#!/bin/bash

# Runs mauve on all files specified in the folder

for file in Treponema_socranskii_subsp*.fsa_nt
	do
		echo $file
		java -Xmx500m -cp /home/archana/Apps/mauve_snapshot_2015-02-13/Mauve.jar org.gel.mauve.contigs.ContigOrderer -output TS_$file -ref Treponema_socranskii_subsp_paredis_ATCC_35535.fsa_nt -draft $file
	done
