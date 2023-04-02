
library(tidyverse)
library(tidymodels)
library(tidyclust)
library(dbscan)
library(GGally)



cytofluorimeter_data = readRDS(url("L16_dataset_cytofluorimeter.rds"))



k_means_model <- k_means(
  num_clusters = 5
) %>% 
  set_engine("stats") %>% 
  set_mode("partition")


k_means_fit <- k_means_model %>% 
  fit(
    formula = ~.,
    data = cytofluorimeter_data
  )


k_means_fit %>% summary()

k_means_fit_summary = k_means_fit %>% extract_fit_summary()
str(k_means_fit_summary)


## combine individuals with cluster assignments

clustered_cyto = bind_cols(
  cytofluorimeter_data,
  k_means_fit %>% extract_cluster_assignment()
)

clustered_cyto %>% 
  ggplot(aes(x=CD12, y=CD45, colour = .cluster))+
  geom_point()

## however, now we have a framework to calculate
## performance metrices

##### within cluster sum-of-squared error (WSS)

k_means_fit_summary$sse_within_total_total

## or 

k_means_fit %>% sse_within_total()

## by cluster

k_means_fit %>% sse_within() ## which is identical as the summary

#### total sum-of-squared error (TSS)

k_means_fit_summary$sse_total

# or 

k_means_fit %>% sse_total()

#### WSS / TSS ratio as summary

k_means_fit %>% sse_ratio()

## small values of the WSS/TSS ratio suggest that 
# the observations within clusters are closer (more similar) 
# to each other than they are to the other clusters.

