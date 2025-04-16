#!/bin/bash
#SBATCH -t 48:00:00
#SBATCH --mem 200G
#SBATCH -A csens2024-3-2
#SBATCH -J star
#SBATCH -o st_map_%j.out
#SBATCH -e st_map_%J.err

cat $0

module purge
module load GCC/12.2.0 STAR/2.7.10b

GENOME_DIR=/scale/gr01/home/sofiafr/References/GRCh38_DNA_ref/GRCh38_DNAref_39bp
DATA_DIR=/scale/gr01/home/sofiafr/DATA/Public_DBA_bulk_RNAseq/GSE119954
SAMPLE_FILE=samples.tsv

while read SAMPLE PREFIX; do

	FASTQ_DIR=${DATA_DIR}/${SAMPLE}
	READ1=${SAMPLE}/${PREFIX}_R1.fastq.gz
	READ2=${SAMPLE}/${PREFIX}_R2.fastq.gz
	OUT_DIR=${SAMPLE}_out

	cp -rp ${FASTQ_DIR} $SNIC_TMP
	cd $SNIC_TMP
	mkdir -p ${OUT_DIR}
	
	STAR \
		--runThreadN 8 \
		--genomeDir $GENOME_DIR \
		--readFilesIn $READ1 $READ2 \
		--readFilesCommand zcat \
		--outFileNamePrefix ${OUT_DIR}/ \
		--outSAMtype BAM SortedByCoordinate \
		--twopassMode Basic \
		--outFilterType BySJout \
		--outFilterMultimapNmax 20 \
		--alignIntronMin 20 \
		--alignIntronMax 1000000 \
		--chimSegmentMin 15 \
		--chimOutType Junctions

	cp -pr ${OUT_DIR} $SLURM_SUBMIT_DIR
	cd $SNIC_DIR
done < $SAMPLE_FILE
