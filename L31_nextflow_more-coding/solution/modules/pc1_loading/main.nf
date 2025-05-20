process PC1_LOADING {
    tag "$experiment_name"
    label 'process_low'
    
    conda "conda-forge::r-readr=2.1.2 conda-forge::r-tibble=3.1.6"
    container "${ workflow.containerEngine == 'apptainer' && !task.ext.singularity_pull_docker_container ?
        'oras://community.wave.seqera.io/library/r-readr_r-tibble:d55f1bf6ed0d1750' :
        'community.wave.seqera.io/library/r-readr_r-tibble:accd2f5f09c7feda' }"
    
    input:
    tuple val(experiment_name), path(data_file)
    
    output:
    tuple val(experiment_name), path("${experiment_name}_pc1load.tsv"), emit: pc1load
    
    script:
    """
    pc1_loading.R $data_file $experiment_name
    """
}