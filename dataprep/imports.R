##CALIFORNIA FISHERIES IMPORT DATA

## Data Source
# NOAA Fisheries Statistics - Cumulative Trade Data by U.S. Customs District
# Link: https://www.st.nmfs.noaa.gov/commercial-fisheries/foreign-trade/applications/trade-by-specific-us-customs-district
# Downloaded each year one at a time, make sure to select December for the 'Month' drop-down to get data from Jan-Dec
# Timeseries: 2014-2018
# Format: ASCII
# Downloaded: 10/30/2018


## Summary 
# Aggregate fisheries imports into California by value and visualize change over time. Summarize products with highest value.
# Check if USD needs to be corrected for inflation
library(validate)
library(tidyverse)
library(plotly)
library(viridis)


## Read in California Import Data from NOAA
data_years <- 2014:2017
data <- list()

for(i in data_years){ # i = 2014
  
  dat <- read.csv(sprintf("int/trade_%s.data_in", i), header = FALSE, skip = 1, sep = "|") %>% 
    mutate(V1 = i)
  # save each year's data into a list
  list_name <- as.character(i)
  data[[list_name]] <- dat
  
}


## Clean up data tables
# Need to hand select Edible products, change with original source online
# Column names should be: Year, Edible, Product Name, Country, Kilos, Dollars
colnames = c("Year", "Product", "Country", "Kilos", "Dollars")

tidy <- function(x) {
  ## clean up dataframe
  tmp <- x[!(names(x) %in% c("V4", "V5", "V8"))]
  tmp <- setNames(tmp, colnames)
}

tidy_data <- lapply(data, tidy)

# Combine (Note: for larger dataset, maybe we don't want to bind it into one)
all_data <- map_df(tidy_data, rbind)

summary(all_data)


## Summarize information
### Average Dollars/Kilos

dollas <- all_data %>% 
  group_by(Year, Product, Country) %>% 
  summarize(Dollars = sum(Dollars),
            Kilos = sum(Kilos)) %>% 
  mutate(AvgRate = Dollars/Kilos) %>% # per country avg
  ungroup() %>% 
  group_by(Year, Product) %>% # aggregate avg across countries
  mutate(TotalValue = sum(Dollars), 
         TotalKilos = sum(Kilos),
         AllAvgRate = mean(AvgRate, na.rm=TRUE)) %>% 
  ungroup()

# Plot timeseries of product values 
# Group by and aggregate mean value per category
plot_rate <- dollas %>% 
  select(Year, Product, AllAvgRate) %>%
  mutate(Category = case_when(
    str_detect(Product, "^ABALONE") ~ "Abalone",
    str_detect(Product, "^ANCHOVY") ~ "Anchovy",
    str_detect(Product, "^AQUATIC INVERTEBRATES") ~ "Aquatic Invertebrates",
    str_detect(Product, ".*MACKEREL.*") ~ "Mackerel",
    str_detect(Product, "^BONITO YELLOWTAIL") ~ "Bonito Yellowtail",
    str_detect(Product, "^CARP CATFISH EELS") ~ "Carp, Catfish, Eels, Misc",
    str_detect(Product, "^CATFISH") ~ "Catfish"
  )) %>% 
  distinct() %>% 
  na.omit() %>%  # remove species you haven't categorized yet 
  group_by(Year, Category) %>% 
  summarize(AvgRateCat = mean(AllAvgRate)) %>% # aggreg per category
  ungroup()

my_plot <- ggplot(plot_rate, aes(x=Year, y=AvgRateCat)) + 
  geom_line(aes(col=Category))

ggplotly(my_plot)


## Summarize information
### Total Value Imported!
plot_total <- dollas %>%
  select(Year, Product, TotalValue, TotalKilos) %>% 
  arrange(Year, desc(TotalValue)) %>% 
  distinct() %>% 
  #filter(grepl('Farmed', Product, ignore.case =TRUE))
  filter(Year == 2017) %>% 
  top_n(20, TotalValue)

### Set manual palette from viridis pkg
pal <- viridis(length(unique(plot_total$Product)))

my_plot <- ggplot(plot_total, aes(x=Year, y=TotalValue)) + 
  geom_line(aes(col=Product)) +
  scale_colour_manual(name = "Product", values = pal) +
  theme_minimal()
