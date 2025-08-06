#!/bin/bash
#SBATCH --job-name=FILT_LC
#SBATCH --output=FILT_LC.%j.out
#SBATCH --error=FILT_LC.%j.err
#################
#SBATCH -t 6:00:00
#SBATCH --partition=amilan
#SBATCH --qos=normal
#SBATCH --ntasks-per-node 4
#SBATCH --mem=12G
#################
#SBATCH --mail-type=END
#################
#SBATCH  --mail-user=ericacnr@colostate.edu
##################
#echo commands to stdout
set -x

##################
#run sbatch in for loop
#from within trim_merged
#for sample in `ls *.merged.fq.gz |cut -f1 -d '_'|sed 's/Z//g'`; do echo  $sample; sbatch ../../2.filt_low_complexity.sbatch $sample ; done

sample=$1

source ~/.bashrc
conda activate bioinf

mkdir ../filter_lc/

prinseq++ \
  -fastq $sample.merged.fq.gz \
  -out_good ../filter_lc/$sample.merged.lc.07.fastq \
  -lc_dust=0.07