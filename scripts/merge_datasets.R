merge_datasets <- function(data_ECDC, data_WB,
                           type = c("daily", "cumul"),
                           baseline = c("country", "world"),
                           select = c("worst_day", "last_day")) {
  
  ## we merge the two datasets:
  data_ECDC %>%
    dplyr::inner_join(data_WB, by = "iso2c") %>%
    dplyr::rename(country = .data$country.x) %>%
    dplyr::arrange(.data$country, dplyr::desc(.data$date_report)) -> full_data_raw
  
  ## we remove useless columns:
  full_data_raw %>%
    dplyr::select(-.data$iso2c, -.data$country.y) -> full_data_raw2
  
  ## we improve information about deaths:
  full_data_raw2 %>%
    dplyr::mutate(days_since_first_10_cumul_deaths = .data$date_report - .data$date_first_10_cumul_deaths,
                  extra_mortality_daily_country = 100 * .data$deaths_daily/.data$total_death_day,
                  extra_mortality_cumul_country = 100 * .data$deaths_cumul/(.data$total_death_day * (as.numeric(.data$days_since_first_10_cumul_deaths) + 1)),
                  extra_mortality_cumul_country = dplyr::if_else(as.numeric(.data$days_since_first_10_cumul_deaths) < 0, NA_real_, extra_mortality_cumul_country),
                  country_weight = .data$country_pop / .data$world_pop,
                  extra_mortality_daily_world = 100 * .data$deaths_daily/(.data$country_weight * .data$total_death_day_world),
                  extra_mortality_cumul_world = dplyr::if_else(.data$days_since_first_10_cumul_deaths >= 0,
                                                       100 * .data$deaths_cumul/(.data$country_weight * .data$total_death_day_world * (as.numeric(.data$days_since_first_10_cumul_deaths) + 1)),
                                                       NA_real_)) -> full_data_raw3
  
  ## we retrieve the extra mortality for the correct baseline:
  full_data_raw3 %>%
    dplyr::mutate(extra_mortality = dplyr::case_when(type[1] == "daily" & baseline[1] == "country" ~ .data$extra_mortality_daily_country,
                                                     type[1] == "daily" & baseline[1] == "world" ~ .data$extra_mortality_daily_world,
                                                     type[1] == "cumul" & baseline[1] == "country" ~ .data$extra_mortality_cumul_country,
                                                     type[1] == "cumul" & baseline[1] == "world" ~ .data$extra_mortality_cumul_world,
                                                     TRUE ~ NA_real_)) -> full_data_raw4
  
  ## we retrieve the extra mortality for the worst before or at report date:
  safe_max <- function(x) {
    if (all(is.na(x))) return(NA)
    max(x, na.rm = TRUE)
  }
  
  safe_cummax <- function(x) {
    res <- rep(NA_real_, length(x)) 
    for (i in seq_len(length(x))) {
      res[i] <- safe_max(x[seq_len(i)])
    }
    res
  } ## safe_cummax(x = c(NA, NA, 1, 1, 2, 2, 3))
  
  if (select[1] == "worst_day") {
  full_data_raw4 %>%
    dplyr::arrange(.data$country, .data$date_report) %>% ## we reverse date order for cummax
    dplyr::group_by(.data$country) %>%
    dplyr::mutate(date = .data$date_report[which(.data$extra_mortality == safe_max(.data$extra_mortality))[1]],
                  extra_mortality = safe_cummax(.data$extra_mortality)) %>%
    dplyr::ungroup() -> full_data_raw5
  } 
  
  if (select[1] == "last_day") {
    full_data_raw4 %>%
      dplyr::group_by(.data$country) %>%
      dplyr::mutate(date = .data$date_report) %>%
      dplyr::ungroup() -> full_data_raw5
  }

  ## we order by country and decreasing date:
  full_data_raw5 %>%
    dplyr::mutate(days_since_date = max(.data$date_report) - .data$date) %>%
    dplyr::arrange(country, dplyr::desc(.data$date_report)) -> full_data
  
  ## output:
  full_data
}