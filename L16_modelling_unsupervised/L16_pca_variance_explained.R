library(tidyverse)
library(tidymodels)


dataCellCulture = readRDS(url("https://raw.githubusercontent.com/lescai-teaching/class-bigdata/main/L16_modelling_unsupervised/L16_dataset_cellculture_advanced.rds"))

### PCA recipe

num_pcs = 10


pca_recipe <- recipe(~., data = dataCellCulture) %>% 
  step_normalize(all_numeric()) %>% 
  step_pca(all_numeric(), num_comp = num_pcs)

## prep() estimates the PCA transformation
pca_estimates <- prep(
  pca_recipe,
  training = dataCellCulture
)


### variance explained by each principal component

## the PCA step is number 2, after the normalization step
pca_variance = pca_estimates %>% 
  tidy(number = 2, type = "variance") %>% 
  filter(component <= num_pcs)

pca_variance %>% 
  filter(terms == "percent variance") %>% 
  select(component, value) %>% 
  mutate(value = round(value, 2))

## cumulative percentage is useful to decide how many components to keep
pca_variance %>% 
  filter(terms == "cumulative percent variance") %>% 
  select(component, value) %>% 
  mutate(value = round(value, 2))

## plot the percentage of variance explained by each component
pca_variance %>% 
  filter(terms == "percent variance") %>% 
  ggplot(aes(x = component, y = value))+
  geom_col()+
  scale_x_continuous(breaks = 1:num_pcs)+
  xlab("Principal component")+
  ylab("Variance explained (%)")
