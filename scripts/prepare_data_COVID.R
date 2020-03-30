## we read to COVID-19 data downloaded from https://www.ecdc.europa.eu/sites/default/files/documents/COVID-19-geographic-disbtribution-worldwide-2020-03-17.xlsx:

data_COVID_basefile <- paste0("source_data/COVID-19-geographic-disbtribution-worldwide-", today)
weblink_COVID_baselfile <- paste0("https://www.ecdc.europa.eu/sites/default/files/documents/COVID-19-geographic-disbtribution-worldwide-", today)

## download file:
tryCatch(download.file(paste0(weblink_COVID_baselfile, ".xlsx"), destfile = paste0(data_COVID_basefile, ".xlsx")), 
         error = function(e) download.file(paste0(weblink_COVID_baselfile, ".xls"), destfile = paste0(data_COVID_basefile, ".xls")))

## read file:
data_COVID_raw <- tryCatch(readxl::read_xlsx(paste0(data_COVID_basefile, ".xlsx")),
                      error = function(e) readxl::read_xls(paste0(data_COVID_basefile, ".xls")))

stopifnot(is_tibble(data_COVID_raw))
rm(data_COVID_basefile)

data_COVID_raw %>%
  rename(Country = "countriesAndTerritories") %>%
  mutate(iso2c = case_when(geoId %in% unique(codelist$iso2c) ~ geoId, ## we fix the country codes
                           geoId == "UK" ~ "GB",
                           geoId == "XK" ~ "XK",
                           geoId == "EL" ~ "GR",
                           TRUE ~ NA_character_),
         date = lubridate::ymd(paste(year, month, day, sep = "/")),
         latest = max(date),
         time_since_today = as.numeric(today - date),
         time_since_today_d = case_when(time_since_today == 0 ~ "now",
                                        time_since_today < 7 ~ "within 7 days",
                                        time_since_today < 15 ~ "within 14 days",
                                        time_since_today >= 15 ~ "later",
                                        TRUE ~ NA_character_
                                        ),
         time_since_today_d = factor(time_since_today_d, levels = c("now", "within 7 days", "within 14 days", "later")),
         date_label = paste(lubridate::month(month, label = TRUE, abbr = FALSE), day, sep = " ")) %>%
  group_by(Country, date_label) %>%
  slice_max(cases) %>% ## we remove some duplicates
  ungroup() -> data_COVID

## we create the continents:
data_COVID %>%
  mutate(continent = if_else(iso2c == "XK", ## Kosovo is not present in the list
                             "Europe",
                             countrycode(iso2c, origin = "iso2c", destination = "continent"))) -> data_COVID

## checks:
print("data_COVID countries not in WB:")

data_COVID %>%
  anti_join(data_pop) %>%
  pull(Country) %>%
  unique() %>%
  print()

rm(data_COVID_raw)

