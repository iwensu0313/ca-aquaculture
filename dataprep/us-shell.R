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




## Import Data
# 1998, 2005, and 2013 Census Data for Molusks
data <- read.csv(file.path(rawdata, "mollusk_sales.csv"), stringsAsFactors = FALSE)




## Wrangle: Total
# Tidy and reorganize

# remove columns that only contain NA values
data <- data[ ,colSums(!is.na(data)) > 0]

# remove unnecessary columns, modify category names/value
molprod <- data %>%
  select(-Program, -Period, -Geo.Level, -watershed_code, -Domain.Category) %>%
  rename(State_Code = State.ANSI) %>%
  mutate(State_Code = ifelse(is.na(State_Code), 0, State_Code)) %>%
  mutate(State = ifelse(State == "US TOTAL", "US", State))

DT::datatable(molprod)




## Select Totals
# Summary
# 1. Unsure what the two categories in `Domain` are: TOTAL and SALES. At times, SALES category seems to be a smaller subset of TOTAL (ironically) and only provides aggregated value for the US, but unclear..
# 2. Split `Data.Item` column into `Product` and `Unit`. Tidy strings.
# 3. Split `Product` into species and product type.
# 4. Separate WHOLESALE types
# 5. Fix species names

# Definitions
# In the `Data.Item` column, `Sales` is defined as sales in US dollars.
# Operations: Depending upon the data series, may refer to farms, ranches, growers, or producers (original USDA metadata).

### Step 1-2
#Split `Data.Item` into `Product` and `Unit`*

# split Data.Item into Product and Unit
# simplify Unit category names
molunit <- molprod %>%
  filter(Domain == "TOTAL") %>% 
  select(-Domain) %>% 
  separate(Data.Item, c("Product", "Unit"), " - ") %>%
  mutate(Product = str_replace(Product, "MOLLUSKS, ", "")) %>%
  mutate(Unit = case_when(
    str_detect(Unit, "OPERATIONS WITH SALES$") ~ "OPERATIONS",
    str_detect(Unit, "SALES, MEASURED IN \\$$") ~ "DOLLARS",
    str_detect(Unit, "SALES, MEASURED IN \\$ \\/ OPERATION$") ~ "DOLLARS_PER_OPERATION",
    str_detect(Unit, "SALES, MEASURED IN EGGS$") ~ "EGGS",
    str_detect(Unit, "SALES, MEASURED IN HEAD$") ~ "HEAD",
    str_detect(Unit, "SALES, MEASURED IN LB$") ~ "LB",
    str_detect(Unit, "SALES, MEASURED IN HEAD \\/ LB$") ~ "HEAD_PER_LB",
    str_detect(Unit, "SALES, MEASURED IN PCT BT SIZE GROUP") ~ "PCT BT SIZE GROUP",
    str_detect(Unit, "SALES, MEASURED IN PCT BY OUTLET") ~ "PCT BY OUTLET"
  ))

# See unique category of values (e.g. dollars, head, lb)
unique(molunit$Unit)

DT::datatable(molunit)

### Step 3
#*Split `Product` into species and product type*
#Not all will split perfectly, will need to fix a few things.
#REGEX `,\\s*(?=[^,]+$)` Explained: look for a comma (`,`) that is followed by zero or more (`*`) white space (`\\s`), which is immediately followed by one or more non-comma values (`?=[^,]+`) at the end of the string (`$`). See (Regex cheatsheet)[https://www.rexegg.com/regex-quickstart.html].

# first split: separate by last comma
firstsplit <- molunit %>%
  separate(Product, c("Species", "Product_Type"), ",\\s*(?=[^,]+$)", fill="right")

### Step 4
# Second split: remove wholesale types & retail from Species column
# Check values (e.g. EXPORTS) in column Product_Type that are associated with WHOLESALE (in col Species) and create new wholesale category column. For these, assign a Species value of NA and Product_Type as WHOLESALE.
whole <- firstsplit %>% filter(Species == "WHOLESALE")
wholesale_types <- str_c(unique(whole$Product_Type), collapse="|")

secsplit <- firstsplit %>%
  mutate(Wholesale_Type = ifelse(str_detect(Product_Type, wholesale_types), Product_Type, NA)) %>%
  mutate(Product_Type = ifelse(Species == "WHOLESALE" | Species == "RETAIL", Species, Product_Type)) %>%
  mutate(Species = ifelse(Species == "WHOLESALE" | Species == "RETAIL", NA, Species)) # remove wholesale/retail from Species

### Step 5
# Correct Species names w/o Product Type
# The only values in `Product_Type` should be:
# * LARVAE & SEED
# * FOODSIZE
# * BROODSTOCK
# * WHOLESALE
# * RETAIL

# check which ones are not product types (e.g. species names)
unique(secsplit$Product_Type)

