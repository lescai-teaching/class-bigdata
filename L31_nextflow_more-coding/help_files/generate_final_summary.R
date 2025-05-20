#!/usr/bin/env Rscript

library(readr)
library(dplyr)
library(purrr)
library(tidyr)

# List all relevant files (pattern: *_meansd.tsv, *_pc1load.tsv, *_mad.tsv)
summary_files <- list.files(pattern = ".*_(meansd|pc1load|mad)\\.tsv$")

# Read and join all summary files by 'Gene'
summary_list <- lapply(summary_files, function(f) read_tsv(f))
final_summary <- reduce(summary_list, full_join, by = "Gene")

# Optional: order columns (Gene, then Exp1/2/3_Mean, then PC1, then MAD)
mean_cols <- grep("_Mean$", colnames(final_summary), value=TRUE)
sd_cols   <- grep("_SD$", colnames(final_summary), value=TRUE)
pc1_cols  <- grep("_PC1_loading$", colnames(final_summary), value=TRUE)
mad_cols  <- grep("_MAD$", colnames(final_summary), value=TRUE)

ordered_cols <- c("Gene", mean_cols, sd_cols, pc1_cols, mad_cols)
ordered_cols <- ordered_cols[ordered_cols %in% colnames(final_summary)] # only those that exist

final_summary <- final_summary %>% select(all_of(ordered_cols))

# Write final summary table
write_tsv(final_summary, "all_experiments_summary.tsv")