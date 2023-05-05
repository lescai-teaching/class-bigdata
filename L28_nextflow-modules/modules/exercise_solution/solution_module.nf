process SUMMARISE {
	tag "summarising"
	label 'process_low'

	publishDir "${params.outdir}/results"

	conda "r-tidyverse:1.2.1"
	container "${ workflow.containerEngine == 'singularity' ?
        'https://depot.galaxyproject.org/singularity/r-tidyverse:1.2.1' :
        'quay.io/biocontainers/r-tidyverse:1.2.1' }"

	input:
	path dataset

	output:
	path "*.pdf", emit: plot
	path "*.rds", emit: summary

	script:
	"""
	#!/usr/bin/env RScript

	babynames = readRDS("L11_dataset_babynames.rds")
	summary = babynames %>%
	group_by(year) %>%
	summarise(n_children = sum(n))
	saveRDS(summary, file = "babynames_summarised.rds")

	pdf("children_per_year.pdf")
	summary %>%
	ggplot() +
	geom_line(aes(x = year, y = n_children))
	dev.off()
	"""


}