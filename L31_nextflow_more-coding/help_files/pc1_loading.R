#!/usr/bin/env Rscript

library(readr)
library(tibble)

args <- commandArgs(trailingOnly = TRUE)
input_file <- args[1]
experiment <- args[2]
output_file <- paste0(experiment, "_pc1load.tsv")

data <- read_tsv(input_file)
mat <- as.matrix(data[,-1]) # Remove Sample column
pc <- prcomp(mat, center=TRUE, scale.=TRUE)
loadings <- pc$rotation[,1, drop=FALSE]
loadings_df <- tibble(Gene = rownames(loadings),
                      !!paste0(experiment, "_PC1_loading") := as.numeric(loadings[,1]))
write_tsv(loadings_df, output_file)