#!/usr/bin/env Rscript

library(tidyverse)

parser <- ArgumentParser()

parser$add_argument("-i", "--input", action="store_true", default=TRUE,
    help="An input is necessary to import data in a TSV format")

args <- parser$parse_args()

dataset = read_tsv(args$input)

saveRDS(dataset, file = "input_dataset.rds")