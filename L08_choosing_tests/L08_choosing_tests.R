

###################
# chi-square test
###################

carrierData = readRDS(url("https://raw.githubusercontent.com/lescai-teaching/class-bigdata/main/L08_choosing_tests/L08_dataset_carrier_data.rds"))

## let's use the infer workflow to show run a chi-square test
## the hypothesis is that the genotype is different in cases and controls

genotype_null_empirical = carrierData %>%
  specify(formula = condition ~ genotype) %>%
  hypothesise(null = "independence") %>%
  generate(reps = 1000, type = "permute") %>%
  calculate(stat = "Chisq")


genotype_observed = carrierData %>%
  specify(formula = condition ~ genotype) %>%
  hypothesise(null = "independence") %>%
  calculate(stat = "Chisq")

# visualize the null distribution and test statistic!
genotype_null_empirical %>%
  visualize() + 
  shade_p_value(genotype_observed,
                direction = "greater")

# calculate the p value from the observed statistic and null distribution
p_value_independence <- genotype_null_empirical %>%
  get_p_value(obs_stat = genotype_observed,
              direction = "greater")

p_value_independence



############## we could alternatively use the theoretical distribution


genotype_null_theoretical = carrierData %>%
  specify(formula = condition ~ genotype) %>%
  assume(distribution = "Chisq")


genotype_null_theoretical %>%
  visualize() + 
  shade_p_value(genotype_observed,
                direction = "greater")


### one can also get the pvalue from the base chisq distribution in R
pchisq(genotype_observed$stat, 2, lower.tail = FALSE)


### there is a wrapper function more conveniently to do this

chisq_test(carrierData, condition ~ genotype)


###########################
## why this is convenient?
##########################

table(carrierData$condition, carrierData$genotype)

chisq_base = chisq.test(
  table(carrierData$condition, carrierData$genotype)
)

chisq_base

tidy(chisq_base)




####################################################
###### T-TEST ##########
####################################################

bloodTestsData = readRDS(url("https://raw.githubusercontent.com/lescai-teaching/class-bigdata/main/L08_choosing_tests/L08_dataset_bloodtests.rds"))


ggplot(bloodTestsData, aes(x=sugar, y=..density.., fill=individual_group))+
  geom_density(alpha = 0.6)

## is this difference going to be significant??


### let's use another way to visualise this

ggplot(bloodTestsData, aes(y=sugar, fill=individual_group))+
  geom_boxplot()+
  coord_flip()

## what do you think now?

sugar_observed = bloodTestsData %>%
  specify(sugar ~ individual_group) %>%
  calculate(stat = "diff in means", order = c("case", "control"))

sugar_null_empirical = bloodTestsData %>%
  specify(sugar ~ individual_group) %>%
  hypothesise(null = "independence") %>%
  generate(reps = 1000, type = "permute") %>%
  calculate(stat = "diff in means", order = c("case", "control"))

sugar_null_empirical %>%
  visualise()+
  shade_p_value(sugar_observed,
                direction = "two-sided")

p_value_sugar = sugar_null_empirical %>%
  get_p_value(obs_stat = sugar_observed,
              direction = "two-sided")

p_value_sugar

#### wrapper for t-test base like with chi-sq

t_test(x = bloodTestsData, 
       formula = sugar ~ individual_group, 
       order = c("case", "control"),
       alternative = "two-sided")




#################################################
###### ANOVA ########
#################################################

bloodTestsGroups = readRDS(url("https://raw.githubusercontent.com/lescai-teaching/class-bigdata/main/L08_choosing_tests/L08_dataset_bloodtests-groups.rds"))

## first let's look at the data

ggplot(bloodTestsGroups, aes(x=sugar, y=..density.., fill=individual_group))+
  geom_density(alpha = 0.6)

## is this difference going to be significant??


### let's use another way to visualise this

ggplot(bloodTestsGroups, aes(y=sugar, fill=individual_group))+
  geom_boxplot()+
  coord_flip()

### we might want to make sure the category is factorised in the order we want

bloodTestsGroups = bloodTestsGroups %>%
  mutate(
    individual_group = factor(individual_group,
                              levels = c("low_exercise", "medium_exercise", "intense_exercise", "athletes")
                              )
  )

### then we repeat

ggplot(bloodTestsGroups, aes(y=sugar, fill=individual_group))+
  geom_boxplot()+
  coord_flip()

## we might actually see a trend here


sugar_groups_observed = bloodTestsGroups %>%
  specify(formula = sugar ~ individual_group ) %>%
  hypothesise(null = "independence") %>%
  calculate(stat = "F")

