#!/bin/Rscript

library(tidymodels)
library(tidyverse)

logreg_variants = readRDS(url("https://raw.githubusercontent.com/lescai-teaching/class-bigdata/main/L15_modelling_supervised_classification/L15_dataset_logreg_variants.rds"))


rf_model_tuning <- rand_forest(
  mtry = tune(),
  trees = tune(),
  min_n = tune()
) %>% 
  set_mode("classification") %>% 
  set_engine("ranger")


rf_tuning_grid <- grid_regular(mtry(range = c(5L,8L)),
                          trees(),
                          min_n(),
                          levels = 3)

## testing / training / validation
## pay attention to the concept

set.seed(324)
variants_new_split = initial_split(logreg_variants %>% 
                                     dplyr::select(-c(individual)) %>% 
                                     mutate(phenotype = factor(phenotype, levels = c("control", "case"))),
                                   prop = 0.75)
variants_new_training = training(variants_new_split)
variants_new_testing = testing(variants_new_split)

## now we further split the training into training itself and validation of the step

set.seed(234)
variants_folds <- vfold_cv(variants_new_training)


## the recipe is going to be the same, as it defines the characteristics
## of the input, relationships of the variables and transformations

predictors <- names(logreg_variants)[!(names(logreg_variants) %in% c("individual", "phenotype"))]


rf_variants_recipe <- recipe(
  as.formula(
    paste0("phenotype ~ ", paste0(predictors, collapse = " + "))
  ),
  data = variants_new_training
) %>% 
  step_dummy(all_predictors()) %>% 
  step_normalize()

## the workflow instead is created according to the above

rf_class_tune_wf <- workflow() %>% 
  add_model(rf_model_tuning) %>% 
  add_recipe(rf_variants_recipe)

## now in order to run the tuning using the cores we requested,
## we need to register the cluster

library(doParallel)                                                                                                                                                                          
cl <- makePSOCKcluster(4)
registerDoParallel(cl)

rf_tuning_results <- 
  rf_class_tune_wf %>% 
  tune_grid(
    resamples = variants_folds,
    grid = rf_tuning_grid
  )


rf_tuning_results %>% 
  collect_metrics() %>%
  write_tsv(file = "metrics_collected.tsv")

pdf("metrics_plot.pdf")
rf_tuning_results %>% 
  collect_metrics() %>% 
  ggplot(aes(x=trees, y=mean, color = factor(min_n)))+
  geom_line(linewidth = 1.5, alpha = 0.6) +
  geom_point(size = 2) +
  facet_wrap(.metric ~ mtry, ncol = 3) +
  scale_x_log10(labels = scales::label_number()) +
  scale_color_viridis_d(option = "plasma", begin = .9, end = 0)
dev.off()