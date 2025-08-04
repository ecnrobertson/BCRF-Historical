#!/bin/bash
#SBATCH --job-name=ALIGN
#SBATCH --output=ALIGN.%j.out
#SBATCH --error=ALIGN.%j.err
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
#from within filter_lc
#for sample in `ls *.merged.lc.07.fastq |cut -f1 -d '_'|sed 's/Z//g'`; do echo  $sample; sbatch ../../3.map_rmdup.sbatch $sample ; done

source ~/.bashrc
conda activate bioinf

# Variables
PLATE="Plate1"
sample=$1
ID="${PLATE}.${sample}"
REFERENCE="/scratch/alpine/ericacnr@colostate.edu/Reference/L.australis_reference/leucosticte_australis_final_assembly.fasta"

# Define working directories (relative to current script location)
FILTER_LC_DIR="../filter_lc"
BWA_MEM_DIR="../bwa_mem"

# Make sure output directory exists
mkdir -p "$BWA_MEM_DIR"

# Input fastq (filtered low complexity)
FASTQ="${FILTER_LC_DIR}/${sample}.merged.lc.07.fastq"

###### Step 1: Align with bwa aln ######
bwa aln -l 1024 -t 4 "$REFERENCE" "$FASTQ" > "${BWA_MEM_DIR}/aln_${sample}.sam.sai"

###### Step 2: Generate SAM with bwa samse ######
bwa samse "$REFERENCE" "${BWA_MEM_DIR}/aln_${sample}.sam.sai" "$FASTQ" > "${BWA_MEM_DIR}/aln_${sample}.sam"

# Clean up sai file
rm "${BWA_MEM_DIR}/aln_${sample}.sam.sai"

###### Step 3: Convert SAM to BAM, filter by mapping quality, and sort ######
samtools view -b -q 30 -o "${BWA_MEM_DIR}/aln_${sample}.bam" "${BWA_MEM_DIR}/aln_${sample}.sam"
samtools sort -o "${BWA_MEM_DIR}/aln_${sample}.sorted.bam" "${BWA_MEM_DIR}/aln_${sample}.bam"

# Clean up intermediate files
rm "${BWA_MEM_DIR}/aln_${sample}.bam" "${BWA_MEM_DIR}/aln_${sample}.sam"

###### Step 4: Add Read Groups with Picard ######
picard AddOrReplaceReadGroups \
  INPUT="${BWA_MEM_DIR}/aln_${sample}.sorted.bam" \
  OUTPUT="${BWA_MEM_DIR}/${sample}_RG.bam" \
  RGID="$ID" RGLB="$PLATE" RGPL=illumina RGPU="${PLATE}.${sample}" RGSM="$sample" \
  VALIDATION_STRINGENCY=SILENT

###### Step 5: Sort by read name (required for fixmate) ######
samtools sort -n -o "${BWA_MEM_DIR}/${sample}_namesort.bam" "${BWA_MEM_DIR}/${sample}_RG.bam"

###### Step 6: Fix mate information ######
samtools fixmate -m "${BWA_MEM_DIR}/${sample}_namesort.bam" "${BWA_MEM_DIR}/${sample}_fixm.bam"

#  Clean up intermediate files
rm "${BWA_MEM_DIR}/${sample}_namesort.bam" "${BWA_MEM_DIR}/${sample}_RG.bam"

###### Step 7: Sort by coordinate for markdup ######
samtools sort -o "${BWA_MEM_DIR}/${sample}_fixm.sort.bam" "${BWA_MEM_DIR}/${sample}_fixm.bam"

# Clean up
rm "${BWA_MEM_DIR}/${sample}_fixm.bam"

###### Step 8: Mark duplicates and remove them (-r), output final BAM ######
samtools markdup -r -s "${BWA_MEM_DIR}/${sample}_fixm.sort.bam" "${BWA_MEM_DIR}/${sample}_rmdup.bam"

###### Step 9: Index final BAM ######
samtools index "${BWA_MEM_DIR}/${sample}_rmdup.bam"

# Remove intermediate sorted BAM before markdup if you want to save space
rm "${BWA_MEM_DIR}/${sample}_fixm.sort.bam"

