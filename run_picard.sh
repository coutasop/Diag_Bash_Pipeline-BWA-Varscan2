#!/bin/bash

if [ -z ${picarddir+x} ]; 
then 
	echo "Erreur: picarddir est non défini -> exit"; 
	exit
else 

	#a#-----------------------------------------
		## Sort aligned reads by coordinate order
		echo -e "\t#-----# Sort aligned reads by coordinate order"
		echo -e "\tRun picard/SortSam.jar for: "$sample
		## run picard SortSam
		## SORT_ORDER=coordinate for Sort order of output file
		## CREATE_INDEX=true to create a BAM index when writing a coordinate-sorted BAM file
		## MAX_RECORDS_IN_RAM= rule of thumb for reads ¬100bp, 250000 by GB of RAM given to -Xmx
		echo "	COMMAND: java -Xmx8g -jar $picarddir/SortSam.jar SORT_ORDER=coordinate INPUT=$samdir/${sample}_bwa-mem-P-M.sam OUTPUT=$bamdir/${sample}.sorted.bam MAX_RECORDS_IN_RAM=2000000"
		time java -Xmx8g -jar $picarddir/SortSam.jar SORT_ORDER=coordinate INPUT=$samdir/${sample}_bwa-mem-P-M.sam OUTPUT=$bamdir/${sample}.sorted.bam MAX_RECORDS_IN_RAM=2000000
	
	
	#b#-----------------------------------------
		## Add read groups to bam files
		## run picard AddOrReplaceReadGroups
		## RGLB=Read Group Library
		## RGPL=Read Group platform (e.g. illumina, solid)
		## RGPU=Read Group platform unit (eg. run barcode)
		## RGSM=Read Group sample name
		## RGCN=Read Group sequencing center name 
		echo -e "\t#-----# Add read groups to bam files"
		echo -e "\tRun picard/AddOrReplaceReadGroups.jar for: "$sample
		
		echo "	COMMAND: java -Xmx8g -jar $picarddir/AddOrReplaceReadGroups.jar RGLB=unknown RGPL=ILLUMINA RGPU=unknown RGSM=${sample} RGCN=${seqcenter} INPUT=$bamdir/${sample}.sorted.bam OUTPUT=$bamdir/${sample}.sorted.withRG.bam"
		time java -Xmx8g -jar $picarddir/AddOrReplaceReadGroups.jar RGLB=unknown RGPL=ILLUMINA RGPU=unknown RGSM=${sample} RGCN=${seqcenter} INPUT=$bamdir/${sample}.sorted.bam OUTPUT=$bamdir/${sample}.sorted.withRG.bam
	
				
	
	#c#-----------------------------------------
		## Build Index for bam file
		echo -e "\t#-----# Build Index for bam file"
		echo -e "\tRun picard/BuildBamIndex.jar for: "$sample	
		echo "	COMMAND: java -Xmx8g -jar $picarddir/BuildBamIndex.jar INPUT=$bamdir/$sample.sorted.withRG.bam"
		time java -Xmx8g -jar $picarddir/BuildBamIndex.jar INPUT=$bamdir/$sample.sorted.withRG.bam
		
fi
