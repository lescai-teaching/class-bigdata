#!/usr/bin/env Rscript

library(tidyverse)
library(tidymodels)

parser <- ArgumentParser()

parser$add_argument("-i", "--input", action="store_true", default=TRUE,
    help="Dataset in RDS format to be used for modelling")
parser$add_argument("-c", "--cores", action="store_true", default=2,
    help="Number of cores to be used for parallel tuning")
parser$add_argument("-o", "--output", action="store_true", default="output",
    help="Base name for output files")

args <- parser$parse_args()

biodegradation_data = readRDS(args$input)

set.seed(367)
biodegradation_data_split = initial_split(biodegradation_data, prop = 0.75)
biodegradation_data_training = training(biodegradation_data_split)
biodegradation_data_testing = testing(biodegradation_data_split)



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
    levels = 5)



biodegradation_recipe <- 
    recipe(biodegradation_rate ~ ., 
        data = biodegradation_data_training) %>% 
    step_normalize(all_predictors())


rf_regression_tune_wf <- workflow() %>% 
    add_model(rf_model_tuning) %>% 
    add_recipe(biodegradation_recipe)


set.seed(234)
biodegradation_folds <- vfold_cv(biodegradation_data_training)

library(doParallel) 
cl <- makePSOCKcluster(args$cores) ## the argument is set dynamically based on inputs
registerDoParallel(cl)



rf_tuning_results <- 
    rf_regression_tune_wf %>% 
    tune_grid(
    resamples = biodegradation_folds,
    grid = rf_tuning_grid
    )


rf_tuning_results %>% 
    collect_metrics() %>%
    write_tsv(file = paste0(args$output, "_randomforest_tuning_metrics.tsv"))



rf_tuning_best_params = rf_tuning_results %>%
    select_best("accuracy")

final_rf_wf <- rf_class_tune_wf %>% 
    finalize_workflow(rf_tuning_best_params)

final_rf_fit <- final_rf_wf %>% 
    last_fit(biodegradation_data_split)

## metrics


final_metrics = final_rf_fit %>% 
    collect_metrics()
write_tsv(final_metrics, file = paste0(args$output, "_randomforest_final_metrics.tsv"))


pdf(paste0(args$output, "_rf_roc-curve_plot.pdf"))
final_rf_fit %>%
    collect_predictions() %>% 
    roc_curve(biodegradation_rate, .pred_control) %>% 
    autoplot()
dev.off()

rf_tuning_best_model <- finalize_model(
    rf_model_tuning, ## this is the model we initially created with tune placeholders
    rf_tuning_best_params ## these are the best parameters identified in tuning
)


library(vip)

pdf(paste0(args$output, "_rf_importance_plot.pdf"))
rf_tuning_best_model %>%
    set_engine("ranger", importance = "permutation") %>%
    fit(
        biodegradation_rate ~ .,
        data = variants_new_testing
    ) %>%
    vip(geom = "point")
dev.off()
