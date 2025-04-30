

library(tidymodels)
tidymodels_prefer()

## read the data in
photosynthesis_data = readRDS(url("https://raw.githubusercontent.com/lescai-teaching/class-bigdata/main/L13_modelling_intro/L13_dataset_photosynthesis_data.rds"))


## split in training and testing
set.seed(502)
photosynthesis_split = initial_split(photosynthesis_data, prop = 0.8)

## inspect the results
photosynthesis_split


## create training data
photosynthesis_training = training(photosynthesis_split)

## create testing data
photosynthesis_testing = testing(photosynthesis_split)

## reflect on the need to split with strata

### define the mathematical structure

lm_model <-
  linear_reg() %>% 
  set_engine("lm")


## fit the model, by defining the relationship
## between the variables

lm_formula_fit <-
  lm_model %>% 
  fit(rate ~ light + temperature + co2, data = photosynthesis_training)


## now there's several ways to inspect the model
## simplest is just

lm_formula_fit

## what has been printed is the fit of the model
## which can also be extracted with

lm_formula_fit %>% extract_fit_engine()


## ths function allows to apply further methods to the fitted model
## such as

## best way to summarise is using a coherent tidymodels function

tidy(lm_formula_fit)

## all variables are clearly associated with the photosynthesis rate

## now we're ready to make a prediction

predicted_photosynthesis_rate = predict(lm_formula_fit, photosynthesis_testing)

## let's inspect this object

predicted_photosynthesis_rate

## we can also add a confidence interval to the prediction

predicted_photosynthesis_rate = predicted_photosynthesis_rate %>% 
  bind_cols(
    predict(lm_formula_fit, photosynthesis_testing, type = "pred_int") ## note addition of "type"
)


### now we can verify what our model predicts

photosynthesis_testing %>% 
  bind_cols(
    predicted_photosynthesis_rate
  ) %>% 
  ggplot(aes(x=rate, y=.pred))+
  geom_point()+
  geom_abline(intercept = 0, slope = 1, colour = "blue")


### we can observe that the relationship is not exactly linear
### something we might have guessed in the initial plots
