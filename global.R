## global variables
## sources goal data for map and chart modules
## defines global variables, source code, etc


## SET UP ENVIRONMENT ##

## libraries
library(sf)
library(tidyverse)
library(shinydashboard)
library(RColorBrewer)
library(plotly)
library(sunburstR)
library(viridis)
library(stringr)
library(USAboundaries)
library(DescTools)
library(janitor)
library(sendmailR)
library(shinyAce)
library(DT)

## Color Palettes
ygb <- colorRampPalette(brewer.pal(5,'YlGnBu'))(200); cols <- ygb[19:200] # blue shades



## SOURCE EXTERNAL SCRIPTS ##

## source modules
source("modules/chart_card.R")
source("modules/map_card.R")
source("modules/summary_stats_card.R")
source("modules/map_minichart_card.R")

## source functions
source("functions/tab_title.R")
source("functions/addLegend_desc.R")

## source front page css/html customization
source("front_page.R")

## set: no scientific notation and round to 2 decimals
options(scipen = 999,
        digits = 5)





## US AQUACULTURE DATA SOURCES ##
source("dataprep/us-fish.R")
source("dataprep/us-shell.R") # combines us-fish and us-shell

## CA AQUACULTURE DATA SOURCES ##
source("dataprep/ca-aqua.R")
source("dataprep/ca-imports.R")

## SHRIMP IMPORT REFUSALS ##
source("dataprep/us-import-refusals.R")
