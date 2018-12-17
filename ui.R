source("global.R")

### Setting up the dashboard page
dashboardPage(
  dashboardHeader(
    title = "Aqculture Data",
    titleWidth = 200),
  
### Dashboard Sidebar  
  dashboardSidebar(
    
    sidebarMenu(
      menuItem("About", tabName = "dashboard"),
      menuItem("California", tabName = "ca"),
      menuItem("Finfish", tabName = "us-fish"),
      menuItem("Shellfish", tabName = "us-shell")
      #,
      #menuItem("Resources"), tabName ="resources",
      #menuItem("Contact", tabName = "contact")
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
    
    
    ## About Page ##
    
    tabItem(tabName = "dashboard",
          
            frontp() # content is in front_page.R
            
            ), # end front page tabItem
    
    
    
    
    ## California Aquaculture
    tabItem(tabName = "ca",
            
            div(class = "master",
                
            ## Tab Title ##  
            tab_title_ui(title = "California Aquaculture",
                         lead = "The land-based aquaculture industry in California has been around for several decades, but there has been recent expansion into coastal and open-ocean production.",
                         subtitle = "About the Data:",
                         description = list("Below you will find information on types of shellfish and food fish species cultivated in California in 2013, 2005, and 1998. Information is from the USDA Census of Aquaculture. Farms are defined as operations that have produced $1,000 or more in sales from aquaculture products. The fourth census will provide data for 2018 and will be available at the end of 2019, so stay tuned! You will also find information about seafood imports from 2014 to 2017. This data comes from the NOAA Fisheries Statistics database. Seafood imports can provide an idea of consumer demand, as the majority of our seafood is not local. However, as local production increases, proper evaluation of demand will have to incorporate both domestic and foreign sources of seafood. The only products shown are those explicitly described as farmed.")
                         ), # end tab title ui
            
            ## Baseline Metrics ##
            summary_stats_ui(id = "ca_metrics",
                             number_boxes = 3),
            
            
            ## Plot CA Shellfish ##
            plot_ui(id = "ca_shell_plot",
                    title_text = "California Shellfish Operations",
                    sub_title_text = "Select different years to view change in number of farms cultivating each species. In 1998, the census only recorded 3 operating mussel farms in California (not shown below).",
                    select_type = "radio",
                    select_location = "above",
                    select_choice = c(
                      "2013" = "2013",
                      "2005" = "2005"),
                    select_label = NULL,
                    source_text = list(
                      p("Sources:"),
                      p(tags$sup("1."), 
                        tags$a(href="https://quickstats.nass.usda.gov/", 
                               "US Department of Agriculture"), 
                        ", Quick Stats Census (2013)"))
            ), # end plot ui
            
            ## Plot CA Food Fish ##
            plot_ui(id = "ca_fish_plot",
                    title_text = "California Food Fish Operations",
                    sub_title_text = "Select different years to view change in number of farms cultivating each species. This plot excludes aquaculture products categorized as sport fish, ornamental fish, and baitfish.",
                    select_type = "radio",
                    select_location = "above",
                    select_choice = c(
                      "2013" = "2013",
                      "2005" = "2005",
                      "1998" = "1998"),
                    select_label = NULL,
                    source_text = list(
                      p("Sources:"),
                      p(tags$sup("1."), 
                        tags$a(href="https://quickstats.nass.usda.gov/", 
                               "US Department of Agriculture"), 
                        ", Quick Stats Census (2013)"))
            ), # end plot ui
            
            ## Plot CA Seafood Import ##
            plot_ui(id = "ca_import_plot",
                    title_text = "California Seafood Imports",
                    sub_title_text = "Select an imported seafood product from the drop down and view sales per country of origin. Data includes only those explicitly described as farmed in the NOAA database. Other imported products such as seaweed are likely farmed, but not displayed below.",
                    select_type = "search",
                    select_location = "above",
                    select_choice = list(
                      "Live Mussels" = "MUSSELS LIVE/FRESH FARMED",
                      "Live Oysters" = "OYSTERS LIVE/FRESH FARMED",
                      "Frozen or Processed Oysters" = "FARMED FROZEN OR PROCESSED OYSTERS",
                      "Fresh Atlantic Salmon" = "FARMED FRESH ATLANTIC SALMON",
                      "Fresh Chinook Salmon" = "SALMON CHINOOK FRESH FARMED",
                      "Fresh Rainbow Trout" = "TROUT RAINBOW FRESH FARMED",
                      "Fresh Coho Salmon" = "SALMON COHO FRESH FARMED"
                      ),
                    select_label = NULL,
                    source_text = list(
                      p("Sources:"),
                      p(tags$sup("1."), 
                        tags$a(href="https://www.st.nmfs.noaa.gov/commercial-fisheries/foreign-trade/applications/trade-by-specific-us-customs-district", 
                               "NOAA Fisheries Statistics"), 
                        ", Cumulative Trade Data (2014-2017)"))
            ) # end plot ui
            
            
                
                ) # end div master
            
    ), # end California page tabItem
    
    
  
    
    ## US Finfish Aquaculture ##
    tabItem(tabName = "us-fish",
            
            div(class = "master",
            
            ## Tab Title ##
            tab_title_ui(title = "US Finfish Aquaculture",
                         lead = "Finfish aquaculture in the US primarily occurs in ponds in the Southeast, in raceways in the Northwest, as well as ocean net pens off the Northeast coast.",
                         subtitle = "About the Data:",
                         description = list(paste0("Below you will find aquaculture production data across US states from the US Department of Aquaculture Quick Stats database. The information displayed is from the most recent, comprehensive, available source: the USDA 2013 Census Aquaculture. Data excludes finfish categorized as sport fish, baitfish, or ornamental fish. Farms include those producing fish eggs, fingerlings & fry, stockers, broodstock, as well as foodsize fish with sales of $1,000 or more. Total sales in dollars had to be estimated for 15 states due to undisclosed data. This was estimated by multiplying the number of farm operations by the average US sales per operation. The 2018 USDA aquaculture census will be released in late 2019."))
                         ),
                
            ## Baseline Metrics ##
            summary_stats_ui(id = "fish_metrics",
                                 number_boxes = 3),
                
            ## Finfish US Map
            map_ui(id = "fish_us_map",
                   title_text = paste0("Finfish Aquaculture Sales in 2013"),
                   sub_title_text = "Start exploring! Select type of data to view: 1) sales in dollars 2) production in weight, no. of fish, or eggs 3) total farm operations. Click on states to see values. It may take a few seconds to load. The data in the map categorizes states into 4 quantiles with 75-100% being the top producing states. Don't forget to check out Hawaii!",
                   select_type = "radio",
                   select_location = "above",
                   select_choices = c("Dollars" = "DOLLARS",
                                          # "Pounds" = "LB",
                                          # "Fish" = "HEAD",
                                          # "Eggs" = "EGGS",
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
                
            tab_title_ui(title = "US Shellfish Aquaculture",
                         lead = "Shellfish cultivation can significantly improve water quality, is environmentally sustainable, and contribute to the increase in protein demand.",
                         subtitle = "About the Data:",
                         description = "Below you will find shellfish aquaculture production data across US states from the US Department of Aquaculture Quick Stats database. The information displayed is from the most recent, comprehensive, available source: the USDA 2013 Census Aquaculture. Shellfish species include clams, mussels, oysters, and abalones. Farms surveyed have sales of $1,000 or more. Total sales in dollars had to be estimated for Alaska, Georgia, Hawaii, Maine, Massachusetts, and Pennsylvania due to undisclosed data. This was estimated by multiplying the number of farm operations by the average US sales per operation. The 2018 USDA aquaculture census will be released in late 2019."),
            
            ## Baseline Metrics ##
            summary_stats_ui(id = "shell_metrics",
                             number_boxes = 3),
            
            ## Shellfish US Map
            map_ui(id = "shell_us_map",
                   title_text = paste0("Shellfish Aquaculture Sales in 2013"),
                   sub_title_text = "Start exploring! Select type of data to view: 1) sales in dollars 2) total farm operations. Click on states to see values. It may take a few seconds to load. The data in the map categorizes countries into 4 quantiles with 75-100% being the top producing states. Don't forget to check out Alaska and Hawaii!",
                   select_type = "radio",
                   select_location = "above",
                   select_choices = c("Dollars" = "DOLLARS",
                                      "Farms" = "OPERATIONS"),
                   select_label = NULL,
                   source_text = list(
                     p("Sources:"),
                     p(tags$sup("1."), tags$a(href="https://quickstats.nass.usda.gov/", "US Department of Agriculture"), ", Quick Stats Census (2013)"))
            ) # end of map ui


            #downloadButton('downloadData', 'Download')   
            
            ) # end div master
    ) # end us-shell tabItem
    
    
    ) # end tabItems 




 ) # end dashboardBody
) # end dashboardPage

