# Exercise 3 Solution

First we need to load the data

```R
dataCytofluorimeter = readRDS(url("https://raw.githubusercontent.com/lescai-teaching/class-bigdata/main/L10_stats_exercises/exercise_03/L10_dataset_exercise03.rds"))
```

We briefly inspect the dataset


```R
head(dataCytofluorimeter)
```

And use the `ggpairs` function to get a better overview of the relationships of all data

```R
library(GGally)
ggpairs(dataCytofluorimeter, columns = c("CD123", "CD345", "CD876"))
```

It's pretty clear from the plots that **CD345** and **CD876** are correlated, and we also get already a correlation coefficient of 0.7.

We then follow the proper *infer* workflow to determine the p-value

First we compute the observed statistic

```R
cytofluorimeter_correlation_observed <- dataCytofluorimeter %>% 
  specify(CD345 ~ CD876) %>%
  calculate(stat = "correlation")
```

Then we compute the null distribution using 1000 permutations

```R
cytofluorimeter_correlation_null <- dataCytofluorimeter %>% 
  specify(CD345 ~ CD876) %>%
  hypothesize(null = "independence") %>%
  generate(reps = 1000, type = "permute") %>%
  calculate(stat = "correlation")
```

and finally we can visualise the relative standing of our observed statistics compared to the null with:


```R
visualize(cytofluorimeter_correlation_null) +
  shade_p_value(obs_stat = cytofluorimeter_correlation_observed, direction = "two-sided")
```

And calculate the p-value from it:


```R
corr_pval = cytofluorimeter_correlation_null %>%
  get_p_value(obs_stat = cytofluorimeter_correlation_observed, direction = "two-sided")
```

We do expect the p-value to be pretty extreme

```R
corr_pval
```

We can verify the extent of the correlation with

```R
cytofluorimeter_correlation_observed
```

Which corresponds to the value indicated in the initial pairs plot.