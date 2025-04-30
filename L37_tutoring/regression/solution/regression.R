
# Import the libraries
library(tidyverse)
library(tidymodels)
library(GGally)
library(vip)

# Load the dataset
blood_pressure_data <- read_tsv("~/bigdata/class-bigdata/L37_tutoring/regression/dataset/mbg_exams_blood_pressure_data.tsv")

# Visualise the relationships between the variables
scatterplot_matrix <- ggpairs(blood_pressure_data)
print(scatterplot_matrix)

# Split the data into training and testing
set.seed(123)
blood_pressure_data_split <- initial_split(blood_pressure_data, prop = 0.75)
blood_pressure_data_training <- training(blood_pressure_data_split)
blood_pressure_data_testing <- testing(blood_pressure_data_split)


#########################
### LINEAR REGRESSION ###
#########################


# Define the model
lm_model <- linear_reg() %>% 
  set_engine("lm")

# Create the recipe
lm_recipe <- 
  recipe(blood_pressure_systolic ~ ., 
         data = blood_pressure_data_training) %>% 
  step_dummy(all_nominal_predictors()) %>%
  step_normalize(all_predictors())
  
# Create the workflow
lm_workflow <- workflow() %>% 
  add_model(lm_model) %>% 
  add_recipe(lm_recipe)

# Fit the workflow 
lm_wf_fit <- fit(
  lm_workflow,
  blood_pressure_data_training
)

# Perform the prediction
lm_wf_prediction = lm_wf_fit %>%
  predict(blood_pressure_data_testing) %>%
  bind_cols(blood_pressure_data_testing)

# Visualise the prediction
lm_wf_prediction %>%
  ggplot(aes(x=blood_pressure_systolic, y=.pred))+
  geom_point(alpha = 0.4, colour = "blue")+
  geom_abline(colour = "red", alpha = 0.9)

# Check the prediction metrics
lm_wf_prediction %>% 
  metrics(truth = blood_pressure_systolic, estimate = .pred)


####################################
### RANDOM FOREST FOR REGRESSION ###
####################################


rf_model <- rand_forest(
  trees = 2000
) %>%
  set_mode("regression") %>% 
  set_engine("ranger", importance = "permutation")

rf_recipe <- 
  recipe(as.formula(paste0("blood_pressure_systolic ~ ", 
    paste0(
     names(blood_pressure_data_training)[!names(blood_pressure_data_training) %in% c("blood_pressure_systolic")],
     collapse = " + "
    )
  )
  ), 
  data = blood_pressure_data_training) %>% 
  step_dummy(all_nominal_predictors()) %>%
  step_normalize(all_predictors())

rf_workflow <- workflow() %>% 
  add_model(rf_model) %>% 
  add_recipe(rf_recipe)
  
rf_wf_fit <- fit(
  rf_workflow,
  blood_pressure_data_training
)

rf_wf_prediction <- rf_wf_fit %>%
  predict(blood_pressure_data_testing) %>%
  bind_cols(blood_pressure_data_testing)

rf_wf_prediction %>%
  ggplot(aes(x=blood_pressure_systolic, y=.pred))+
  geom_point(alpha = 0.4, colour = "blue")+
  geom_abline(colour = "red", alpha = 0.9)

rf_wf_prediction %>% 
  metrics(truth = blood_pressure_systolic, estimate = .pred)

# Explainability check - variables importance plot
rf_wf_fit %>% 
  extract_fit_parsnip() %>% 
  vip(num_features = 10, geom = "point")

# Infer workflow - Calculate a statistic for the most important variable and the related p-value

# Data exploration - box plot to visualise the relationship between gender and the outcome variable
ggplot(blood_pressure_data, aes(y=blood_pressure_systolic, fill=gender))+
  geom_boxplot()+
  coord_flip()

# Generate the observed statistic with the appropriate test (t-test -> Continuous outcome variable and categorical explanatory variable with 2 levels)
bloodPressure_gender_observed = blood_pressure_data %>%
  specify(blood_pressure_systolic ~ gender) %>%
  calculate(stat = "diff in means", order = c("female", "male"))

# Generate the null distribution from the data
bloodPressure_gender_null_empirical = blood_pressure_data %>%
  specify(blood_pressure_systolic ~ gender) %>%
  hypothesise(null = "independence") %>%
  generate(reps = 1000, type = "permute") %>%
  calculate(stat = "diff in means", order = c("female", "male"))

