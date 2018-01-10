#! /bin/sh

# *** Change the paths as necessary
# DATA_DIR is the location of raw fastq files
# PROJECT_DIR is the main directory for this analysis
# ALL_FILE_LIST is the list of renamed sample fastq files
# Module files represent the necessary software packages
# Either load equivalent moduels or put those programs in path

export PROJECT_DIR="/home/smalkaram/Projects/alwayMRNA20170516143625"
export DATA_DIR="/home/smalkaram/Projects/alwayMRNA20170516143625/raw_data/file_links"
export ALL_FILE_LIST="/home/smalkaram/Projects/alwayMRNA20170516143625/ALL_FILE_LIST"

module load bio/processing/Fastqc/0.11.5
module load pkg/perl5/5.22.1
module load pkg/anaconda2/4.3.1

# This script needs the presence of perl script 'quantify_all_mature_novel.pl',  for processing
module load bio/alignment/mirdeep/2.0.0.8
module load pkg/perl5/5.22.1

WD=`pwd`
# Change the output 
RESULT="/home/smalkaram/Projects/alwayMIRNA20170612201235/TRIM/MIRDEEP_MAPPER/MIRDEEP2_run3/quantify_all_mature_novel/result_21_08_2017_t_23_03_01.csv"
READS="/home/smalkaram/Projects/alwayMIRNA20170612201235/TRIM/MIRDEEP_MAPPER/MIRDEEP2_run3/quantify_all_mature_novel/reads2.fa"
SPECIES="mmu"
TIME=`date +"%Y%m%d%H%M%S"`

perl /home/smalkaram/Projects/alwayMIRNA20170612201235/TRIM/MIRDEEP_MAPPER/MIRDEEP2_run3/quantify_all_mature_novel/quantify_all_mature_novel.pl $RESULT
mkdir -p $WD/NOVEL
mv sigNOVEL.txt all_novel_precursor.fa  all_novel_mature.fa  all_novel_star.fa  $WD/NOVEL/.
mkdir -p $WD/MATURE
mv sigMATURE.txt all_mirbase_detected_mature.fa all_mirbase_detected_precursor.fa all_mirbase_detected_star.fa $WD/MATURE/.

# NOVEL QUANTIFICATION
#=====================
cd $WD/NOVEL
quantifier.pl -y $TIME -p all_novel_precursor.fa  -m all_novel_mature.fa  -s all_novel_star.fa -r $READS -t $SPECIES

# MATURE QUANTIFICATION
#=====================
cd $WD/MATURE
quantifier.pl -y $TIME -p all_mirbase_detected_precursor.fa -m all_mirbase_detected_mature.fa -s all_mirbase_detected_star.fa -r $READS -t $SPECIES
# Sridhar A Malkaram (smalkaram@wvstateu.edu)
# Last modified on: 12/30/2017
