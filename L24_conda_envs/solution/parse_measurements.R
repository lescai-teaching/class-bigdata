#!/bin/Rscript

library(tidyverse)
measures = read_delim("cell_measurements.txt", delim=";")

res = measures %>%
group_by(type) %>%
summarise(
	avg_diameter = mean(diameter),
	cells = n()
)

write_tsv(res, "grouped_measurements.tsv")