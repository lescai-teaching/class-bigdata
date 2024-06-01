#!/usr/bin/env Rscript

library(tidyverse)
library(tidymodels)

args   = commandArgs(trailingOnly=TRUE)
input  = args[1]
cores  = args[2]
output = args[3]

writeLines("Load the dataset")
blood_pressure_data = readRDS(input)

writeLines("Split the data into training and testing")
set.seed(123)
blood_pressure_data_split <- initial_split(blood_pressure_data, prop = 0.75)
blood_pressure_data_training <- training(blood_pressure_data_split)
blood_pressure_data_testing <- testing(blood_pressure_data_split)

saveRDS(blood_pressure_data_split, paste0(output, "_initial_split.rds"))
saveRDS(blood_pressure_data_training, paste0(output, "_training_split.rds"))
saveRDS(blood_pressure_data_testing, paste0(output, "_testing_split.rds"))


############################
### K-NEAREST NEIGHBOURS ###
############################


writeLines("Define the model - tuning of the neighbours hyperparameter")
knn_model <-
  nearest_neighbor(
    neighbors = tune(), 
    weight_func = "triangular") %>%
  set_mode("regression") %>%
  set_engine("kknn")

writeLines("Set up the tuning grid")
knn_tuning_grid <- grid_regular(
  neighbors(range = c(3L,8L))
)

writeLines("Generate data folds")
set.seed(123)
blood_pressure_data_folds <- vfold_cv(blood_pressure_data_training)

writeLines("Create the recipe")
knn_recipe <- recipe(blood_pressure_systolic ~ .,
                     data = blood_pressure_data_training) %>% 
  step_dummy(all_nominal_predictors()) %>%
  step_normalize(all_predictors())

writeLines("Create the workflow")
knn_wf <- workflow() %>% 
  add_model(knn_model) %>% 
  add_recipe(knn_recipe)

writeLines("Tune")
knn_tuning_results <- knn_wf %>% 
  tune_grid(
    resamples = blood_pressure_data_folds,
    grid = knn_tuning_grid
  )

writeLines("Tuning complete - collecting metrics")
knn_tuning_metrics <- knn_tuning_results %>% 
  collect_metrics()
write_tsv(knn_tuning_metrics, paste0(output, "_tuning_metrics.tsv"))

writeLines("Extract best hyperparams")
knn_tuning_best_params <- knn_tuning_results %>%
  select_best("rmse")
write_tsv(knn_tuning_best_params, file = paste0(output, "_tuning_best_params.tsv"))

writeLines("Finalise the workflow")
final_knn_wf <- knn_wf %>% 
  finalize_workflow(knn_tuning_best_params)

writeLines("Fit the workflow with the best hyperparameters")
final_knn_fit <- final_knn_wf %>% 
  last_fit(blood_pressure_data_split)
saveRDS(final_knn_fit, paste0(output, "_final_fit.rds"))

writeLines("Collect the final metrics")
final_knn_metrics <- final_knn_fit %>% 
  collect_metrics()
write_tsv(final_knn_metrics, file = paste0(output, "_final_metrics.tsv"))

writeLines("Save the prediction")
pdf(paste0(output, "_predictions_plot.pdf"))
final_knn_fit %>% 
  collect_predictions() %>% 
  ggplot(aes(x=blood_pressure_systolic, y=.pred))+
  geom_point(alpha = 0.4, colour = "blue")+
  geom_abline(colour = "red", alpha = 0.9)
dev.off()

writeLines("Save the best model")
knn_tuning_best_model <- finalize_model(
  knn_model,
  knn_tuning_best_params
)
saveRDS(knn_tuning_best_model, paste0(output, "_best_model.rds"))

writeLines("Save workspace image")
save.image(paste0(output, "_calc.RData"))
