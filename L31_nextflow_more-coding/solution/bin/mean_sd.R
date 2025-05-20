#!/usr/bin/env Rscript

library(readr)
library(dplyr)
library(tidyr)

args <- commandArgs(trailingOnly = TRUE)
input_file <- args[1]
experiment <- args[2]
output_file <- paste0(experiment, "_meansd.tsv")

data <- read_tsv(input_file)
data_long <- pivot_longer(data, -Sample, names_to = "Gene", values_to = "Expression")
meansd <- data_long %>%
  group_by(Gene) %>%
  summarise(!!paste0(experiment, "_Mean") := mean(Expression),
            !!paste0(experiment, "_SD") := sd(Expression))
write_tsv(meansd, output_file)