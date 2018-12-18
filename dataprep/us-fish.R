## US Food Fish Production ##

## Data Source
# USDA Quick Stats Census

# Source: https://quickstats.nass.usda.gov/
# Downloaded: Nov. 15, 2018
# Timeseries: 2013
# Format: CSV
# Metadata: https://quickstats.nass.usda.gov/src/glossary.pdf
# Notes: Queried for Census, Aquaculture, Mollusk, Sales (clicking the Get Data button should extract all data items, all years, and both state and national data. Data tables include sales (in $, head, and lb) and no. of operations per state. I don't believe inflation is accounted for. 

# The life cycle of fish products goes from EGGS to FINGERLINGS & FRY to STOCKERS to FOODSIZE or BROODSTOCK. STOCKERS are young fish kept until mature or food size. BROODSTOCK are mature fish that are used in aquaculture for breeding purposes. 

# Outputs:
# data/int/usda_fish/data_NA_count.csv
# data/int/usda_fish/US_sales_2013.csv
# data/int/usda_fish/US_sales_all_tidy.csv
# data/int/usda_fish/US_sales_gapfill_2013.csv
# # data/int/usda_fish/US_sales_per_operation
# data/output/fish_us_map.csv


## Setup
library(tidyverse)
library(USAboundaries)
library(validate)
library(devtools)
library(Hmisc)

# raw data file directory
rawdata <- "data/raw/USDA_Quickstats"
intdata <- "data/int"


## Import Data
# 1998, 2005, and 2013 Census Data for Fish Food
data <- read.csv(file.path(rawdata, "food_fish_sales.csv"), stringsAsFactors = FALSE)


## Wrangle: Total
# Tidy and reorganize categories of fish sales. Set US TOTAL category to have code of 0.

# remove columns that only contain NA values
data <- data[ ,colSums(!is.na(data)) > 0]

# remove unnecessary columns
fishprod <- data %>%
  select(-Program, -Period, -Geo.Level, -watershed_code, -Domain.Category) %>%
  rename(State_Code = State.ANSI) %>%
  mutate(State_Code = ifelse(is.na(State_Code), 0, State_Code)) %>%
  mutate(State = ifelse(State == "US TOTAL", "US", State))

DT::datatable(fishprod)


## Select Totals
# Summary
# 1. There are two categories in `Domain`: TOTAL and SALES. Select TOTAL.
# 2. Split `Data.Item` column into `Product` and `Unit`. Tidy strings.
# 3. Split `Product` into species and product type.
# 4. Separate WHOLESALE types
# 5. Fix species names

# Definitions
# In the `Data.Item` column, `Sales` is defined as sales in US dollars.
# Operations: Depending upon the data series, may refer to farms, ranches, growers, or producers (original USDA metadata).

### Step 1-2
# Select TOTALS and Split `Data.Item` into `Product` and `Unit`

# split Data.Item into Product and Unit
fishunit <- fishprod %>%
  filter(Domain == "TOTAL") %>%
  select(-Domain) %>%
  separate(Data.Item, c("Product", "Unit"), " - ") %>%
  mutate(Product = str_replace(Product, "FOOD FISH, ", "")) %>%
  mutate(Unit = case_when(
    str_detect(Unit, "OPERATIONS WITH SALES$") ~ "OPERATIONS",
    str_detect(Unit, "SALES, MEASURED IN \\$$") ~ "DOLLARS",
    str_detect(Unit, "SALES, MEASURED IN \\$ \\/ OPERATION$") ~ "DOLLARS_PER_OPERATION",
    str_detect(Unit, "SALES, MEASURED IN EGGS$") ~ "EGGS",
    str_detect(Unit, "SALES, MEASURED IN HEAD$") ~ "HEAD",
    str_detect(Unit, "SALES, MEASURED IN LB$") ~ "LB",
    str_detect(Unit, "SALES, MEASURED IN LB \\/ HEAD$") ~ "LB_PER_HEAD",
    str_detect(Unit, "SALES, MEASURED IN PCT BT SIZE GROUP") ~ "PCT BT SIZE GROUP",
    str_detect(Unit, "SALES, MEASURED IN PCT BY OUTLET") ~ "PCT BY OUTLET"
  ))

# Save unique category of values (e.g. dollars, head, lb)
data_cat <- unique(fishunit$Unit)

DT::datatable(fishunit)

### Step 3
#*Split `Product` into species and product type*
#Not all will split perfectly, will need to fix a few things.
#REGEX `,\\s*(?=[^,]+$)` Explained: look for a comma (`,`) that is followed by zero or more (`*`) white space (`\\s`), which is immediately followed by one or more non-comma values (`?=[^,]+`) at the end of the string (`$`). See (Regex cheatsheet)[https://www.rexegg.com/regex-quickstart.html].

