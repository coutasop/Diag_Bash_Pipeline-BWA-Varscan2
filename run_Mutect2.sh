#!/bin/bash
#
# Sophie COUTANT
# 22/06/2015

#Pour le matched normal
#PICARD MergeSamFile pour fusionner un bam témoin.
#java -jar /opt/PICARD/MergeSamFiles.jar `cat bam.list` O=PoolNorm.bam USE_THREADING=True
#Ou
#java -jar /opt/PICARD/MergeSamFiles.jar I=bam1.bam I=bam2.bam ... I=bamN.bam O=PoolNorm.bam USE_THREADING=True

# usage
function usage
{
	echo "#------------------------------------------------------------------------------------------------------------------------------------------------------------#"
	echo "# Ce script permet le lancement du variant caller Somatic Mutect2                                                                                           #"
	echo "# Etape:                                                                                                                                                     #"
	echo "# 1- Lancer Mutect2                                                                                                                                         #"
	echo "# 2- Annoter les variants avec alamutHT                                                                                                                      #"
	echo "#------------------------------------------------------------------------------------------------------------------------------------------------------------#"
	echo " "
	echo "USAGE: run_Mutect2.sh -runFold <dir> -bamDir <dir> -ref <file> [-norm <file>] -outDirVCF <dir> outDirANN <dir> -gatk <dir> -alamutBatchPath <dir>" 
	echo "	-runFold <path to the run folder>"
	echo "	-bamDir <path to the Bam folder relatively to runFolder>"
	echo "	-ref <path to the reference genome file>"
	echo "	-dbsnp <path to the dbSNP VCF file>"
	echo "	-cosmic <path to the Cosmic VCF file>"
	echo "	-norm [optional] <path to the normal bam file>"
	echo "	-outDirVCF <path to vcf outpur folder relativelt to runFolder>"
	echo "	-outDirANN <path to ann outpur folder relativelt to runFolder>"
	echo "	-gatk <path to the gatk tool folder>"
	echo "	-alamutBatchPath <path to the alamutBatch tool folder>"
	echo "EXAMPLE: "
	echo -e "\nREQUIREMENT: GATK 3.5 and AlamutHT doivent etre installe"
	echo " "
}

# get the arguments of the command line
if [ $# -lt 18 ]; then
	usage
	exit
else
	while [ "$1" != "" ]; do
	    case $1 in
		-runFold | --runFold )         shift
			if [ "$1" != "" ]; then
				#Run folderPath path
				runFold=$1
			else
				usage
				exit
			fi
						;;
		-bamDir | --bamDir )         shift
			if [ "$1" != "" ]; then
				bamDir=$1
			else
				usage
				exit
			fi
						;;
		-ref | --ref )         shift
			if [ "$1" != "" ]; then
				ref=$1
			else
				usage
				exit
			fi
						;;	
		-dbsnp | --dbsnp )         shift
			if [ "$1" != "" ]; then
				dbsnp=$1
			else
				usage
				exit
			fi
						;;	
		-cosmic | --cosmic )         shift
			if [ "$1" != "" ]; then
				cosmic=$1
			else
				usage
				exit
			fi
						;;	
		-norm | --norm )         shift
			if [ "$1" != "" ]; then
				norm=$1
			else
				usage
				exit
			fi
						;;
		-outDirVCF | --outDirVCF )         shift
			if [ "$1" != "" ]; then
				outDirVCF=$1
			else
				usage
				exit
			fi
						;;	
		-outDirANN | --outDirANN )         shift
			if [ "$1" != "" ]; then
				outDirANN=$1
			else
				usage
				exit
			fi
						;;	
		-gatk | --gatk )    	shift
					if [ "$1" != "" ]; then
						gatk=$1
					else
						usage
						exit
					fi
						;;
		-alamutBatchPath | --alamutBatchPath )    	shift
					if [ "$1" != "" ]; then
						alamutBatchPath=$1
					else
						usage
						exit
					fi
						;;						
	    esac
	    shift
	done
fi

