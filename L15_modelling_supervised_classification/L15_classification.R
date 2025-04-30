
logreg_variants = readRDS(url("https://raw.githubusercontent.com/lescai-teaching/class-bigdata/main/L15_modelling_supervised_classification/L15_dataset_logreg_variants.rds"))


library(tidymodels)
library(tidyverse)

variants_split = initial_split(logreg_variants %>% 
                                 dplyr::select(-c(individual)) %>% 
                                 mutate(phenotype = factor(phenotype, levels = c("control", "case"))),
                               prop = 0.75)
variants_training = training(variants_split)
variants_testing = testing(variants_split)


logistic_model <- logistic_reg() %>% 
  set_engine("glm") %>% 
  set_mode("classification")

variants_recipe <- recipe(phenotype ~ ., data = variants_training) %>% 
  step_dummy(all_nominal_predictors()) %>%
  step_normalize()

logreg_wf_variants <- workflow() %>% 
  add_recipe(variants_recipe) %>% 
  add_model(logistic_model)


logreg_variants_fit <- fit(
  logreg_wf_variants,
  variants_training
)


tidy(logreg_variants_fit)

## we can convert the estimates to an odds-ratio
## and also filter nominally significant variants

tidy(logreg_variants_fit, exponentiate = TRUE) %>% 
  filter(p.value < 0.05) 


phenotype_variants_prediction = bind_cols(
  variants_testing %>% dplyr::select(phenotype),
  logreg_variants_fit %>% 
    predict(variants_testing, type = "class"),
  logreg_variants_fit %>% 
    predict(variants_testing, type = "prob")
)
  
phenotype_variants_prediction %>% metrics(truth = phenotype, estimate = .pred_class)

precision(phenotype_variants_prediction, truth = phenotype, estimate = .pred_class)
recall(phenotype_variants_prediction, truth = phenotype, estimate = .pred_class)

###########################################
## now let's see by selecting the variants

sig_variants = tidy(logreg_variants_fit, exponentiate = TRUE) %>% 
  filter(p.value < (0.05/100)) %>% ## remember bonferroni correction
  filter(term != "(Intercept)") %>% 
  mutate(
    variant = sub("^(chr.+_.+)_X.+$", "\\1", term)
  ) %>% 
  pull(variant) %>% unique()

## the number of nominally significant variants is:
length(sig_variants)

## we use for the formula only the significant variants
## have a look at what the paste0 code does

variants_selection_recipe <- 
  recipe(as.formula(paste0("phenotype", "~", paste0(sig_variants, collapse = " + "))),
         data = variants_training) %>% 
  step_dummy(all_nominal_predictors()) %>%
  step_normalize()



logreg_wf_selected_variants <- workflow() %>% 
  add_recipe(variants_selection_recipe) %>% 
  add_model(logistic_model)


logreg_selected_variants_fit <- fit(
  logreg_wf_selected_variants,
  variants_training
)


phenotype_selected_variants_prediction = bind_cols(
  variants_testing %>% dplyr::select(phenotype),
  logreg_selected_variants_fit %>% 
    predict(variants_testing, type = "class"),
  logreg_selected_variants_fit %>% 
    predict(variants_testing, type = "prob")
)

phenotype_selected_variants_prediction %>% metrics(truth = phenotype, estimate = .pred_class)

## current model
precision(phenotype_selected_variants_prediction, truth = phenotype, estimate = .pred_class)
recall(phenotype_selected_variants_prediction, truth = phenotype, estimate = .pred_class)

## previoius model
precision(phenotype_variants_prediction, truth = phenotype, estimate = .pred_class)
recall(phenotype_variants_prediction, truth = phenotype, estimate = .pred_class)

## we have modestly improved in precision, not much in recall
f_meas(phenotype_variants_prediction, truth = phenotype, estimate = .pred_class)
f_meas(phenotype_selected_variants_prediction, truth = phenotype, estimate = .pred_class)
## overall a modest improvement in accuracy


################################################
### RANDOM FOREST CLASSIFIER ###################
################################################

library(tidymodels)

rf_model <- rand_forest() %>% 
  set_mode("classification") %>% 
  set_engine("ranger")

predictors <- names(logreg_variants)[!(names(logreg_variants) %in% c("individual", "phenotype"))]

rf_variants_recipe <- recipe(
  as.formula(
    paste0("phenotype ~ ", paste0(predictors, collapse = " + "))
  ),
  data = variants_training
) %>% 
  step_dummy(all_predictors()) %>% 
  step_normalize()

rf_class_wf <- workflow() %>% 
  add_model(rf_model) %>% 
  add_recipe(rf_variants_recipe)

rf_class_fit <- fit(
  rf_class_wf,
  variants_training
)


phenotype_rf_prediction = bind_cols(
  variants_testing %>% dplyr::select(phenotype),
  rf_class_fit %>% 
    predict(variants_testing, type = "class"),
  rf_class_fit %>% 
    predict(variants_testing, type = "prob")
)


precision(phenotype_rf_prediction, truth = phenotype, estimate = .pred_class)
recall(phenotype_rf_prediction, truth = phenotype, estimate = .pred_class)
f_meas(phenotype_rf_prediction, truth = phenotype, estimate = .pred_class)
