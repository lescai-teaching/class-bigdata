#!/usr/bin/Rscript

args = commandArgs(trailingOnly=TRUE)

if (length(args)==0) {
  stop("At least one argument must be supplied", call.=FALSE)
}

library(tidyverse)

babynames = readRDS(args[1])
summary = babynames %>%
group_by(year) %>%
summarise(n_children = sum(n))
saveRDS(summary, file = "babynames_summarised.rds")

pdf("children_per_year.pdf")
summary %>%
ggplot() +
geom_line(aes(x = year, y = n_children))
dev.off()