#!/bin/bash
#
# Sophie
# LAST UPDATE : 01/10/2015
#
#------------------------------------------------------------------------------------------------------------------------------------------------------------#
# Ce script permet le lancement automatique du pipeline BEST PRACTICE de GATK + VARSCAN                                                                      #
# Etape:                                                                                                                                                     #
# 0- Donnée ayant une structure CASAVA : Copier les FASTQ issus du démultipléxage                                                                            #
# 1- Lancer BWA                                                                                                                                              #
# 2- Lancer Picard                                                                                                                                           #
# 3- Lancer GATK realign et BQSR                                                                                                                             #
# 4- Lancer VarScan2 variant calling                                                                                                                         #
# 5- Lancer AlamutBatch Annotation                                                                                                                           #
# 6- Lancer Quality                                                                                                                                          #
#------------------------------------------------------------------------------------------------------------------------------------------------------------#

#----------------------------------------------------------------------#
#-------------------------USAGE AND PARAMETERS-------------------------#
#----------------------------------------------------------------------#

# usage
function usage
{
	echo "#------------------------------------------------------------------------------------------------------------------------------------------------------------#"
	echo "# Ce script permet le lancement automatique du pipeline BEST PRACTICE de GATK + VARSCAN                                                                      #"
	echo "# Etape:                                                                                                                                                     #"
	echo "# 0- Donnée ayant une structure CASAVA : Copier les FASTQ issus du démultipléxage                                                                            #"
	echo "# 1- Lancer BWA                                                                                                                                              #"
	echo "# 2- Lancer Picard                                                                                                                                           #"
	echo "# 3- Lancer GATK realign et BQSR                                                                                                                             #"
	echo "# 4- Lancer VarScan2 variant calling                                                                                                                         #"
	echo "# 5- Lancer AlamutBatch Annotation                                                                                                                           #"
	echo "# 6- Lancer Quality                                                                                                                                          #"
	echo "#------------------------------------------------------------------------------------------------------------------------------------------------------------#"
	echo " "
	echo "USAGE: runMaster_BWA-GATK-VarScan2_Somatique.sh -s <file>" 
	echo "	-s <path to settings file>"
	echo "EXAMPLE: ./runMaster_BWA-GATK-VarScan2_Somatique -s path/to/settings.txt"
	echo -e "\nREQUIREMENT: BWA / PICARD / GATK / VarScan2 / Alamut Batch / JAVA7 must be installed"
	echo -e "\tSettings for the programs and data must be set the setting file provided as an argument\n"
	echo " "
}

# get the arguments of the command line
if [ $# -lt 2 ]; then
	usage
	exit
else
	while [ "$1" != "" ]; do
	    case $1 in
		-s | --settings )    	shift
					if [ "$1" != "" ]; then
						settingsFile=$1
					else
						usage
						exit
					fi
		                        ;;     
	    esac
	    shift
	done
fi

echo "#------------------------------------------------------------------------------------------------------------------------------------------------------------#"
echo "# Ce script permet le lancement automatique du pipeline BEST PRACTICE de GATK + VARSCAN                                                                      #"
echo "# Etape:                                                                                                                                                     #"
echo "# 0- Donnée ayant une structure CASAVA : Copier les FASTQ issus du démultipléxage                                                                            #"
echo "# 1- BWA                                                                                                                                                     #"
echo "# 2- Picard                                                                                                                                                  #"
echo "# 3- GATK realign et BQSR                                                                                                                                    #"
echo "# 4- Lancer VarScan2 variant calling                                                                                                                         #"
echo "# 5- Lancer AlamutBatch Annotation                                                                                                                           #"
echo "#------------------------------------------------------------------------------------------------------------------------------------------------------------#"

echo -e "\n#----------------------------PIPELINE BEGIN------------------------------#"
date

#----------------------------------------------------------------------#
#-----------------READ SETTINGS AND OUTPUT FOLDER CHECK----------------#
#----------------------------------------------------------------------#

