source("global.R")

### Setting up the dashboard page
dashboardPage(
  dashboardHeader(
    title = "Aquaculture Data",
    titleWidth = 210), # 200 will line it up with the sidebar
  
  ### Dashboard Sidebar  
  dashboardSidebar(
    
    sidebarMenu(
      menuItem("About", tabName = "dashboard"),
      menuItem("California", tabName = "ca"),
      menuItem("Food Fish", tabName = "us-fish"),
      menuItem("Shellfish", tabName = "us-shell"),
      menuItem("Download Data", tabName = "data-tables")
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
                               lead = "California's aquaculture industry includes land-based and coastal systems, but there has been recent expansion into open-ocean production.",
                               subtitle = "About the Data:",
                               description = list("Below you will find information on types of shellfish and food fish species cultivated in California in 2013, 2005, and 1998. Information is from the USDA Census of Aquaculture. Farms are defined as operations that have produced $1,000 or more in sales from aquaculture products. The fourth census will provide data for 2018 and will be available at the end of 2019, so stay tuned! You will also find information about seafood imports from 2014 to 2017. This data comes from the NOAA Fisheries Statistics database. Seafood imports can provide an idea of consumer demand, as the majority of our seafood is not local. However, as local production increases, proper evaluation of demand will have to incorporate both domestic and foreign sources of seafood. The only products shown are those explicitly described as farmed.")
                  ), # end tab title ui
                  
                  ## Baseline Metrics ##
                  summary_stats_ui(id = "ca_metrics",
                                   number_boxes = 3),
                  
                  
                  ## Plot CA Shellfish ##
                  plot_ui(id = "ca_shell_plot",
                          title_text = "California Shellfish Operations",
                          sub_title_text = "Select different years to view change in number of farms cultivating each species. Hover over bars to view data. Double-click or single-click on legend categories to view a subset of the data. In 1998, the census only recorded 3 operating mussel farms in California (not shown below).",
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
                          sub_title_text = "Select different years to view change in number of farms cultivating each species. Hover over bars to view data. Double-click or single-click on legend categories to view a subset of the data. This plot excludes aquaculture products categorized as sport fish, ornamental fish, and baitfish.",
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
                          title_text = "California Farmed Seafood Imports",
                          sub_title_text = "Select an imported seafood product from the drop down and view sales per country of origin. Double-click on a country of interest to view a single timeseries. Data include only those explicitly described as farmed in the NOAA database.",
                          select_type = "search",
                          select_location = "above",
                          select_choice = list(
                            "All Products" = "ALL PRODUCTS",
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
      
      
      
      
      ## US Food Fish Aquaculture ##
      tabItem(tabName = "us-fish",
              
              div(class = "master",
                  
                  ## Tab Title ##
                  tab_title_ui(title = "US Food Fish Aquaculture",
                               lead = "Finfish aquaculture in the US primarily occurs in ponds in the Southeast, in raceways in the Northwest, as well as ocean net pens off the Northeast coast.",
                               subtitle = "About the Data:",
                               description = list(paste0("Food fish data excludes finfish categorized as sport fish, baitfish, or ornamental fish. Below you will find food fish production data across US states from the US Department of Aquaculture Quick Stats database. The information displayed is from the most recent, comprehensive, available source: the USDA 2013 Census Aquaculture. Farms include those producing fish eggs, fingerlings & fry, stockers, broodstock, as well as foodsize fish with sales of $1,000 or more. Total sales in dollars had to be estimated for 15 states due to undisclosed data. This was estimated by multiplying the number of farm operations by the average US sales per operation. The 2018 USDA aquaculture census will be released in late 2019."))
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
                  
              ) # end div master
      ), # end us-shell tabItem
      
      
      
      
      ## Download Data ##
      tabItem(tabName = "data-tables",
              div(class = "master",
                  h1(strong("Aquaculture Data Sources")),
                  
                  tags$br(),
                  
                  p("Below you will find the USDA and NOAA Fisheries data tables that were used to create the maps and plots in the Aquaculture Data dashboard. They are tidied versions of the original raw data tables, allowing users to more easily filter and search the data for categories of interest."),
                  p(strong("A Note about Downloading:"), "The download button only downloads the subset of the table that is shown. To download the entire table, first select 'Show All Entries' then press 'Download'."),
                  
                  tags$br(),
                  
                  ## USDA Data Table Intro
                  p(h3("USDA Census of Aquaculture: Mollusk and Food Fish")),
                  p("Aquaculture sales in dollars, number of operations, head, and head per pound as reported by the US Department of Agriculture Census of Aquaculture in 1998, 2005, and 2013. Excluded wholesale and retail information. Data that was not disclosed by USDA to protect individual farms are left blank. The data table below is an intermediate, more tidied version of the", tags$a(href="https://quickstats.nass.usda.gov/", "original USDA data"), "."),
                  p(strong("Reading the data:")),
                  p("This data table combines subsets and totals. See", tags$a(href="data/int/README.txt", "metadata documentation"), "for more information before using the data in analysis."),
                  
                  ## USDA Data Table
                  fluidRow(
                    column(12, 
                           div(dataTableOutput("usdaTable"))
                    )
                  ), # end table
                  
                  
                  ## NOAA Data Table Intro
                  p(h3("NOAA Statistics: All California Seafood Imports")),
                  p("The California Farmed Seafood Imports plot only displays 'farmed' seafood import values. This tidied data table contains weight and dollar value of all California seafood imports as reported by NOAA from 2014 to 2017. Access original raw data here:", tags$a(href="https://www.st.nmfs.noaa.gov/commercial-fisheries/foreign-trade/applications/trade-by-specific-us-customs-district", "NOAA Fisheries Statistics"), "."),
                  
                  ## NOAA Data Table
                  fluidRow(
                    column(12, 
                           div(dataTableOutput("noaaimportTable"))
                    )
                  ) # end table
              ) # end div master
      ) # end data tabItem
      
      
      
      
      ## Contact ##
      #   tabItem(tabName = "contact",
      #                              
      #           pageWithSidebar(
      #             headerPanel("Email sender"),
      #             
      #             sidebarPanel(
      #               textInput("from", "From:", value="du.iwensu@gmail.com"),
      #               textInput("to", "To:", value="du.iwensu@gmail.com"),
      #               textInput("subject", "Subject:", value=""),
      #               actionButton("send", "Send mail")
      #             ),
      #             
      #             mainPanel(    
      #               aceEditor("message", value="write message here")
      #             )
      #           )
      #           
      #   ) # end contact tabitem
      # 
    ) # end tabItems 
    
    
    
    
  ) # end dashboardBody
) # end dashboardPage

