source("global.R")

### Setting up the dashboard page

# Here, dashboardPage is a modified function - see functions
dashboardPage("California Aquaculture", 
              thead = tags$head(tags$link(rel = "stylesheet", type = "text/css", href = "custom.css"),
                                
                                # Place mbie_header inside a container-fluid for correct positioning
                                div(class = "container-fluid", aq_header())
                                
              ),
              
              
              ## About Page ##
              
              tabPanel(title = "About",
                       frontp() # content is in front_page.R
              ), # end tab panel
              
              
              
              
              ## California Production ##
              
              navbarMenu("Production",
                         
                         ## Food Fish Production
                         tabPanel("Food Fish",
                                  
                                  div(class = "master",
                                      
                                      ## Tab Title
                                      tab_title_ui(title = "Food Fish Production",
                                                   lead = "",
                                                   subtitle = "About the Data:",
                                                   description = list("Food fish data excludes finfish categorized as sport fish, baitfish, or ornamental fish. Below you will find information on types of food fish species cultivated in California in 2013, 2005, and 1998. Information is from the USDA Census of Aquaculture.  Farms include those producing fish eggs, fingerlings & fry, stockers, broodstock, as well as foodsize fish with sales of $1,000 or more. The fourth census will provide data for 2018 and will be available at the end of 2019, so stay tuned!")
                                      ),
                                      
                                      
                                      ## Baseline Metrics ##
                                      summary_stats_ui(id = "ca_metrics",
                                                       number_boxes = 3),
                                          
                                      
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
                                      ) # end plot ui
                                  ) # end div
                                  
                         ), # end food fish tab panel
                         
                         
                         ## Mollusk Production
                         tabPanel("Mollusk",
                                  
                                  div(class = "master",
                                      
                                      ## Tab Title
                                      tab_title_ui(title = "Shellfish Production",
                                                   lead = "Shellfish cultivation can significantly improve water quality, be environmentally sustainable, and contribute to the increase in protein demand.",
                                                   subtitle = "About the Data:",
                                                   description = list("Below you will find information on types of mollusk species cultivated in California in 2013, 2005, and 1998. Information is from the USDA Census of Aquaculture. Shellfish species include clams, mussels, oysters, and abalones. Farms are defined as operations that have produced $1,000 or more in sales from aquaculture products. The 2018 USDA aquaculture census will be released in late 2019.")),
                                      
                                      ## Baseline Metrics ##
                                      summary_stats_ui(id = "ca_metrics",
                                                       number_boxes = 3),
                                      
                                      ## Plot CA Mollusk ##
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
                                      ) # end plot ui
                                      
                                  ) # end div
                         ) # end CA mollusk tab Panel
                         
              ), # end CA Production nav bar menu
              
              
              
              
              ## Farmed Seafood Imports
              tabPanel("Imports",
                       
                       div(class = "master",
                           
                           
                           ## Tab Title
                           tab_title_ui(title = "Farmed Seafood Imports",
                                        lead = "Seafood imports can provide an idea of consumer demand, as the majority of our seafood is not local.",
                                        subtitle = "About the Data:",
                                        description = list("Below you will find information about seafood imports from 2014 to 2017. This data comes from the NOAA Fisheries Statistics database. Proper evaluation of demand will have to incorporate both domestic and foreign sources of seafood. The only products shown are those explicitly described as farmed.")
                           ),
                           
                           ## Baseline Metrics ##
                           summary_stats_ui(id = "ca_metrics",
                                            number_boxes = 3),
                           
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
                           
                       ) # end div
              ), # end imports tab Panel
              
              
              ## National Data
              navbarMenu("National",
                         
                         # US Production
                         tabPanel("US Production",
                                  
                                  div(class = "master",
                                      
                                      tab_title_ui(title = "US Aquaculture Production",
                                                   lead = "",
                                                   subtitle = "About the Data:",
                                                   description = list("Below you will find US production data from the US Department of Aquaculture Quick Stats database for food fish and mollusks. The information displayed is from the most recent, comprehensive, available source: the USDA 2013 Census Aquaculture. Farms include facilities with sales of $1,000 or more. Total sales in dollars for US food fish production had to be estimated for 15 states due to undisclosed data. For shellfish production, total sales in dollars had to be estimated for Alaska, Georgia, Hawaii, Maine, Massachusetts, and Pennsylvania. These were estimated by multiplying the number of farm operations by the average US sales per operation for mollusks and food fish separately. The 2018 USDA aquaculture census will be released in late 2019.")),
                                      
                                      ## Baseline Metrics ##
                                      summary_stats_ui(id = "fish_metrics",
                                                       number_boxes = 3),
                                      
                                      summary_stats_ui(id = "shell_metrics",
                                                       number_boxes = 3),
                                      
                                      ## Food Fish US Map
                                      map_ui(id = "fish_us_map",
                                             title_text = paste0("Food Fish Aquaculture Sales in 2013"),
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
                                      ), # end of map ui
                                      
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
                                      
                                  ) # end div
                         ), # end US prod tab panel
                         
                         
                         
                         tabPanel("Import Refusals",
                                  
                                  div(class = "master",
                                      
                                      tab_title_ui(title = "FDA Shrimp Import Refusals",
                                                   lead = "Lead",
                                                   subtitle = "About the Data:",
                                                   description = "Description"),
                                      
                                      
                                      ## Global Map of Refusals
                                      map_ui(id = "shrimp_refuse_map",
                                             title_text = paste0("Import Refusals"),
                                             sub_title_text = "Start exploring! ",
                                             select_type = "slider",
                                             select_location = "below",
                                             slider_min = 2002,
                                             slider_max = 2018,
                                             slider_start = 2018,
                                             slider_sep = "",


                                             source_text = list(
                                               p("Sources:"),
                                               p(tags$sup("1."), tags$a(href="https://www.accessdata.fda.gov/scripts/ImportRefusals/index.cfm", "Food and Drug Administration"), ", Import Refusal Report (2002-2018)"))
                                      ), # end of map ui
                                      
                                      mapmini_ui(id = "shrimp_refuse_map",
                                                 title_text = "FDA Shrimp Import Refusals",
                                                 sub_title_text = "Start exploring! Data includes time series from 2014 to 2018.",
                                                 select_type = "slider",
                                                 select_location = "below",
                                                 slider_min = 2002,
                                                 slider_max = 2018,
                                                 slider_start = 2018,
                                                 slider_sep = ""
                                      ) # end map mini ui import refusal
                                      
                                      
                                  ) # end div
                         ) # end shrimp import refusal tab panel
                         
                         
              ), # end National
              
              ## Data Download
              navbarMenu("Data Download",
                         
                         tabPanel("USDA Census of Aquaculture",
                                  
                                  div(class = "master",
                                      
                                      h3("USDA Census of Aquaculture: Mollusk and Food Fish"),
                                      
                                      ## Summary
                                      p("Below you will find the USDA Quick Stats data that were used to create the maps and plots in this dashboard. They are tidied versions of the original raw data, allowing users to more easily search the data for categories of interest."),
                                      p(strong("Downloading the Data:"), "The download button only downloads the subset of the table that is shown. To download the entire table, first select 'Show All Entries' then press 'Download'."),
                                      
                                      tags$br(),
                                      
                                      p("Aquaculture sales in dollars, number of operations, head, and head per pound as reported by the US Department of Agriculture Census of Aquaculture in 1998, 2005, and 2013. Excluded wholesale and retail information. Data that was not disclosed by USDA to protect individual farms are left blank. The data table below is an intermediate, more tidied version of the", tags$a(href="https://quickstats.nass.usda.gov/", "original USDA data"), "."),
                                      p(strong("Reading the data:")),
                                      p("This data table combines subsets and totals. See", tags$a(href="https://raw.githubusercontent.com/iwensu0313/aqculture-data/master/data/int/USDA_Metadata.txt", "metadata documentation"), "for more information before using the data in analysis."),

                                  ## USDA Data Table
                                  dataTableOutput("usdaTable")
                                  
                                  ) # end div
                                  ), # end usda census tabPanel

                         tabPanel("NOAA Fisheries Statistics Import",
                                  
                                  div(class = "master",
                                      
                                      h3("NOAA Statistics: All California Seafood Imports"),
                                      
                                      ## Summary
                                      p("Below you will find the NOAA Fisheries data that were used to create the maps and plots in this dashboard. They are tidied versions of the original raw data, allowing users to more easily search the data for categories of interest."),
                                      p(strong("Downloading the Data:"), "The download button only downloads the subset of the table that is shown. To download the entire table, first select 'Show All Entries' then press 'Download'."),
                                      
                                      tags$br(),
                                      
                                      
                                     p("The California Farmed Seafood Imports plot only displays 'farmed' seafood import values. This tidied data table contains weight and dollar value of all California seafood imports as reported by NOAA from 2014 to 2017. Access original raw data here:", tags$a(href="https://www.st.nmfs.noaa.gov/commercial-fisheries/foreign-trade/applications/trade-by-specific-us-customs-district", "NOAA Fisheries Statistics"), "."),
                                     
                                  ## NOAA Data Table
                                  dataTableOutput("noaaimportTable")
                                  
                                  ) # end div
                                  ) # end noaa fisheries tabPanel
                         
              ) # end download nav bar menu

              # ) # end dashboard body
) # end nav page




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
#       # 
#     ) # end tabItems 
#     
#     
#     
#     
#   ) # end dashboardBody
# ) # end dashboardPage

