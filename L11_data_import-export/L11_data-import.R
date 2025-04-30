### READR functions
### how to look at a function's options

formals(read_tsv)

names(formals(read_tsv))
names(formals(read_csv))

### one can compare options of different functions

intersect(names(formals(read_tsv)), names(formals(read_csv)))

identical(names(formals(read_tsv)), names(formals(read_csv)))

## why this is false?
## let's order the options

identical(
  names(formals(read_tsv))[order(names(formals(read_tsv)))], 
  names(formals(read_csv))[order(names(formals(read_csv)))]
  )



##################################################
## READING DATA 
##################################################

### NIMBUS DATASET 

data = url("https://raw.githubusercontent.com/lescai-teaching/class-bigdata/main/L11_data_import-export/L11_dataset_babynames.rds")

## one can read from the web
nimbus = read_csv(data)
## or alternatively reaad it locally


## what do you observe?
nimbus

## inspect one single element
## observe the role of the function pull()
nimbus %>% pull(ozone) %>% class()

## one can obtain a similar result with the function pluck()
## observe the difference between the two
nimbus %>% pluck("ozone") %>% class()

## what is the conclusion of the vector type
## compare it with visual inspection of the above dataset
## why is that?

nimbus %>% pluck("ozone") %>% unique()

## observe better

## let's add an option

nimbus = read_csv(data, na = ".")

nimbus

## see what's changed
nimbus %>% pluck("ozone") %>% class()

## we can manually specify the column types

nimbus = read_csv(data, 
					na = ".",
					col_types = list(
                    ozone = col_double()
					)
					)

### let's see the result
nimbus

## look at all possible col types
?cols()
## and choose readr package

