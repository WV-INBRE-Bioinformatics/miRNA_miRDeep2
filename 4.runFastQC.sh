#! /bin/sh
# Change the paths as necessary
# DATA_DIR is the location of raw fastq files
# PROJECT_DIR is the main directory for this analysis
# ALL_FILE_LIST is the list of renamed sample fastq files

export PROJECT_DIR="/home/smalkaram/Projects/alwayMRNA20170516143625"
export DATA_DIR="/home/smalkaram/Projects/alwayMRNA20170516143625/raw_data/file_links"
export ALL_FILE_LIST="/home/smalkaram/Projects/alwayMRNA20170516143625/ALL_FILE_LIST"

# The following modules needed or have the programs in path and change the path in the calling script line
module load bio/processing/Fastqc/0.11.5
module load pkg/perl5/5.22.1

IN="$DATA_DIR"
# Change path accordingly
OUT="/home/smalkaram/Projects/alwayMIRNA20170612201235/QC/QC_FASTQC"

for FILE in `cat $ALL_FILE_LIST`
do
	BASE=`echo $FILE | sed 's/.fastq.gz//'`
	mkdir -p $OUT/$BASE	
	echo $BASE
	# Change path to fastqc as required
	# If not using cluster, remove the piped portion of the command
	echo "perl /data/bio/processing/Fastqc/0.11.5/fastqc $IN/$FILE --outdir=$OUT/$BASE --extract"  | qsub -V -l nodes=1:ppn=1 -q batch -d $OUT/$BASE -N $BASE
done

