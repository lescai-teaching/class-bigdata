# Exercise 4 Solution


## Data import and inspection

First we import the data as described.

```R
dataReactor = readRDS(url("https://raw.githubusercontent.com/lescai-teaching/class-bigdata/main/L10_stats_exercises/exercise_04/L10_dataset_exercise04.rds"))
```

Then it's always better to have a look:

```R
dataReactor
```

We can explore these variables by using a density plot

```R
ggplot(dataReactor, aes(x=proteinA, y=..density.., fill=bioreactor))+
  geom_density()
```
Or a boxplot

```R
ggplot(dataReactor, aes(y=proteinA, fill=bioreactor))+
  geom_boxplot()
```
There seem to be a difference at least in some bioreactors, but we cannot be entirely sure about the ensemble.

## Hypothesis testing

Here, the data contain a continuous outcome (proteinA) and a categorical predictor (bioreactor) with more than 2 groups.
The ensemble test is therefore an ANOVA.

We begin by calculating the F statistic of our observations:


```R
bioreactor_groups_observed = dataReactor %>%
  specify(formula = proteinA ~ bioreactor ) %>%
  hypothesise(null = "independence") %>%
  calculate(stat = "F")
```

Then we can use permutations to compute the null distribution

```R
bioreactor_groups_null_empirical = dataReactor %>%
  specify(formula = proteinA ~ bioreactor ) %>%
  hypothesise(null = "independence") %>%
  generate(reps = 1000, type = "permute") %>%
  calculate(stat = "F")
```

And finally visualise the relative standing of our observed statistic compared to the distribution.


```R
bioreactor_groups_null_empirical %>%
  visualise()+
  shade_p_value(
    obs_stat = bioreactor_groups_observed,
    direction = "greater"
  )
```
The p-value is then calculated with:

```R
p_value_bioreactor_groups <- bioreactor_groups_null_empirical %>%
  get_p_value(obs_stat = bioreactor_groups_observed,
              direction = "greater")
```

We can visualise its value 

```R
p_value_bioreactor_groups
```

and we cannot conclude that overall changing the reactor always affects the production of the protein.

We should however observe that some of the proteinA concentrations might be significantly different if we compared pairs of bioreactors, most likely for one specific condition affecting the production.

To test this, we should run a t-test by pairs of bioreactors.
