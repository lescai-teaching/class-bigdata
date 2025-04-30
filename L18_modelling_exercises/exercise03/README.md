# Microbiome Exercise


## Context
Microbiome composition is largely correlated to the health status of an individual and deeply influenced by the individual diet. However, the idea that a specific signature for each individual exists, due to the individual's genetic makeup, is supported by a substantial track record of research.
This dataset presents the microbiome comoposition of about 4,500 individuals of different age, tracked through four different genera which are known to be associated to a Human's health status.


## Available Data

The dataset can be loaded with:

```R
dataMicrobiome = readRDS(url("https://raw.githubusercontent.com/lescai-teaching/class-bigdata/main/L18_modelling_exercises/L18_dataset_dataMicrobiome.rds"))
```

and contains the following variables:

- age
- lactobacillus
- bifidobacterium
- methanobrevibacter
- fusicatenibacter

## Exercise

Please explore the data and, using the appropriate modelling technique, test at least two different approaches (either different models or different parameters) and explain the best performance of your model.
Based on your observations and also the results of your model, try and draw some conclusions on the biology underlying the described dataset.