# first split: separate by last comma
firstsplit <- fishunit %>%
  separate(Product, c("Species", "Product_Type"), ",\\s*(?=[^,]+$)", fill="right")

### Step 4

# Second split: wholesale types & retail
# Wholesale Product Types
# Check values (e.g. EXPORTS) in column Product_Type that are associated with WHOLESALE in Species and create new wholesale category column. For these, assign a Species value of NA and Product_Type as WHOLESALE.
whole <- firstsplit %>% filter(Species == "WHOLESALE")
wholesale_types <- str_c(unique(whole$Product_Type), collapse="|")

secsplit <- firstsplit %>%
  mutate(Wholesale_Type = ifelse(str_detect(Product_Type, wholesale_types), Product_Type, NA),
         Product_Type = ifelse(Species == "WHOLESALE" | Species == "RETAIL", Species, Product_Type),
         Species = ifelse(Species == "WHOLESALE" | Species == "RETAIL", NA, Species))

### Step 5
# Correct Species names w/o Product Type
# The only values in `Product_Type` should be:
# * FINGERLINGS & FRY
# * FOODSIZE
# * STOCKERS
# * BROODSTOCK
# * EGGS
# * WHOLESALE
# * RETAIL

# First rearrange Species column separated by commas, placing second part before the first (except for "CARP, (EXCL GRASS)". Second, move parts of species names (e.g. `RED`, `ARCTIC`) in the `Product_Type` column back into `Species`.
# REGEX `'(.*)\\,\\s+(\\w+)','\\2 \\1'` explained: Substitute any strings in `Species` that have a comma separating two word phrases and place the second phrase in front of the first.

secsplit$Species <- sub('(.*)\\,\\s+(.*)','\\2 \\1', secsplit$Species)
secsplit$Species <- sub('\\(.*\\)', 'OTHER', secsplit$Species)
#secsplit$Species <- sub(', ', ' ', secsplit$Species) # remove comma from "CARP, (EXCL GRASS)"

# check names, should be 24 types incl NA
unique(secsplit$Species)

# find parts of species names that got placed in product type - do "(EXCL GRASS" separately
unique(secsplit$Product_Type)
secsplit$Product_Type <- sub('\\(.*\\)', 'OTHER', secsplit$Product_Type)
sp_names <- str_c(c("HYBRID STRIPED", "^GRASS$", "RED", "YELLOW", "ATLANTIC", "PACIFIC", "ARCTIC", "^OTHER$"), collapse="|")

# Replace any NAs with "NONE" to prevent it from being removed in filters later
sp_fix <- secsplit %>%
  mutate(
    Product_Type = ifelse(is.na(Product_Type), "ALL PRODUCTS", Product_Type),
    Species = ifelse(str_detect(Product_Type, sp_names),
                     paste(Product_Type, Species, sep=" "), Species)
    #Species = ifelse(str_detect(Product_Type, "(EXCL GRASS)"),
     #                paste(Species, Product_Type, sep=" "), Species),
    #Species = ifelse(is.na(Species), "NONE", Species)
    )

# remove species names from Product_Type
#sp_remove <- str_c(c(sp_names, "(EXCL GRASS)"), collapse="|")
totalfish <- sp_fix %>%
  mutate(Product_Type = ifelse(str_detect(Product_Type, sp_names), "ALL PRODUCTS", Product_Type))


## Check
unique(totalfish$Product_Type) # should have 9 values 
unique(totalfish$Species) # should have 27 values incl NA

# Check whether there are repeated values (lb per head is just lb divided by head, or if each row is just reported in different units.
# test <- totalfish %>%
#   filter(Unit %in% c("HEAD","LB","LB_PER_HEAD")) %>%
#   select(-Wholesale_Type, -State_Code, -Commodity)
# 
# test$Value = as.factor(test$Value)
# 
# test2 <- test %>%
#   mutate(Value = str_replace_all(Value, ",", "")) %>%
#   spread(Unit, Value) %>%
#   mutate(HEAD = as.numeric(HEAD), # convert from character to numeric
#          LB = as.numeric(LB),
#          LB_PER_HEAD = as.numeric(LB_PER_HEAD),
#          testval = LB/HEAD) # check testval against LB_PER_HEAD
# 
# # use validate to do a second check - should be no fails
# k = validate::check_that(test2, round(LB/HEAD,1) == LB_PER_HEAD)
# summary(k)
# 
# DT::datatable(test2)


