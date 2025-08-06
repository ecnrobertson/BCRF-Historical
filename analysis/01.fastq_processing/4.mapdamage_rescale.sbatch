#!/bin/bash
#SBATCH --job-name=RESCALE
#SBATCH --output=RESCALE.%j.out
#SBATCH --error=RESCALE.%j.err
#################
#SBATCH -t 24:00:00
#SBATCH --partition=amilan
#SBATCH --qos=normal
#SBATCH --ntasks-per-node 4
#SBATCH --mem=16G
#################
#SBATCH --mail-type=END
#################
#SBATCH  --mail-user=ericacnr@colostate.edu
##################
#echo commands to stdout
set -x

##################
#run sbatch in for loop
#from within bwa_mem
#for sample in `ls *_rmdup.bam |cut -f1 -d '_'|sed 's/Z//g'`; do echo  $sample; sbatch ../../3.map_rmdup.sbatch $sample ; done

source ~/.bashrc
conda activate bioinf

# Input arguments
sample=$1

# Define input and output paths
REFERENCE="/scratch/alpine/ericacnr@colostate.edu/Reference/L.australis_reference/leucosticte_australis_final_assembly.fasta"
INPUT_BAM="../bwa_mem/${sample}_rmdup.bam"

OUTDIR="../mapdamage/${sample}"
RESCALED_DIR="../mapdamage/rescaled_bams"
LOGDIR="../mapdamage/logs"

mkdir -p "$OUTDIR" "$RESCALED_DIR" "$LOGDIR"

# Run mapDamage2 with rescaling
mapDamage -i "$INPUT_BAM" -r "$REFERENCE" \
  --rescale \
  --no-stats \
  --merge-reference-sequences \
  --folder "$OUTDIR" \
  --output-file "${sample}" \
  --rescaled-out "${RESCALED_DIR}/${sample}.rescaled.bam" \
  > "${LOGDIR}/${sample}.log" 2>&1

