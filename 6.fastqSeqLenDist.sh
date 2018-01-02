#! /bin/sh

# Change the paths as necessary
# DATA_DIR is the location of raw fastq files
# PROJECT_DIR is the main directory for this analysis
# ALL_FILE_LIST is the list of renamed sample fastq files

export PROJECT_DIR="/home/smalkaram/Projects/alwayMRNA20170516143625"
export DATA_DIR="/home/smalkaram/Projects/alwayMRNA20170516143625/raw_data/file_links"
export ALL_FILE_LIST="/home/smalkaram/Projects/alwayMRNA20170516143625/ALL_FILE_LIST"

# Run this by supplying a trimmed fastq file, to get the distribution of read lengths in that sample
zcat $1 | paste  - - - - |  awk 'BEGIN{FS="\t"}{print(length($2));}' | sort | uniq -c | awk '{print($2, $1);}'
