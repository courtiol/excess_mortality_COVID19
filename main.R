library(wbstats)
library(countrycode)
library(tidyverse)

today <- Sys.Date()

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
  data_plot_mortality %>%
    #slice(1:30) %>%
    select(country, Deaths,  total_death_day, extra_mortality) %>%
    print(n = Inf)
  
