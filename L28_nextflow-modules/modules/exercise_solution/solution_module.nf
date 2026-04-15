process SUMMARISE {
	tag "summarising"
	label 'process_low'

	publishDir "${params.outdir}/results", mode: 'copy'

	conda "conda-forge::r-base=4.5 conda-forge::r-tidyverse=2.0.0"
	container 'ghcr.io/lescai-teaching/bigdata-rstudio:1.4.0'

	input:
	path dataset
	path rscriptfile

	output:
	path "*.pdf", emit: plot
	path "*.rds", emit: summary

	script:
	"""
	Rscript "$rscriptfile" "$dataset"
	"""
}
