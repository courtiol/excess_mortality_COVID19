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

levels_time_since_today <- c("last day",
                             "last week",
                             "last 14d",
                             ">14 days")

data_COVID_raw %>%
  rename(Country = "countriesAndTerritories") %>%
  mutate(iso2c = case_when(geoId %in% unique(codelist$iso2c) ~ geoId, ## we fix the country codes
                           geoId == "UK" ~ "GB",
                           geoId == "XK" ~ "XK",
                           geoId == "EL" ~ "GR",
                           TRUE ~ NA_character_),
         date = lubridate::ymd(paste(year, month, day, sep = "/")),
         time_since_today = as.numeric(as.Date(today) - date),
         time_since_today_d = case_when(time_since_today == 0  ~ levels_time_since_today[1],
                                        time_since_today  < 7  ~ levels_time_since_today[2],
                                        time_since_today  < 15 ~ levels_time_since_today[3],
                                        time_since_today >= 15 ~ levels_time_since_today[4],
                                        TRUE ~ NA_character_
                                        ),
         time_since_today_d = factor(time_since_today_d, levels = levels_time_since_today),
         date_label = paste(lubridate::month(month, label = TRUE, abbr = FALSE), day, sep = " ")) %>%
  group_by(Country) %>%
    arrange(date, .group_by = TRUE) %>%
    mutate(latest = max(date),
           deaths_cumul = cumsum(deaths),
           date_10_deaths_cumul = date[which(deaths_cumul >= 10)[1]]) %>%
  group_by(Country, date_label) %>%
  slice_max(cases) %>% ## we remove some duplicates
  ungroup() %>%
  mutate(days_since_10_deaths_cumul = as.numeric(as.Date(today) - date_10_deaths_cumul)) %>%
  arrange(Country, date) -> data_COVID

## we create the continents:
data_COVID %>%
  mutate(continent = if_else(iso2c == "XK", ## Kosovo is not present in the list
                             "Europe",
                             countrycode(iso2c, origin = "iso2c", destination = "continent"))) -> data_COVID

## fix lump report of deaths from nursing homes:
data_COVID[data_COVID$Country == "France" & data_COVID$date == "2020-04-04", "deaths"] <- 1120
data_COVID[data_COVID$Country == "Belgium" & data_COVID$date == "2020-04-08", "deaths"] <- 162


## checks:
print("data_COVID countries not in WB:")

data_COVID %>%
  anti_join(data_pop) %>%
  pull(Country) %>%
  unique() %>%
  print()

rm(data_COVID_raw)

