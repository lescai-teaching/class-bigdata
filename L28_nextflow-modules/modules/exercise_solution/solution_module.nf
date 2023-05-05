process SUMMARISE {
	tag "summarising"
	label 'process_low'

	publishDir "${params.outdir}/results", mode: 'copy'

	conda "r-tidyverse:1.2.1"
	container "${ workflow.containerEngine == 'singularity' ?
        'https://depot.galaxyproject.org/singularity/r-tidyverse:1.2.1' :
        'quay.io/biocontainers/r-tidyverse:1.2.1' }"

	input:
	path dataset
	path rscriptfile

	output:
	path "*.pdf", emit: plot
	path "*.rds", emit: summary

	script:
	"""
	Rscript $rscriptfile $dataset
	"""


}