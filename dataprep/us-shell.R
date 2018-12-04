## US Mollusk Production
# Data Source
# USDA Quick Stats Census

# Source: https://quickstats.nass.usda.gov/
# Downloaded: Dec. 3, 2018
# Timeseries: 2013
# Format: CSV
# Metadata: https://quickstats.nass.usda.gov/src/glossary.pdf
# Notes: Queried for Census, Aquaculture, Mollusk, Sales (clicking the Get Data button should extract all data items, all years, and both state and national data. Data tables include sales (in $, head, and lb) and no. of operations per state. I don't believe inflation is accounted for. 


## Setup
library(tidyverse)
library(USAboundaries)
library(validate)
library(devtools)

# raw data file directory
rawdata <- "data/raw/USDA_Quickstats"
intdata <- "data/int"


# ## Import Data
# # 1998, 2005, and 2013 Census Data for Molusks
# data <- read.csv(file.path(rawdata, "mollusk_sales.csv"), stringsAsFactors = FALSE)
# 
# 
# 
# ## Wrangle: Total
# # Tidy and reorganize
# 
# 
# # remove columns that only contain NA values
# data <- data[ ,colSums(!is.na(data)) > 0]
# 
# # remove unnecessary columns, modify category names/value
# molprod <- data %>%
# select(-Program, -Period, -Geo.Level, -watershed_code, -Domain.Category) %>%
# rename(State_Code = State.ANSI) %>%
# mutate(State_Code = ifelse(is.na(State_Code), 0, State_Code)) %>%
# mutate(State = ifelse(State == "US TOTAL", "US", State))
# 
# DT::datatable(molprod)
# 
# 
# 
# ## Select Totals
# # Summary
# # 1. There are two categories in `Domain`: TOTAL and SALES. Select TOTAL. SALES category is a smaller subset of TOTAL (ironically) and only provides aggregated value for the US.
# # 2. Split `Data.Item` column into `Product` and `Unit`. Tidy strings.
# # 3. Split `Product` into species and product type.
# # 4. Separate WHOLESALE types
# # 5. Fix species names
# 
# # Definitions
# 
# #* In the `Data.Item` column, `Sales` is defined as sales in US dollars.
# #* Operations: Depending upon the data series, may refer to farms, ranches, growers, or producers (original USDA metadata).
# 
# 
# ### Step 1-2
# #*Select TOTALS and Split `Data.Item` into `Product` and `Unit`*
# 
# 
# # split Data.Item into Product and Unit
# molunit <- molprod %>%
# filter(Domain == "TOTAL") %>%
# select(-Domain) %>%
# separate(Data.Item, c("Product", "Unit"), " - ") %>%
# mutate(Product = str_replace(Product, "MOLLUSKS, ", "")) %>%
# mutate(Unit = case_when(
# str_detect(Unit, "OPERATIONS WITH SALES$") ~ "OPERATIONS",
# str_detect(Unit, "SALES, MEASURED IN \\$$") ~ "DOLLARS",
# str_detect(Unit, "SALES, MEASURED IN \\$ \\/ OPERATION$") ~ "DOLLARS_PER_OPERATION",
# str_detect(Unit, "SALES, MEASURED IN EGGS$") ~ "EGGS",
# str_detect(Unit, "SALES, MEASURED IN HEAD$") ~ "HEAD",
# str_detect(Unit, "SALES, MEASURED IN LB$") ~ "LB",
# str_detect(Unit, "SALES, MEASURED IN HEAD \\/ LB$") ~ "HEAD_PER_LB",
# str_detect(Unit, "SALES, MEASURED IN PCT BT SIZE GROUP") ~ "PCT BT SIZE GROUP",
# str_detect(Unit, "SALES, MEASURED IN PCT BY OUTLET") ~ "PCT BY OUTLET"
# ))
# 
# # Save unique category of values (e.g. dollars, head, lb)
# data_cat <- unique(molunit$Unit)
# 
# DT::datatable(molunit)
# 
# 
# 
# ### Step 3
# #*Split `Product` into species and product type*
# 
# #Not all will split perfectly, will need to fix a few things.
# 
# #REGEX `,\\s*(?=[^,]+$)` Explained: look for a comma (`,`) that is followed by zero or more (`*`) white space (`\\s`), which is immediately followed by one or more non-comma values (`?=[^,]+`) at the end of the string (`$`). See (Regex cheatsheet)[https://www.rexegg.com/regex-quickstart.html].
# 
# 
# ## first split: separate by last comma
# firstsplit <-  molunit %>%
# separate(Product, c("Species", "Product_Type"), ",\\s*(?=[^,]+$)", fill="right")
# 
# 
# ### Step 4
# 
# # Second split: remove wholesale types & retail from Species column
# # Wholesale Product Types
# # Check values (e.g. EXPORTS) in column Product_Type that are associated with WHOLESALE in Species and create new wholesale category column. For these, assign a Species value of NA and Product_Type as WHOLESALE.
# 
# 
# whole <- firstsplit %>% filter(Species == "WHOLESALE")
# wholesale_types <- str_c(unique(whole$Product_Type), collapse="|")
# 
# secsplit <- firstsplit %>%
#   mutate(Wholesale_Type = ifelse(str_detect(Product_Type, wholesale_types), Product_Type, NA)) %>%
#   mutate(Product_Type = ifelse(Species == "WHOLESALE" | Species == "RETAIL", Species, Product_Type)) %>%
#   mutate(Species = ifelse(Species == "WHOLESALE" | Species == "RETAIL", NA, Species)) # remove wholesale/retail from Species
# 
# 
# ### Step 5
# 
# # Correct Species names w/o Product Type
# 
# # The only values in `Product_Type` should be:
# # * LARVAE & SEED
# # * FOODSIZE
# # * BROODSTOCK
# # * WHOLESALE
# # * RETAIL
# 
# # check which ones are not product types (e.g. species names)
# unique(secsplit$Product_Type)
# 
# # First rearrange Species column separated by commas, placing second part before the first (except for those with parentheses, just turn them into generic taxa: "CLAMS, (EXCL HARD & MANILA)" = "CLAMS").
# #Second, move parts of species names (e.g. `MANILA`, `PACIFIC`) in the `Product_Type` column back into `Species`.
# 
# # REGEX `'(.*)\\,\\s+(\\w+)','\\2 \\1'` explained: Substitute any strings in `Species` that have a comma separating two word phrases and place the second phrase in front of the first.
# 
# 
# secsplit$Species <- sub('(.*)\\,\\s+(\\w+)','\\2 \\1', secsplit$Species)
# secsplit$Species <- sub(',.*$', '', secsplit$Species) # remove taxa with ", (EXCL...)"
# 
# # check names, should be 12 types incl NA
# unique(secsplit$Species)
# 
# # find parts of species names that got placed in product type - do "(EXCL GRASS)" separately
# unique(secsplit$Product_Type)
# sp_names <- str_c(c("GEODUCK", "HARD", "MANILA", "EASTERN", "PACIFIC"), collapse="|")
# # names to remove
# rm_names <- str_c(c("(EXCL GEODUCK & HARD & MANILA)", "(EXCL EASTERN & PACIFIC)", "(EXCL HARD & MANILA)"), collapse="|")
# 
# # Replace any NAs with "NONE" to prevent it from being removed in filters later
# sp_fix <- secsplit %>%
# mutate(
#   Product_Type = ifelse(is.na(Product_Type), "NONE", Product_Type),
#   Species = ifelse(str_detect(Product_Type, sp_names),
#                    paste(Product_Type, Species, sep=" "), Species),
#   Species = ifelse(str_detect(Product_Type, "(EXCL GEODUCK & HARD & MANILA)"), "NONE", Species), # remove parentheses contents
#   Species = ifelse(str_detect(Product_Type, rm_names), "NONE", Species),
#   Species = ifelse(is.na(Species), "NONE", Species)
#   )
# 
# # remove species names from Product_Type
# sp_remove <- str_c(c(sp_names, rm_names), collapse="|")
# 
# totalmol <- sp_fix %>%
# mutate(Product_Type = ifelse(str_detect(Product_Type, sp_remove), "NONE", Product_Type))
# 
# # Check
# unique(totalmol$Product_Type) # should have 7 values incl NONE
# unique(totalmol$Species) # should have 12 values incl NONE
# 
# 
# 
# # Checkpoint
# 
# # Check whether there are repeated values (lb per head is just lb divided by head, or if each row is just reported in different units.
# 
# 
# 
# test <- totalmol %>%
# filter(Unit %in% c("HEAD","LB","HEAD_PER_LB")) %>%
# select(-Wholesale_Type, -State_Code, -Commodity)
# 
# test$Value = as.factor(test$Value)
# 
# test2 <- test %>%
# mutate(Value = str_replace_all(Value, ",", "")) %>%
# spread(Unit, Value) %>%
# mutate(HEAD = as.numeric(HEAD), # convert from character to numeric
# LB = as.numeric(LB),
# HEAD_PER_LB = as.numeric(HEAD_PER_LB),
# testval = HEAD/LB) # check testval against HEAD_PER_LB
# 
# # use validate to do a second check - should be no fails
# k = validate::check_that(test2, round(HEAD/LB,0) == HEAD_PER_LB)
# summary(k)
# 
# DT::datatable(test2)
# 
# 
# 
# # Filter: 2013 Raw Data
# 
# # Within totals, just select raw,  not calculated, data. Select for most recent year (2013).
# #
# # Remove wholesale and retail information - the units for this is PCT BY OUTLET.
# #
# # Average 2013 sales in dollars per operation in the US is 434,613 USD. in 2005 it was 207,330 USD and in 1998 it was 166,594 USD.
# 
# 
# 
# dolperop <- totalmol %>%
# filter(Unit == "DOLLARS_PER_OPERATION") %>%
# select(Year, State, Species, Unit, Value) %>%
# mutate(Value = as.numeric(str_replace_all(Value, ",", "")))
# 
# write.csv(dolperop, file.path(intdata, "mollusk_totals/US_sales_per_operation.csv"))
# 
# # Filter removes NA
# rawmoll <- totalmol %>%
# filter(Product_Type != "WHOLESALE" & Product_Type != "RETAIL") %>%
# filter(Unit %in% c("OPERATIONS", "HEAD", "LB", "DOLLARS")) %>%
# filter(State != "US") %>%
# select(-Wholesale_Type, -State_Code) %>%
# filter(Year == 2013) %>%
# mutate(Value = ifelse(str_detect(Value, "\\(.*\\)"), NA, Value),
#        Value = as.numeric(str_replace_all(Value, ",", "")))
# 
# write.csv(rawmoll, file.path(intdata, "mollusk_totals/US_sales_2013.csv"), row.names = F)
# 
# 
# # Count number of NAs per data type
# # Lots of NAs for Sales measured in dollars.
# 
# 
# NA_count <- rawmoll %>%
#   group_by(Unit) %>%
#   summarise(num_NA = sum(is.na(Value)),
#             pct_NA = round(sum(is.na(Value))/length(Value),2)) %>%
#   ungroup()
# 
# write.csv(NA_count, file.path(intdata, "mollusk_totals/US_sales_NA_2013.csv"))
# 
# 
# 
# # Gapfill
# 
# # Yipes.. lots of gapfilling using linear regression.. lots of missing data!! Improve gapfill method later. Investigate linear regression and imputation.
# 
# # * For states with at least the mean number of non-missing values, use state-unit average
# # * For states with all missing values, use the regional-unit average.
# # * For remaining missing values, use unit average
# 
# 
# 
# # Combine State Region Information from R `datasets` database
# state_df <- cbind(state.name, as.character(state.region)) %>%
#   as.data.frame() %>%
#   rename(State = state.name, Region = V2) %>%
#   mutate(State = toupper(State))
# 
# write.csv(state_df, file.path(intdata, "state_region.csv"))
# 
# moll_rgns <- rawmoll %>%
#   left_join(state_df, by = "State")
# 
# 
# # Add gapfill info based on number of non-missing values
# # Gapfill column: 1 means gapfilled, 0 means not gapfilled
# moll_gf <- moll_rgns %>%
# group_by(State, Unit) %>%
# mutate(NAs = sum(is.na(Value)),
# nonNAs = sum(!is.na(Value))) %>%
# ungroup() %>%
# mutate(Gapfill = ifelse(is.na(Value), 1, 0),
# GF_Method = ifelse(Gapfill == 1 & nonNAs >= 6, "State Average", NA),
# GF_Method = ifelse(Gapfill == 1 & nonNAs < 6, "Region Average", GF_Method))
# 
# moll_gf_final <- moll_gf %>%
# group_by(State, Unit) %>%
# mutate(State_Avg = mean(Value, na.rm=TRUE)) %>%
# ungroup() %>%
# mutate(Value = ifelse(is.na(Value) & GF_Method == "State Average", State_Avg, Value)) %>%
# group_by(Region, Unit) %>%
# mutate(Region_Avg = mean(Value, na.rm=TRUE)) %>%
# ungroup() %>%
# mutate(Value = ifelse(is.na(Value) & GF_Method == "Region Average", Region_Avg, Value)) %>%
# group_by(Unit) %>%
# mutate(Unit_Avg = mean(Value, na.rm=TRUE)) %>%
# ungroup() %>%
# mutate(Value = ifelse(is.na(Value), Unit_Avg, Value))
# 
# write.csv(moll_gf_final, file.path(intdata, "mollusk_totals/US_sales_gapfill.csv"), row.names=FALSE)
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
# 
# 
# # Total Sales in 2013 per State
# 
# 
# moll_sales <- moll_gf_final %>%
# select(Year, State, Species, Product_Type, Unit, Value) %>%
# group_by(State, Unit) %>%
# summarise(Total = sum(Value)) %>%
# ungroup()
# 
# # create columns needed for mapping in map module
# moll_us_map <- moll_sales %>%
#   rename(state = State,
#          map_data = Total,
#          type = Unit) %>%
#   mutate(units = case_when(
#     str_detect(type, "DOLLARS") ~ "USD",
#     str_detect(type,"OPERATIONS") ~ "operations",
#     TRUE ~ type
#   )) %>%
#   mutate(taxon = "Mollusk")
# 
# write.csv(moll_us_map, file.path(intdata, "mollusk_us_map.csv"), row.names = FALSE)



