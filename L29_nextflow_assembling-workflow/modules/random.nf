
process RANDOMFOREST {

    tag "randomforest"
	label 'process_medium'

	cpus = 4
	memory = 20.GB

	publishDir "${params.outdir}/results/random_forest", mode: 'copy'
    
	container "${ workflow.containerEngine == 'singularity' ?
        'library://lescailab/bigdata/bigdata-rstudio:1.4.0' :
        'ghcr.io/lescai-teaching/bigdata-rstudio:1.4.0' }"
    
	input:
	path dataset

	output:
	path "*.rds", emit: rdata
	path "*.tsv", emit: tables
	path "*.pdf", emit: plots

	script:
	"""
    run_random_forest.R \
	--input $dataset \
	--cores ${task.cpus} \
	--output "RF_results"
	"""

}