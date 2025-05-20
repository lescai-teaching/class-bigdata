process MEAN_SD {
    tag "$experiment_name"
    label 'process_low'
    
    conda "conda-forge::r-tidyverse=1.3.1"
    container "${ workflow.containerEngine == 'apptainer' && !task.ext.singularity_pull_docker_container ?
        'oras://community.wave.seqera.io/library/r-tidyverse:1.3.1--6278dcf30dd26796' :
        'community.wave.seqera.io/library/r-tidyverse:1.3.1--4953a1407d1e33c7' }"
    
    input:
    tuple val(experiment_name), path(data_file)
    
    output:
    tuple val(experiment_name), path("${experiment_name}_meansd.tsv"), emit: meansd
    
    script:
    """
    mean_sd.R $data_file $experiment_name
    """
}