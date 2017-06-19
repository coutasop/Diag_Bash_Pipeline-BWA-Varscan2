#!/bin/bash

#Construit la liste des individus au fur et à mesure
if [ -e "$scriptdir/listePatients.txt" ]; 
then
	rm $scriptdir/listePatients.txt
	touch $scriptdir/listePatients.txt
else
	touch $scriptdir/listePatients.txt
fi
export listIndv=$scriptdir/listePatients.txt


#Avant de lancer les scripts il faut attendre que le run soit copié sur la baie de travail
	#Fichier à verifier pour savoir si la copie est terminée
	copy="copy.completed"
	#while the copy file does not exist continue to check
	while [ ! -f $runFolder/$copy ]; 
	do
		echo -e "\t".`date`.": WAIT 15min : File $runFolder/$copy doesn't exists"
		sleep 15m
	done
		

#Parcourir toutes les Lanes
for File in `ls $unaligneddir/ | grep "R1_001.fastq.gz"`
do
	#extrait le 1er champs du nom du fichier (en prenant '_' comme séparateur)
	#il s'agit du numero d'individu
	echo $File
	ind=$(echo $File | awk -F"_" '{print $1}')
	echo $ind >> $listIndv

	#Pour Chaque READ 
	fastq=$File
	S=$(echo $fastq | awk -F"_" '{print $2}')
	lane=$(echo $fastq | awk -F"_" '{print $3}')

	if [ -e $fastqdir"/"$ind"_R1.fastq.gz" ]; #If file already exist
	then
		echo -e "\t\t File already in ouput folder -> ignore copy"
	else #If file does not already exist
		echo -e "\t\t#-----# COPY FASTQ"
		echo -e "\t\tCOMMAND: cp ${unaligneddir}/${ind}_${S}_${lane}_R1_001.fastq.gz ${fastqdir}/${ind}_R1.fastq.gz"
		cp $unaligneddir"/"$ind"_"$S"_"$lane"_R1_001.fastq.gz" $fastqdir"/"$ind"_R1.fastq.gz"
		echo -e "\t\tCOMMAND: cp ${unaligneddir}/${ind}_${S}_${lane}_R2_001.fastq.gz ${fastqdir}/${ind}_R2.fastq.gz"
		cp $unaligneddir"/"$ind"_"$S"_"$lane"_R2_001.fastq.gz" $fastqdir"/"$ind"_R2.fastq.gz"
	fi
done
