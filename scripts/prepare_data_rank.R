prepare_data_rank <- function(data_combined) {

  ## we extract last day mortality:
  data_combined %>%
    dplyr::group_by(.data$country) %>%
    dplyr::mutate(extra_mortality_last = .data$extra_mortality[.data$date_report == .data$date_report_last]) -> data_rank_raw2

  ## we compute the ranks:
  data_rank_raw2 %>%
    dplyr::group_by(.data$date_report) %>%
    dplyr::mutate(rank = rank(-.data$extra_mortality, ties.method = "min")) %>%
    dplyr::ungroup() %>%
    dplyr::select(.data$date_report, .data$country, .data$rank, .data$extra_mortality) %>%
    dplyr::arrange(.data$date_report, .data$rank, .data$extra_mortality, .data$country) -> data_rank
  
  ## output:
  data_rank
}
