#!/bin/bash
# *** Change the paths as necessary
# DATA_DIR is the location of raw fastq files
# PROJECT_DIR is the main directory for this analysis
# ALL_FILE_LIST is the list of renamed sample fastq files
# Store the output to "getRGs.txt"

export PROJECT_DIR="/home/smalkaram/Projects/alwayMRNA20170516143625"
export DATA_DIR="/home/smalkaram/Projects/alwayMRNA20170516143625/raw_data/file_links"
export ALL_FILE_LIST="/home/smalkaram/Projects/alwayMRNA20170516143625/ALL_FILE_LIST"


for FILE in `cat $ALL_FILE_LIST | grep -v "_2.fastq.gz"`
do
	#WT_80W_CR_R2_S16_L1_1.fastq.gz

	A=`echo $FILE | sed 's/_1.fastq.gz//'`
	PU=`zcat $DATA_DIR/$FILE | head -1 | cut -d':' -f 3,4,10`
	ID=$A
	PARTS=( `echo $A | sed 's/_/ /g'` )
	TREATMENT=${PARTS[0]}
	TIME=${PARTS[1]}
	DIET=${PARTS[2]}
	REPLICATE=${PARTS[3]}
	LIB=${PARTS[3]}
	LANE=${PARTS[4]}
	LB=$TREATMENT"_"$TIME"_"$REPLICATE
	PL="ILLUMINA"
	CN="MUGenomicsCore"
	SM=$TREATMENT"_"$TIME"_"$DIET
	DS="$LANE"

	echo -e "$A\t@RG ID:$ID CN:$CN PU:$PU PL:$PL LB:$LB SM:$SM\n"
done
