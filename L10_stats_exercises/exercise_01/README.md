# Exercise 1

## Dataset

A sample has been collected of 1,000 individuals who self-reported to be in healthy condition, and
1,000 individuals who self-reported not to feel healthy at all times.

A set of questions was asked to these individuals:

- if they usually drink or not
- if they do sport at least once a week or not
- if they smoke or not

You can load the data with the following code

```R
dataExposure = readRDS(url("https://raw.githubusercontent.com/lescai-teaching/class-bigdata/main/L10_stats_exercises/exercise_01/L10_dataset_exercise01.rds"))
```

## Question

Please find out, with the appropriate test, whether one of these self-reported behaviours might be responsible for
the self reported health status of the individuals.
