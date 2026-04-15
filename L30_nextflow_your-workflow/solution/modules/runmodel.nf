
process RUNMODEL {

    tag "run: ${modeltype}"

	cpus params.max_cpus
	memory params.max_memory

	publishDir(
		path: { "${params.outdir}/results/${modeltype}" },
		mode: 'copy'
	)

	conda "conda-forge::r-base=4.5 conda-forge::r-tidyverse=2.0.0 conda-forge::r-tidymodels=1.4.1 conda-forge::r-ranger=0.18.0 conda-forge::r-vip"
	container 'ghcr.io/lescai-teaching/bigdata-rstudio:1.4.0'
    
	input:
	path dataset
	path rscript
	val  modeltype

	output:
	path "*.rds", emit: model
	path "*.pdf", emit: plots

	script:
	"""
    Rscript "$rscript" \
	"$dataset" \
	${task.cpus} \
	"${modeltype}"
	"""

}
