source("global.R")

### Setting up the dashboard page
dashboardPage(
  dashboardHeader(
    title = "Aquaculture in California",
    titleWidth = 300),
  
### Dashboard Sidebar  
  dashboardSidebar(
    
    sidebarMenu(
      menuItem("About", tabName = "dashboard"),
      menuItem("Global Data", tabName = "mar", icon = icon("globe", lib="glyphicon"))
  ),
  
  # Footer tag, include hyperlink
  tags$a(href="https://iwensu0313.github.io/", 
  tags$footer("\u00a9 Iwen Su", align = "right", style = "
              position:absolute;
              bottom:0;
              width:100%;
              height:50px;   /* Height of the footer */
              color: white;
              padding: 10px;
              z-index: 1000;")
  ),
  
  width = 200),
  
  
### Dashboard Body
  dashboardBody(
    #adding this tag to make header longer, from here:https://rstudio.github.io/shinydashboard/appearance.html#long-titles
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")
      ),
    
### Side Bar Tabs
  tabItems(
    
    ## The OHI Story ##
    
    tabItem(tabName = "dashboard",
          
            frontp() # content is in front_page.R
            
            ),
    
   
    ## Mariculture ##
    
    tabItem(tabName = "mar",
            
          ## Mariculture Tab Title ##
          tab_title_ui(goal_text = "MARICULTURE",
                       goal_description = "Global mariculture has been growing impressively since the 1980s, while wild-caught fishery production has remained relatively static.",
                       definition = list("Mariculture measures the ability to reach the highest levels of seafood gained from farm-raised facilities without damaging the ocean’s ability to provide fish sustainably now and in the future. The status of each country is calculated by taking tonnes of seafood produced, weighting it for sustainability and dividing it by the country's coastal population to scale it across the global. Since OHI also defines higher mariculture statuses as those that are maximizing sustainable harvest from the oceans, we compare the production per coastal population to the highest global historic production capacity. The mariculture and fisheries status both contribute equally to measuring the OHI Food Provisions goal.")),
          
          ## Mariculture Baseline Metrics ##
          summary_stats_ui(id = "mar_baseline",
                               number_boxes = 3),
                
          ## Mariculture Global Map
          map_ui(id = "mar_global_map",
                 title_text = paste0("Global Map of Mariculture Production in ", data_yr),
                 sub_title_text = "Start exploring! Select data to view on the map & click on EEZ regions to see country and values. It may take a few seconds to load. The data in the map categorizes countries into 4 quantiles with 75-100% being the top producing countries.",
                 select_type = "radio",
                 select_location = "above",
                 select_choices = c("All Production" = "prodTonnesAll",
                                    "Production per Capita" = "prodPerCap"),
                 select_label = "",
                 source_text = list(
                   p("Sources:"),
                   p(tags$sup("1."), tags$a(href="http://www.fao.org/fishery/statistics/software/fishstatj/en", "Food and Agriculture Organization"), ", Global Aquaculture Production Quantity (March 2018)"),
                   p(tags$sup("2."), tags$a(href="http://sedac.ciesin.columbia.edu/data/collection/gpw-v4/documentation","Center for International Earth Science Information Network"), ", Gridded Population of the World, V4 (2016).")
                   )
                 ),
          
          ## Annual Mariculture Production ##
           card_ui(id = "mar_prod",
                    title_text = "Tonnes of Species Harvested by Country",
                    sub_title_text = "Start exploring! Select or type in a country of interest. Click on names of species you want to remove from the plot. Hover over the points to view tonnes and species harvested.",
                    select_type = "search",
                    select_location = "above",
                    select_choices = unique(mar_harvest$country),
                    select_label = NULL,
                    source_text = list(
                      p("Sources:"),
                      p(tags$sup("1."), tags$a(href="http://www.fao.org/fishery/statistics/software/fishstatj/en", "Food and Agriculture Organization"), ", Global Aquaculture Production Quantity (March 2018)"))
                      
                     )
            )
    
  )
    )
  )

