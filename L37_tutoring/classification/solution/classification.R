
# Import the libraries
library(tidyverse)
library(tidymodels)
library(GGally)
library(vip)
library(cowplot)

# Load the dataset
cancer_classtype_data <- read_tsv("~/bigdata/tutorati-2024/datasets/02_classification/mbg_exams_cancer_classtype_data.tsv")

# Visualise the relationships between the variables 
scatterplot_matrix <- ggpairs(cancer_classtype_data)
print(scatterplot_matrix)

# Split the data into training and testing
set.seed(123)
cancer_classtype_data_split = initial_split(cancer_classtype_data %>% 
                                              mutate(presence_metastasis = factor(presence_metastasis, levels = c("yes", "no"))),
                                            prop = 0.75,
                                            # The goal of stratified sampling is to maintain the proportions of different classes in the sample that closely reflect their proportions in the entire population
                                            strata = presence_metastasis)
cancer_classtype_data_training <- training(cancer_classtype_data_split)
cancer_classtype_data_testing <- testing(cancer_classtype_data_split)


###########################
### LOGISTIC REGRESSION ###
###########################


# Define the model
logreg_model <- logistic_reg() %>% 
  set_engine("glm") %>% 
  set_mode("classification")

# Create the recipe
logreg_recipe <- 
  recipe(presence_metastasis ~ .,
         data = cancer_classtype_data_training) %>% 
  step_dummy(all_nominal_predictors()) %>%
  step_normalize()

# Create the workflow
logreg_wf <- workflow() %>% 
  add_model(logreg_model) %>% 
  add_recipe(logreg_recipe)

# Fit the workflow 
logreg_wf_fit <- fit(
  logreg_wf,
  cancer_classtype_data_training
)

# Extract model coefficients and their statistics from the logistic regression workflow fit
tidy(logreg_wf_fit)

# Calculate the odds ratio and filter for statistically significant predictors (p-value < 0.05)
tidy(logreg_wf_fit, exponentiate = TRUE) %>% 
  filter(p.value < 0.05)

# Perform the prediction
logreg_wf_prediction <- bind_cols(
  cancer_classtype_data_testing %>% select(presence_metastasis),
  logreg_wf_fit %>% 
    predict(cancer_classtype_data_testing, type = "class"),
  logreg_wf_fit %>% 
    predict(cancer_classtype_data_testing, type = "prob")
)

# Create a variable importance plot for the logistic regression model, displaying the top 10 most important features
logreg_wf_fit %>% 
  extract_fit_parsnip() %>% 
  vip(num_features = 10, geom = "point")

# Accuracy and kappa coefficient
logreg_wf_prediction %>% metrics(truth = presence_metastasis, estimate = .pred_class)

# Precision (proportion of truth among results) and recall (how much the model captures reality)
precision(logreg_wf_prediction, truth = presence_metastasis, estimate = .pred_class)
recall(logreg_wf_prediction, truth = presence_metastasis, estimate = .pred_class)
spec(logreg_wf_prediction, truth = presence_metastasis, estimate = .pred_class)

# F1 score gives a better measure of the incorrectly classified cases than the accuracy metrics
# It's another way to measure accuracy, to be preferred in case false negatives and false positives are crucial
f_meas(logreg_wf_prediction, truth = presence_metastasis, estimate = .pred_class)

# Confusion matrix
logreg_conf_mat <- logreg_wf_prediction %>% 
  conf_mat(truth = presence_metastasis, estimate = .pred_class) %>% 
  autoplot(type = "heatmap")

# ROC Curve
logreg_roc <- logreg_wf_prediction %>%
  roc_curve(presence_metastasis, .pred_yes) %>% 
  autoplot()


########################################
### RANDOM FOREST FOR CLASSIFICATION ###
########################################


# Define the model
rf_class_model <- rand_forest(
  trees = tune(),
  mtry = tune(),
  min_n = tune()
) %>% 
  set_mode("classification") %>% 
  set_engine("ranger")

