process RANDOMFOREST {

    tag "randomforest"
	label 'process_medium'

	cpus params.max_cpus
	memory params.max_memory

	publishDir "${params.outdir}/results/random_forest", mode: 'copy'

	conda "conda-forge::r-base=4.5 conda-forge::r-tidyverse=2.0.0 conda-forge::r-tidymodels=1.4.1 conda-forge::r-doparallel conda-forge::r-ranger=0.18.0 conda-forge::r-vip"
	container 'ghcr.io/lescai-teaching/bigdata-rstudio:1.4.0'
    
	input:
	path dataset

	output:
	path "*.tsv", emit: tables
	path "*.pdf", emit: plots

	script:
	"""
    run_random_forest.R \
	"$dataset" \
	${task.cpus} \
	"RF_results"
	"""

}
