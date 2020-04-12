plot_deaths <- function(data_ECDC,
                        data_WB,
                        type_major = c("daily", "cumul"),
                        baseline_major = c("country", "world"),
                        select_major = c("worst_day", "last_day"),
                        type_minor = NULL,
                        baseline_minor = NULL,
                        select_minor = NULL,
                        title = "") {

  data_for_plot_major <- prepare_data_plot(data_ECDC = data_ECDC,
                                           data_WB = data_WB,
                                           type = type_major[1],
                                           baseline = baseline_major[1],
                                           select = select_major[1])
  
  if (!is.null(type_minor) && !is.null(baseline_minor) && !is.null(select_minor)) {
  data_for_plot_minor <- prepare_data_plot(data_ECDC = data_ECDC,
                                           data_WB = data_WB,
                                           type = type_minor[1],
                                           baseline = baseline_minor[1],
                                           select = select_minor[1])
  } else {
    data_for_plot_minor <- NULL
  }
  
  minor <- !is.null(data_for_plot_minor)
  
  ## select from the datasets what we need from minor and add it to major:
  if (minor) {
  data_for_plot_minor %>%
    dplyr::select(.data$country, extra_mortality_minor = .data$extra_mortality) -> data_for_plot_minor2
  data_for_plot_major %>%
    dplyr::left_join(data_for_plot_minor2, by = "country") -> data_for_plot_raw
  } else {
    data_for_plot_major -> data_for_plot_raw
  }
  
  ## select worst 30
  data_for_plot_raw %>%
    dplyr::slice_max(.data$extra_mortality, n = 30, with_ties = FALSE) -> data_plot
  
  ## define xmax
  xmax <- 10 + round(0.1*max(data_for_plot_raw$extra_mortality)) * 10
  xmax <- xmax + xmax %% 20
  
  ## define theme:
  ggplot2::theme_minimal(base_size = 12) +
  ggplot2::theme(panel.grid.major.y = ggplot2::element_blank(),
          plot.caption = ggplot2::element_text(hjust = 0, colour = "darkgrey"),
          plot.caption.position = "plot",
          plot.title = ggplot2::element_text(hjust = 0.5),
          plot.subtitle = ggplot2::element_text(hjust = 0.5, face = "italic"),
          plot.tag = ggplot2::element_text(face = "italic", size = 10, colour = "red", hjust = 0),
          plot.tag.position = c(0, 1),
          legend.key.width = ggplot2::unit(0.4, "cm"),
          legend.key.height = ggplot2::unit(0.4, "cm"),
          legend.title = ggplot2::element_text(size = 9, face = "italic", margin = ggplot2::margin(b = 0.1, unit = "cm")),
          legend.text = ggplot2::element_text(size = 8)) -> theme_coronaR
  
  ## plot
  data_plot %>%
    ggplot2::ggplot() + 
    ggplot2::aes(x = extra_mortality,
        y = country_label,
        label = date,
        fill = continent) +
    ggplot2::geom_col(alpha = ifelse(minor, 0.6, 1)) +
    ggplot2::geom_text(ggplot2::aes(label = diff_ranks, x = 0),
                       size = 2.5, hjust = 1, fontface = "bold") +
    ggplot2::geom_text(ggplot2::aes(colour = date_cat), size = 2, nudge_x = 0.2, hjust = 0) +
    ggplot2::scale_colour_manual(values = c("red", "orange", "blue", "darkgreen"),
                                 drop = FALSE,
                                 guide = ggplot2::guide_legend(override.aes = list(label = levels(data_plot$date_cat)),
                                                      label = FALSE, nrow = 1, keywidth = 1, unit = "cm")) +
    ggplot2::scale_x_continuous(breaks = seq(0, xmax, by = 20), limits = c(0, xmax)) +
   # ggplot2::scale_fill_hue(h.start = 220, c = 80, drop = FALSE) +
    # palette = ggplot2::scale_color_hue(h.start = 220, c = 80)$palette(5)
    ggplot2::scale_fill_manual(values = c(Africa = "#9CA600",
                                          Americas = "#E88170",
                                          Asia = "#DD78DE",
                                          Europe = "#00AAE8",
                                          Oceania = "#00BA8B"),
                               drop = FALSE) +
    ggplot2::labs(title = title,
                  tag = paste0("Update ", max(data_plot$date_report)),
                  subtitle = "Most affected 30 countries with more than 2,000,000 inhabitants",
                  caption = "Data processed by @alexcourtiol and downloaded from:\n - European Centre for Disease Prevention and Control for death counts attributed to COVID19 (direct download)\n - World Bank for yearly mortality per country (via R package {wbstats})\n For the R code and explanations on how to interpret the x-axis, please visit https://github.com/courtiol/excess_mortality_COVID19",
                  x = "Deaths caused by COVID-19 per 100 deaths due to all other causes", y = "",
                  fill = "Continent",
                  colour = "Date of worst day") +
    theme_coronaR -> plot_temp
  
  ## add minor plot:
  if (minor) {
    plot_temp +
      ggplot2::geom_col(ggplot2::aes(x = extra_mortality_minor)) -> plot_temp2
  } else {
    plot_temp -> plot_temp2
  }
      
  ## output:
  plot_temp2
}
  
  