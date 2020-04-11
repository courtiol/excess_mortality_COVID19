plot_deaths <- function(data_for_plot_major, data_for_plot_minor = NULL, xmax = 100, cumul = FALSE) {

  data_for_plot_major %>%
    slice_max(extra_mortality, n = 30, with_ties = FALSE) %>% ## top 30 countries
    ggplot() + 
    aes(x = extra_mortality,
        y = country_label,
        label = days_since_report_cat,
        fill = continent) +
    geom_col(alpha = ifelse(!cumul, 0.6, 1)) +
    geom_text(aes(label = diff_ranks_pretty, x = 0), size = 2.5, hjust = 1, fontface = "bold") +
    labs(tag = paste0("Update ", max(data_for_plot_major$date_report)),
         subtitle = "Most affected 30 countries with more than 2,000,000 inhabitants",
         caption = "Data processed by @alexcourtiol and downloaded from:\n - European Centre for Disease Prevention and Control for death counts attributed to COVID19 (direct download)\n - World Bank for yearly mortality per country (via R package {wbstats})\n For the R code and explanations on how to interpret the x-axis, please visit https://github.com/courtiol/excess_mortality_COVID19",
         x = "Deaths caused by COVID-19 per 100 deaths due to all other causes", y = "",
         fill = "Continent") -> plot_temp
  
    plot_temp +
      geom_col(aes(x = extra_mortality)) +
      geom_text(aes(colour = time_since_today_d), size = 2, nudge_x = 0.2, hjust = 0) +
      scale_colour_manual(values = c("red", "orange", "blue", "darkgreen"),
                          drop = FALSE,
                          guide = guide_legend(override.aes = list(label = levels(data_plot_mortality$time_since_today_d)),
                                               label = FALSE, nrow = 1, keywidth = 1, unit = "cm")) +
      labs(title = "Deaths by COVID-19 on the last & worst day (dull & bright colour)\nrelative to baseline mortality",
           colour = "Date of worst day") -> plot_temp

  
    if (cumul) {
      plot_temp + 
        labs(title = "Cumulative deaths by COVID-19 relative to baseline mortality") -> plot_temp
      }
  
  plot_temp +
    theme_minimal(base_size = 12) +
    theme(panel.grid.major.y = element_blank(),
          plot.caption = element_text(hjust = 0, colour = "darkgrey"),
          plot.caption.position = "plot",
          plot.title = element_text(hjust = 0.5),
          plot.subtitle = element_text(hjust = 0.5, face = "italic"),
          plot.tag = element_text(face = "italic", size = 10, colour = "red", hjust = 0),
          plot.tag.position = c(0, 1),
          legend.key.width = unit(0.4, "cm"),
          legend.key.height = unit(0.4, "cm"),
          legend.title = element_text(size = 9, face = "italic", margin = margin(b = 0.1, unit = "cm")),
          legend.text = element_text(size = 8)) +
    scale_x_continuous(breaks = seq(0, xmax, by = 20), limits = c(0, xmax)) +
    scale_fill_hue(h.start = 220, c = 80, drop = FALSE)
}
  
  