#Get the paths and names of all the scripts and datas that will be launched
scriptPath=$(dirname $0) #Get the folder path of this script
source $settingsFile	 #Import the settings
GATKversion=$(java -jar $gatkdir/GenomeAnalysisTK.jar -version);


#Test if the outDIRs directory exists, if no, create them
# -- outdir -- fastqdir -- samdir -- bamdir -- vcfdir -- scriptdir
if [ -d $outdir ]; then
 echo -e "\n\tOUTPUT FOLDER: $outdir (folder already exist)" 
else
 mkdir -p $outdir
 echo -e "\n\tOUTPUT FOLDER : $outdir (folder created)"
fi
if [ -d $fastqdir ]; then
 echo -e "\n\tOUTPUT FOLDER: $fastqdir (folder already exist)" 
else
 mkdir -p $fastqdir 
 echo -e "\n\tOUTPUT FOLDER : $fastqdir (folder created)"
fi
if [ -d $samdir ]; then
 echo -e "\n\tOUTPUT FOLDER: $samdir (folder already exist)" 
else
 mkdir -p $samdir 
 echo -e "\n\tOUTPUT FOLDER : $samdir (folder created)"
fi
if [ -d $bamdir ]; then
 echo -e "\n\tOUTPUT FOLDER: $bamdir (folder already exist)" 
else
 mkdir -p $bamdir 
 echo -e "\n\tOUTPUT FOLDER : $bamdir (folder created)"
fi
if [ -d $vcfdir ]; then
 echo -e "\n\tOUTPUT FOLDER: $vcfdir (folder already exist)" 
else
 mkdir -p $vcfdir 
 echo -e "\n\tOUTPUT FOLDER : $vcfdir (folder created)"
fi
if [ -d $scriptdir ]; then
 echo -e "\n\tOUTPUT FOLDER: $scriptdir (folder already exist)" 
else
 mkdir -p $scriptdir 
 echo -e "\n\tOUTPUT FOLDER : $scriptdir (folder created)"
fi
if [ -d $anndir ]; then
 echo -e "\n\tOUTPUT FOLDER: $anndir (folder already exist)" 
else
 mkdir -p $anndir 
 echo -e "\n\tOUTPUT FOLDER : $anndir (folder created)"
fi
if [ -d $reportDir ]; then
 echo -e "\n\tOUTPUT FOLDER: $reportDir (folder already exist)" 
else
 mkdir -p $reportDir 
 echo -e "\n\tOUTPUT FOLDER : $reportDir (folder created)"
fi
sudo chmod -R 777 $outdir

#----------------------------------------------------------------------#
#---------------------------PIPELINE BEGIN-----------------------------#
#----------------------------------------------------------------------#

#--0--#
#Si Run issus du GAIIx et Data rangé selon architecture CASAVA
#Copie les FASTQ issus du démultiplexage et créé la liste des échantillons à annalyser
if [ -z ${runFolder+x} ]; 
then #Si pas CASAVA
	echo -e "\n#--0--#";
	echo -e "\tData not organised with a CASAVA Struture";
else #Si CASAVA
	echo -e "\n#--0--#";
	echo -e "\tA CASAVA runFolder is set : Copy FASTQ"; 
	echo -e "\tCOMMAND: time source $pipedir/run_cpFASTQ.sh";
	time source $pipedir/run_cpFASTQ.sh #source permet de lancer un script dans le même bash
fi

#----------------------------------------------------------------------#
#--A--#PER SAMPLE ANALYSIS 
echo -e "\n#--A--#PER SAMPLE ANALYSIS"
	
	countsample=0;
	while read sample  
	do 
		export sample
		countsample=$(($countsample + 1))
		echo -e "\n#-----#SAMPLE $countsample: $sample"
		#--1--# Alignement
		if [ $doALN = "y" ]; 
		then  
			echo -e "\n\t#--1--# Alignement";
			echo -e "\tCOMMAND: time bash $pipedir/run_bwa.sh";
			time bash $pipedir/run_bwa.sh
		else
			echo -e "\n\tSKIP: #--1--# Alignement"
		fi

		#--2--# Clean Sam/Bam files with Picard
		if [ $doPIC = "y" ]; 
		then  
			echo -e "\n\t#--2--# Picard";
			echo -e "\tCOMMAND: time bash $pipedir/run_picard.sh";
			time bash $pipedir/run_picard.sh
		else
			echo -e "\n\tSKIP: #--2--# Picard"
		fi

		#--3--# Perform Realignment and BQSR according to GATK BP
		if [ $doREALN = "y" ]; 
		then  
			echo -e "\n\t#--3--# GATK REALIGN";
			echo -e "\tCOMMAND: time bash $pipedir/run_GATK_BPalign.sh";
			time bash $pipedir/run_GATK_BPalign.sh
		else
			echo -e "\n\tSKIP: #--3--# GATK REALIGN"
		fi
		
	done < $listIndv
	export countsample