# First rearrange Species column separated by commas, placing second part before the first and convert all Species with a specified exclusion into "OTHER". Ex: "CLAMS, (EXCL HARD & MANILA)" = "OTHER CLAMS".
#Second, move parts of species names (e.g. `MANILA`, `PACIFIC`) in the `Product_Type` column back into `Species`.
# REGEX `'(.*)\\,\\s+(\\w+)','\\2 \\1'` explained: Substitute any strings in `Species` that have a comma separating two word phrases and place the second phrase in front of the first.
secsplit$Species <- sub('(.*)\\,\\s+(.*)','\\2 \\1', secsplit$Species)
secsplit$Species <- sub('\\(.*\\)', 'OTHER', secsplit$Species)

# check names, should be 14 types incl NA
unique(secsplit$Species)
# Check that any NAs in Species is associated with WHOLESALE data
check <- secsplit %>% 
  mutate(check = ifelse(is.na(Species) | Product_Type == "WHOLESALE", 1,0))
table(check$check)[2] == sum(is.na(check$Species)) # should be TRUE

# find parts of species names that got placed in product type
# replace (EXCL) with "OTHER" and save species names
unique(secsplit$Product_Type)
secsplit$Product_Type <- sub('\\(.*\\)', 'OTHER', secsplit$Product_Type)
sp_names <- str_c(c("GEODUCK", "HARD", "MANILA", "EASTERN", "PACIFIC", "^OTHER$"), collapse="|")

# Replace missing product type with ALL PRODUCTS, fix species names in product type col
sp_fix <- secsplit %>%
  mutate(
    Product_Type = ifelse(is.na(Product_Type), "ALL PRODUCTS", Product_Type),
    Species = ifelse(str_detect(Product_Type, sp_names),
                     paste(Product_Type, Species, sep=" "), Species)#,
    #Species = ifelse(is.na(Species), "NONE", Species)
  )

# remove species names from Product_Type, replace with "ALL PRODUCTS"
totalmol <- sp_fix %>%
  mutate(Product_Type = ifelse(str_detect(Product_Type, sp_names), "ALL PRODUCTS", Product_Type))




## Check
unique(totalmol$Product_Type) # should have 7 values
unique(totalmol$Species) # should have 14 values incl NA
# make sure remaining NAs in Species column are all WHOLESALE or RETAIL data
# IN THE FUTURE ADD IN IF STATEMENT TO STOP IF FALSE
k <- totalmol %>% filter(is.na(Species))
unique(k$Product_Type)




## Save Tidied TOTAL Shellfish Data
# check with USDA 2013 Census Report, pg 10 (http://www.aquafeed.com/documents/1412204142_1.pdf)
tidy_mol <- totalmol %>% 
  mutate(Value = as.numeric(str_replace_all(Value, ",", "")))
write.csv(tidy_mol, "data/int/mollusk_totals/US_sales_all_tidy.csv")




## Filter: 2013 Raw Data
# Within totals, just select raw,  not calculated, data. Select for most recent year (2013). Replace (D) with NA.
# Remove wholesale and retail information - the units for this is PCT BY OUTLET.
rawmoll <- tidy_mol %>%
  filter(Product_Type != "WHOLESALE" & Product_Type != "RETAIL") %>%
  filter(Unit %in% c("OPERATIONS", "HEAD", "LB", "DOLLARS")) %>%
  filter(State != "US") %>%
  select(-Wholesale_Type, -State_Code) %>%
  filter(Year == 2013) %>%
  #mutate(Value = ifelse(str_detect(Value, "\\(.*\\)"), NA, Value)) %>% 
  filter(Species == "MOLLUSKS", Product_Type == "ALL PRODUCTS") # this is a temp solution for getting the total number of mollusk data per state... fix later

DT::datatable(rawmoll)




## Gapfill
# Use average sales in dollars per operation in 2013 to estimate missing state values
# Average 2013 sales in dollars per operation in the US is 434,613 USD. in 2005 it was 207,330 USD and in 1998 it was 166,594 USD.
dolperop <- tidy_mol %>%
  filter(Unit == "DOLLARS_PER_OPERATION") %>%
  select(Year, State, Species, Unit, Value)
dolperop2013 <- dolperop[1,5] # row one, col five
write.csv(dolperop, file.path(intdata, "mollusk_totals/US_sales_per_operation.csv"))

# Check: should only be two entries per state, one for OPERATIONS, one for DOLLARS
table(rawmoll$State)

# fill in estimated values and gapfill method
gf_moll <- rawmoll %>%
  mutate(gf_method = ifelse(is.na(Value), "AVG USD PER OP", "NONE")) %>% 
  group_by(State) %>% 
  mutate(Value = ifelse(is.na(Value),
                  prod(Value, na.rm=TRUE)*dolperop2013,
                  Value))




## Check 
# total sales after gapfilling, actual number is ~328,567,000
gf_moll %>% 
  filter(Species == "MOLLUSKS", Product_Type == "ALL PRODUCTS") %>% 
  group_by(Unit) %>% 
  summarise(tots = sum(Value, na.rm = TRUE))




## NA Tracking
# Count number of NAs per data type
# Lots of NAs for Sales measured in dollars.
NA_count <- rawmoll %>%
  group_by(Unit) %>%
  summarise(num_NA = sum(is.na(Value)),
            pct_NA = round(sum(is.na(Value))/length(Value),2)) %>%
  ungroup()

