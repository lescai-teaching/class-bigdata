# Exercise 3


## Dataset

Data have been collected from a population of 5,000 cells, for three CD (cluster of differentiation) markers:

- CD123
- CD345
- CD876

The intensity of each marker bound to an appropriate antibody has been assessed at the cytofluorimeter.

You can load the data as follows:

```R
dataCytofluorimeter = readRDS(url("https://raw.githubusercontent.com/lescai-teaching/class-bigdata/main/L10_stats_exercises/exercise_03/L10_dataset_exercise03.rds"))
```



## Hypothesis

The quantitative expression of these proteins on the surface might be correlated. We would like to know which ones are correlated, and what is the strenght of this correlation.
