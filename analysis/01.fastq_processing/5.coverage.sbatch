#!/bin/bash

#SBATCH --job-name=COV_ARRAY
#SBATCH --output=COV_ARRAY.%A_%a.out
#SBATCH --error=COV_ARRAY.%A_%a.err
#################
#SBATCH -t 24:00:00
#SBATCH --partition=amilan
#SBATCH --qos=normal
#SBATCH --ntasks-per-node 1
#SBATCH --mem=4G
#################
#SBATCH --array=0-9
#################
#SBATCH --mail-type=END
#SBATCH  --mail-user=ericacnr@colostate.edu
##################
#echo commands to stdout
set -x


##################
#this is an array, so run from within the parent directory 01.fastq_processing

source ~/.bashrc
conda activate bioinf

cd ../bwa_mem
bam_files=( *_rmdup.bam )

bam="${bam_files[$SLURM_ARRAY_TASK_ID]}"
sample=$(basename "$bam" _rmdup.bam)

# Temporary coverage output
cov_tmp="../coverage/${sample}_cov.bedtools.txt"

# Final summary file (append mode, only 1 line per sample)
summary="../coverage/covSummary.bedtools.txt"

# Compute per-base depth and mean coverage < 500x
bedtools genomecov -d -ibam "$bam" > "$cov_tmp"

# Append average coverage to summary (atomic append using flock)
{
  awk '{if($3<500){total+=$3;++lines}} END{if(lines>0){print FILENAME, total/lines} else {print FILENAME, "NA"}}' "$cov_tmp"
} >> "$summary"

# Clean up temporary file
rm "$cov_tmp"
