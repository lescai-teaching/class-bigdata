#!/usr/bin/env Rscript

library(tidyverse)
library(tidymodels)

args   = commandArgs(trailingOnly=TRUE)
input  = args[1]
cores  = args[2]
output = args[3]


writeLines("######### reading input data")
metastasis_risk_data = readRDS(input)


writeLines("######### splitting training / validation")
metastasis_risk_data_split = initial_split(metastasis_risk_data)
metastasis_risk_data_training = training(metastasis_risk_data_split)
metastasis_risk_data_testing = testing(metastasis_risk_data_split)


writeLines("######### assembling model specs")
logreg_model <- logistic_reg() %>% 
  set_mode("classification") %>% 
  set_engine("glm")

writeLines("######### assembling recipe")
logreg_recipe <- recipe(metastasis_risk ~ .,
        data = metastasis_risk_data_training
  ) %>% 
  step_zv() %>% 
  step_normalize(all_numeric_predictors()) %>% 
  step_dummy(all_nominal_predictors())

writeLines("######### assembling model workflow")
logreg_wf <- workflow() %>% 
  add_recipe(logreg_recipe) %>% 
  add_model(logreg_model)

writeLines("######### fitting the model workflow")
logreg_wf_fit <- fit(
  logreg_wf,
  metastasis_risk_data_training
)


writeLines("######### saving fitted model")
saveRDS(logreg_wf_fit, file = "logreg_fitted_model.rds")


writeLines("######### collecting prediction")
logreg_wf_prediction <-
  bind_cols(
    metastasis_risk_data_testing,
    logreg_wf_fit %>% 
      predict(metastasis_risk_data_testing),
    logreg_wf_fit %>% 
      predict(metastasis_risk_data_testing, type = "prob")
  )

risk_levels = c("High", "Medium", "Low")

writeLines("######### plot confusion matrix")
pdf("logreg_confusion-matrix_plot.pdf")
logreg_wf_prediction %>% 
  mutate(
    metastasis_risk = factor(metastasis_risk, levels = risk_levels),
    .pred_class = factor(.pred_class, levels = risk_levels)
  ) %>% 
  conf_mat(truth = metastasis_risk, estimate = .pred_class) %>% 
  autoplot(type = "heatmap")
dev.off()



writeLines("######### variable importance")
library(vip)

pdf("logreg_variable-importance_plot.pdf")
logreg_wf_fit %>% 
  extract_fit_parsnip() %>% 
  vip(num_features = 10)
dev.off()


writeLines("######### CALC COMPLETED")