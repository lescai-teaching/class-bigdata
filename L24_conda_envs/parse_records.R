#!/bin/Rscript

library(tidyverse)

data = read_tsv("records.tsv")

groups = data %>%
    group_by(category) %>%
	summarise(
		cat_sum = sum(value)
	)

write_tsv(groups, file = "results_groupvalues.tsv")