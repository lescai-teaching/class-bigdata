library(tidymodels)
library(tidyverse)
library(GGally)
library(vip)


############ EXPLAINABILITY ###############



### from the random forest

biodegradation_rf_wf_fit %>% 
  extract_fit_parsnip() %>% 
  vip(num_features = 10, geom = "point")



# Data exploration - scatter plot to visualise the relationship between gender and the outcome variable
ggplot(biodegradation_data, 
       aes(y=biodegradation_rate, x=temperature))+
  geom_point()+
  coord_flip()


#### Inference
### causality can be derived from the linear regression

tidy(biodegradation_lm_wf_fit, exponentiate = TRUE) %>% 
  filter(p.value < 0.05) 

### we could also fit a simple linear regression with just one of the predictors
### using classic R 

temperature_fit <- lm(biodegradation_rate ~ temperature, biodegradation_data)
tidy(temperature_fit)


