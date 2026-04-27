library(tidyverse)
library(tidymodels)


genotypes = readRDS(url("https://raw.githubusercontent.com/lescai-teaching/class-bigdata/main/L12_tidy_eda/L12_dataset_genotypes.rds"))


genotyped_individuals = genotypes %>% 
  pivot_longer(
    cols = starts_with("sim"),
    names_to = "individual",
    values_to = "genotype"
  ) %>% 
  mutate(
    genotype = case_when(
      genotype == "0/0" ~ 0,
      genotype == "0/1" ~ 1,
      genotype == "1/1" ~ 2,
      TRUE ~ NA
    )
  ) %>% 
  pivot_wider(
    names_from = "variant",
    values_from = "genotype"
  )


### PCA recipe

num_pcs = 10

pca_data = genotyped_individuals %>% 
  select(-c(individual))

pca_recipe <- recipe(~., data = pca_data) %>% 
  step_normalize(all_numeric()) %>% 
  step_pca(all_numeric(), num_comp = num_pcs)

## prep() estimates the PCA transformation
pca_estimates <- prep(
  pca_recipe,
  training = pca_data
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
