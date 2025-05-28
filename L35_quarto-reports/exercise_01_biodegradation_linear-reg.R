library(tidymodels)
library(tidyverse)
library(GGally)
library(vip)

biodegradation_data = readRDS(url("https://raw.githubusercontent.com/lescai-teaching/class-bigdata/main/L18_modelling_exercises/L18_dataset_biodegradation_data.rds"))


biodegradation_ggpairs <- ggpairs(biodegradation_data)
names(biodegradation_data)

biodegradation_data_split = initial_split(biodegradation_data, prop = 0.75)
biodegradation_data_training = training(biodegradation_data_split)
biodegradation_data_testing = testing(biodegradation_data_split)

lm_model <-
  linear_reg() %>% 
  set_engine("lm")

biodegradation_recipe <- 
  recipe(biodegradation_rate ~ ., 
         data = biodegradation_data_training) %>% 
  step_normalize(all_predictors())


biodegradation_lm_workflow <- workflow() %>% 
  add_model(lm_model) %>% 
  add_recipe(biodegradation_recipe)


biodegradation_lm_wf_fit <- fit(
  biodegradation_lm_workflow,
  biodegradation_data_training
)

biodegradation_lm_wf_prediction = biodegradation_lm_wf_fit %>%
  predict(biodegradation_data_testing) %>%
  bind_cols(biodegradation_data_testing)

biodegradation_lm_wf_prediction_plot <- biodegradation_lm_wf_prediction %>%
  ggplot(aes(x=biodegradation_rate, y=.pred))+
  geom_point(alpha = 0.4, colour = "blue")+
  geom_abline(colour = "red", alpha = 0.9)



biodegradation_lm_wf_prediction_table <- biodegradation_lm_wf_prediction %>% 
  metrics(truth = biodegradation_rate, estimate = .pred)
