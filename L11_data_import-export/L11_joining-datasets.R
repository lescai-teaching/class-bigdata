

### introducing tribble()


band = tribble(
  ~name, ~band,
  "Mick", "Stones",
  "John", "Beatles",
  "Paul", "Beatles"
)


instrument <- tribble(
  ~name, ~plays,
  "John", "guitar",
  "Paul", "bass",
  "Keith", "guitar"
)


### the effect of different joins

### LEFT JOIN

band %>% 
  left_join(instrument, by = "name")


### RIGHT JOIN

band %>% 
  right_join(instrument, by = "name")


### FULL JOIN

band %>% 
  full_join(instrument, by = "name")


### INNER JOIN

band %>% 
  inner_join(instrument, by = "name")
