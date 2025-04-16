#!/bin/bash
#SBATCH -t 48:00:00
#SBATCH --mem 200G
#SBATCH -A csens2024-3-2
#SBATCH -J star
#SBATCH -o st_ind_%j.out
#SBATCH -e st_ind_%j.err

cat $0
module purge
module load GCC/12.2.0 STAR/2.7.10b

fasta=/scale/gr01/home/sofiafr/References/GRCh38_DNA_ref/Homo_sapiens.GRCh38.dna_sm.primary_assembly.fa
gtf=/scale/gr01/home/sofiafr/References/GRCh38_DNA_ref/Homo_sapiens.GRCh38.113.gtf

cp -p $fasta $SNIC_TMP
cp -p $gtf $SNIC_TMP
cd $SNIC_TMP

STAR --runThreadN 20 \
     --runMode genomeGenerate \
     --genomeDir GRCh38_DNAref_39bp \
     --genomeFastaFiles Homo_sapiens.GRCh38.dna_sm.primary_assembly.fa \
     --sjdbGTFfile Homo_sapiens.GRCh38.113.gtf \
     --sjdbOverhang 38

cp -pr GRCh38_DNAref_39bp $SLURM_SUBMIT_DIR