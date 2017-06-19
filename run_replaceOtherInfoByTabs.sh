#----------------------------------------------------------------------#
#-------------------------USAGE AND PARAMETERS-------------------------#
#----------------------------------------------------------------------#

# usage
function usage
{
	echo "#------------------------------------------------------------------------------------------------------------------------------------------------------------#"
	echo "# Ce script permet de mettre en forme les champs suplémentaire VCF (INFO) en tabulation                                                                      #"
	echo "#------------------------------------------------------------------------------------------------------------------------------------------------------------#"
	echo " "
	echo "USAGE: runreplaceOtherInfoByTabs.sh -vcfDir <folder> -multiannoDir <Folder> -o <Folder> -R <file> -gatkPath <Folder>" 
	echo "	-vcfDir <file.vcf folder>"
	echo "	-multiannoDir <multianno.txt folder>"
	echo "	-o <output Folder>"
	echo "	-R <path to reference geneome file>"
	echo "	-gatkPath <path to GATK Folder>"
	echo "EXAMPLE: ./runreplaceOtherInfoByTabs.sh -vcfDir /storage/crihan-msa/RunsPlateforme/NextSeq/160817_NB501076_0020_AH7KVMAFXX/BWA-GATK-VarScan2_Run20-PanelNormand-NS8/VCF -multiannoDir /storage/crihan-msa/RunsPlateforme/NextSeq/160817_NB501076_0020_AH7KVMAFXX/BWA-GATK-VarScan2_Run20-PanelNormand-NS8/ANN -o /storage/crihan-msa/RunsPlateforme/NextSeq/160817_NB501076_0020_AH7KVMAFXX/BWA-GATK-VarScan2_Run20-PanelNormand-NS8/ANN -R /storage/crihan-msa/RunsPlateforme/Reference/Homo_sapiens/hg19/human_g1k_v37.fasta -gatkPath /opt/GenomeAnalysisTK-3.4-46/"
	echo -e "\nREQUIREMENT: GATK / JAVA7 must be installed"
	echo " "
}

# get the arguments of the command line
if [ $# -lt 10 ]; then
	usage
	exit
else
	while [ "$1" != "" ]; do
	    case $1 in
		-vcfDir | --vcfDir )    	shift
					if [ "$1" != "" ]; then
						vcfDir=$1
					else
						usage
						exit
					fi
		                        ;; 
		-multiannoDir | --multiannoDir )         shift
					if [ "$1" != "" ]; then
						multiannoDir=$1
					else
						usage
						exit
					fi
		                        ;;    
		-o | --ouput )         shift
					if [ "$1" != "" ]; then
						o=$1
					else
						usage
						exit
					fi
		                        ;;  
		-gatkPath | --gatkPath )         shift
					if [ "$1" != "" ]; then
						gatkPath=$1
					else
						usage
						exit
					fi
		                        ;;  
		-R | --multiannoDir )         shift
					if [ "$1" != "" ]; then
						refGenome=$1
					else
						usage
						exit
					fi
		                        ;;  
	    esac
	    shift
	done
fi

for vcf in `ls $vcfDir/*.vcf`
do
	#Récupérer le header correspondant au nom de colonne du fichier vcf de $fileName de départ
	echo "vcf: "$vcf

	fileName=${vcf%.*} #nom du fichier+Path sans sa dernière extension (ici: .vcf)
	sample=$(basename $vcf) #nom du fichier sans path et sans extention


	grep "#" $vcf > $multiannoDir/$sample.header
	#header="#CHROM	POS	ID	REF	ALT	QUAL	FILTER	INFO	FORMAT	$sample"
done



for multianno in `ls $multiannoDir/*multianno.txt`; 
do 

	fileName=${multianno%.*} #nom du fichier+Path sans sa dernière extension (ici: .txt)
	sample=$(basename $multianno) #nom du fichier sans path et sans extention
	echo "sample: "$sample
	path=$(dirname $multianno) #nom du path, sans le fichier
	headerFiletmp=${sample%.*}
	headerFile=${headerFiletmp%.*}
	echo "headerFile: "$headerFile
	#get Otherinfo column number;
	otherInfoNbCol=$(head -n 1 $multianno | awk '{ for(i;i<=NF;i++){ if ($i ~ /Otherinfo/) { print i } }}';)

	echo "multianno: "$multianno

	#Extraire toutes les colonnes avant OtherInfo et les coller dans un nouveau fichier 'multiannoOnly'
	#echo "cut -f1-$(($otherInfoNbCol-1)) $multianno > $fileNameOnly.txt"
	cut -f1-$(($otherInfoNbCol-1)) $multianno > $fileName"Only.txt"
	echo $fileName"Only.txt"

	#Extraire toutes les colonnes Otherinfo et les coller dans un nouveau fichier 'extract vcflike'
	#echo "cut -f$otherInfoNbCol- $multianno | sed -e 's/Otherinfo/'"$header"'/g' > $fileName.vcflike"
	header=$(cat $multiannoDir/$headerFile.vcf.header)
	cat $multiannoDir/$headerFile.vcf.header > $fileName".vcflike"
	cut -f$otherInfoNbCol- $multianno | sed -e 's/Otherinfo/''/g' | tail -n +2 >> $fileName".vcflike"
	echo $fileName".vcflike"

	#VCF2tabs VARSCAN2
	java -jar $gatkPath/GenomeAnalysisTK.jar -T VariantsToTable -V $fileName".vcflike" -o $fileName.table -F CHROM -F POS -F REF -F ALT -F QUAL -GF GT -GF AD -GF DP -GF DP4 -GF FREQ -GF RD -o --allowMissingData --showFiltered -R /storage/crihan-msa/RunsPlateforme/Reference/Homo_sapiens/hg19/human_g1k_v37.fasta

	#Paste
	paste  $fileName"Only.txt" $fileName.table > $fileName.csv

	#SuprFich TMP	
	rm $fileName".vcflike"
	rm $fileName".vcflike.idx"
	rm $fileName"Only.txt"
	rm $fileName".table"
	rm $multiannoDir/$headerFile.vcf.header

done