## Save Tidied TOTAL Finfish Data
# check with USDA 2013 Census Report, pg 10 (http://www.aquafeed.com/documents/1412204142_1.pdf)
tidy_fish <- totalfish %>% 
  mutate(Value = as.numeric(str_replace_all(Value, ",", "")))
write.csv(tidy_fish, "data/int/usda_fish/US_sales_all_tidy.csv", row.names = FALSE)


## Filter: 2013 Raw Data
# Within totals, just select raw,  not calculated, data. Select for most recent year (2013).
# Remove wholesale and retail information - the units for this is PCT BY OUTLET.

# Filter removes NA
rawfish <- tidy_fish %>%
  filter(Product_Type != "WHOLESALE" & Product_Type != "RETAIL") %>%
  filter(Unit %in% c("OPERATIONS", "HEAD", "LB", "DOLLARS", "EGGS")) %>%
  filter(State != "US") %>%
  select(-Wholesale_Type, -State_Code) %>%
  filter(Year == 2013) %>%
  filter(Species == "FOOD FISH", Product_Type == "ALL PRODUCTS") # get totals for food fish
  #mutate(Value = ifelse(str_detect(Value, "\\(.*\\)"), NA, Value),
  #       Value = as.numeric(str_replace_all(Value, ",", "")))




## Gapfill
# Use average sales in dollars per operation in 2013 to estimate missing state values
# Average 2013 sales in dollars per operation in the US is 564,928 USD. in 2005 it was 364,038 USD and in 1998 it was 319,056 USD.
dolperop <- tidy_fish %>%
  filter(Unit == "DOLLARS_PER_OPERATION") %>%
  select(Year, State, Species, Unit, Value) #%>%
#mutate(Value = as.numeric(str_replace_all(Value, ",", "")))
dolperop2013 <- dolperop[1,5]
write.csv(dolperop, file.path(intdata, "usda_fish/US_sales_per_operation.csv"))

# Check: 
# should only be two entries per state, one for OPERATIONS, one for DOLLARS
table(rawfish$State)
# Only NAs should be DOLLAR value
sum(is.na(rawfish$Value))
er <- rawfish %>% filter(Unit == "DOLLARS")
sum(is.na(er$Value))

# fill in estimated values and gapfill method
gf_fish <- rawfish %>%
  mutate(gf_method = ifelse(is.na(Value), "AVG USD PER OP", "NONE")) %>% 
  group_by(State) %>% 
  mutate(Value = ifelse(is.na(Value),
                        prod(Value, na.rm=TRUE)*dolperop2013,
                        Value))


## NA Count 
# per data type
# Lots of NAs for Sales measured in dollars.
NA_count <- rawfish %>%
  group_by(Unit) %>%
  summarise(num_NA = sum(is.na(Value)),
            pct_NA = round(sum(is.na(Value))/length(Value),2)) %>%
  ungroup()

write.csv(NA_count, file.path(intdata, "usda_fish/data_NA_count.csv"))


## Gapfill
# Yipes.. lots of gapfilling using linear regression.. lots of missing data!! Improve gapfill method later. Investigate linear regression and imputation.
#
# * For states with at least the mean number of non-missing values, use state-unit average
# * For states with all missing values, use the regional-unit average.
# * For remaining missing values, use unit average

# Combine State Region Information from R `datasets` database
# state_df <- cbind(state.name, as.character(state.region)) %>%
#   as.data.frame() %>%
#   rename(State = state.name, Region = V2) %>%
#   mutate(State = toupper(State))
#
# fish_rgns <- rawfish %>%
#   left_join(state_df, by = "State")
#
#
# # Add gapfill info based on number of non-missing values
# # Gapfill column: 1 means gapfilled, 0 means not gapfilled
# fish_gf <- fish_rgns %>%
#   group_by(State, Unit) %>%
#   mutate(NAs = sum(is.na(Value)),
#          nonNAs = sum(!is.na(Value))) %>%
#   ungroup() %>%
#   mutate(Gapfill = ifelse(is.na(Value), 1, 0),
#          GF_Method = ifelse(Gapfill == 1 & nonNAs >= 6, "State Average", NA),
#          GF_Method = ifelse(Gapfill == 1 & nonNAs < 6, "Region Average", GF_Method))
# 
# fish_gf_final <- fish_gf %>%
#   group_by(State, Unit) %>%
#   mutate(State_Avg = mean(Value, na.rm=TRUE)) %>%
#   ungroup() %>%
#   mutate(Value = ifelse(is.na(Value) & GF_Method == "State Average", State_Avg, Value)) %>%
#   group_by(Region, Unit) %>%
#   mutate(Region_Avg = mean(Value, na.rm=TRUE)) %>%
#   ungroup() %>%
#   mutate(Value = ifelse(is.na(Value) & GF_Method == "Region Average", Region_Avg, Value)) %>%
#   group_by(Unit) %>%
#   mutate(Unit_Avg = mean(Value, na.rm=TRUE)) %>%
#   ungroup() %>%
#   mutate(Value = ifelse(is.na(Value), Unit_Avg, Value))
# 
# write.csv(fish_gf_final, file.path(intdata, "usda_fish/US_sales_gapfill.csv"), row.names=FALSE)
# 
# ## Predict values with linear model- try this later
# # Compare models to select a gapfilling method
# # mod1 <- lm(Value ~ State + Species + Product_Type, data = fish_gf, na.action="na.exclude")
# # mod2 <- lm(Value ~ Species + Product_Type, data = fish_gf, na.action="na.exclude")
# # mod3 <- lm(Value ~ State + Product_Type, data = fish_gf, na.action="na.exclude")
# #
# # summary(mod1)
# # summary(mod2)
# # summary(mod3)
# #
# # AIC(mod1) # best model
# # AIC(mod2)
# # AIC(mod3)


