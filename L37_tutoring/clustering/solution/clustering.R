# Load the libraries
library(tidyverse)
library(tidymodels)
library(tidyclust)
library(GGally)

# Load the dataset
patients_data <- read_tsv("~/bigdata/tutorati-2024/datasets/03_clustering/mbg_exams_patientexpr_data.tsv")

# Inspect the data
ggpairs(patients_data)


##########################
### K-MEANS CLUSTERING ###
##########################


# Generate data folds
patients_data_cv <- vfold_cv(patients_data, v = 5)

# Assemble model
kmeans_model <- k_means(
    num_clusters = tune()
  ) %>% 
  set_engine("stats") %>% 
  set_mode("partition")

# Assemble model recipe
kmeans_recipe <- recipe(~., data = patients_data) %>% 
  step_normalize(all_numeric()) %>% 
  # Reduce the dimensionality of the dataset while capturing the variance in principal components PC1 and PC2
  step_pca(all_numeric(), num_comp = 2)

# Assemble model workflow
kmeans_wf <- workflow() %>%
  add_model(kmeans_model) %>% 
  add_recipe(kmeans_recipe)

# Generate tuning grid
kmeans_tuning_grid <- grid_regular(num_clusters(),
                               levels = 10)

# Tune
kmeans_tuning <- tune_cluster(
  kmeans_wf,
  resamples = patients_data_cv,
  grid = kmeans_tuning_grid,
  control = control_grid(save_pred = TRUE, extract = identity),
  metrics = cluster_metric_set(sse_within_total, sse_total, sse_ratio)
)

# Collect metrics
kmeans_tuning_metrics <- kmeans_tuning %>% 
  collect_metrics()

# Plotting WSS/TSS ratio by number of clusters. Remember that you should observe the plot and choose the number of clusters that minimises the WSS/TSS ratio the most
wss_tss_ratio <- kmeans_tuning_metrics %>%
  filter(.metric == "sse_ratio") %>%
  ggplot(aes(x = num_clusters, y = mean)) +
  geom_point() +
  geom_line() +
  theme_minimal() +
  ylab("mean WSS/TSS ratio, over 5 folds") +
  xlab("Number of clusters") +
  scale_x_continuous(breaks = 1:10)

# Create a new model using the number of clusters we discovered by tuning
k_means_model_best <- k_means(
  num_clusters = 5
) %>% 
  set_engine("stats") %>% 
  set_mode("partition")

# Create new recipe
k_means_model_best_recipe <- recipe(~., data = patients_data) %>% 
  step_normalize(all_numeric()) %>% 
  step_pca(all_numeric(), num_comp = 2)

# Create new workflow
k_means_model_best_wf <- workflow() %>% 
  add_model(k_means_model_best) %>% 
  add_recipe(k_means_model_best_recipe)

# Fit the workflow
k_means_model_best_fit <- k_means_model_best_wf %>% 
  fit(patients_data)

# Visualise WSS/TSS ratio
k_means_model_best_fit_sse_ratio <- k_means_model_best_fit %>% 
  sse_ratio()

# Bind cluster assignments to the dataset
kmeans_clustered_dataset <- k_means_model_best_fit %>% 
  augment(patients_data)

# Generate augmented scatterplot matrix
kmeans_augmented_clustered_dataset <- ggpairs(kmeans_clustered_dataset, columns = 1:6, aes(colour = .pred_cluster))


###############################
### HIERARCHICAL CLUSTERING ###
###############################


hc_model <- hier_clust(
  num_clusters = 5,
  linkage_method = "ward.D2"
) %>% 
  set_engine("stats") %>% 
  set_mode("partition")

hc_recipe <- recipe(~., data = patients_data) %>% 
  step_normalize(all_numeric()) %>% 
  step_pca(all_numeric(), num_comp = 2)

hc_wf <- workflow() %>%
  add_model(hc_model) %>% 
  add_recipe(hc_recipe)

hc_wf_fit <- hc_wf %>% 
  fit(patients_data)

hc_fit_sse_ratio <- hc_wf_fit %>% 
  sse_ratio()

# Extract fit summary
hc_wf_fit %>%  extract_fit_summary() %>% str()

hc_clustered_dataset <- bind_cols(
  patients_data,
  hc_wf_fit %>% extract_cluster_assignment()
)

hc_augmented_clustered_dataset <- ggpairs(hc_clustered_dataset, columns = 1:6, aes(colour = .cluster))
