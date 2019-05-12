library(gapminder)
data("gapminder")

gapminder <- gapminder

summary(gapminder)

mean(gapminder$pop)

hist(gapminder$lifeExp)

hist(log(gapminder$pop))


boxplot(gapminder$lifeExp ~ gapminder$continent)

plot(gapminder$lifeExp ~ log(gapminder$gdpPercap))

library(dplyr)

gapminder %>% 
  select(country, lifeExp) %>% 
  filter(country == "South Africa" | country == "Ireland") %>%
  group_by(country) %>%
  summarise(Average_life = mean(lifeExp))


df1 <- gapminder %>% 
  select(country, lifeExp) %>% 
  filter(country == "South Africa" | country == "Ireland")

t.test(data = df1, lifeExp ~ country)

t.test(lifeExp ~ country, data = df1)

library(ggplot2)

gapminder %>%
  filter(gdpPercap < 50000) %>%
  ggplot(aes(x=log(gdpPercap), y=lifeExp, col=year, size=pop)) + 
  geom_point(alpha = 0.3) + 
  geom_smooth(method = lm) +
  facet_wrap(~continent)