# Visualise the empirical distribution and the observed statistic
bloodPressure_gender_null_empirical %>%
  visualise()+
  shade_p_value(bloodPressure_gender_observed,
                direction = "two-sided")

# Get the p-value for the observed statistic
bloodPressure_p_value_gender = bloodPressure_gender_null_empirical %>%
  get_p_value(obs_stat = bloodPressure_gender_observed,
              direction = "two-sided")

# This wrapper function is a faster alternative to the infer workflow above
t_test(x = blood_pressure_data, 
       formula = blood_pressure_systolic ~ gender, 
       order = c("female", "male"),
       alternative = "two-sided")


############################
### K-NEAREST NEIGHBOURS ###
############################


# Define the model - tuning of the "neighbours" hyperparameter
knn_model <-
  nearest_neighbor(
    neighbors = tune(), 
    weight_func = "triangular") %>%
  set_mode("regression") %>%
  set_engine("kknn")

# Set up the tuning grid
knn_tuning_grid <- grid_regular(
  neighbors(range = c(3L,8L))
)

# Generate data folds
set.seed(123)
blood_pressure_data_folds <- vfold_cv(blood_pressure_data_training)

# Create the recipe
knn_recipe <- recipe(blood_pressure_systolic ~ .,
                     data = blood_pressure_data_training) %>% 
  step_dummy(all_nominal_predictors()) %>%
  step_normalize(all_predictors())

# Create the workflow
knn_wf <- workflow() %>% 
  add_model(knn_model) %>% 
  add_recipe(knn_recipe)

# Tune
knn_tuning_results <- knn_wf %>% 
  tune_grid(
    resamples = blood_pressure_data_folds,
    grid = knn_tuning_grid
  )

# Visualise tuning metrics
knn_tuning_results %>% 
  collect_metrics()

# Extract best hyperparams based on the rmse
knn_tuning_best_params = knn_tuning_results %>%
  select_best("rmse")

# Finalise the workflow
final_knn_wf <- knn_wf %>% 
  finalize_workflow(knn_tuning_best_params)

# Fit the workflow with the best hyperparameters
final_knn_fit <- final_knn_wf %>% 
  last_fit(blood_pressure_data_split)

# Visualise the prediction
final_knn_fit %>% 
  collect_predictions() %>% 
  ggplot(aes(x=blood_pressure_systolic, y=.pred))+
  geom_point(alpha = 0.4, colour = "blue")+
  geom_abline(colour = "red", alpha = 0.9)

# Collect the final metrics
final_knn_fit %>% 
  collect_metrics()


#########################
### MODELS COMPARISON ###
#########################


# Recap of the three models performances

# Linear model
lm_wf_prediction %>% 
  metrics(truth = blood_pressure_systolic, estimate = .pred)

# Random forest
rf_wf_prediction %>% 
  metrics(truth = blood_pressure_systolic, estimate = .pred)

# K-nearest neighbours
final_knn_fit %>% 
  collect_metrics()

# Evaluate the differences (metrics) between the models
compare_metrics <- bind_rows(
  bind_cols(
    lm_wf_prediction %>%
      metrics(truth = blood_pressure_systolic, estimate = .pred) %>%
      select(.metric, .estimate),
    model = "lm"
  ),
  bind_cols(
    rf_wf_prediction %>%
      metrics(truth = blood_pressure_systolic, estimate = .pred) %>%
      select(.metric, .estimate),
    model = "rf"
  ),
  bind_cols(
    final_knn_fit %>% 
      collect_metrics() %>% 
      select(.metric, .estimate),
    model = "knn"
  )
) %>%
  pivot_wider(
    names_from = .metric,
    values_from = .estimate
  )

# Compare the predictions between the models
compare_predictions <- bind_rows(
  bind_cols(
    lm_wf_prediction %>% select(blood_pressure_systolic, .pred),
    model = "lm"
  ),
  bind_cols(
    rf_wf_prediction %>% select(blood_pressure_systolic, .pred),
    model = "rf"
  ),
  bind_cols(
    final_knn_fit %>% 
      collect_predictions(),
      model = "knn"
  )
)

# Plot the models predictions side to side
ggplot(compare_predictions, aes(x = blood_pressure_systolic, y = .pred, colour = model))+
  geom_point()+
  geom_abline()+
  facet_wrap(~model)
