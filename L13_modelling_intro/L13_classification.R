
heart_disease_data = readRDS(url("https://raw.githubusercontent.com/lescai-teaching/class-bigdata/main/L13_modelling_intro/L13_dataset_heart_disease_data.rds"))


## first let's split

heart_disease_split = initial_split(heart_disease_data, prop = 0.8)

## then training and testing

heart_disease_training = training(heart_disease_split)
heart_disease_testing = testing(heart_disease_split)

### now we prepare the model

rf_model <- rand_forest() %>% 
  set_mode("classification") %>% 
  set_engine("ranger")


heart_disease_fit = rf_model %>% 
  fit(heart_disease_risk ~ ., data = heart_disease_training)


## let's make a prediction and check it

heart_disease_predictions = heart_disease_testing %>% 
  bind_cols(
    predict(heart_disease_fit, heart_disease_testing),
    predict(heart_disease_fit, heart_disease_testing, type = "prob")
  )


## let's quickly check how our predictions go
table(heart_disease_predictions$heart_disease_risk, heart_disease_predictions$.pred_class)

## we will discuss in the next class how we can improve this