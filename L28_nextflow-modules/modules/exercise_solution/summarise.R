#!/usr/bin/Rscript

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