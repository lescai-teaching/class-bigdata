process MAD {
    tag "$experiment_name"
    label 'process_low'
    
    conda "conda-forge::r-matrixstats=0.61.0 conda-forge::r-readr=2.1.2 conda-forge::r-tibble=3.1.6"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'oras://community.wave.seqera.io/library/r-matrixstats_r-readr_r-tibble:1d25ad1f11a6301f' :
        'community.wave.seqera.io/library/r-matrixstats_r-readr_r-tibble:00f58eacc57dc193' }"
    
    input:
    tuple val(experiment_name), path(data_file)
    
    output:
    tuple val(experiment_name), path("${experiment_name}_mad.tsv"), emit: mad
    
    script:
    """
    mad.R $data_file $experiment_name
    """
}