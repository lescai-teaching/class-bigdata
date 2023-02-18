###############################
### DATA TO WORK WITH #########
###############################


numbers_list <- list(
  c(1,2,3,4,5),
  c(10,20,30,40),
  c(100,200,250,300)
)


measurements <- tibble(
  sample = c('cell01', 'cell02', 'cell03', 'cell04'),
  time01 = c(23,24,22,23),
  time02 = c(45,44,55,42),
  time03 = c(62,61,89,63)
)



some_values = c(23,43,22,34, rep(12,3), 43, 22)



#########################################
## WRITE A FUNCTION #####################
#########################################

increase <- function(x){
  # create an empty vector
  newvector = vector()
  # loop over the input
  for (val in x){
    new = val *3
    # append the value into new vector
    newvector = c(newvector, new)
  }
  # return as result this new vector
  return(newvector)
}


## execute the function:

new_values = increase(some_values)

## let's see the results
new_values

# what happens if we try and inspect the vector
# created inside the function?
newvector


########################################
##### GLOBAL ASSIGNMENT ################
########################################

increase <- function(x){
  # create an empty vector
  newvector <<- vector()
  # loop over the input
  for (val in x){
    new = val *3
    # append the value into new vector
    newvector <<- c(newvector, new)
  }
  # return as result this new vector
  return(newvector)
}

supernew_values = increase(some_values)

## let's see the results
supernew_values

## how about we type now
newvector



#########################################
### USE APPLY FUNCTIONS INSTEAD OF LOOPS
#########################################

## let's create a simpler function - no loop
simple_increase = function(x){
  new = x *3 + 1
  return(new)
}

## use L-APPLY
new_numbers = lapply(some_values, simple_increase)

## let's check 
new_numbers

## l-apply returns a list
str(new_numbers)

### this allows easier identification of the results of each step
## but it can be difficult to understand or parse
## --> ONLY if each step returns just one value, one could do:
new_numbers = unlist(
  lapply(some_values, simple_increase)
)

## which yields:
new_numbers

#### when we have a simple function, like a mathematical operation, we can apply it 
### straight inside the lapply code like this
### let's use square root

unlist(
  lapply(some_values, function(input) sqrt(input))
)

### the argument of function(x) is set to each values of the list used and MUST be the same of the function



###################################
####### EXERCISE ##################
###################################

### the average of a vector is calculated with the function: mean(x)
### use the list: numbers_list
### and calculate the average of each of the three vectors by using 3 methods
### a for loop using an index instead of a variable assignment
### a foo loop using a variable assignment
### a lapply function



######################################
#### PLOTTING ########################
######################################

library(tidyverse)

### we have previously created dataset
measurements

## these are time points measurements of 
## four different cell cultures

## we want to plot the time point in x and the value in y
## however - our time points have been recorded as different variables
## we need to transform the data

dataplot = measurements %>%
  pivot_longer(
    cols = c(time01,time02,time03),
    names_to = "timepoint",
    values_to = "value"
    )


## let's have a look to what we have done
dataplot


### now we can plot

ggplot(dataplot, aes(x=timepoint, y=value, colour=sample))+
  geom_point()


### let's add some more information

ggplot(dataplot, aes(x=timepoint, y=value, colour=sample))+
  geom_point()+
  geom_smooth()


### our x is not really a number 

dataplot$time <- as.numeric(factor(dataplot$timepoint))

## now we can plot again

ggplot(dataplot, aes(x=time, y=value, colour=sample))+
  geom_point()+
  geom_smooth()

## some more fanciness

ggplot(dataplot, aes(x=time, y=value, colour=sample))+
  geom_point()+
  geom_smooth()+
  facet_wrap(sample~., ncol = 2)


