
process LINEARMODEL {

    tag "linear"
	label 'process_medium'

	cpus = 4
	memory = 20.GB

	publishDir "${params.outdir}/results/linear_model", mode: 'copy'
    
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
    run_linear_model.R \
	--input $dataset \
	--cores ${task.cpus} \
	--output "LM_results"
	"""

}