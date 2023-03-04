library(tidyverse)

############################
### score of exams ########

s = 0:35 # possible scores of the exam
joe = 30 # score of our test student

normalDensity = tibble(
  score = s,
  probability = dnorm(s, mean = 25, sd = 4) ## probability of achieving that score with normal mean 25 & sd 4
)

alpha = 0.05 # we need to choose our significance level

normalDensity = normalDensity %>%
  arrange(probability) %>% ## to make sure data are ordered by probability first
  mutate(
    cumulative_p = cumsum(probability),
    reject = cumulative_p <= alpha
  )

## now we can plot this

ggplot(normalDensity)+
  geom_bar(aes(x=score, y=probability, fill = reject), stat = "identity")+
  scale_fill_manual(
    values = c(
      `TRUE` = "red",
      `FALSE` = "darkgrey"
    )
  )+
  geom_vline(xintercept = joe, col = "blue")+
  theme(legend.position = "none")


z_score = (30-25)/4

sum(
  normalDensity$probability[normalDensity$score>=joe]
)

