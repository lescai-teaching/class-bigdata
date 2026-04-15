process MAD {
    tag "$experiment_name"
    label 'process_low'

    publishDir(
        path: { "${params.outdir}/results/mad/${experiment_name}" },
        mode: params.publish_dir_mode
    )

    conda "conda-forge::r-base=4.5 conda-forge::r-matrixstats=1.5.0 conda-forge::r-readr conda-forge::r-tibble"
    container "${ workflow.containerEngine == 'apptainer' && !task.ext.singularity_pull_docker_container ?
        'oras://community.wave.seqera.io/library/r-matrixstats_r-readr_r-tibble:eb48f6df9f087519' :
        'community.wave.seqera.io/library/r-matrixstats_r-readr_r-tibble:eaa6eb67f2ecc815' }"
    
    input:
    tuple val(experiment_name), path(data_file)
    
    output:
    tuple val(experiment_name), path("${experiment_name}_mad.tsv"), emit: mad
    
    script:
    """
    mad.R "$data_file" "$experiment_name"
    """
}
