#!/usr/bin/env Rscript

library(readr)
library(matrixStats)
library(tibble)

args <- commandArgs(trailingOnly = TRUE)
input_file <- args[1]
experiment <- args[2]
output_file <- paste0(experiment, "_mad.tsv")

data <- read_tsv(input_file)
mat <- as.matrix(data[,-1])
mad_vals <- colMads(mat)
mad_df <- tibble(Gene = colnames(mat),
                 !!paste0(experiment, "_MAD") := mad_vals)
write_tsv(mad_df, output_file)