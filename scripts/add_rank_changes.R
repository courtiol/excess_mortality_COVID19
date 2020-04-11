add_rank_changes <- function(data_rank) {
 data_rank %>%
    dplyr::filter(date_report %in% c(max(date_report), max(date_report) - 1)) %>%
    tidyr::pivot_wider(-.data$extra_mortality, values_from = .data$rank, names_from = .data$date_report) %>%
    dplyr::rename(rank_before_last_report = 2, rank_last_report = 3) %>%
    dplyr::mutate(diff_ranks = -1*(.data$rank_last_report - .data$rank_before_last_report),
                  diff_ranks_pretty = dplyr::case_when(diff_ranks > 0 ~ paste0(diff_ranks, "↑ "),
                                                       diff_ranks < 0 ~ paste0(-diff_ranks, "↓ "),
                                                       diff_ranks == "0" ~ "= ",
                                                       TRUE ~ "new")) %>%
    dplyr::arrange(.data$rank_last_report)
}