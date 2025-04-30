# Exercise 2 solution

## Loading the data


```R
dataHappyness = readRDS(url("https://raw.githubusercontent.com/lescai-teaching/class-bigdata/main/L10_stats_exercises/exercise_02/L10_dataset_exercise_02.rds"))
```

```R
head(dataHappyness)
```


## Data exploration

Since there are two variables, we can first create a plot of the first one

```R
ggplot(dataHappyness, aes(y=serotonin_level, fill=happyness))+
  geom_boxplot()+
  coord_flip()
```

Then a plot of the second one

```R
ggplot(dataHappyness, aes(y=endorphin_level, fill=happyness))+
  geom_boxplot()+
  coord_flip()
```
And formulate some hypotheses.


## Hypothesis testing


### Serotonin levels and happyness

First we generate the observed statistic with the appropriate test, which is a t-test between two independent samples, i.e. testing if the means are different between the two categories


```R
serotonin_happyness_observed = dataHappyness %>%
  specify(serotonin_level ~ happyness) %>%
  calculate(stat = "diff in means", order = c("rarely_happy", "usually_happy"))
```

Then we can use permutations to create a null distribution out of our data


```R
serotonin_happyness_null_empirical = dataHappyness %>%
  specify(serotonin_level ~ happyness) %>%
  hypothesise(null = "independence") %>%
  generate(reps = 1000, type = "permute") %>%
  calculate(stat = "diff in means", order = c("rarely_happy", "usually_happy"))
```

and visualise the results

```R
serotonin_happyness_null_empirical %>%
  visualise()+
  shade_p_value(serotonin_happyness_observed,
                direction = "two-sided")
```

get the associated p-value, even if the result should be expected after looking at the previous plot

```R
serotonin_p_value_happyness = serotonin_happyness_null_empirical %>%
  get_p_value(obs_stat = serotonin_happyness_observed,
              direction = "two-sided")
```
and finally print the p-value corresponding to the test statistic of our observations.
```R
serotonin_p_value_happyness
```

A shortcut for the above procedure, since it is available would be:

```R
t_test(x = dataHappyness, 
       formula = serotonin_level ~ happyness, 
       order = c("rarely_happy", "usually_happy"),
       alternative = "two-sided")
```



### Endorphins levels

As usual first we calculate the appropriate test statistic of our observations


```R
endorphin_happyness_observed = dataHappyness %>%
  specify(endorphin_level ~ happyness) %>%
  calculate(stat = "diff in means", order = c("rarely_happy", "usually_happy"))
```

Then we calculate the null hypothesis by permutations

```R
endorphin_happyness_null_empirical = dataHappyness %>%
  specify(endorphin_level ~ happyness) %>%
  hypothesise(null = "independence") %>%
  generate(reps = 1000, type = "permute") %>%
  calculate(stat = "diff in means", order = c("rarely_happy", "usually_happy"))```

and visualise the relative standing of our observation

```R
endorphin_happyness_null_empirical %>%
  visualise()+
  shade_p_value(endorphin_happyness_observed,
                direction = "two-sided")
```

calculate the associated p-value

```R
endorphin_p_value_happyness = endorphin_happyness_null_empirical %>%
  get_p_value(obs_stat = endorphin_happyness_observed,
              direction = "two-sided")
```

and visualise its value:

```
endorphin_p_value_happyness
```

Finally, in the same way we can use a shortcut

```Rt_test(x = dataHappyness, 
       formula = endorphin_level ~ happyness, 
       order = c("rarely_happy", "usually_happy"),
       alternative = "two-sided")
```

which allows us to conclude that while serotonin levels are not different between the groups, endorphin levels clearly are.

