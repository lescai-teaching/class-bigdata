
process LINEARMODEL {

    tag "linear"
	label 'process_medium'

	cpus = params.max_cpus
	memory = params.max_memory

	publishDir "${params.outdir}/results/linear_model", mode: 'copy'
    
	container "${ workflow.containerEngine == 'singularity' ?
        'library://lescailab/bigdata/bigdata-rstudio:1.4.0' :
        'ghcr.io/lescai-teaching/bigdata-rstudio:1.4.0' }"
    
	input:
	path dataset

	output:
	path "*.tsv", emit: tables
	path "*.pdf", emit: plots

	script:
	"""
    run_linear_model.R \
	$dataset \
	${task.cpus} \
	"LM_results"
	"""

}