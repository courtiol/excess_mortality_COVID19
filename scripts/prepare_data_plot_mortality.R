## we merge the two datasets:
full_data_raw <- inner_join(data_pop, data_COVID, by = "iso2c")

## we prepare the data for the plot:
full_data_raw %>%
  filter(SP.POP.TOTL > 2e6) %>%
  mutate(baseline_daily_mortality = (SP.DYN.CDRT.IN/1000 * SP.POP.TOTL) / 365,
         extra_mortality = 100 * deaths/baseline_daily_mortality) -> full_data_processed ## compute what we want to plot

full_data_processed %>%
 group_by(country) %>%
  mutate(extra_mortality_today = extra_mortality[date == latest]) %>%
  slice_max(extra_mortality, with_ties = FALSE) %>% ## fetch data for worst day
  ungroup() %>%
  arrange(-extra_mortality) -> data_plot_mortality_temp
#select(country, country_label, date, continent, extra_mortality) 

rm(full_data_raw)

## update ranks in list:
load("data/list_ranks.rda")
list_ranks[[today]] <- data_plot_mortality_temp$country
save(list_ranks, file = "data/list_ranks.rda")

## compute rank changes and add to data:
ranks_now <- 1:length(list_ranks[[today]])
ranks_change_raw <- -1*(ranks_now - match(list_ranks[[today]], list_ranks[[paste(as.Date(today) - 1)]]))
ranks_change_pretty <- case_when(ranks_change_raw > 0 ~ paste0(ranks_change_raw, "↑ "),
                                 ranks_change_raw < 0 ~ paste0(-ranks_change_raw, "↓ "),
                                 ranks_change_raw == "0" ~ "= ",
                                 TRUE ~ "new")
rm(list_ranks)

data_plot_mortality_temp %>%
  bind_cols(ranks_change = ranks_change_raw, delta_ranks = ranks_change_pretty) %>%
  mutate(country_label = paste0(country, " - ", 1:n()), ## country label
         country_label = fct_reorder(country_label, extra_mortality),
         continent = fct_reorder(continent, -extra_mortality, min)) -> data_plot_mortality

rm(list = c("data_plot_mortality_temp", "ranks_now", "ranks_change_raw", "ranks_change_pretty"))

