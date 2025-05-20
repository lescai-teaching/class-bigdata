process SUMMARY {
    label 'process_low'
    
    conda "conda-forge::r-tidyverse=1.3.1"
    container "${ workflow.containerEngine == 'apptainer' && !task.ext.singularity_pull_docker_container ?
        'oras://community.wave.seqera.io/library/r-tidyverse:1.3.1--6278dcf30dd26796' :
        'community.wave.seqera.io/library/r-tidyverse:1.3.1--4953a1407d1e33c7' }"
    
    input:
    path(stats_files)
    
    output:
    path("all_experiments_summary.tsv"), emit: summary
    
    script:
    """
    generate_final_summary.R
    """
}