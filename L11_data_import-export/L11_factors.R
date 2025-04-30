
## we can create a factor with the function factor()
## the argument x represents the data
## the levels argument defines the attribute

eyes <- factor(x = c("blue", "green", "green"),
               levels = c("blue", "brown", "green")
               )

## when we inspect the object
eyes

## however its internal representation can be visualise with
unclass(eyes)


## import a dataset
factorData = readRDS(url("https://raw.githubusercontent.com/lescai-teaching/class-bigdata/main/L11_data_import-export/L11_dataset_factors.rds"))

## inspect the dataset
factorData

## we can already see the class in the tibble
## but let's run this
factorData %>% pull(base) %>% class()

## we use the function levels() to access a factor's levels

levels(factorData$base)

## by default they are ordered alphabetically

## REORDER levels

ggplot(factorData, aes(x=base, y=counts))+
  geom_bar(stat = "identity")

## to help visualising trends and relationshipcs, the factors 
## should follow the order of data

factorData %>%
  mutate(
    base = fct_reorder(base, counts)
  ) %>%
  ggplot(aes(x=base, y=counts))+
  geom_bar(stat = "identity")

## or in a decreasing order

factorData %>%
  mutate(
    base = fct_reorder(base, counts, .desc = TRUE)
  ) %>%
  ggplot(aes(x=base, y=counts))+
  geom_bar(stat = "identity")


## changing levels can be tricky
## reconding can be done safely with fct_recode()
## new level = old level


factorData %>%
  mutate(
    base = fct_recode(base, 
                      "Adenine" = "A",
                      "Guanine" = "G",
                      "Thymine" = "T",
                      "Cytosine" = "C"
                      )
  )


### sometimes we need to collapse groups

factorData %>% 
  mutate(
    base = fct_collapse(base,
                        purines = c("A", "G"),
                        pyrimidines = c("T", "C")
                        )
  )

## this allows us to group

factorData %>% 
  mutate(
    base = fct_collapse(base,
                        purines = c("A", "G"),
                        pyrimidines = c("T", "C")
    )
  ) %>% 
  group_by(base) %>% 
  summarise(
    base_cat_count = sum(counts)
  )
