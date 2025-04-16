nextflow.enable.dsl=2

params.samples = file('samples.tsv')
params.outdir = "${workflow.launchDir}/results"
params.fastqc_dir = "${params.outdir}/fastqc"

process DownloadAndPrepare {
    tag "$sample_name"

    maxForks = 1
    scratch true

    input:
    tuple val(sample_name), val(srr_id)

    output:
    path("${sample_name}/${srr_id}_R1.fastq.gz"), emit: R1
    path("${sample_name}/${srr_id}_R2.fastq.gz"), emit: R2

    publishDir "${params.outdir}", mode: 'copy', pattern: "${sample_name}/*"

    script:
    """
    mkdir -p ${sample_name}
    prefetch ${srr_id} --output-directory ${sample_name}

    fasterq-dump --split-files --threads 4 --outdir ${sample_name} ${sample_name}/${srr_id}/${srr_id}.sra
    pigz -p 4 ${sample_name}/${srr_id}_1.fastq
    pigz -p 4 ${sample_name}/${srr_id}_2.fastq

    rm -r ${sample_name}/${srr_id}

    mv ${sample_name}/${srr_id}_1.fastq.gz ${sample_name}/${srr_id}_R1.fastq.gz
    mv ${sample_name}/${srr_id}_2.fastq.gz ${sample_name}/${srr_id}_R2.fastq.gz
    """
}

process FastQC {
    tag "$sample_name"

    input:
    tuple val(sample_name), path(reads)

    output:
    path("*.html")
    path("*.zip")

    publishDir "${params.fastqc_dir}", mode: 'copy'

    script:
    """
    fastqc -t 4 ${reads}
    """
}

workflow {

    samples_ch = Channel
        .fromPath(params.samples)
        .splitCsv(header: true, sep: '\t')
        .map { row -> tuple(row.sample_name, row.SRR_id) }

    download_results = samples_ch | DownloadAndPrepare
    R1_ch = download_results.R1
    R2_ch = download_results.R2

    fastqc_input = R1_ch
        .combine(R2_ch)
        .map { r1, r2 ->
            def sample_name = r1.getBaseName().split('_')[0]
            tuple(sample_name, [r1, r2])
        }

    fastqc_results = fastqc_input | FastQC
}
