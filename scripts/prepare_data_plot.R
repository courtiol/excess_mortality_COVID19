prepare_data_plot <- function(data_ECDC,
                              data_WB,
                              type = c("daily", "cumul"),
                              baseline = c("country", "world"),
                              select = c("worst_day", "last_day")) {
  
  ## we combine the two sources of data:
  data_combined <- merge_datasets(data_ECDC = data_ECDC,
                                  data_WB = data_WB,
                                  type = type[1],
                                  baseline = baseline[1],
                                  select = select[1]) ## checked -> OK
  
  ## we prepare the rank of the last day, of previous day and their difference:
  data_ranked <- prepare_data_with_rank(data_combined = data_combined) ## checked -> OK
  data_ranked2 <- compare_last_2(data_ranked = data_ranked) ## checked -> OK
  
  ## we add nice columns for pretty plotting:
  data_plot_raw <- augment_data_plot(data_ranked = data_ranked2)

  ## clean up:
  data_plot_raw %>%
    dplyr::select(.data$date_report,
                  .data$country,
                  .data$country_label,
                  .data$continent,
                  extra_mortality = .data$extra_mortality_last_report,
                  diff_ranks = .data$diff_ranks_pretty,
                  date = .data$date_simple,
                  .data$date_cat) -> data_plot
  
  ## output:
  data_plot
}
