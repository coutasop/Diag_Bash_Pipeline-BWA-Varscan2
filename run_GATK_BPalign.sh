###--------------------------------------------------------------------------------------------###
###     Realignement and Base Quality Score Recalibration according to GATK Best Practices     ###
###--------------------------------------------------------------------------------------------###


#-a-# Perform realignment on targeted intervals
	#-a1# Create targeted intervals with bam file for realignment
	echo -e "\t#-----# Create targeted intervals with bam file for realignment"
	echo -e "\tCOMMAND: time java -Xmx16g -jar $gatkdir/GenomeAnalysisTK.jar -T RealignerTargetCreator -R $refdir/$myref -L $refdir/$targets -nt $maxthreads -I $bamdir/$sample.sorted.withRG.bam -o $scriptdir/$sample-target_intervals.list -known $refdir/$mills -known $refdir/$kGindels"
	time java -Xmx16g -jar $gatkdir/GenomeAnalysisTK.jar -T RealignerTargetCreator -R $refdir/$myref -L $refdir/$targets -nt $maxthreads -I $bamdir/$sample.sorted.withRG.bam -o $scriptdir/$sample-target_intervals.list -known $refdir/$mills -known $refdir/$kGindels
	#-a2# do the realignment on targeted intervals
	echo -e "\t#-----# realignment on targeted intervals"
	echo -e "\tCOMMAND: time java -Xmx16g -jar $gatkdir/GenomeAnalysisTK.jar -T IndelRealigner -R $refdir/$myref -I $bamdir/$sample.sorted.withRG.bam -targetIntervals $outdir/target_intervals.list -known $refdir/$mills -known $refdir/$kGindels -o $bamdir/$sample.sorted.withRG.real.bam"
	time java -Xmx16g -jar $gatkdir/GenomeAnalysisTK.jar -T IndelRealigner -R $refdir/$myref -I $bamdir/$sample.sorted.withRG.bam -targetIntervals $scriptdir/$sample-target_intervals.list -known $refdir/$mills -known $refdir/$kGindels -o $bamdir/$sample.sorted.withRG.real.bam 


#-b-# Perform Base Quality Score Recalibration (BQSR)
	## Analyse patterns of covariation in the sequence dataset
	echo -e "\t#-----# Perform Base Quality Score Recalibration (BQSR)"
	echo -e "\tCOMMAND: time java -Xmx16g -jar $gatkdir/GenomeAnalysisTK.jar -T BaseRecalibrator -nct $maxthreads -R $refdir/$myref -I $bamdir/$sample.sorted.withRG.real.bam -knownSites $refdir/$dbsnp -knownSites $refdir/$mills -knownSites $refdir/$kGindels -o $scriptdir/$sample.BQSR.table "
	time java -Xmx16g -jar $gatkdir/GenomeAnalysisTK.jar -T BaseRecalibrator -nct $maxthreads -R $refdir/$myref -I $bamdir/$sample.sorted.withRG.real.bam -knownSites $refdir/$dbsnp -knownSites $refdir/$mills -knownSites $refdir/$kGindels -o $scriptdir/$sample.BQSR.table 


#-c-# Apply recalibration to sequence data Pourrait demander jusqu'a 8 cpu aussi ici.
	echo -e "\t#-----# Apply recalibration to sequence data"
	echo -e "\tCOMMAND: time java -Xmx16g -jar $gatkdir/GenomeAnalysisTK.jar -T PrintReads -nct $maxthreads -R $refdir/$myref -I $bamdir/$sample.sorted.withRG.real.bam -BQSR $script/$sample.BQSR.table -o $bamdir/$sample.sorted.withRG.real.BQSR.bam"
	time java -Xmx16g -jar $gatkdir/GenomeAnalysisTK.jar -T PrintReads -nct $maxthreads -R $refdir/$myref -I $bamdir/$sample.sorted.withRG.real.bam -BQSR $scriptdir/$sample.BQSR.table -o $bamdir/$sample.sorted.withRG.real.BQSR.bam



#-d-# Nettoyage des bam temporaires
	echo -e "\t#-----# Nettoyage des bam temporaires"
	if [ -f $bamdir/$sample.sorted.withRG.real.BQSR.bam ]
	then
		echo -e "\tCOMMAND:"
		echo -e	"\t rm $bamdir/$sample.sorted.bam"
		echo -e	"\t rm $bamdir/$sample.sorted.withRG.bam "
		echo -e	"\t rm $bamdir/$sample.sorted.withRG.bai "
		echo -e	"\t rm $bamdir/$sample.sorted.withRG.real.bam "
		echo -e	"\t rm $bamdir/$sample.sorted.withRG.real.bai "
		rm $bamdir/$sample.sorted.bam 
		rm $bamdir/$sample.sorted.withRG.bam 
		rm $bamdir/$sample.sorted.withRG.bai 
		rm $bamdir/$sample.sorted.withRG.real.bam 
		rm $bamdir/$sample.sorted.withRG.real.bai
	fi

