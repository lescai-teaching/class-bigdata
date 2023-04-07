
```R
library(tidyverse)
library(tidymodels)
library(tidyclust)
library(GGally)
```



```R
metastasis_risk_data = readRDS(url("https://raw.githubusercontent.com/lescai-teaching/class-bigdata-2023/main/L18_modelling_exercises/L18_dataset_metastasis_risk_data.rds"))
```

```R
ggpairs(metastasis_risk_data, aes(colour = metastasis_risk))
```


```R
metastasis_risk_data_split = initial_split(metastasis_risk_data)
metastasis_risk_data_training = training(metastasis_risk_data_split)
metastasis_risk_data_testing = testing(metastasis_risk_data_split)
```



```R
logreg_model <- logistic_reg() %>% 
  set_mode("classification") %>% 
  set_engine("glm")
```



```R
logreg_recipe <- recipe(metastasis_risk ~ .,
                        data = metastasis_risk_data_training) %>% 
  step_zv() %>% 
  step_normalize(all_numeric_predictors()) %>% 
  step_dummy(all_nominal_predictors())
```



```R
logreg_wf <- workflow() %>% 
  add_recipe(logreg_recipe) %>% 
  add_model(logreg_model)
```



```R
logreg_wf_fit <- fit(
  logreg_wf,
  metastasis_risk_data_training
)
```


```R
logreg_wf_prediction <-
  bind_cols(
    metastasis_risk_data_testing,
    logreg_wf_fit %>% 
      predict(metastasis_risk_data_testing),
    logreg_wf_fit %>% 
      predict(metastasis_risk_data_testing, type = "prob")
  )
```

```R
logreg_wf_prediction %>% metrics(truth = metastasis_risk, estimate = .pred_class)
```


```R
logreg_wf_prediction %>% 
  conf_mat(truth = metastasis_risk, estimate = .pred_class)
```


```R
rf_model <- rand_forest(
  trees = 2000,
  min_n = 20
) %>% 
  set_mode("classification") %>% 
  set_engine("ranger")
```


```R
rf_recipe <- recipe(metastasis_risk ~ .,
                    data = metastasis_risk_data_training) %>% 
  step_zv() %>% 
  step_normalize(all_numeric_predictors()) %>% 
  step_dummy(all_nominal_predictors())
```


```R
rf_workflow <- workflow() %>% 
  add_recipe(rf_recipe) %>% 
  add_model(rf_model)
```


```R
rf_workflow_fit <-
  rf_workflow %>% 
  fit(metastasis_risk_data_training)
```


```R
rf_workflow_prediction <- bind_cols(
  metastasis_risk_data_testing,
  rf_workflow_fit %>% 
    predict(metastasis_risk_data_testing),
  rf_workflow_fit %>% 
    predict(metastasis_risk_data_testing, type = "prob")
)
```


```R
rf_workflow_prediction %>% 
  roc_curve(metastasis_risk, .pred_Low, .pred_Medium, .pred_High) %>% 
  autoplot()
```


```R
rf_workflow_prediction %>% 
  metrics(truth = metastasis_risk, estimate = .pred_class)
```




```R
rf_workflow_prediction %>% 
  precision(truth = metastasis_risk, estimate = .pred_class)

rf_workflow_prediction %>% 
  recall(truth = metastasis_risk, estimate = .pred_class)

rf_workflow_prediction %>% 
  f_meas(truth = metastasis_risk, estimate = .pred_class)
```




```R
rf_workflow_prediction %>% 
  conf_mat(truth = metastasis_risk, estimate = .pred_class)
```




```R
library(vip)
rf_model %>%
  set_engine("ranger", importance = "permutation") %>%
  fit(
    metastasis_risk ~ .,
    data = metastasis_risk_data_testing
  ) %>%
  vip(geom = "point")
```
