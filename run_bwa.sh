#!/bin/bash

## add bwa to PATH
#~ PATH=$PATH:/opt/bwa-0.7.5a

if [ -z ${bwadir+x} ]; 
then 
	echo "Erreur: bwadir est non défini -> exit"; 
	exit
else 

echo -e "\t#-----# ALIGNEMENT"
echo -e "\nRun bwa mem -P -M for Sample: "$sample
	## run bwa mem
	## -t for number of threads
	## -P for paired-end mode
	## -M for Picard compatibility
	echo "COMMAND: $bwadir/bwa mem -t 8 -M $refdir/$myref $fastqdir/${sample}_R1.fastq.gz $fastqdir/${sample}_R2.fastq.gz > $samdir/${sample}_bwa-mem-P-M.sam"
	
	$bwadir/bwa mem -t $maxthreads -M $refdir/$myref $fastqdir/${sample}_R1.fastq.gz $fastqdir/${sample}_R2.fastq.gz > $samdir/${sample}_bwa-mem-P-M.sam
fi
