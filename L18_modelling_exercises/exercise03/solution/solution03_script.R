
dataMicrobiome = readRDS(url("https://raw.githubusercontent.com/lescai-teaching/class-bigdata/main/L18_modelling_exercises/L18_dataset_dataMicrobiome.rds"))



library(GGally)
#######
ggpairs(dataMicrobiome)



pca_recipe <- recipe(~., 
                     data = dataMicrobiome)
pca_transformation <- pca_recipe %>% 
  step_normalize(all_numeric()) %>% 
  step_pca(all_numeric(), num_comp = 3)

## however, here we are not fitting a workflow as in a supervised training
## therefore we use two internal functions which serve
## first to prepare the recipe, i.e. fit the recipe to the data
pca_estimates <- prep(
  pca_transformation,
  training = dataMicrobiome)


## and then apply that in order to make the actual calculation
## of the principal components
pca_data <- bake(
  pca_estimates,
  dataMicrobiome)


### this can be plotted as before
ggplot(pca_data,
       aes(x=PC1, y=PC2))+
  geom_point()

ggplot(pca_data,
       aes(x=PC1, y=PC3))+
  geom_point()

ggplot(pca_data,
       aes(x=PC2, y=PC3))+
  geom_point()


### k means clustering



k_means_model_tuning <- k_means(
  num_clusters = tune()
) %>% 
  set_engine("stats") %>% 
  set_mode("partition")

k_means_tune_clusters = grid_regular(
  num_clusters(range = c(3L,10L)),
  levels = 5
)

k_means_model_tuning_recipe <- recipe(~., data = dataMicrobiome) %>% 
  step_normalize(all_numeric_predictors())

k_means_model_tuning_wf = workflow() %>% 
  add_model(k_means_model_tuning) %>% 
  add_recipe(k_means_model_tuning_recipe)

dataMicrobiome_folds = vfold_cv(dataMicrobiome)


microbiome_k_means_tune_fit <- tune_cluster(
  k_means_model_tuning_wf,
  resamples = dataMicrobiome_folds,
  grid = k_means_tune_clusters,
  control = control_grid(save_pred = TRUE, extract = identity),
  metrics = cluster_metric_set(sse_within_total, sse_total, sse_ratio)
)

microbiome_k_means_metrics <- microbiome_k_means_tune_fit %>% collect_metrics()


microbiome_k_means_metrics %>%
  filter(.metric == "sse_ratio") %>%
  ggplot(aes(x = num_clusters, y = mean)) +
  geom_point() +
  geom_line() +
  theme_minimal() +
  ylab("mean WSS/TSS ratio, over 10 folds") +
  xlab("Number of clusters") +
  scale_x_continuous(breaks = 1:10)


microbiome_k_means_best_params = microbiome_k_means_tune_fit %>%
  select_best("sse_ratio")

## we cannot finalise a clustering model in the same way we do for
## a prediction model (functions are different)
## thus, we just print the parameters and setup a new model with those


k_means_model_selected <- k_means(
  num_clusters = 10
) %>% 
  set_engine("stats") %>% 
  set_mode("partition")


k_means_model_selected_wf = workflow() %>% 
  add_model(k_means_model_selected) %>% 
  add_recipe(k_means_model_tuning_recipe)


k_means_model_selected_fit = k_means_model_selected_wf %>% 
  fit(dataMicrobiome)

clustered_microbiome = k_means_model_selected_fit %>%
  augment(dataMicrobiome)

ggpairs(clustered_microbiome, columns = 1:5, aes(colour = .pred_cluster))
