augment_data_plot <- function(data_ranked) {
  
  ## we add country labels based on last rank:
  data_ranked %>%
    dplyr::mutate(country_label = paste(.data$country, "-", .data$rank_last_report),
                  country_label =  gsub(pattern = "_", replacement = " ", x = country_label),
                  country_label = forcats::fct_reorder(.data$country_label, -.data$rank_last_report)) -> data_plot_raw
  
  ## we add data labels:
  levels_days <- c("last day", "last week", "last 14d", ">14 days")
  
  data_plot_raw %>%
    dplyr::mutate(date_simple = paste(lubridate::month(date, label = TRUE, abbr = FALSE),
                                      lubridate::day(date), sep = " "),
                  date_cat = dplyr::case_when(
                    days_since_date == 0  ~ levels_days[1],
                    days_since_date  < 7  ~ levels_days[2],
                    days_since_date  < 15 ~ levels_days[3],
                    days_since_date >= 15 ~ levels_days[4],
                    TRUE ~ NA_character_),
                  date_cat = factor(date_cat, levels = levels_days),
                  cumul_span = paste0(.data$date_report, " -> ", .data$date_first_10_cumul_deaths),
                  cumul_span = dplyr::if_else(is.na(.data$date_first_10_cumul_deaths),
                                              NA_character_,
                                              cumul_span))  -> data_plot
  
  ## output:
  data_plot
}