# Total Sales in 2013 per State
fish_sales <- gf_fish %>%
  select(Year, State, Unit, Value) 

# create columns needed for mapping in map module
data_for_map <- fish_sales %>%
  rename(state = State,
         map_data = Value,
         type = Unit) %>%
  mutate(units = case_when(
    str_detect(type, "DOLLARS") ~ "USD",
    # str_detect(type, "HEAD") ~ "fish",
    # str_detect(type, "LB") ~ "lbs",
    str_detect(type,"OPERATIONS") ~ "operations",
    #str_detect(type, "EGGS") ~ "eggs",
    TRUE ~ type
  )) %>%
  mutate(taxon = "Fish")


## TIDY FOR PLOTTING MAP
# just state and lat/lon
state_tidy <- us_states(resolution = "low") %>%
  select(state_name) %>%
  rename(state = state_name) %>%
  mutate(state = toupper(state))

# maybe there's a more efficient way to add values back into the states with missing values.. but for now this is fine..
fish_us <- state_tidy %>%
  full_join(data_for_map, by = "state") %>%
  filter(!state %in% c("PUERTO RICO", "DISTRICT OF COLUMBIA")) %>%
  complete(state, type) %>%  # fill in categories where there is no data
  filter(!is.na(type)) %>% # remove extra NA rows created
  select(-geometry) %>%  # temporarily remove geometry 
  mutate(units = case_when( # add back in where there are NAs..
    str_detect(type, "EGGS") ~ "eggs",
    str_detect(type, "DOLLARS") ~ "USD",
    str_detect(type, "HEAD") ~ "fish",
    str_detect(type, "OPERATIONS") ~ "operations",
    str_detect(type, "LB") ~ "lbs"
  )) %>% 
  mutate(taxon = "Fish") # add back in where there are NAs..

fish_us_map <- state_tidy %>% 
  left_join(fish_us, by = "state") # add lat/lon back in


#st_write(fish_us_map, "data/output/fish_us_map.csv") # saves sf object as data frame




## FOOD FISH PRODUCTION STATS
# Read in tidied US Food Fish data
stats <- read.csv("data/int/usda_fish/US_sales_all_tidy.csv")

## which species has the largest $ share
sales <- stats %>%
  filter(Unit == "DOLLARS",
         Year == 2013,
         Product_Type == "ALL PRODUCTS", # select totals for all products
         State == "US") %>% 
  filter(!Species %in% c("GRASS CARP", "OTHER CARP")) %>%  # remove sub categories
  select(Species, Unit, Value) %>% 
  arrange(desc(Value)) %>% 
  mutate(Percent = Value/.[.$Species == "FOOD FISH",][["Value"]]) # divide by total value

# which state has the largest $ share and what was the sales
state <- stats %>%
  filter(Unit == "DOLLARS",
         Year == 2013,
         Species == "FOOD FISH",
         Product_Type == "ALL PRODUCTS") %>% 
  select(State, Unit, Value) %>% 
  arrange(desc(Value))

# where are most of the food fish operations?
op <- stats %>%
  filter(Unit == "OPERATIONS",
         Year == 2013,
         Species == "FOOD FISH",
         Product_Type == "ALL PRODUCTS") %>%
  select(State, Unit, Value) %>%  
  arrange(desc(Value)) %>% 
  mutate(Percent = Value/.[.$State == "US",][["Value"]]) # divide by US value
