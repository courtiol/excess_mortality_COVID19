mortality_plot <- data_plot_mortality %>%
  slice_max(extra_mortality, n = 30, with_ties = FALSE) %>% ## top 30 countries
  ggplot() + 
  aes(x = extra_mortality,
      y = country_label,
      label = date_label,
      fill = continent) +
  geom_col() + 
  geom_text(aes(colour = time_since_today_d), size = 2, nudge_x = 0.2, hjust = 0) +
  geom_text(aes(label = delta_ranks, x = 0), size = 2.5, hjust = 1, fontface = "bold") +
  labs(tag = paste0("Update ", today),
       title = "Deaths by COVID-19 on the worst day, relative to baseline mortality",
       subtitle = "Most affected 30 countries with more than 2,000,000 inhabitants",
       caption = "Data processed by @alexcourtiol and downloaded from:\n - European Centre for Disease Prevention and Control for death counts attributed to COVID19 (direct download)\n - World Bank for yearly mortality per country (via R package {wbstats})\n For the R code and explanations on how to interpret the x-axis, please visit https://github.com/courtiol/excess_mortality_COVID19",
       x = "Deaths caused by COVID-19 per 100 deaths due to all other causes", y = "",
       fill = "Continent",
       colour = "Date of worst day") +
  scale_colour_manual(values = c("red", "orange", "blue", "darkgreen"),
                      drop = FALSE,
                      guide = guide_legend(override.aes = list(label = levels(data_plot_mortality$time_since_today_d)),
                                           label = FALSE, nrow = 1, keywidth = 1, unit = "cm")) +
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
  scale_x_continuous(breaks = seq(0, 140, by = 20), limits = c(0, 140)) +
  scale_fill_hue(h.start = 220, c = 80,  drop = FALSE)

ggsave(plot = mortality_plot, filename = paste0("./figures/extra_mortality_", today, ".png"), width = 9, height = 6, units = "in")
