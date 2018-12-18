## California Aquaculture Farm Operations ##

## Data Source
# USDA Quick Stats Census

# Source: https://quickstats.nass.usda.gov/
# Downloaded: Nov. 15, 2018
# Timeseries: 1998, 2005, 2013
# Format: CSV
# Metadata: https://quickstats.nass.usda.gov/src/glossary.pdf
# Notes: Queried for Census, Aquaculture, Mollusk/Food Fish, Sales (clicking the Get Data button should extract all data items, all years, and both state and national data. Data tables include sales (in $, head, and lb) and no. of operations per state. I don't believe inflation is accounted for. 


## CA Shellfish

# Data from Table 1 and 9 from USDA 2013 Census Report 
# total CA farms 2013 124 $85,583,000 (Above avg?)
# total CA farms 2005 118, $69,607,000 (abov avg?)
# mollusk farms 2013 27 $16,992,000
# mollusk farms 2005 21 $20,064,000
# US avg mollusk sales/farm 2013 $434,613
# US avg mollusk sales/farm 2005 $207,330


## Read in Tidied US Mollusk Sales Data
all_sales <- read.csv("data/int/usda_mollusk/US_sales_all_tidy.csv")


## Filter for California Mollusk Sales
ca <- all_sales %>% 
  filter(State == "CALIFORNIA", 
         !Product_Type %in% c("RETAIL", "WHOLESALE")) %>% 
  select(-State_Code, -Commodity, -Wholesale_Type)


## Tidy for Plotting
# Filter for Operations and Unique Species Categories
# Remove umbrella categories (e.g. "CLAMS" is the summary data for "MANILA CLAMS" and "OTHER CLAMS")
# Had to factorize species so legend categories constant across filtered datasets
ca_shell_plot <- ca %>% 
  filter(Unit == "OPERATIONS",
         !Species %in% c("MOLLUSKS", "CLAMS", "OYSTERS"),
         Product_Type == "ALL PRODUCTS") %>% 
  mutate(Species = as.factor(as.character(Species))) # remove previous factor info, and change back so only the current Species are translated to factors

write.csv(ca_shell_plot, "data/output/ca_shell_plot.csv")




## CA Food Fish 

# Data from Table 1 and 9 from USDA 2013 Census Report 
# all CA farms 2013 124 $85,583,000 (Above avg?)
# all CA farms 2005 118, $69,607,000 (abov avg?)
# food fish farms 2013 71 $37,395,000
# food fish farms 2005 69 $36,887,000
# US avg food fish sales/farm 2013 $564,928
# US avg food fish sales/farm 2005 $364,038
# 42/71 # no. of tilapia farms/total CA food fish farms


## Read in Tidied US Food Fish Sales
all_sales <- read.csv("data/int/usda_fish/US_sales_all_tidy.csv")


## Filter for CA Food Fish Sales
ca_fish <- all_sales %>% 
  filter(State == "CALIFORNIA",
         !Product_Type %in% c("RETAIL", "WHOLESALE")) %>%
  select(-State_Code, -Commodity, -Wholesale_Type)


## Tidy for Plotting
# Select Farm Operations data
# Had to factorize species so legend categories constant across filtered datasets
ca_fish_plot <- ca_fish %>% 
  filter(Unit == "OPERATIONS",
         !Species %in% c("FOOD FISH", "CARP"),
         Product_Type == "ALL PRODUCTS") %>% 
  mutate(Species = as.character(Species)) %>% # remove prev factors 
  mutate(Species = ifelse(str_detect(Species, "^HYBRID.*"), "STRIPED BASS", Species)) %>%  # simplify striped bass name for graphing
  mutate(Species = as.factor(Species))  # convert existing sp to factors
  
write.csv(ca_fish_plot, "data/output/ca_fish_plot.csv")  
