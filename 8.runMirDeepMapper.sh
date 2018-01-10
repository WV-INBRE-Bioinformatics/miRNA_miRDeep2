#! /bin/sh
# Change the paths as necessary
# DATA_DIR is the location of raw fastq files
# PROJECT_DIR is the main directory for this analysis
# ALL_FILE_LIST is the list of renamed sample fastq files

export PROJECT_DIR="/home/smalkaram/Projects/alwayMRNA20170516143625"
export DATA_DIR="/home/smalkaram/Projects/alwayMRNA20170516143625/raw_data/file_links"
export ALL_FILE_LIST="/home/smalkaram/Projects/alwayMRNA20170516143625/ALL_FILE_LIST"

module load bio/processing/Fastqc/0.11.5
module load pkg/perl5/5.22.1
module load pkg/anaconda2/4.3.1
# I have used mireep version 2.0.0.8. Have modified the mapper.pl program (mapperMOD.pl is included in this directory)
module load bio/alignment/mirdeep/2.0.0.8
#module load bio/processing/trim_galore/0.4.4

IN="$DATA_DIR"
# Change the path as needed
OUT="/home/smalkaram/Projects/alwayMIRNA20170612201235/TRIM/MIRDEEP_MAPPER"
MINLEN=16
MULTIPLE=5
# Change the path as needed
BOWTIE_INDEX="/data/db/BowtieIndexes/GRCm38p5/GRCm38p5"
MIRDEEP_MAPPER_OPTIONS=" -e -h -d -i -j -m -p $BOWTIE_INDEX -r $MULTIPLE -v -n "

mapperMOD.pl config.txt $MIRDEEP_MAPPER_OPTIONS -s reads.fa -t reads_vs_genome.arf
# Sridhar A Malkaram (smalkaram@wvstateu.edu)
# Last modified on: 12/30/2017
