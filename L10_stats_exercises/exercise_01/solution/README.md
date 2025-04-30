# Exercise 01 Solution

## Load Data

We load the data with:

```R
dataExposure = readRDS(url("https://raw.githubusercontent.com/lescai-teaching/class-bigdata/main/L10_stats_exercises/exercise_01/L10_dataset_exercise01.rds"))
```

## Data overview

```R
head(dataExposure)
```

## Data analysis - Drinking habit

First we calculate the observed statistic:


```R
observed_statistic_drinking <- dataExposure %>%
  specify(condition ~ drinking, success = "healthy") %>%
  hypothesize(null = "independence") %>%
  calculate(stat = "Chisq")
```

Then we generate the null distribution using randomization:


```R
null_statistic_drinking <- dataExposure %>%
  specify(condition ~ drinking, success = "healthy") %>%
  hypothesize(null = "independence") %>%
  generate(reps = 1000, type = "permute") %>%
  calculate(stat = "Chisq")
```

And finally we visualize both null distributions and the test statistic:

```R
null_statistic_drinking %>%
  visualize() + 
  shade_p_value(observed_statistic_drinking,
                direction = "greater")
```

We can also get the p-value for a confirmation 

```R
null_statistic_drinking %>%
  get_p_value(
    obs_stat = observed_statistic_drinking,
    direction = "greater"
  )
```



## Data analysis - Smoking habit

Again, we first calculate the observed statistic


```R
observed_statistic_smoking <- dataExposure %>%
  specify(condition ~ smoking, success = "healthy") %>%
  hypothesize(null = "independence") %>%
  calculate(stat = "Chisq")
```

Then we generate the null distribution using randomization

```R
null_statistic_smoking <- dataExposure %>%
  specify(condition ~ smoking, success = "healthy") %>%
  hypothesize(null = "independence") %>%
  generate(reps = 1000, type = "permute") %>%
  calculate(stat = "Chisq")
```

And we visualize both null distributions and the test statistic!

```R
null_statistic_smoking %>%
  visualize() + 
  shade_p_value(observed_statistic_smoking,
                direction = "greater")
```

We finally get the p-value associated with the statistic

```R
null_statistic_smoking %>%
  get_p_value(
    obs_stat = observed_statistic_smoking,
    direction = "greater"
  )
```


## Data analysis - sport habit

The procedure is the same, so we first calculate the observed statistic


```R
observed_statistic_sport <- dataExposure %>%
  specify(condition ~ sport, success = "healthy") %>%
  hypothesize(null = "independence") %>%
  calculate(stat = "Chisq")
```

We then generate the null distribution using randomization

```R
null_statistic_sport <- dataExposure %>%
  specify(condition ~ sport, success = "healthy") %>%
  hypothesize(null = "independence") %>%
  generate(reps = 1000, type = "permute") %>%
  calculate(stat = "Chisq")
```


And visualize both null distributions and the test statistic

```R
null_statistic_sport %>%
  visualize() + 
  shade_p_value(observed_statistic_sport,
                direction = "greater")
```
And finally confirm with the p-value
```R
null_statistic_sport %>%
  get_p_value(
    obs_stat = observed_statistic_sport,
    direction = "greater"
  )
```

We could also have used a shortcut to the test and permutation like this:

```R
chisq_test(dataExposure, condition ~ sport)
```

## Conclusion

Based on the test, we can conclude that active people who do sport activities at least once a week are less likely to report they feel unhealthy.