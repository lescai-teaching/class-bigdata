
library(tidyverse)
library(tidymodels)
tidymodels_prefer()


enzyme_process_data = readRDS(url("https://raw.githubusercontent.com/lescai-teaching/class-bigdata/main/L14_modelling_supervised_regression/L14_dataset_enzyme_process_data.rds"))


## FIRST WE SPLIT the dataset into training and testing
set.seed(358)

enzyme_split = initial_split(enzyme_process_data, prop = 0.75)
enzyme_training = training(enzyme_split)
enzyme_testing = testing(enzyme_split)


########################
# LINEAR REGRESSION ####
########################

### define the mathematical structure

lm_model <-
  linear_reg() %>% 
  set_engine("lm")


## fit the model, by defining the relationship
## between the variables

enzyme_lm_formula_fit <-
  lm_model %>% 
  fit(product ~ ., data = enzyme_training)


## now there's several ways to inspect the model
## simplest is just

enzyme_lm_formula_fit

## what has been printed is the fit of the model
## which can also be extracted with

enzyme_lm_formula_fit %>% extract_fit_engine()


## ths function allows to apply further methods to the fitted model
## such as

## best way to summarise is using a coherent tidymodels function

tidy(enzyme_lm_formula_fit)


enzyme_lm_prediction = enzyme_lm_formula_fit %>%
  predict(enzyme_testing) %>%
  bind_cols(enzyme_testing)

saveRDS(enzyme_lm_prediction, file = 'enzyme_lm_prediction.rds')

pdf("enzyme_lm_prediction.pdf")
enzyme_lm_prediction %>%
  ggplot(aes(x=product, y=.pred))+
  geom_point(alpha = 0.4, colour = "blue")+
  geom_abline(colour = "red", alpha = 0.9)
dev.off()