sugar_groups_null_empirical = bloodTestsGroups %>%
  specify(formula = sugar ~ individual_group ) %>%
  hypothesise(null = "independence") %>%
  generate(reps = 1000, type = "permute") %>%
  calculate(stat = "F")


sugar_groups_null_empirical %>%
  visualise()+
  shade_p_value(
    obs_stat = sugar_groups_observed,
    direction = "greater"
  )


# calculate the p value from the observed statistic and null distribution
p_value_sugar_groups <- sugar_groups_null_empirical %>%
  get_p_value(obs_stat = sugar_groups_observed,
              direction = "greater")

p_value_sugar_groups


### what about the theoretical distribution?

# visualize the theoretical null distribution and test statistic!
sugar_groups_null_theoretical <- bloodTestsGroups %>%
  specify(formula = sugar ~ individual_group ) %>%
  assume(distribution = "F")

visualize(sugar_groups_null_theoretical) +
  shade_p_value(sugar_groups_observed,
                direction = "greater")





#################################################
####   CORRELATION ANALYSIS #####################
#################################################


## we can use the same dataset bloodTestsData

head(bloodTestsData)

### the assumption is that insulin levels are correlated to sugar levels
### let's see what a plot would tell us

ggplot(bloodTestsData, aes(x=sugar, y=insulin))+
  geom_point()

## we can separate the groups

ggplot(bloodTestsData, aes(x=sugar, y=insulin, colour = individual_group))+
  geom_point()

### they overlap too much

ggplot(bloodTestsData, aes(x=sugar, y=insulin, colour = individual_group))+
  geom_point()+
  facet_wrap(~individual_group)

### we already know that case sugar is higher in cases
### there is surely a correlation so we really want to test the magnitude

bloodTests_correlation_observed <- bloodTestsData %>% 
  specify(insulin ~ sugar) %>%
  calculate(stat = "correlation")


### visualise the Pearson's correlation score r

bloodTests_correlation_observed



bloodTests_correlation_null <- bloodTestsData %>% 
  specify(insulin ~ sugar) %>%
  hypothesize(null = "independence") %>%
  generate(reps = 1000, type = "permute") %>%
  calculate(stat = "correlation")

visualize(bloodTests_correlation_null) +
  shade_p_value(obs_stat = bloodTests_correlation_observed, direction = "two-sided")

corr_pval = bloodTests_correlation_null %>%
  get_p_value(obs_stat = bloodTests_correlation_observed, direction = "two-sided")

corr_pval


################# LOGISTIC REGRESSION - TRADITIONAL WAY


ggplot(bloodTestsData, aes(x=sugar, y=insulin, colour = individual_group))+
  geom_point()+
  geom_smooth(method = "lm", colour = "blue")+
  facet_wrap(~individual_group)

### the relationship seems very clear, let's see when we run a linear regression in the traditional way

linear_model = glm(insulin~sugar, data = bloodTestsData, family = "gaussian")
tidy(linear_model)

linear_model2 = lm(insulin~sugar, data = bloodTestsData)
tidy(linear_model2)


###########################################
## CHI-SQUARE VS FISHER TEST ##############
###########################################

carrierDataRARE = readRDS(url("https://raw.githubusercontent.com/lescai-teaching/class-bigdata/main/L08_choosing_tests/L08_dataset_carrierRARE_data.rds"))

chisq_test(carrierDataRARE, condition ~ genotype)


fisher = fisher.test(table(carrierDataRARE$condition, carrierDataRARE$genotype))
fisher
tidy(fisher)




#############################################
### CHI-SQUARE VS LOGISTIC REGRESSION #######
#############################################

## we have seen we can do this

table(carrierData$condition, carrierData$genotype)

chisq_base = chisq.test(
  table(carrierData$condition, carrierData$genotype)
)

chisq_base

head(carrierData)

## genotype and condition are 2 numeric variables now
## condition is binomial, i.e. can be either a control (1) or a patient (2)
## logistic regression tests presence / absence or better 0 / 1 so
## we have to transform the data

carrierData = carrierData %>%
  mutate(
    genotype_reg = case_when(
      genotype == "0/0" ~ 0,
      genotype == "0/1" ~ 1,
      genotype == "1/1" ~ 2
    ),
    condition_reg = ifelse(condition == "control", 0, 1)
  )


genotype_test = glm(condition_reg ~ genotype_reg, data = carrierData, family = "binomial")

tidy(genotype_test)

