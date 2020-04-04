library(wbstats)
library(countrycode)
library(tidyverse)

today <- paste(Sys.Date())

## create data_pop:
  if (!file.exists("data/data_pop.rda")) {
    source("scripts/prepare_data_pop.R")
  } else {
    load("data/data_pop.rda")
  }
  data_pop

## create data_COVID:
  source("scripts/prepare_data_COVID.R")
  data_COVID

## create data_plot_mortality:
  source("scripts/prepare_data_plot_mortality.R")
  data_plot_mortality

## draw plot:
  source("scripts/draw_mortality_plot.R")
  mortality_plot

## quick look at the numbers:
  ### worst 30:
    data_plot_mortality %>%
      slice(1:30) %>%
      select(country, delta_ranks, deaths,  total_death_day, extra_mortality) %>%
      print(n = Inf)
    
  ### new in worst 30:
    data_plot_mortality %>%
      mutate(new_rank = row_number(),
             old_rank = row_number() + ranks_change) %>%
      filter(old_rank > 30, new_rank < 31) %>%
      select(country, new_rank, old_rank,  total_death_day, extra_mortality)
    
  ### leaving worst 20:
    data_plot_mortality %>%
      mutate(new_rank = row_number(),
             old_rank = row_number() + ranks_change) %>%
      filter(new_rank > 30, old_rank < 31) %>%
      select(country, new_rank, old_rank,  total_death_day, extra_mortality)
    
