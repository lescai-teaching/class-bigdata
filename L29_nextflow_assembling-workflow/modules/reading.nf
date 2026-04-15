process READ_DATA {

	tag "import"
	label 'process_low'

	cpus 1
    memory 1.GB

	publishDir "${params.outdir}/preprocess", mode: 'copy'

	conda "conda-forge::r-base=4.5 conda-forge::r-tidyverse=2.0.0"
	container 'ghcr.io/lescai-teaching/bigdata-rstudio:1.4.0'
	
	input:
	path tsvfile

	output:
	path "*.rds", emit: dataset

	script:
	"""
	run_import.R \
	"$tsvfile"
	"""

}
