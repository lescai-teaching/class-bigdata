process RUNMODEL {

    cpus params.max_cpus
    memory params.max_memory

    publishDir({ "${params.outdir}/results/${task.process.toLowerCase()}" }, mode: 'copy')

    container "${workflow.containerEngine == 'singularity' ?
        'library://lescailab/bigdata/bigdata-rstudio:1.4.0' :
        'ghcr.io/lescai-teaching/bigdata-rstudio:1.4.0'}"

    input:
    path dataset
    path rscript
    val modeltype

    output:
    path '*.rds', emit: model
    path '*.pdf', emit: plots

    script:
    """
    Rscript $rscript \
    $dataset \
    ${task.cpus} \
    $modeltype
    """
}