## FOR WRANGLING SHELLFISH PRODUCTION STATS
## which species has the largest $ share
stats <- read.csv(file.path(intdata, "mollusk_totals/US_sales_2013.csv"), stringsAsFactors = FALSE)
stats_sp <- stats %>%
  group_by(Species) %>%
  summarise(Species_Value = sum(Value, na.rm=T)) %>%
  ungroup() %>%
  arrange(desc(Species_Value)) %>%
  mutate(Total_Sales = sum(Species_Value, na.rm=T),
         Pct_Sales = round(100*(Species_Value/Total_Sales),2))

# which state has the largest $ share
stats_state <- stats %>%
  group_by(State) %>%
  summarise(State_Value = sum(Value, na.rm=T)) %>%
  ungroup() %>%
  arrange(desc(State_Value)) %>%
  mutate(Total_Sales = sum(State_Value, na.rm=T),
         Pct_Sales = round(100*(State_Value/Total_Sales),2))

# which state has the most $/operation
US_sales_gapfill <- read_csv("data/int/mollusk_totals/US_sales_gapfill.csv")
op <- US_sales_gapfill %>%
  select(Year, State, Species, Product_Type, Unit, Value) %>%
  filter(Unit == "OPERATIONS") %>%
  group_by(State) %>%
  summarise(Total_Val = sum(Value, na.rm=T)) %>%
  ungroup() %>%
  arrange(desc(Total_Val)) %>%
  mutate(US_Total_Val = sum(Total_Val, na.rm=T),
         Pct_Total = round(100*(Total_Val/US_Total_Val),2))

