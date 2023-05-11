#!/usr/bin/env Rscript

library(tidyverse)
library(tidymodels)

args   = commandArgs(trailingOnly=TRUE)
input  = args[1]
cores  = args[2]
output = args[3]

writeLines("receiving data")
biodegradation_data = readRDS(input)

writeLines("splitting dataset")
set.seed(367)
biodegradation_data_split = initial_split(biodegradation_data, prop = 0.75)
biodegradation_data_training = training(biodegradation_data_split)
biodegradation_data_testing = testing(biodegradation_data_split)

writeLines("assembling workflow")
lm_model <-
    linear_reg(
        penalty = tune(),
        mixture = tune()
    ) %>% 
    set_engine("glmnet")

lm_tuning_grid <- grid_regular(penalty(),
    mixture(range = c(0.3,0.7)),
    levels = 3)

biodegradation_recipe <- 
    recipe(biodegradation_rate ~ ., 
        data = biodegradation_data_training) %>% 
    step_normalize(all_predictors())


biodegradation_lm_workflow <- workflow() %>% 
    add_model(lm_model) %>% 
    add_recipe(biodegradation_recipe)


set.seed(234)
biodegradation_folds <- vfold_cv(biodegradation_data_training)

# this code seems to get stuck in creating the cluster
# this code seems to get stuck in creating the cluster
writeLines("loading doParallel library")
library(doParallel) 
writeLines("registering parallel without creating the cluster")
registerDoParallel(cores=cores)

writeLines("starting tuning")
lm_tuning_results <- 
    biodegradation_lm_workflow %>% 
    tune_grid(
        resamples = biodegradation_folds,
        grid = lm_tuning_grid
    )

writeLines("tuning complete - collecting metrics")
tuning_metrics = lm_tuning_results %>%
  collect_metrics()
write_tsv(tuning_metrics, file = paste0(output, "_lm_tuning_metrics.tsv"))

## and we can select the model in a model object

lm_tuning_best_params = lm_tuning_results %>%
  select_best("rmse")

### in order to USE the params for predictions
### we need to "finalise" the workflow after tuning
### using the best model we just saved

writeLines("finalising workflow")
final_lm_wf <- biodegradation_lm_workflow %>% 
  finalize_workflow(lm_tuning_best_params)


## and do a "last" fit on the split data which will automatically
## run on the test split

final_lm_fit <- final_lm_wf %>% 
  last_fit(biodegradation_data_split)

## metrics

final_metrics = final_lm_fit %>% 
  collect_metrics()
write_tsv(final_metrics, file = paste0(output, "_lm_final_metrics.tsv"))

writeLines("plotting predictions")

pdf(paste0(output, "_lm_predictions_plot.pdf"))
final_lm_fit %>%
  collect_predictions() %>% 
  ggplot(aes(x=biodegradation_rate, y=.pred))+
  geom_point(alpha = 0.4, colour = "blue")+
  geom_abline(colour = "red", alpha = 0.9)
dev.off()


lm_tuning_best_model <- finalize_model(
  lm_model,
  lm_tuning_best_params
)

writeLines("creating importance plot")

library(vip)

pdf(paste0(output, "_lm_importance_plot.pdf"))
lm_tuning_best_model %>%
  set_engine("glmnet", importance = "permutation") %>%
  fit(
    biodegradation_rate ~ .,
    data = biodegradation_data_testing
  ) %>%
  vip(geom = "point")
dev.off()
