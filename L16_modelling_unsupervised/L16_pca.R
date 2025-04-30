
library(tidyverse)
library(tidymodels)
library(tidyclust)
library(dbscan)
library(GGally)


genotypes = readRDS(url("https://raw.githubusercontent.com/lescai-teaching/class-bigdata/main/L12_tidy_eda/L12_dataset_genotypes.rds"))


### base R

## first we consider this dataset ok for the purpose of a PCA, except we need to
## consider the variants our measurement variables and the individuals our cases
## so we need to transpose the dataset

## there is no transpose function for tibbles as for matrices so we need to pivot
## back and forth through a properly tidy dataset

genotyped_individuals = genotypes %>% 
  pivot_longer(
    cols = starts_with("sim"),
    names_to = "individual",
    values_to = "genotype"
  ) %>% 
  mutate( ## we take the chance to mutate the genotypes now 
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

## let's check the result
genotyped_individuals


### tidymodels approach

## as usual we prepare a recipe
pca_recipe <- recipe(~., 
                     data = genotyped_individuals %>% select(-c(individual))
                     )
pca_transformation <- pca_recipe %>% 
  step_normalize(all_numeric()) %>% 
  step_pca(all_numeric(), num_comp = 10)

## however, here we are not fitting a workflow as in a supervised training
## therefore we use two internal functions which serve
## first to prepare the recipe, i.e. fit the recipe to the data
pca_estimates <- prep(
  pca_transformation,
  training = genotyped_individuals %>% select(-c(individual))
)

## and then apply that in order to make the actual calculation
## of the principal components
pca_data <- bake(
  pca_estimates,
  genotyped_individuals %>% select(-c(individual))
  )

### this can be plotted as before
ggplot(pca_data,
       aes(x=PC01, y=PC02))+
  geom_point()

