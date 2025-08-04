#!/bin/bash
#SBATCH --job-name=TRIM_MERGE
#SBATCH --output=TRIM_MERGE.%j.out
#SBATCH --error=TRIM_MERGE.%j.err
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
#from within raw_data
#for sample in `ls *1.fq.gz |cut -f1 -d '_'|sed 's/Z//g'`; do echo  $sample; sbatch ../../1.trim.sbatch $sample ; done


source ~/.bashrc
conda activate bioinf

sample=$1

#FASTP
#fastp -i "$sample".R1.fq.gz -I "$sample".R2.fq.gz -o "$sample".R1.trim.fq.gz -O "$sample".R2.trim.fq.gz

#SEQPREP2

mkdir ../trim_merged
mkdir ../logs/seqprep2_trim_merge

merged="trim-merged/${sample}.merged.fq.gz"
log_out="logs/seqprep2_trim_merge/${sample}.log"
log_err="logs/seqprep2_trim_merge/${sample}.err"

adapter_a="AGATCGGAAGAGCACACGTCTGAACTCCAGTCA"
adapter_b="AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT"
minlen="28"
overlap="19"

/projects/ericacnr@colostate.edu/SeqPrep2/SeqPrep2 \
  -f "$sample".R1.fq.gz -r "$sample".R2.fq.gz \
  -1 /dev/null -2 /dev/null -s "$merged"
 \
  -A "$adapter_a" -B "$adapter_b" \
  -L "$minlen" -o "$overlap" \
  > "$log_out" 2> "$log_err"
