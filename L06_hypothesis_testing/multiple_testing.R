
variant_analysis = readRDS(url("https://raw.githubusercontent.com/lescai-teaching/class-bigdata/main/L06_hypothesis_testing/L06_multiple_testing_dataset_variants.rds"))


variant_analysis = variant_analysis %>%
  mutate(
    false_discovery = case_when(
      annotation == "associated" & pvalue < 0.05 ~ "true_positive",
      annotation == "associated" & pvalue >= 0.05 ~ "false_negative",
      annotation == "neutral" & pvalue < 0.05 ~ "false_positive",
      annotation == "neutral" & pvalue >= 0.05 ~ "true_negative",
      TRUE ~ NA
    )
  )
### how many p values significant now?
length(variant_analysis$pvalue[variant_analysis$pvalue < 0.05])

qqplot <- ggplot(variant_analysis, aes(sample = -log10(pvalue))) +
  stat_qq() +
  stat_qq_line() +
  xlab("Theoretical Quantiles") +
  ylab("Sample Quantiles") +
  ggtitle("Q-Q Plot of P-Values")

qqplot


### we want to colour the variants but
### we do not want to separate the groups 


variant_qq_data = cbind(
  variant_analysis, 
  setNames(qqnorm(-log10(variant_analysis$pvalue), plot.it=FALSE), c("Theoretical", "Sample"))
  )

ggplot(variant_qq_data) + 
  geom_point(aes(x=Theoretical, y=Sample, colour=false_discovery))+
  scale_color_manual(
    values = c(
      "true_positive" = "#E31A1C",
      "false_negative" = "#FB9A99",
      "false_positive" = "#A6CEE3",
      "true_negative" = "#1F78B4"
    )
  )


table(variant_analysis$false_discovery)

######################################
## CORRECTING PVALUE WITH BONFERRONI
######################################

variant_analysis = variant_analysis %>%
  mutate(
    pvalue_corrected = p.adjust(pvalue, method = "bonferroni")
  ) %>%
  mutate(
    false_discovery_corrected = case_when(
      annotation == "associated" & pvalue_corrected < 0.05 ~ "true_positive",
      annotation == "associated" & pvalue_corrected >= 0.05 ~ "false_negative",
      annotation == "neutral" & pvalue_corrected < 0.05 ~ "false_positive",
      annotation == "neutral" & pvalue_corrected >= 0.05 ~ "true_negative",
      TRUE ~ NA
    )
  )
  


## how many significant now?
length(variant_analysis$pvalue_corrected[variant_analysis$pvalue_corrected < 0.5])

qqplot_corrected <- ggplot(variant_analysis, aes(sample = -log10(pvalue_corrected))) +
  stat_qq() +
  stat_qq_line() +
  xlab("Theoretical Quantiles") +
  ylab("Sample Quantiles") +
  ggtitle("Q-Q Plot of Corrected P-Values")

qqplot_corrected


variant_qq_data_corrected = cbind(
  variant_analysis, 
  setNames(qqnorm(-log10(variant_analysis$pvalue_corrected), plot.it=FALSE), c("Theoretical", "Sample"))
)

ggplot(variant_qq_data_corrected) + 
  geom_point(aes(x=Theoretical, y=Sample, colour=false_discovery_corrected))+
  scale_color_manual(
    values = c(
      "true_positive" = "#E31A1C",
      "false_negative" = "#FB9A99",
      "false_positive" = "#A6CEE3",
      "true_negative" = "#1F78B4"
    )
  )

table(variant_analysis$false_discovery_corrected)



################################################
### CORRECTING WITH BENJAMINI HOCHBERG #########
################################################


variant_analysis = variant_analysis %>%
  mutate(
    pvalue_corrected = p.adjust(pvalue, method = "BH")
  ) %>%
  mutate(
    false_discovery_corrected = case_when(
      annotation == "associated" & pvalue_corrected < 0.05 ~ "true_positive",
      annotation == "associated" & pvalue_corrected >= 0.05 ~ "false_negative",
      annotation == "neutral" & pvalue_corrected < 0.05 ~ "false_positive",
      annotation == "neutral" & pvalue_corrected >= 0.05 ~ "true_negative",
      TRUE ~ NA
    )
  )



## how many significant now?
length(variant_analysis$pvalue_corrected[variant_analysis$pvalue_corrected < 0.5])

qqplot_corrected <- ggplot(variant_analysis, aes(sample = -log10(pvalue_corrected))) +
  stat_qq() +
  stat_qq_line() +
  xlab("Theoretical Quantiles") +
  ylab("Sample Quantiles") +
  ggtitle("Q-Q Plot of Corrected P-Values")

qqplot_corrected


variant_qq_data_corrected = cbind(
  variant_analysis, 
  setNames(qqnorm(-log10(variant_analysis$pvalue_corrected), plot.it=FALSE), c("Theoretical", "Sample"))
)

ggplot(variant_qq_data_corrected) + 
  geom_point(aes(x=Theoretical, y=Sample, colour=false_discovery_corrected))+
  scale_color_manual(
    values = c(
      "true_positive" = "#E31A1C",
      "false_negative" = "#FB9A99",
      "false_positive" = "#A6CEE3",
      "true_negative" = "#1F78B4"
    )
  )

table(variant_analysis$false_discovery_corrected)