maxcore=8
refdir="/storage/crihan-msa/RunsPlateforme/Reference"
myref="Homo_sapiens/hg19/human_g1k_v37.fasta"
dbsnp="dbsnp_137.b37.vcf"
cosmic="b37_cosmic_v54_120711.vcf"
targets="/storage/crihan-msa/RunsPlateforme/Reference/Amplicon/INCA_Multiplicom/IFU448_Tumor_Hotspot_MASTRPlus_BED_v150221_ssChr_TARGET.bed"

echo -e "\tTIME: BEGIN RUN MUTECT2".`date`

if [ -d $outDirVCF ]; 
then
	echo -e "\n\tOUTPUT FOLDER: $outDirVCF (folder already exist)" 
else
	mkdir -p $outDirVCF
	echo -e "\n\tOUTPUT FOLDER : $outDirVCF (folder created)"
fi
if [ -d $outDirANN ]; 
then
	echo -e "\n\tOUTPUT FOLDER: $outDirANN (folder already exist)" 
else
	mkdir -p $outDirANN
	echo -e "\n\tOUTPUT FOLDER : $outDirANN (folder created)"
fi

for file in `ls $bamDir | grep "BQSR.bam$"`;
do
	sample=$(echo $file | awk -F"." '{print $1}')
	echo -e "\n\tSample: $sample"; 

	#2 cas distincts : lancement paire sample/pool ou tum/norm
	if [ "$norm" != "" ];
	then
		#sample/pool
		echo -e "\n\tTumor/Normal not yet implemented - STOP SCRIPT"
		exit
	else
		
		echo "Mutect2 will analyse only one type of input (mozaic in normal sample OR somatic in tumor sample)"
		echo -e "\nCOMMAND: java -jar $gatk/GenomeAnalysisTK.jar -T MuTect2 -nct $maxcore -R $refdir/$myref -I:tumor $bamDir/$file --dbsnp $refdir/$dbsnp --cosmic $refdir/$cosmic -L $targets -o $outDirVCF/"$sample"_Mutect2.vcf"
		#~ java -jar $gatk/GenomeAnalysisTK.jar -T MuTect2 -nct $maxcore -R $refdir/$myref -I:tumor $bamDir/$file --dbsnp $refdir/$dbsnp --cosmic $refdir/$cosmic -L $targets -o $outDirVCF"/"$sample"_Mutect2.vcf"
	fi
	
	#AlamutHT
	echo -e "\nAlamut-batch - $sample"
	$alamutBatchPath/alamut-batch --in $outDirVCF/$sample"_Mutect2.vcf" --ann $outDirANN/$sample"_Mutect2.ann" --unann $outDirANN/$sample"_Mutect2.unann" --alltrans --nonnsplice --nogenesplicer --ssIntronicRange 2 --outputVCFFilter --outputVCFQuality --outputVCFInfo AC AF AN DP SS --outputVCFGenotypeData GT AD DP DP4 FREQ GQ RD --outputEmptyValuesAs .
done

echo -e "\n\tTIME: END RUN MUTECT2".`date`;


#~ sed -e s/"\/-"/","/ $outDirVCF/$sample"_VarScan2.vcf.snp" > $outDirVCF/$sample"_VarScan2.vcf.snp.tmp1"
	#~ sed -e s/"\/[+][ACGT]*"/""/ $outDirVCF/$sample"_VarScan2.vcf.snp.tmp1" > $outDirVCF/$sample"_VarScan2.vcf.snp.tmp2"
	#~ sed -e '/\/[ACGT]/s/\//,/' $outDirVCF/$sample"_VarScan2.vcf.snp.tmp2" > $outDirVCF/$sample"_VarScan2.vcf.snp.tmp3"
	#~ sed -e '/\,[ACGT]\+/s/,[ACGT]//' $outDirVCF/$sample"_VarScan2.vcf.snp.tmp3" > $outDirVCF/$sample"_VarScan2.vcf.snp.tmp4"
	
#outil BBMap pour générer des randoms reads
#/opt/bbmap/randomreads.sh ref=/storage/crihan-msa/RunsPlateforme/Reference/Amplicon/EGFR_GRGh37.fa length=151 illuminanames=true reads=1000000 paired=true maxq=36 midq=32 minq=28 adderrors=true
#puis : BWA mem, picard sort et samtools index
