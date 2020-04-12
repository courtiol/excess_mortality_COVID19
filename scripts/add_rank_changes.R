compare_last_2 <- function(data_ranked) {
    
  ## we focus on the information of last day:
  data_ranked %>%
    dplyr::filter(.data$date_report == max(.data$date_report)) %>%
    dplyr::select(-.data$rank, -.data$extra_mortality) -> data_last
                  

  ## we focus on difference between last day and day before last:
  data_ranked %>%
    dplyr::filter(.data$date_report %in% c(max(.data$date_report), max(.data$date_report - 1))) %>%
    dplyr::select(.data$country, .data$date_report, .data$rank, .data$extra_mortality) %>%
    dplyr::arrange(.data$country) %>%
    tidyr::pivot_wider(values_from = c(.data$rank, .data$extra_mortality), names_from = .data$date_report) %>%
    dplyr::rename(rank_before_last_report = 2,
                  rank_last_report = 3,
                  extra_mortality_before_last_report = 4,
                  extra_mortality_last_report = 5) %>%
    dplyr::mutate(diff_ranks = -1*(.data$rank_last_report - .data$rank_before_last_report),
                  diff_ranks_pretty = dplyr::case_when(diff_ranks > 0 ~ paste0(diff_ranks, "↑ "),
                                                       diff_ranks < 0 ~ paste0(-diff_ranks, "↓ "),
                                                       diff_ranks == "0" ~ "= ",
                                                       TRUE ~ "new"), .after = .data$rank_last_report) %>%
    dplyr::arrange(.data$rank_last_report) -> data_compared
  
  ## we merge the datasets:
  data_last %>%
      dplyr::left_join(data_compared, by = "country") -> data_ranked
  
  data_ranked
}