#----------------------------------------------------------------------#
#VarScan2
if [ $doVC = "y" ]; 
then
	echo -e "\n\t#--B--# VARSCAN2 SOMATIC VARIANT CALLING";
	echo -e "\tCOMAND: $pipedir/run_Varscan2.sh -runFold $runFolder -bamDir $bamdir -ref $refdir/$myref -norm $normBamFile -outDirVCF $vcfdir -outDirANN $anndir -varscan $varscandir -gatk $gatkdir -alamutBatchPath $alamutHTdir"
	$pipedir/run_Varscan2.sh -runFold $runFolder -bamDir $bamdir -ref $refdir/$myref -norm $normBamFile -outDirVCF $vcfdir -outDirANN $anndir -varscan $varscandir -gatk $gatkdir -alamutBatchPath $alamutHTdir
fi

if [ $doANN = "y" ];
then
	echo -e "\n\t#--C--# ALAMUT BATCH";
	for file in `ls $vcfdir | grep "_VarScan2.vcf$"`;
	do
		sample=$(echo $file | awk -F"_" '{print $1}')
		echo -e "\n\tSample: $sample"; 
		#AlamutHT
			##INFO=<ID=AC,Number=A,Type=Integer,Description="Allele count in genotypes, for each ALT allele, in the same order as listed">
			##INFO=<ID=AF,Number=A,Type=Float,Description="Allele Frequency, for each ALT allele, in the same order as listed">
			##INFO=<ID=AN,Number=1,Type=Integer,Description="Total number of alleles in called genotypes">
			##INFO=<ID=DP,Number=1,Type=Integer,Description="Total depth of quality bases">
			##INFO=<ID=SS,Number=1,Type=String,Description="Somatic status of variant (0=Reference,1=Germline,2=Somatic,3=LOH, or 5=Unknown)">
			##FORMAT=<ID=GT,Number=1,Type=String,Description="Genotype">	
			##FORMAT=<ID=AD,Number=.,Type=Integer,Description="Allelic depths for the ref and alt alleles in the order listed">
			##FORMAT=<ID=DP,Number=1,Type=Integer,Description="Read Depth">
			##FORMAT=<ID=DP4,Number=1,Type=String,Description="Strand read counts: ref/fwd, ref/rev, var/fwd, var/rev">
			##FORMAT=<ID=FREQ,Number=1,Type=String,Description="Variant allele frequency">
			##FORMAT=<ID=GQ,Number=1,Type=Integer,Description="Genotype Quality">
			##FORMAT=<ID=RD,Number=1,Type=Integer,Description="Depth of reference-supporting bases (reads1)">
		echo -e "\n\t#--1--# Alamut-batch - $sample"
		echo -e "\tCOMAND: $alamutHTdir/alamut-batch --in "$vcfdir"/"$sample"_VarScan2.vcf" --ann $anndir"/"$sample"_VarScan2.ann --unann "$anndir"/"$sample"_VarScan2.unann --alltrans --ssIntronicRange 2 --outputVCFFilter --outputVCFQuality --outputVCFInfo AC AF AN DP SS --outputVCFGenotypeData GT AD DP DP4 FREQ GQ RD --outputEmptyValuesAs ."
		$alamutHTdir/alamut-batch --in $vcfdir/$sample"_VarScan2.vcf" --ann $anndir/$sample"_VarScan2.ann" --unann $anndir/$sample"_VarScan2.unann" --alltrans --ssIntronicRange 2 --outputVCFFilter --outputVCFQuality --outputVCFInfo AC AF AN DP SS --outputVCFGenotypeData GT AD DP DP4 FREQ GQ RD --outputEmptyValuesAs .
	done
	
		echo -e "\n\t#--2--# Extract"
		echo -e "\tCOMAND: $pipedir/run_extract.sh -i $anndir -o $extractdir -nm "$refdir"/"$nmList" -bt $bedtoolsdir -bed $refdir/$targetsDiagExtract"	
		$pipedir/run_extract.sh -i $anndir -o $extractdir -nm $refdir"/"$nmList -bt $bedtoolsdir -bed $refdir/$targetsDiagExtract
		
		ficheAnnExtract=$(echo `ls $extractdir | grep "ann-extract" | head -n 1`) 
		header=$(head -n 1 $extractdir/$ficheAnnExtract)
		echo "sample	$header" > $extractdir"/Varscan2-Results-all-sample_"$project.csv
		
		grep -f $refdir/$nmList $extractdir/*.ann-extract >> $extractdir"/Varscan2-Results-all-sample_"$project.csv
		sed -i "s|$extractdir/||g" $extractdir"/Varscan2-Results-all-sample_"$project".csv" 
		sed -i "s|_VarScan2-50.ann-extract:|\t|g" $extractdir"/Varscan2-Results-all-sample_"$project".csv" 

		#rename les .bai en .bam.bai (pour les visualisateurs)
		echo -e "\n\t#--3--# Rename .bai in .bam.bai"
		rename .BQSR.bai .BQSR.bam.bai $bamdir/*.BQSR.bai	
fi

if [ $doQUAL = "y" ];
then
		echo -e "\n\t#--D--# Quality"		
		echo -e "\n\t#--1--# Compute Depth"
		echo -e "\tCOMAND: $pipedir/run_depthDiag.sh -i $bamdir -o $outdir/DEPTH -bed $refdir/$targets"
		$pipedir/run_depthDiagGATK.sh -i $bamdir -o $outdir/DEPTH -bed $refdir/$targets
		
		echo -e "\n\t#--2--# Compute min and mean Depth (QualityGATK.txt)"
		echo -e "\tCOMAND: $pipedir/run_prepareRapportQualGATK_v2.sh -i $outdir/DEPTH -o $outdir -bed $refdir/$targetsDiag"
		$pipedir/run_prepareRapportQualGATK_v2.sh -i $outdir/DEPTH -o $outdir -bed $refdir/$targetsDiag

fi

if [ $doREPORT = "y" ];
then
	echo -e "\n\tGenerate Quality xls repport"
	echo -e "\t  COMMAND: java -jar $pipedir/Rapport_QualPatient_GATK.jar $runFolder/ $numRun $numRunDiag $opSeq $refdir/$targetsDiag $outdir/QualityGATK.txt $refdir/$geneNmList $extractdir $reportDir $feuilleRouteFile"
	java -jar $pipedir/Rapport_QualPatient_GATK.jar $runFolder/ $numRun $numRunDiag $opSeq $refdir/$targetsDiag $outdir/QualityGATK.txt $refdir/$geneNmList $extractdir $reportDir $feuilleRouteFile

	echo -e "\n\tGenerate Variants xls repport"
	echo -e "\t  COMMAND: java -jar $pipedir/Rapport_Variants_VarScan2.jar $runFolder/ $numRun $numRunDiag $opSeq $feuilleRouteFile $refdir/$geneNmList $refdir/$polList $extractdir $reportDir"
	java -jar $pipedir/Rapport_Variants_VarScan2.jar $runFolder/ $numRun $numRunDiag $opSeq $feuilleRouteFile $refdir/$geneNmList $refdir/$polList $extractdir $reportDir
fi

date
echo -e "\n#----------------------------PIPELINE END------------------------------#";
		
#----------------------------------------------------------------------#
#----------------------------PIPELINE END------------------------------#
#----------------------------------------------------------------------#
