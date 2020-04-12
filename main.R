#library(wbstats)
#library(countrycode)
#library(tidyverse)
library(magrittr) ## for testing

## we load the functions:
  source("scripts/prepare_data_ECDC.R")
  source("scripts/prepare_data_WB.R")
  source("scripts/merge_datasets.R")
  source("scripts/add_rank_changes.R")
  source("scripts/prepare_data_rank.R")
  source("scripts/prepare_data_plot.R")


## create data_COVID:
  data_COVID <- prepare_data_ECDC(path_save_data = "~/Downloads/COVID19",
                                  date_of_report = Sys.Date() - 10)
  data_COVID
  
  ## NOTE: the following Warning is expected:
  #Warning message:                                                                         
  #  In countrycode::countrycode(.data$iso2c, origin = "iso2c", destination = "continent") :
  #  Some values were not matched unambiguously: XK
  
  ## we fix manually lump report of deaths from nursing homes (does not impact deaths_cumul):
  data_COVID[data_COVID$country == "France" & data_COVID$date_report == "2020-04-04", "deaths_daily"] <- 1120
  data_COVID[data_COVID$country == "Belgium" & data_COVID$date_report == "2020-04-08", "deaths_daily"] <- 162
  data_COVID[data_COVID$country == "Belgium" & data_COVID$date_report == "2020-04-11", "deaths_daily"] <- 325
  
  
## create data_baseline_mortality:
  data_baseline_mortality <- prepare_data_WB() ## the data do sometimes change from day to day!
  data_baseline_mortality


## create plots:
  plot_deaths(data_ECDC = data_COVID,
              data_WB = data_baseline_mortality,
              type_major = "daily",
              baseline_major = "country",
              select_major = "worst_day",
              type_minor = "daily",
              baseline_minor = "country",
              select_minor = "last_day",
              title = "Deaths by COVID19 on the worst and last day (dull & bright colour)\nrelative to baseline mortality")
    
    