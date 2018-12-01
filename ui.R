source("global.R")

### Setting up the dashboard page
dashboardPage(
  dashboardHeader(
    title = "US Aquaculture",
    titleWidth = 200),
  
### Dashboard Sidebar  
  dashboardSidebar(
    
    sidebarMenu(
      menuItem("About", tabName = "dashboard"),
      menuItem("Finfish", tabName = "us-fish"),
      menuItem("Shellfish", tabName = "us-shell"),
      menuItem("Resources"), tabName ="resources",
      menuItem("Contact", tabName = "contact")
  ),
  
  # Footer tag, include hyperlink
  tags$a(href="https://iwensu0313.github.io/", 
  tags$footer("\u00a9 Iwen Su", align = "right", style = 
              "position: absolute;
               bottom: 0;
               width: 100%;
               height: 50px;   /* Height of the footer */
               color: white;
               padding: 10px;
               z-index: 1000;")
  ),
  
  width = 200), # end dashboard sidebar
  
  
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
            
            ), # end front page tabItem
    
    
    ## US Finfish Aquaculture ##
    tabItem(tabName = "us-fish",
            
          div(class = "master",
            
            ## Tab Title ##
            tab_title_ui(title = "Finfish Aquaculture",
                         lead = "Finfish aquaculture in the US primarily occurs in ponds in the Southeast, in raceways in the Northwest, as well as ocean net pens off the Northeast coast.",
                         subtitle = "About the Data:",
                         description = list(paste0("Below you will find aquaculture production data across US states from the US Department of Aquaculture Quick Stats database. The information displayed is from the most recent, comprehensive, available source: the USDA 2013 Census Aquaculture. Farms include those producing fish eggs, fingerlings & fry, stockers, broodstock, as well as foodsize fish with sales of $1,000 or more. In most cases, 50-60% of production information for individual farms was withheld from the public to avoid disclosing data where requested. Undisclosed data was estimated using state or regional averages within each data type. The fourth USDA aquaculture census will be conducted in December 2018 by the National Agriculture Statistics Service (NASS)."))
                         ),
                
            ## Baseline Metrics ##
            summary_stats_ui(id = "fish_baseline",
                                 number_boxes = 3),
                
            ## Mariculture Global Map
            map_ui(id = "fish_us_map",
                   title_text = paste0("Finfish Aquaculture Sales in 2013"),
                   sub_title_text = "Start exploring! Select type of data to view: 1) sales in dollars 2) production in weight, no. of fish, or eggs 3) total farm operations. Click on states to see values. It may take a few seconds to load. The data in the map categorizes countries into 4 quantiles with 75-100% being the top producing countries. Don't forget to check out Hawaii!",
                   select_type = "radio",
                   select_location = "above",
                   select_choices = c("Dollars" = "DOLLARS",
                                          "Pounds" = "LB",
                                          "Fish" = "HEAD",
                                          "Eggs" = "EGGS",
                                          "Farms" = "OPERATIONS"),
                   select_label = NULL,
                   source_text = list(
                         p("Sources:"),
                         p(tags$sup("1."), tags$a(href="https://quickstats.nass.usda.gov/", "US Department of Agriculture"), ", Quick Stats Census (2013)"))
                       ) # end of map ui
            ) # end div-master
         ), # end us-fish tabItem
    
    ## US Shellfish Aquaculture ##
    tabItem(tabName = "us-shell",
            
            div(class = "master",
                
                tab_title_ui(title = "Shellfish Aquaculture",
                             lead = "Anticipated completion will mid-December!",
                             subtitle = "",
                             description = "")
                
            ) # end div master
    ) # end us-shell tabItem
    
    
    ) # end tabItems 

 ) # end dashboardBody
) # end dashboardPage

