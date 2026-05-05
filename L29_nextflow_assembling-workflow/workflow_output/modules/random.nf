process RANDOMFOREST {

    tag 'randomforest'
    label 'process_medium'

    cpus params.max_cpus
    memory params.max_memory

    container "${workflow.containerEngine == 'singularity' ?
        'library://lescailab/bigdata/bigdata-rstudio:1.4.0' :
        'ghcr.io/lescai-teaching/bigdata-rstudio:1.4.0'}"

    input:
    path dataset

    output:
    path '*.tsv', emit: tables
    path '*.pdf', emit: plots

    script:
    """
    run_random_forest.R \
    $dataset \
    ${task.cpus} \
    "RF_results"
    """
}
