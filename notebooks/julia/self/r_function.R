library(stringr)

fn <- function(a, b=3, ..., c) {
  print(str_interp("a = ${a}")) 
  print(str_interp("b = ${b}")) 
  # print(str_interp("args = ${...}")) 
  print(str_interp("c = ${c}"))
}

fn(b=2, 1, a = 5, c=4)


# get all function in base package
objs <- mget(ls("package:base"), inherits = TRUE)
funs <- Filter(is.function, objs)


fn <- function(a=2, b,c) {
  print(str_interp("a = ${a}")) 
  print(str_interp("b = ${b}")) 
  print(str_interp("c = ${c}")) 
}

library(dplyr)

starwars %>% 
  filter(species == "Droid")


starwars %>% 
  select(name, ends_with("color"))


starwars %>% 
  mutate(bmi = mass / ((height / 100)  ^ 2)) %>%
  select(name:mass, bmi)

starwars %>% 
  arrange(desc(mass))


starwars %>%
  group_by(species) %>%
  summarise(
    n = n(),
    mass = mean(mass, na.rm = TRUE)
  ) %>%
  filter(n > 1)
