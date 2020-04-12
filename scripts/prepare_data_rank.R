prepare_data_with_rank <- function(data_combined) {

  ## we compute the ranks:
  data_combined %>%
    dplyr::group_by(.data$date_report) %>%
    dplyr::mutate(rank = rank(-.data$extra_mortality, ties.method = "min")) %>%
    dplyr::ungroup() %>%
    dplyr::select(.data$date_report, .data$country, .data$continent, .data$rank, .data$extra_mortality, .data$date, .data$days_since_date, .data$date_first_10_cumul_deaths, days_since_10 = .data$days_since_first_10_cumul_deaths) %>%
    dplyr::arrange(.data$date_report, .data$rank, .data$extra_mortality, .data$country) -> data_rank
  
  ## output:
  data_rank
}