write.csv(NA_count, file.path(intdata, "mollusk_totals/US_sales_NA_2013.csv"))



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
#   group_by(State, Unit) %>%
#   mutate(NAs = sum(is.na(Value)),
#          nonNAs = sum(!is.na(Value))) %>%
#   ungroup() %>%
#   mutate(Gapfill = ifelse(is.na(Value), 1, 0),
#          GF_Method = ifelse(Gapfill == 1 & nonNAs >= 6, "State Average", NA),
#          GF_Method = ifelse(Gapfill == 1 & nonNAs < 6, "Region Average", GF_Method))
# 
# moll_gf_final <- moll_gf %>%
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
# write.csv(moll_gf_final, file.path(intdata, "mollusk_totals/US_sales_gapfill.csv"), row.names=FALSE)

## Predict values with linear model- try this later
# Compare models to select a gapfilling method
# mod1 <- lm(Value ~ State + Species + Product_Type, data = fish_gf, na.action="na.exclude")
# mod2 <- lm(Value ~ Species + Product_Type, data = fish_gf, na.action="na.exclude")
# mod3 <- lm(Value ~ State + Product_Type, data = fish_gf, na.action="na.exclude")
#
# summary(mod1)
# summary(mod2)
# summary(mod3)
#
# AIC(mod1) # best model
# AIC(mod2)
# AIC(mod3)




## Total Sales in 2013 per State
moll_sales <- gf_moll %>%
  select(Year, State, Unit, Value)

# create columns needed for mapping in map module
moll_us_map <- moll_sales %>%
  rename(state = State,
         map_data = Value,
         type = Unit) %>%
  mutate(units = case_when(
    str_detect(type, "DOLLARS") ~ "USD",
    str_detect(type,"OPERATIONS") ~ "operations",
    TRUE ~ type
  )) %>%
  mutate(taxon = "Mollusk")

write.csv(moll_us_map, file.path(intdata, "mollusk_us_map.csv"), row.names = FALSE)




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

# SHELL_US_MAP
shell_us_map <- state_tidy %>% 
  left_join(moll_us, by = "state") # add lat/lon back in




## FOR WRANGLING SHELLFISH PRODUCTION STATS
# which species has the largest $ share
180150/328567
123293/328567
12253/328567
# stats <- read.csv(file.path(intdata, "mollusk_totals/US_sales_2013.csv"), stringsAsFactors = FALSE)
# stats_sp <- stats %>%
#   group_by(Species) %>%
#   summarise(Species_Value = sum(Value, na.rm=T)) %>%
#   ungroup() %>%
#   arrange(desc(Species_Value)) %>%
#   mutate(Total_Sales = sum(Species_Value, na.rm=T),
#          Pct_Sales = round(100*(Species_Value/Total_Sales),2))

# which state has the largest $ share
k <- gf_moll %>% 
  filter(Unit == "DOLLARS") %>%
  arrange(desc(Value)) %>% 
  group_by(Year) %>% 
  mutate(Total_Sales = sum(Value, na.rm=T),
         Pct_Sales = round(100*(Value/Total_Sales),2))

# stats_state <- stats %>%
#   group_by(State) %>%
#   summarise(State_Value = sum(Value, na.rm=T)) %>%
#   ungroup() %>%
#   arrange(desc(State_Value)) %>%
#   mutate(Total_Sales = sum(State_Value, na.rm=T),
#          Pct_Sales = round(100*(State_Value/Total_Sales),2))

# which state has the most $/operation
j <- gf_moll %>% 
  filter(Unit == "OPERATIONS") %>%
  arrange(desc(Value)) %>% 
  group_by(Year) %>% 
  mutate(Total_Op = sum(Value, na.rm=T),
         Pct_Op = round(100*(Value/Total_Op),2))

# US_sales_gapfill <- read_csv("data/int/mollusk_totals/US_sales_gapfill.csv")
# op <- US_sales_gapfill %>%
#   select(Year, State, Species, Product_Type, Unit, Value) %>%
#   filter(Unit == "OPERATIONS") %>%
#   group_by(State) %>%
#   summarise(Total_Val = sum(Value, na.rm=T)) %>%
#   ungroup() %>%
#   arrange(desc(Total_Val)) %>%
#   mutate(US_Total_Val = sum(Total_Val, na.rm=T),
#          Pct_Total = round(100*(Total_Val/US_Total_Val),2))
# 
# # Sales per operation
# stats_state[stats_state$State == "WASHINGTON",][["State_Value"]]/op[op$State == "WASHINGTON",][["Total_Val"]]
# stats_state[stats_state$State == "MASSACHUSETTS",][["State_Value"]]/op[op$State == "MASSACHUSETTS",][["Total_Val"]]
# 
# sales_per_op <- stats_state %>% 
#   full_join(op, by = "State") %>% 
#   rename(No_Operations = Total_Val,
#          Sales = State_Value) %>% 
#   mutate(sales_pr_op = Sales/No_Operations) %>% 
#   arrange(desc(sales_pr_op))