#!/usr/bin/env Rscript

library(tidyverse)
library(tidymodels)

args   = commandArgs(trailingOnly=TRUE)
input  = args[1]
cores  = args[2]
output = args[3]


library(tidyverse)
library(tidymodels)
library(tidyclust)
library(GGally)

writeLines("######### reading input data")
metastasis_risk_data = readRDS(input)


writeLines("######### splitting training / validation")
metastasis_risk_data_split = initial_split(metastasis_risk_data)
metastasis_risk_data_training = training(metastasis_risk_data_split)
metastasis_risk_data_testing = testing(metastasis_risk_data_split)


writeLines("######### assembling random forest model specs")
rf_model <- rand_forest(
  trees = 2000,
  min_n = 20
) %>% 
  set_mode("classification") %>% 
  set_engine("ranger")
  

writeLines("######### assembling random forest recipe")
rf_recipe <- recipe(metastasis_risk ~ .,
      data = metastasis_risk_data_training) %>% 
  step_zv() %>% 
  step_normalize(all_numeric_predictors()) %>% 
  step_dummy(all_nominal_predictors())

writeLines("######### assembling model workflow")
rf_workflow <- workflow() %>% 
  add_recipe(rf_recipe) %>% 
  add_model(rf_model)

writeLines("######### fitting assembled model")
rf_workflow_fit <-
  rf_workflow %>% 
  fit(metastasis_risk_data_training)

writeLines("######### saving fitted model")
saveRDS(rf_workflow_fit, file = "randomforest_fitted_model.rds")

writeLines("######### collecting predictions from fit")
rf_workflow_prediction <- bind_cols(
  metastasis_risk_data_testing,
  rf_workflow_fit %>% 
    predict(metastasis_risk_data_testing),
  rf_workflow_fit %>% 
    predict(metastasis_risk_data_testing, type = "prob")
)

risk_levels = c("High", "Medium", "Low")

writeLines("######### generating ROC curve plot")
pdf("randomforest_ROC_plot.pdf")
rf_workflow_prediction %>% 
  mutate(
    metastasis_risk = factor(metastasis_risk, levels = risk_levels),
    .pred_class = factor(.pred_class, levels = risk_levels)
  ) %>%
  roc_curve(metastasis_risk, .pred_Low, .pred_Medium, .pred_High) %>% 
  autoplot()
dev.off()


writeLines("######### generating confusion matrix plot")
pdf("randomforest_confusion-matrix_plot.pdf")
rf_workflow_prediction %>% 
  mutate(
    metastasis_risk = factor(metastasis_risk, levels = risk_levels),
    .pred_class = factor(.pred_class, levels = risk_levels)
  ) %>% 
  conf_mat(truth = metastasis_risk, estimate = .pred_class) %>% 
  autoplot(type = "heatmap")
dev.off()


writeLines("######### ")
library(vip)

pdf("randomforest_importance_plot.pdf")
rf_model %>%
  set_engine("ranger", importance = "permutation") %>%
  fit(
    metastasis_risk ~ .,
    data = metastasis_risk_data_testing %>% 
      mutate(metastasis_risk = factor(metastasis_risk, levels = risk_levels))
  ) %>%
  vip(geom = "point")
dev.off()