## FDA SHRIMP IMPORT REFUSAL

## Data Source
# Food and Drug Administration
# Received from WWF Aquaculture Lead Madeleine Craig on Jan 16, 2019
# Timeseries: 2014 to 2017
# Format: XLSX, CSV


## Summary 
# Collaborate with WWF to visualize US shrimp import refusals timeseries. Where they are coming from and reason for refusal.
library(tidyverse)
library(plotly)
library(viridis)
library(lubridate)
library(rworldmap)
library(leaflet.minicharts)

# create file path shortcuts to the data
raw_path <- "data/raw/FDA_Shrimp_Import"
int_path <- "data/int/FDA_Shrimp_Import"



## Read in FDA Data
fda <- read.csv(file.path(raw_path, "Shrimp_Import_Refusals.csv"), stringsAsFactors = FALSE)



## NUMBER OF SHRIMP IMPORT REFUSALS PER COUNTRY ##

## Tidy Data
shrimp_sub <- fda %>%
  select(REFUSAL_DATE, COUNTRY_NAME)

# fix date column to a format R can understand
# before converting, make sure date column is in format 'YYYY-MM-DD'
shrimp_sub$REFUSAL_DATE <- as.Date(shrimp_sub$REFUSAL_DATE, "%Y-%m-%d")
class(shrimp_sub$REFUSAL_DATE) # check

# create a separate year column
shrimp_date <- shrimp_sub %>%
  mutate(YEAR = lubridate::year(REFUSAL_DATE)) %>%
  select(YEAR, COUNTRY_NAME)

# remove leading white spaces
shrimp_space <- shrimp_date %>%
  mutate(COUNTRY_NAME = sub("^\\s+", "", COUNTRY_NAME), # if starts with
         COUNTRY_NAME = sub("\\s+$", "", COUNTRY_NAME)) # if ends with

# check which country names need to be fixed
# compare with cntry_coord, what's in shrimp_space not in cntry_coord
cntry_coord <- read.csv("data/ref/country_lat_lon.csv", stringsAsFactors = FALSE)
setdiff(unique(shrimp_space$COUNTRY_NAME), unique(cntry_coord$COUNTRY_NAME))

shrimp_cntry <- shrimp_space %>%
  mutate(COUNTRY_NAME = case_when(
    str_detect(COUNTRY_NAME, "Viet Nam") ~ "Vietnam",
    str_detect(COUNTRY_NAME, "Venezuela \\(Bolivarian Republic of\\)") ~ "Venezuela",
    str_detect(COUNTRY_NAME, "\\#N\\/A") ~ "Myanmar", # check original data, missing country info, cities Yangon and Rangoon are in Myanmar
    str_detect(COUNTRY_NAME, "Korea, Republic of") ~ "South Korea",
    str_detect(COUNTRY_NAME, "Taiwan, Province of China\\[a\\]") ~ "Taiwan",
    str_detect(COUNTRY_NAME, "Cote d'Ivoire") ~ "Ivory Coast",
    str_detect(COUNTRY_NAME, "Côte d'Ivoire") ~ "Ivory Coast",
    str_detect(COUNTRY_NAME, "Brunei Darussalam") ~ "Brunei",
    str_detect(COUNTRY_NAME, "UAE") ~ "United Arab Emirates",
    TRUE ~ COUNTRY_NAME
  ))

# should now be 0 differences, all match!
setdiff(unique(shrimp_cntry$COUNTRY_NAME), unique(cntry_coord$COUNTRY_NAME))



## Summarize: Count number of refusals per country per year
shrimp_summ <- shrimp_cntry %>%
  group_by(YEAR, COUNTRY_NAME) %>%
  tally() %>%
  ungroup() %>%
  rename(REFUSALS = n)

# check that summary went ok
# manually compare a few values with shrimp_cntry
DT::datatable(shrimp_summ)



## Plotting
# Add spatial data
global <- st_read("data/ref/countries.shp")
global_tidy <- global %>%
  select(COUNTRY_NAME = SOVEREIGNT)

