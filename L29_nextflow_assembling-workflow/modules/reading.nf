process READ_DATA {

	tag "import"
	label 'process_low'

	publishDir "${params.outdir}/preprocess", mode: 'copy'

	conda "r-tidyverse:1.2.1"
	container "${ workflow.containerEngine == 'singularity' ?
        'https://depot.galaxyproject.org/singularity/r-tidyverse:1.2.1' :
        'quay.io/biocontainers/r-tidyverse:1.2.1' }"
	
	input:
	path tsvfile

	output:
	path "*.rds", emit: dataset

	script:
	"""
	run_import.R \
	--input $tsvfile
	"""

}