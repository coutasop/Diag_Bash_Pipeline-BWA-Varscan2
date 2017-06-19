#!/bin/bash

#Script pour remplacer les INFO vcf en tabulation
opt/pipeline_NGS/Pipeline-Somatique/run_replaceOtherInfoByTabs.sh -vcfDir /storage/crihan-msa/RunsPlateforme/NextSeq/160817_NB501076_0020_AH7KVMAFXX/BWA-GATK-VarScan2_Run20-PanelNormand-NS8/VCF -multiannoDir /storage/crihan-msa/RunsPlateforme/NextSeq/160817_NB501076_0020_AH7KVMAFXX/BWA-GATK-VarScan2_Run20-PanelNormand-NS8/ANN -o /storage/crihan-msa/RunsPlateforme/NextSeq/160817_NB501076_0020_AH7KVMAFXX/BWA-GATK-VarScan2_Run20-PanelNormand-NS8/ANN -R /storage/crihan-msa/RunsPlateforme/Reference/Homo_sapiens/hg19/human_g1k_v37.fasta -gatkPath /opt/GenomeAnalysisTK-3.4-46/


#Filter Gene
for s in `ls *.csv`; do echo $s; head -n 1 $s > $s"_geneListOnly.csv"; grep -w -f geneList.txt $s >> $s"_geneListOnly.csv"; done

#Filter Freq
for f in `ls *.csv`; do echo $f; head -n 1 $f > $f.freqFiltered; sed -e 's/%//g' $f | awk -F"\\t" ' OFS="\t" { gsub(",",".",$83); gsub(",",".",$77); if ( ( $77 <= 10 ) && ( $83 >= 5 ) )  print }' >> $f.freqFiltered; done