# Sales per operation
stats_state[stats_state$State == "WASHINGTON",][["State_Value"]]/op[op$State == "WASHINGTON",][["Total_Val"]]
stats_state[stats_state$State == "MASSACHUSETTS",][["State_Value"]]/op[op$State == "MASSACHUSETTS",][["Total_Val"]]

sales_per_op <- stats_state %>% 
  full_join(op, by = "State") %>% 
  rename(No_Operations = Total_Val,
         Sales = State_Value) %>% 
  mutate(sales_pr_op = Sales/No_Operations) %>% 
  arrange(desc(sales_pr_op))


## FOR PLOTTING MOLLUSK PRODUCTION MAP
data_for_map <- read.csv(file.path(intdata, "mollusk_us_map.csv"))

# just state and lat/lon
state_tidy <- us_states(resolution = "low") %>%
  select(state_name, geometry) %>%
  rename(state = state_name) %>%
  mutate(state = toupper(state))

## add in all states so states with no data will show up gray
moll_us <- state_tidy %>%
  full_join(data_for_map, by = "state") %>%
  filter(!state %in% c("PUERTO RICO", "DISTRICT OF COLUMBIA")) %>%
  complete(state, type) %>%  # fill in categories where there is no data
  filter(!is.na(type)) %>% # remove extra NA rows created
  select(-geometry) %>%  # temporarily remove geometry 
  mutate(units = case_when( # add back in where there are NAs..
    str_detect(type, "DOLLARS") ~ "USD",
    str_detect(type, "OPERATIONS") ~ "operations"
  )) %>% 
  mutate(taxon = "Mollusk") # add back in where there are NAs..

shell_us_map <- state_tidy %>% 
  left_join(moll_us, by = "state") # add lat/lon back in

