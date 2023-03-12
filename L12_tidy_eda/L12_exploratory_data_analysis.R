

## we can load internal datasets with
data("diamonds")

## let's inspect the dataset
diamonds


## one way of looking at variation

ggplot(data = diamonds) +
  geom_bar(mapping = aes(x = cut))

## or we can look at the counts, use a shortcut function

diamonds %>% 
  count(cut)

### which is a shortcut for 

diamonds %>% 
  group_by(cut) %>% 
  summarise(n = n())

### if we count a continuous variable in intervals, we transform it into a categorical one

ggplot(data = diamonds) +
  geom_histogram(mapping = aes(x = carat), binwidth = 0.5)

## one can do this with the data using the function cut_width()

diamonds %>% 
  count(cut_width(carat, 0.5))

## the grouping variable has become a factor with range intervals

## by filtering for some values we might notice unusual data

unusual <- diamonds %>% 
  filter(y < 3 | y > 20) %>% 
  select(price, x, y, z) %>%
  arrange(y)

unusual

## so we might want to decide to 

## A) drop those values
## notice the use of the function between()

diamonds2 <- diamonds %>% 
  filter(between(y, 3, 20))

## B) better to set them as missing and keep the records in the data

diamonds2 <- diamonds %>% 
  mutate(y = ifelse(y < 3 | y > 20, NA, y))

### there's another way to do this

diamonds2 <- diamonds %>% 
  mutate(
    y = case_when(
      y < 3 ~ NA,
      y > 20 ~ NA,
      TRUE ~ y
    )
  )

### missing values are highlighted as a warning 
### when plotting

ggplot(data = diamonds2, mapping = aes(x = x, y = y)) + 
  geom_point()


#################
# covariation
###############

## between a categorical and a continuous variable

ggplot(data = diamonds, mapping = aes(x = cut, y = price)) +
  geom_boxplot()


### two continuous variables

ggplot(data = diamonds) +
  geom_point(mapping = aes(x = carat, y = price))


### a more powerful way to get them all

library(GGally)

ggpairs(diamonds)

### if we already know a potential grouping

## check the index of the columns
names(diamonds)

## reformat the function this way
ggpairs(diamonds, columns = c(1,3:10), aes(colour = cut))