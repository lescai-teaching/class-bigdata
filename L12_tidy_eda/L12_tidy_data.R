
## load simple data
table_colvars = readRDS(url("https://raw.githubusercontent.com/lescai-teaching/class-bigdata/main/L12_tidy_eda/L12_dataset_table-colvars.rds"))
table_diffvars = readRDS(url("https://raw.githubusercontent.com/lescai-teaching/class-bigdata/main/L12_tidy_eda/L12_dataset_table-diffvars.rds"))

## inspect the dataset
table_colvars

# use pivot_longer()
table_colvars %>%
  pivot_longer(
    cols = c(`2020`:`2022`),
    names_to = "year",
    values_to = "cases"
  )


## inspect a different dataset
table_diffvars

## use pivot_wider()
table_diffvars %>%
  pivot_wider(
    names_from = type,
    values_from = count
  )


###########################
## more complex example


## load genotype data and samples metadata
genotypes = readRDS(url("https://raw.githubusercontent.com/lescai-teaching/class-bigdata/main/L12_tidy_eda/L12_dataset_genotypes.rds"))
samples_metadata = readRDS(url("https://raw.githubusercontent.com/lescai-teaching/class-bigdata/main/L12_tidy_eda/L12_dataset_sample_metadata.rds"))


## inspect them both
genotypes

## and metadata
samples_metadata

## to make data tidy we have 2 variables here, one is spread in columns
## genotype and individuals
## then we want to join this with the samples metadata to know who is our case

genotypes_long = genotypes %>%
  pivot_longer(
    !variant,
    names_to = "individual",
    values_to = "genotype"
  ) %>%
  left_join(
    samples_metadata %>% dplyr::select(individual, PHENO),
    by = "individual"
  )


## to calculate a chi-square in a traditional way though we need the counts
## and we need them by each genotype which becomes our categorical predictor
genotypes_count = genotypes_long %>%
  group_by(variant, genotype, PHENO) %>%
  summarise(
    count = n()
  ) %>%
  pivot_wider(
    names_from = genotype,
    values_from = count
  )

### we can't have NA so we just set it to 0
genotypes_count[is.na(genotypes_count)] <- 0


genotypes_count

## this way we can calculate using the base R chisq.test:

chisq.test(
  genotypes_count %>% filter(variant == "dis_0") %>% ungroup() %>% select(`0/0`,`0/1`,`1/1`)
)
