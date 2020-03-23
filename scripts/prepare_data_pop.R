## download new data from WB:
new_cache <- wbcache()

## extract data from WB:
data_pop_raw <- wb(indicator = c("SP.POP.TOTL", "SP.DYN.CDRT.IN"),
                   startdate = 2010,
                   enddate = 2020, cache = new_cache)

## process data from WB to get daily mortality:
data_pop_raw %>%
  group_by(country, indicatorID) %>%
  slice_max(date) %>%
  ungroup() %>%
  add_count(country) %>%
  filter(n == 2) %>% ## we need both indicators!
  pivot_wider(-c(date, indicator, n),
              names_from = indicatorID,
              values_from = value) %>%
  mutate(total_death = SP.DYN.CDRT.IN * SP.POP.TOTL / 1000,
         total_death_day = total_death / 365) %>%
  filter(iso2c %in% c(codelist$iso2c, "XK")) -> data_pop

## we perform some visual checks:
data_pop %>%
  arrange(total_death)

data_pop %>%
  ggplot() + 
  aes(y = total_death_day, x = fct_reorder(country, total_death_day)) +
  geom_col() +
  scale_y_log10()

## save data:
save(data_pop, file = "data/data_pop.rda")