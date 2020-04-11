prepare_data_plot <- function(data_ECDC, data_WB, type = c("daily", "cumul"), baseline = c("country", "world"), select = c("worst_day", "last_day")) {
  
  ## we combine the two sources of data:
  data_combined <- merge_datasets(data_ECDC = data_ECDC,
                                  data_WB = data_WB,
                                  type = type[1],
                                  baseline = baseline[1],
                                  select = select[1])
  
  ## we prepare the rank of the last day, of previous day and their difference:
  data_rank <- prepare_data_rank(data_combined = data_combined)
  data_rank2 <- add_rank_changes(data_rank)
  
  ## we keep only worst in data_combined:
  data_combined %>%
    dplyr::group_by(.data$country) %>%
    dplyr::slice_max(.data$extra_mortality, with_ties = FALSE) %>%
    dplyr::ungroup() %>%
    dplyr::arrange(-.data$extra_mortality) -> data_combined2
  
  ## we combine the 2 datasets:
  data_rank2 %>%
    dplyr::left_join(data_combined2, by = "country") %>%
    dplyr::arrange(.data$rank_last_report) -> data_plot_raw
  
  ## we add nice labels for country:
  data_plot_raw %>%
    dplyr::mutate(country_label = paste(.data$country, "-", .data$rank_last_report),
                  country_label = forcats::fct_reorder(.data$country_label, -.data$rank_last_report)) -> data_plot
  
  ## output:
  data_plot
}
