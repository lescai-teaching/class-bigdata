#!/usr/bin/env Rscript

library(tidyverse)
library(tidymodels)

args   = commandArgs(trailingOnly=TRUE)
input  = args[1]
cores  = args[2]
output = args[3]

writeLines("getting data")
biodegradation_data = readRDS(input)


writeLines("splitting data")
set.seed(367)
biodegradation_data_split = initial_split(biodegradation_data, prop = 0.75)
biodegradation_data_training = training(biodegradation_data_split)
biodegradation_data_testing = testing(biodegradation_data_split)


writeLines("assembling workflow")

rf_model_tuning <- rand_forest(
  mtry = tune(),
  trees = tune(),
  min_n = tune()
) %>% 
  set_mode("regression") %>% 
  set_engine("ranger")


rf_tuning_grid <- grid_regular(
  mtry(range = c(5L,8L)),
  trees(),
  min_n(),
  levels = 3)



biodegradation_recipe <- 
  recipe(biodegradation_rate ~ ., 
         data = biodegradation_data_training) %>% 
  step_normalize(all_predictors())


rf_regression_tune_wf <- workflow() %>% 
  add_model(rf_model_tuning) %>% 
  add_recipe(biodegradation_recipe)


set.seed(234)
biodegradation_folds <- vfold_cv(biodegradation_data_training)

# this code seems to get stuck in creating the cluster
writeLines("loading doParallel library")
library(doParallel) 
writeLines("registering parallel without creating the cluster")
registerDoParallel(cores=cores)


writeLines("beging tuning")
rf_tuning_results <- 
  rf_regression_tune_wf %>% 
  tune_grid(
    resamples = biodegradation_folds,
    grid = rf_tuning_grid
  )

writeLines("tuning completed - collecting metrics")

rf_tuning_results %>% 
  collect_metrics() %>%
  write_tsv(file = paste0(output, "_randomforest_tuning_metrics.tsv"))


writeLines("finalising workflow")

rf_tuning_best_params = rf_tuning_results %>%
  select_best("rmse")

final_rf_wf <- rf_regression_tune_wf %>% 
  finalize_workflow(rf_tuning_best_params)

final_rf_fit <- final_rf_wf %>% 
  last_fit(biodegradation_data_split)

## metrics


final_metrics = final_rf_fit %>% 
  collect_metrics()
write_tsv(final_metrics, file = paste0(output, "_randomforest_final_metrics.tsv"))

writeLines("plotting predictions")

pdf(paste0(output, "_rf_prediction_plot.pdf"))
final_rf_fit %>%
  collect_predictions() %>%
  ggplot(aes(x=biodegradation_rate, y=.pred))+
  geom_point(alpha = 0.4, colour = "blue")+
  geom_abline(colour = "red", alpha = 0.9)
dev.off()

rf_tuning_best_model <- finalize_model(
  rf_model_tuning, ## this is the model we initially created with tune placeholders
  rf_tuning_best_params ## these are the best parameters identified in tuning
)

writeLines("plotting importance")

library(vip)

pdf(paste0(output, "_rf_importance_plot.pdf"))
rf_tuning_best_model %>%
  set_engine("ranger", importance = "permutation") %>%
  fit(
    biodegradation_rate ~ .,
    data = biodegradation_data_testing
  ) %>%
  vip(geom = "point")
dev.off()
