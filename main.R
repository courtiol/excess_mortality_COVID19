library(wbstats)
library(countrycode)
library(tidyverse)

## we load the functions:
  source("scripts/prepare_data_ECDC.R")
  source("scripts/prepare_data_WB.R")
  source("scripts/merge_datasets.R")
  source("scripts/add_rank_changes.R")
  source("scripts/prepare_data_rank.R")
  source("scripts/prepare_data_plot.R")


library(magrittr)

## create data_COVID:
  data_COVID <- prepare_data_ECDC(path_save_data = "./source_data")
  
  ## NOTE: the following Warning is expected:
  #Warning message:                                                                         
  #  In countrycode::countrycode(.data$iso2c, origin = "iso2c", destination = "continent") :
  #  Some values were not matched unambiguously: XK
  
  data_COVID
  
  
## create data_baseline_mortality (only if not existing, as it does not change within a year):
  folder_path <- "./data/"
  file_name <- "data_baseline_mortality.rda"
  if (file.exists(paste0(folder_path, file_name))) {
    load(paste0(folder_path, file_name)) ## it is exist, we just import the data
  } else {## otherwise, we create them
    if (!dir.exists(folder_path)) {
      dir.create(folder_path) ## create folder if missing
    }
    data_baseline_mortality <- prepare_data_WB() ## create the data
    save(data_baseline_mortality, file = paste0(folder_path, file_name)) ## save the data as R object
  }
  
  data_baseline_mortality
  
  
## create the dataset for plotting:
  data_for_plot_major <- prepare_data_plot(data_ECDC = data_COVID,
                                           data_WB = data_baseline_mortality,
                                           type = "daily",
                                           baseline = "country",
                                           select = "worst_day")
  
  data_for_plot_minor <- prepare_data_plot(data_ECDC = data_COVID,
                                           data_WB = data_baseline_mortality,
                                           type = "daily",
                                           baseline = "country",
                                           select = "last_day")
  