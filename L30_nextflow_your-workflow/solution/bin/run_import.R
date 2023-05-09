#!/usr/bin/env Rscript

library(tidyverse)

args   = commandArgs(trailingOnly=TRUE)
input  = args[1]

dataset = read_tsv(input)

saveRDS(dataset, file = "input_dataset.rds")