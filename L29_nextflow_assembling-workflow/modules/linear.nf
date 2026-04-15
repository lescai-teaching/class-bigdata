
process LINEARMODEL {

    tag "linear"
	label 'process_medium'

	cpus params.max_cpus
	memory params.max_memory

	publishDir "${params.outdir}/results/linear_model", mode: 'copy'

	conda "conda-forge::r-base=4.5 conda-forge::r-tidyverse=2.0.0 conda-forge::r-tidymodels=1.4.1 conda-forge::r-doparallel conda-forge::r-glmnet conda-forge::r-vip"
	container 'ghcr.io/lescai-teaching/bigdata-rstudio:1.4.0'
    
	input:
	path dataset

	output:
	path "*.tsv", emit: tables
	path "*.pdf", emit: plots

	script:
	"""
    run_linear_model.R \
	"$dataset" \
	${task.cpus} \
	"LM_results"
	"""

}
