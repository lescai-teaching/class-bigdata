
## we load the dataset
babynames = readRDS(url("https://raw.githubusercontent.com/lescai-teaching/class-bigdata/main/L11_data_import-export/L11_dataset_babynames.rds"))

## have a look at the data
babynames


select(babynames, name, prop)


###################
# SELECT HELPERS
###################


### select range of columns

select(babynames, name:prop)

select(babynames, year:n)


### select except

select(babynames, -c(sex,n))


### select with match

select(babynames, starts_with("n"))



###################
## FILTER
###################

filter(babynames, name == "Garrett")

filter(babynames, prop >= 0.08)

## filter extracts rows that meet every logical criteria

filter(babynames, name == "Garrett", year == 1880)


###################
## ARRANGE
###################


babynames %>% 
  arrange(n)


## inverting the order

babynames %>% 
  arrange(desc(n))


###################
## MAGIC FUNCTIONS
###################

## number of rows in a dataset or group
babynames %>% 
  summarise(n = n())

# number of DISTINCT values in a variable

babynames %>% 
  summarise(
    n = n(), 
    nname = n_distinct(name)
    )