# check country name matches
setdiff(shrimp_summ$COUNTRY_NAME, global_tidy$COUNTRY_NAME)

# FIXXXXXXXXXXX missing aruba, singapore, hong kong shapefiles
shrimp_refuse_map <- global_tidy %>%
  left_join(shrimp_summ, by="COUNTRY_NAME") %>%
  filter(!is.na(YEAR)) %>%  # FIXXXX
  mutate(YEAR = as.integer(YEAR)) %>% 
  mutate(Units = "Refusals")




# ## SHRIMP IMPORT REFUSAL CHARGES MAP MINI PIE CHART ##
# ## Tidy: Take a subset of data and fix date column
# shrimp_tidy <- fda %>%
#   select(REFUSAL_DATE, COUNTRY_NAME, starts_with("REFUSAL_CHARGES"))
# 
# # fix date column to a format R can understand
# shrimp_tidy$REFUSAL_DATE <- as.Date(shrimp_tidy$REFUSAL_DATE, "%Y-%m-%d")
# 
# # create a separate year column
# shrimp_imp <- shrimp_tidy %>%
#   mutate(YEAR = lubridate::year(REFUSAL_DATE)) %>%
#   select(YEAR, COUNTRY_NAME, starts_with("REFUSAL_CHARGES"))
# 
# # fix country name Cote d'Ivoire to Ivory Coast
# 
# shrimp_cntry <- shrimp_imp %>%
#   mutate(COUNTRY_NAME = case_when(
#     str_detect(COUNTRY_NAME, "Cote d'Ivoire") ~ "Ivory Coast",
#     str_detect(COUNTRY_NAME, "UAE") ~ "United Arab Emirates",
#     TRUE ~ COUNTRY_NAME
#   ))
# 
# 
# 
# ## Wrangle: Expand refusal charges column so that each row is an individual refusal reason
# shrimp_gather <- shrimp_cntry %>%
#   gather("DELETE", "REFUSAL_CHARGES", contains("REFUSAL_CHARGES")) %>%
#   select(-DELETE) %>%
#   filter(REFUSAL_CHARGES != "") # remove rows with no refusal charge value
# 
# 
# 
# ## Summarize: Count types of refusal charges per country and year
# # This format will work for pie graph
# shrimp_summ <- shrimp_gather %>%
#   mutate(REFUSAL_CHARGES = trimws(REFUSAL_CHARGES, which = "both")) %>% # fix leading white spaces, weird..
#   group_by(YEAR, COUNTRY_NAME, REFUSAL_CHARGES) %>%
#   tally() %>%
#   ungroup() %>%
#   group_by(YEAR, COUNTRY_NAME) %>%
#  # mutate(TOTAL = sum(n)) %>%  # repeats will be removed when spread
#   mutate(REFUSAL_CHARGES = str_replace(REFUSAL_CHARGES," ", "_")) %>%
#   mutate(REFUSAL_CHARGES = case_when(
#            str_detect(REFUSAL_CHARGES, "^YELLOW_#5$") ~ "YELLOW_5",
#            str_detect(REFUSAL_CHARGES, "^3LACKS_FIRM$") ~ "LACKS_FIRM3",
#            TRUE ~ REFUSAL_CHARGES)
#          ) %>%
#   spread(REFUSAL_CHARGES, n, fill = 0)
# 
# 
# 
# ## Plotting
# # Combine lat lon info with shrimp data
# cntry_coord <- read.csv("data/ref/country_lat_lon.csv", stringsAsFactors = FALSE)
# 
# shrimp_spatial <- shrimp_summ %>%
#   left_join(cntry_coord, by = "COUNTRY_NAME")
# 
# # Taking top refusals to make dataset easier to test
# shrimp_refuse <- shrimp_spatial %>%
#   select(YEAR, COUNTRY_NAME, LAT, LON, SALMONELLA, VETDRUGES, NITROFURAN, FILTHY) %>%
#   mutate(TOTAL = SALMONELLA + VETDRUGES + NITROFURAN + FILTHY)

