##CALIFORNIA FISHERIES IMPORT DATA

## Data Source
# NOAA Fisheries Statistics
# Timeseries: 2014-2018
# Format: ASCII
# Downloaded: 10/30/2018


## Summary 
# Aggregate fisheries imports into California by value and visualize change over time. Summarize products with highest value.
# Check if USD needs to be corrected for inflation
library(validate)
library(tidyverse)


## Read in California Import Data from NOAA
data_years <- 2014:2018
data <- list()

for(i in data_years){
  
  dat <- read.csv(sprintf("int/trade_%s.results", i), header = FALSE, skip = 1, sep = "|")
  # save each year's data into a list
  list_name <- as.character(i)
  data[[list_name]] <- dat
  
}


## Clean up data tables
# Column names should be: Year, Edible, Product Name, Country, Kilos, Dollars
colnames = c("Year", "Edible", "Product", "Country", "Kilos", "Dollars")

tidy <- function(x) {
  ## clean up dataframe
  tmp <- x[!(names(x) %in% c("V1", "V8"))]
  tmp <- setNames(tmp, colnames)
  
  tmp <- tmp %>% 
    filter(Edible == "E") %>% 
    select(-Edible)
}

tidy_data <- lapply(data, tidy)

## Combine (Note: for larger dataset, maybe we don't want to bind it into one)
all_data <- map_df(tidy_data, rbind)

summary(all_data)
