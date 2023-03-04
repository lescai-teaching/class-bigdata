library(tidyverse)

############################
### score of exams ########

s = 0:35 # possible scores of the exam
joe = 30 # score of our test student
pop_mean = 25 # mean score of most students at exam
pop_sd = 4 # standard deviation of exam results
alpha = 0.05 # we need to choose our significance level

## create a tibble with probability associated to each possible score
## from a normal distribution with these characteristics

normalDensity = tibble(
  score = s,
  probability = dnorm(s, mean = pop_mean, sd = pop_sd) ## probability of achieving that score with normal mean 25 & sd 4
)

## we can now order the values of the probability in order to compute
## the cumulative probability

normalDensity = normalDensity %>%
  arrange(probability) %>% ## to make sure data are ordered by probability first
  mutate(
    cumulative_p = cumsum(probability), ## now they are ordered we can make a cumulative p
    reject = cumulative_p <= alpha
  )

## now we can plot this

normalplot = ggplot(normalDensity)+
  geom_bar(aes(x=score, y=probability, fill = reject), stat = "identity")+
  scale_fill_manual(
    values = c(
      `TRUE` = "red",
      `FALSE` = "darkgrey"
    )
  )+
  geom_vline(xintercept = joe, col = "blue")+
  theme(legend.position = "none")

plot(normalplot)

## if we consider the sum of the probabilities of all the scores higher than
## our student, we obtain

sum(
  normalDensity$probability[normalDensity$score>=joe]
)


### for a proper test statistic we compute a relative standing
### using a z-score, which in this case would be

z_score = (joe - pop_mean) / pop_sd


## the p-value is then calculated as the proportion of probability
## equal or above the z-score of our single measure
## on a default normal distribution (i.e. mean = 0 and sd = 1)

pnorm(z_score, lower.tail = FALSE)


## roughly it still represents the proportion we have seen above



###############################################
## why z-score plotted on a normal dist?
##############################################

## our null hypothesis is NOT the distribution of scores
## but the distribution of z-scores
## we can compute it as below:

## pack z-score calculation in a function

zcalc <- function(x){
  z = (x-pop_mean)/pop_sd
  return(z)
}


## create a tibble with real scores (not their probability)
## drawn out of the same normal distribution

exam_sample = tibble(
  scores = rnorm(2000, mean = pop_mean, sd = pop_sd)
) %>%
  mutate(
    zscore = zcalc(scores) ## then we calculate the z-score of each exam score
  ) %>%
  arrange(zscore)

## we can plot it, and measure against our z-score

zplot = ggplot(exam_sample)+
  geom_bar(aes(x=zscore), stat = "density")+
  geom_vline(xintercept = z_score, col = "red")

plot(zplot)

### if we plot the two one below the other we can see they're distributed in a pretty
### similar way

library(gridExtra)
grid.arrange(normalplot+xlim(10,38), zplot, nrow=2)

