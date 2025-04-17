#! /bin/bash
#SBATCH -t 24:00:00
#SBATCH --mem 200G
#SBATCH -A csens2024-3-2
#SBATCH -J strtie
#SBATCH -o strtie.%j.out
#SBATCH -e strtie.%j.err

module purge
cat $0

IMAGE=/scale/gr01/home/sofiafr/images/stringtie.sif
ANNOTATION=/scale/gr01/home/sofiafr/References/GRCh38_DNA_ref/Homo_sapiens.GRCh38.113.gtf
DATA_DIR=/scale/gr01/home/sofiafr/DATA/Public_DBA_bulk_RNAseq/GSE119954/
SAMPLE=Control_1
BAM_FILE=${SAMPLE}_out/Aligned.sortedByCoord.out.bam

cp -p $IMAGE $SNIC_TMP
cp -p $ANNOTATION $SNIC_TMP
cp -p $BAM_FILE $SNIC_TMP
cd $SNIC_TMP
ls > log

singularity exec stringtie.sif \
	Aligned.sortedByCoord.out.bam \
	-G Homo_sapiens.GRCh38.113.gtf \
	-e -B \
	-o /data/${SAMPLE}.gtf

cp -pr log ${SAMPLE}.gtf $SLURM_SUBMIT_DIR
