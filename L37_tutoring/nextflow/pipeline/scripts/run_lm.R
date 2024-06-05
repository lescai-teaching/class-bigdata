#!/usr/bin/env Rscript

library(tidyverse)
library(tidymodels)
library(vip)

args   = commandArgs(trailingOnly=TRUE)
input  = args[1]
cores  = args[2]
output = args[3]

writeLines("Load the dataset")
blood_pressure_data <- readRDS(input)

writeLines("Split the data into training and testing")
set.seed(123)
blood_pressure_data_split <- initial_split(blood_pressure_data, prop = 0.75)
blood_pressure_data_training <- training(blood_pressure_data_split)
blood_pressure_data_testing <- testing(blood_pressure_data_split)

saveRDS(blood_pressure_data_split, paste0(output, "_initial_split.rds"))
saveRDS(blood_pressure_data_training, paste0(output, "_training_split.rds"))
saveRDS(blood_pressure_data_testing, paste0(output, "_testing_split.rds"))


#########################
### LINEAR REGRESSION ###
#########################


writeLines("Define the model")
lm_model <-
  linear_reg(
    penalty = tune(),
    mixture = tune()
  ) %>% 
  set_engine("glmnet")

writeLines("Create hyperparameters table")
lm_tuning_grid <- grid_regular(penalty(),
    mixture(range = c(0.3,0.7)),
    levels = 3)

writeLines("Generate data folds")
set.seed(234)
blood_pressure_data_folds <- vfold_cv(blood_pressure_data_training)

writeLines("Create the recipe")
lm_recipe <- 
  recipe(blood_pressure_systolic ~ ., 
         data = blood_pressure_data_training) %>% 
  step_dummy(all_nominal_predictors()) %>%
  step_normalize(all_predictors())

writeLines("Create the workflow")
lm_wf <- workflow() %>% 
  add_model(lm_model) %>% 
  add_recipe(lm_recipe)
 
writeLines("Fit the workflow")
lm_wf_fit <- fit(
  lm_wf,
  blood_pressure_data_training
)

writeLines("Tune")
lm_tuning_results <- lm_wf %>% 
  tune_grid(
    resamples = blood_pressure_data_folds,
    grid = lm_tuning_grid
  )

writeLines("Tuning complete - collecting metrics")
lm_tuning_metrics <- lm_tuning_results %>%
  collect_metrics()
write_tsv(lm_tuning_metrics, file = paste0(output, "_tuning_metrics.tsv"))

writeLines("Extract best hyperparams")
lm_tuning_best_params <- lm_tuning_results %>%
  select_best("rmse")
write_tsv(lm_tuning_best_params, file = paste0(output, "_tuning_best_params.tsv"))

writeLines("Finalise the workflow")
final_lm_wf <- lm_wf %>% 
  finalize_workflow(lm_tuning_best_params)

writeLines("Fit the workflow with the best hyperparameters")
final_lm_fit <- final_lm_wf %>%
  last_fit(blood_pressure_data_split)
saveRDS(final_lm_fit, paste0(output, "_final_fit.rds"))

writeLines("Collect the final metrics")
final_lm_metrics <- final_lm_fit %>% 
  collect_metrics()
write_tsv(final_lm_metrics, file = paste0(output, "_final_metrics.tsv"))

writeLines("Save the prediction")
pdf(paste0(output, "_predictions_plot.pdf"))
final_lm_fit %>% 
  collect_predictions() %>% 
  ggplot(aes(x=blood_pressure_systolic, y=.pred))+
  geom_point(alpha = 0.4, colour = "blue")+
  geom_abline(colour = "red", alpha = 0.9)
dev.off()

writeLines("Save the best model")
lm_tuning_best_model <- finalize_model(
  lm_model,
  lm_tuning_best_params
)
saveRDS(lm_tuning_best_model, paste0(output, "_best_model.rds"))

writeLines("Save importance plot")
pdf(paste0(output, "_importance_plot.pdf"))
lm_tuning_best_model %>%
  set_engine("glmnet", importance = "permutation") %>%
  fit(
    blood_pressure_systolic ~ .,
    data = blood_pressure_data_testing
  ) %>%
  vip(geom = "point")
dev.off()

writeLines("Save workspace image")
save.image(paste0(output, "_calc.RData"))
