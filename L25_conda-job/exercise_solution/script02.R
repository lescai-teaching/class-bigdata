
library(tidyverse)
library(tidymodels)
tidymodels_prefer()


enzyme_process_data = readRDS(url("https://raw.githubusercontent.com/lescai-teaching/class-bigdata/main/L14_modelling_supervised_regression/L14_dataset_enzyme_process_data.rds"))


## FIRST WE SPLIT the dataset into training and testing
set.seed(358)

enzyme_split = initial_split(enzyme_process_data, prop = 0.75)
enzyme_training = training(enzyme_split)
enzyme_testing = testing(enzyme_split)



#########################
## RANDOM FOREST ########
#########################


rf_model_reg <- rand_forest() %>% 
  set_mode("regression") %>% 
  set_engine("ranger")


enzyme_rf_formula_fit <-
  rf_model_reg %>% 
  fit(formula = product ~ temperature + substrateA + substrateB + enzymeA + enzymeB + enzymeC + eA_rate + eB_rate + eC_rate, 
      data = enzyme_training)


enzyme_rf_prediction = enzyme_rf_formula_fit %>%
  predict(enzyme_testing) %>%
  bind_cols(enzyme_testing)

saveRDS(enzyme_rf_prediction, file = "enzyme_rf_prediction.rds")

pdf("enzyme_rf_prediction.pdf")
enzyme_rf_prediction %>%
  ggplot(aes(x=product, y=.pred))+
  geom_point(alpha = 0.4, colour = "blue")+
  geom_abline(colour = "red", alpha = 0.9)
dev.off()
