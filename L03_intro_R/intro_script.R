####
## create folder from the files pane
## enter the folder from the explorer window
## menu -> session -> Set Working Directory -> Files Pane Location

#################################
## VARIABLES ####################
#################################

## variable assignment
foo <- 1
bar = 1

## print variables at screen
foo
bar

#################################
## VECTORS   ####################
#################################

## numeric vector
vec_1 <- c(1,2,3,4,5)

## character vector
vec_2 <- c("A", "B", "C", "D")

## check what happens
vec_3 <- c(1, "B", 2, "C")
print(vec_3)

is.character(vec_3[1])

## slice a vector

vec_2[2]

vec_2[[2]]

vec_2[c(1,3)]

#################################
## LISTS   ######################
#################################

list_a = list(
  a = c(1,2,3,4,5),
  b = c('a', 'b', 'd'),
  c = "a"
)

list_a

# slice a list

list_a[1]

list_a[[1]]

## what has happened?

is.list(list_a[1])

is.list(list_a[[1]])

str(list_a[[1]])

str(list_a)
str(list_a[1])

#################################
## MATRICES ####################
#################################

mat_a = matrix(c(1,2,3,4,5,6), ncol = 3)
mat_b = matrix(c(1,2,3,4,5,6), ncol = 3, byrow = TRUE)

mat_a
mat_b

## slice a matrix
mat_b[2,1]

mat_b[2,]

mat_b[,1]

str(mat_b[,1])

colnames(mat_b) = c("A", "B", "C")
rownames(mat_b) <- c("row1", "row2")

mat_b

### named columns: what happens?
mat_b["B"]

## named columns: better
mat_b[,"B"]

#################################
## DATA FRAMES ##################
#################################

res_a <- data.frame(
  sample = c("sample1", "sample2", "sample3"),
  measure = c(123, 234, 345)
)


res_a

rownames(res_a)

## what happens
rownames(res_a) <- "sample"

## assign rownames
rownames(res_a) <- res_a$sample

res_a


## better

rownames(res_a) <- c("record1", 'record2', "record3")

res_a


### slicing

res_a["measure"]

res_a$measure

## check difference

str(res_a["measure"])
str(res_a$measure)

str(res_a[["measure"]])

res_a['record1']

res_a['record1',]


#################################
## libraries ####################
#################################

library(tidyverse)


#################################
## TIBBLES ######################
#################################

tib_a <- as_tibble(res_a)

tib_a


tib_b = tibble(
  sample = c('sam1', 'sam2', 'sam3', 'sam4'),
  measure = c(123, 234, 345, 456),
  category = c('good', 'good', 'bad', 'bad')
)



#################################
## TRANSFORM ####################
#################################


## operator and mutate

tib_b %>%
  mutate(sample = gsub('sam', 'sample', sample))

### group

tib_b %>%
  group_by(category)

## use groups

tib_b %>%
  group_by(category) %>%
  mutate(members = n())

tib_b %>%
  group_by(category) %>%
  summarise(members = n())



#################################
## READ / WRITE FILES ###########
#################################

write_tsv(tib_b, file = "test_tibble.tsv")

tib_copy <- read_tsv("test_tibble.tsv")

tib_copy

#################################
## LOOPS ########################
#################################


for (number in tib_b$measure){
  res <- number * 2
  print(res)
}

res

