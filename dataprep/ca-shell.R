

## CA Shellfish ##

## Data from Table 1 and 9 from USDA 2013 Census Report 
## total CA farms 2013 124 $85,583,000 (Above avg?)
## total CA farms 2005 118, $69,607,000 (abov avg?)
## mollusk farms 2013 27 $16,992,000
## mollusk farms 2005 21 $20,064,000
## US avg mollusk sales/farm 2013 $434,613
## US avg mollusk sales/farm 2005 $207,330

all_sales <- read.csv("data/int/mollusk_totals/US_sales_all_tidy.csv")

ca <- all_sales %>% 
  filter(State == "CALIFORNIA", 
         !Product_Type %in% c("RETAIL", "WHOLESALE")) %>% 
  select(-State_Code, -Commodity, -Wholesale_Type)


## No. of Operations per Species
ca_operations_plot <- ca %>% 
  filter(Unit == "OPERATIONS",
         !Species %in% c("MOLLUSKS", "CLAMS", "OYSTERS"),
         Product_Type == "ALL PRODUCTS") 

## CA Finfish ##