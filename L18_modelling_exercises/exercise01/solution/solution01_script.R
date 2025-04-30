
biodegradation_data = readRDS(url("https://raw.githubusercontent.com/lescai-teaching/class-bigdata/main/L18_modelling_exercises/L18_dataset_biodegradation_data.rds"))


ggpairs(biodegradation_data)
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

biodegradation_lm_wf_prediction %>%
  ggplot(aes(x=biodegradation_rate, y=.pred))+
  geom_point(alpha = 0.4, colour = "blue")+
  geom_abline(colour = "red", alpha = 0.9)



biodegradation_lm_wf_prediction %>% 
  metrics(truth = biodegradation_rate, estimate = .pred)


### testing random forest for regression

rf_model <- rand_forest(
  trees = 1000
  ) %>% 
  set_mode("regression") %>% 
  set_engine("ranger")

biodegradation_rf_recipe <- 
  recipe(as.formula(paste0("biodegradation_rate ~ ", 
                           paste0(
                             names(biodegradation_data_training)[!names(biodegradation_data_training) %in% c("biodegradation_rate")],
                             collapse = " + "
                             )
                           )
                    ), 
         data = biodegradation_data_training) %>% 
  step_normalize(all_predictors())


biodegradation_rf_workflow <- workflow() %>% 
  add_model(rf_model) %>% 
  add_recipe(biodegradation_rf_recipe)


biodegradation_rf_wf_fit <- fit(
  biodegradation_rf_workflow,
  biodegradation_data_training
)

biodegradation_rf_wf_prediction = biodegradation_rf_wf_fit %>%
  predict(biodegradation_data_testing) %>%
  bind_cols(biodegradation_data_testing)

biodegradation_rf_wf_prediction %>%
  ggplot(aes(x=biodegradation_rate, y=.pred))+
  geom_point(alpha = 0.4, colour = "blue")+
  geom_abline(colour = "red", alpha = 0.9)



biodegradation_rf_wf_prediction %>% 
  metrics(truth = biodegradation_rate, estimate = .pred)

