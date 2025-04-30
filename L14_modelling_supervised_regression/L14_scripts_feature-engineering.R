

library(tidyverse)
library(tidymodels)
tidymodels_prefer()


#######################
## center and scale ###
#######################


rf_model_reg <- rand_forest() %>% 
  set_mode("regression") %>% 
  set_engine("ranger")

## creating a recipe
enzyme_recipe <- 
  recipe(product ~ temperature + substrateA + substrateB + enzymeA + enzymeB + enzymeC + eA_rate + eB_rate + eC_rate, 
         data = enzyme_training) %>% 
  step_center(all_predictors()) %>% ## centre all predictors 
  step_scale(all_predictors()) ## scale all predictors


rf_workflow <- workflow() %>% 
  add_model(rf_model_reg) %>% 
  add_recipe(enzyme_recipe)


rf_wf_enzyme_fit <- fit(
  rf_workflow,
  enzyme_training
)

enzyme_rf_wf_prediction = rf_wf_enzyme_fit %>%
  predict(enzyme_testing) %>%
  bind_cols(enzyme_testing)

enzyme_rf_wf_prediction %>%
  ggplot(aes(x=product, y=.pred))+
  geom_point(alpha = 0.4, colour = "blue")+
  geom_abline(colour = "red", alpha = 0.9)

enzyme_rf_wf_prediction %>% 
  metrics(truth = product, estimate = .pred)

## if we compare with the previous model

enzyme_rf_prediction  %>%
  metrics(truth = product, estimate = .pred)

## we can see it has helped, just a little in terms of RSQ (increased) and RMSE (reduced)



########################
## splines #############
########################


enzyme_intermediate_data = readRDS(url("https://raw.githubusercontent.com/lescai-teaching/class-bigdata/main/L14_modelling_supervised_regression/L14_dataset_enzyme_intermediate_data.rds"))

### since the relationship is not linear
### we don't know which variable is not linearly correlated
## but we can modify the workflow steps

enzyme_intermediate_split = initial_split(enzyme_intermediate_data)
enzyme_intermediate_training = training(enzyme_intermediate_split)
enzyme_intermediate_testing = testing(enzyme_intermediate_split)

lm_model <-
  linear_reg() %>% 
  set_engine("lm")

enzyme_recipe_nonlinear <- recipe(intermediate_a ~ ., ### note how in regression you can use a shortcut for all others
                                  data = enzyme_intermediate_training) %>% 
  step_center(all_predictors()) %>% 
  step_scale(all_predictors()) %>%
  step_interact(~ temperature:eA_rate)  %>% ## interaction term
  step_ns(temperature, deg_free = 5) %>% ## splines for temperature
  step_ns(eA_rate, deg_free = 5) ## splines for enzyme rate

lm_workflow <- workflow() %>% 
  add_model(lm_model) %>% 
  add_recipe(enzyme_recipe_nonlinear)


lm_wf_enzyme_fit <- fit(
  lm_workflow,
  enzyme_intermediate_training
)

enzyme_lm_wf_prediction = lm_wf_enzyme_fit %>%
  predict(enzyme_intermediate_testing) %>%
  bind_cols(enzyme_intermediate_testing)

enzyme_lm_wf_prediction %>%
  ggplot(aes(x=intermediate_a, y=.pred))+
  geom_point(alpha = 0.4, colour = "blue")+
  geom_abline(colour = "red", alpha = 0.9)


enzyme_lm_wf_prediction %>% 
  metrics(truth = intermediate_a, estimate = .pred)

## if we compare with the previous performance

enzyme_lm_prediction %>%
  metrics(truth = product, estimate = .pred)

## this has helped dramatically
## and has even improved compared to random forest method



############################
## feature selection #######
############################


enzyme_mix_data = readRDS(url("https://raw.githubusercontent.com/lescai-teaching/class-bigdata/main/L14_modelling_supervised_regression/L14_dataset_enzyme_mix_data.rds"))

## if we run
ggpairs(enzyme_mix_data)

## we can see that some of the variables are highly correlated
cor(enzyme_mix_data$enzymeA, enzyme_mix_data$enzymeB, method = "pearson")
## which is the value reported on the pairs plot
## other correlations
# substrate C and substrate A
# substtate D and substrate A
# eA rate and temperature
# enzymeB and enzymeA
# substrate C and sustrate D

## let's eliminate the following

enzyme_mix_reduced = enzyme_mix_data %>% 
  select(-c(substrateC, substrateD, enzymeA, temperature))


## now we use the random forest to predict again the intermediate_a

reduced_recipe = recipe(
  formula = intermediate_a ~ substrateA + substrateB + enzymeB + eA_rate,
  data = enzyme_mix_reduced) %>% 
  step_center(all_predictors()) %>% 
  step_scale(all_predictors())


## we can use the same model as earlier

rf_model_reg <- rand_forest() %>% 
  set_mode("regression") %>% 
  set_engine("ranger")


### create subsets

enzyme_reduced_split = initial_split(enzyme_mix_reduced)
enzyme_reduced_training = training(enzyme_reduced_split)
enzyme_reduced_testing = training(enzyme_reduced_split)


## and now build the workflow

rf_reduced_wf = workflow() %>% 
  add_recipe(reduced_recipe) %>% 
  add_model(rf_model_reg)


enzyme_reduced_fit = fit(
  rf_reduced_wf,
  enzyme_reduced_training
)


enzyme_reduced_prediction = enzyme_reduced_fit %>%
  predict(enzyme_reduced_testing) %>%
  bind_cols(enzyme_reduced_testing)

enzyme_reduced_prediction %>%
  ggplot(aes(x=intermediate_a, y=.pred))+
  geom_point(alpha = 0.4, colour = "blue")+
  geom_abline(colour = "red", alpha = 0.9)


enzyme_reduced_prediction %>% 
  metrics(truth = intermediate_a, estimate = .pred)


## we get a basically perfect prediction even if we used enzymeB instead of enzymeA