# Set up the tuning grid
rf_class_tuning_grid <- grid_regular(
  trees(),
  mtry(range = c(5L,8L)),
  min_n(),
  levels = 3)

# Generate data folds
set.seed(123)
cancer_classtype_data_folds <- vfold_cv(cancer_classtype_data_training)

# Extract the predictors for building a formula
predictors <- names(cancer_classtype_data)[!(names(cancer_classtype_data) %in% c("presence_metastasis"))]

# Define the recipe
rf_class_recipe <- recipe(
  as.formula(
    paste0("presence_metastasis ~ ", paste0(predictors, collapse = " + "))
  ),
  data = cancer_classtype_data_training
) %>% 
  step_dummy(all_nominal_predictors()) %>% 
  step_normalize(all_predictors())

# Create the workflow
rf_class_wf <- workflow() %>% 
  add_model(rf_class_model) %>% 
  add_recipe(rf_class_recipe)

# Tune
rf_tuning_results <- rf_class_wf %>% 
  tune_grid(
    resamples = cancer_classtype_data_folds,
    grid = rf_class_tuning_grid
  )

# Extract best hyperparams based on the accuracy
rf_tuning_best_params <- rf_tuning_results %>%
  select_best("accuracy")

# Finalise the workflow 
final_rf_class_wf <- rf_class_wf %>% 
  finalize_workflow(rf_tuning_best_params)

# Fit the workflow with the best hyperparameters
final_rf_class_fit <- final_rf_class_wf %>% 
  last_fit(cancer_classtype_data_split)

# Accuracy and roc_auc
final_rf_class_fit %>% 
  collect_metrics()

# Collect predictions for each train/test split of data
final_rf_class_fit %>% 
  collect_predictions()

# Finalise the best model
rf_tuning_best_model <- finalize_model(
  rf_class_model, ## this is the model we initially created with tune placeholders
  rf_tuning_best_params ## these are the best parameters identified in tuning
)

# Create a variable importance plot for the random forest (classification), displaying the top 10 most important features
rf_tuning_best_model %>%
  set_engine("ranger", importance = "permutation") %>%
  fit(
    as.formula(
      paste0("presence_metastasis ~ ", paste0(predictors, collapse = " + "))
    ),
    data = cancer_classtype_data_testing
  ) %>%
  vip(geom = "point")

# Inference on the "most important" variable for the model prediction according to the vip plot
chisq_test(cancer_classtype_data, presence_metastasis ~ tumour_type)

# Confusion matrix
rf_conf_mat <- final_rf_class_fit %>% 
  collect_predictions() %>% 
  conf_mat(truth = presence_metastasis, estimate = .pred_class) %>% 
  autoplot(type = "heatmap")

# ROC Curve
rf_roc <- final_rf_class_fit %>% 
  collect_predictions() %>% 
  roc_curve(presence_metastasis, .pred_yes) %>% 
  autoplot()


#########################
### MODELS COMPARISON ###
#########################


# Evaluate the differences (metrics) between the models
compare_metrics <- bind_rows(
  bind_cols(
    logreg_wf_prediction %>%
      metrics(truth = presence_metastasis, estimate = .pred_class) %>%
      select(.metric, .estimate),
    model = "logreg"
  ),
  bind_cols(
    final_rf_class_fit %>% 
      collect_metrics() %>% 
      select(.metric, .estimate),
    model = "rf_class"
  )
) %>%
  pivot_wider(
    names_from = .metric,
    values_from = .estimate
  )

# Compare confusion matrices
plot_grid(logreg_conf_mat, rf_conf_mat, labels = c('Logistic Regression', 'Random Forest'), label_size = 16, ncol = 2, align = 'v')

# Compare ROC curves
plot_grid(logreg_roc, rf_roc, labels = c('Logistic Regression', 'Random Forest'), label_size = 16, ncol = 2, align = 'v')
