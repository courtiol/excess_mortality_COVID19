merge_datasets <- function(data_ECDC, data_WB,
                           type = c("daily", "cumul"),
                           baseline = c("country", "world"),
                           select = c("worst_day", "last_day")) {
  
  ## we merge the two datasets:
  data_ECDC %>%
    dplyr::inner_join(data_WB, by = "iso2c") %>%
    dplyr::rename(country = .data$country.x) -> full_data_raw
  
  ## we remove useless columns:
  full_data_raw %>%
    dplyr::select(-.data$iso2c, -.data$country.y) -> full_data_raw2
  
  ## we improve information about deaths:
  full_data_raw2 %>%
    dplyr::mutate(extra_mortality_daily = 100 * .data$deaths_daily/.data$total_death_day,
                  extra_mortality_cumul = 100 * .data$deaths_cumul/(.data$total_death_day * (.data$days_since_first_10_cumul_deaths + 1)),
                  country_weight = .data$country_pop / .data$world_pop,
                  extra_mortality_daily_world = 100 * .data$deaths_daily/(.data$country_weight * .data$total_death_day_world),
                  extra_mortality_cumul_world = ifelse(.data$days_since_first_10_cumul_deaths >= 0,
                                                       100 * .data$deaths_cumul/(.data$country_weight * .data$total_death_day_world * (.data$days_since_first_10_cumul_deaths + 1)),
                                                       NA)) -> full_data_raw3
  
  ## we retrieve the extra mortality for the correct baseline:
  full_data_raw3 %>%
    dplyr::mutate(extra_mortality = dplyr::case_when(type[1] == "daily" & baseline[1] == "country" ~ .data$extra_mortality_daily,
                                                     type[1] == "daily" & baseline[1] == "world" ~ .data$extra_mortality_daily_world,
                                                     type[1] == "cumul" & baseline[1] == "country" ~ .data$extra_mortality_cumul,
                                                     type[1] == "cumul" & baseline[1] == "world" ~ .data$extra_mortality_cumul_world,
                                                     TRUE ~ NA_real_)) -> full_data_raw4
  
  ## we retrieve the extra mortality for the worst if needed:
  if (select[1] == "worst_day") {
  full_data_raw4 %>%
    dplyr::group_by(.data$country) %>%
    dplyr::mutate(extra_mortality = ifelse(!all(is.na(.data$extra_mortality)), max(.data$extra_mortality, na.rm = TRUE), NA)) %>%
    dplyr::ungroup() -> full_data
  } 
  
  if (select[1] == "last_day") {
    full_data_raw4 -> full_data
  }

  ## output:
  full_data
}