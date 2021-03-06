
function(input, output, session) {
  
  
  # ## California Baseline Metrics ##
  # callModule(summary_stats, "ca_metrics",
  #            number_boxes = 3,
  #            statistic = list("67%", "64%", "$84M"),
  #            text = list("of mollusk farms in CA cultivated Pacific Oysters and 59% of food fish farms grew Catfish.",
  #                        "of CA aquaculture sales in 2013 came from food fish and mollusk, totalling $37 M and $17 M respectively.",
  #                        "Sales of all California aquaculture products in 2013, with a total of 124 operating farms."))
  # 
  
  
  ## California Mollusk Plot ##
  callModule(card_plot, "ca_shell_plot",
             df = ca_shell_plot,
             x = "Species",
             y = "Value",
             color_group = "Species",
             filter_field = "Year",
             colors = ygb_cols,
             plot_type = "bar",
             mode = NULL,
             tooltip_text = ~paste("No. of Farms:", Value, 
                                   "<br>Species:", StrCap(tolower(Species), method="word"), sep=" "),
             xaxis_label = "Type of Mollusk",
             yaxis_label = "Number of Mollusk Farms",
             yaxis_range = c(0,20))
  
  
  
  ## California Food Fish Plot ##
  callModule(card_plot, "ca_fish_plot",
             df = ca_fish_plot,
             x = "Species",
             y = "Value",
             color_group = "Species",
             filter_field = "Year",
             colors = ygb_cols,
             plot_type = "bar",
             mode = NULL,
             tooltip_text = ~paste("No. of Farms:", Value,
                                   "<br>Species:", StrCap(tolower(Species), method="word"), sep=" "),
             xaxis_label = "Type of Food Fish",
             yaxis_label = "Number of Fish Farms",
             yaxis_range = c(0,52)) # Set y-axis range
  
  
  
  ## California Seafood Import Plot ##
  callModule(card_plot, "ca_import_plot",
             df = ca_import_plot,
             x = "Year",
             y = "Dollars",
             color_group = "Country",
             filter_field = "Product",
             colors = ygb_cols,
             plot_type = "scatter",
             mode = "lines+markers",
             tooltip_text = ~paste("Imported from", Country,
                                   "<br>Sales:", prettyNum(Dollars, big.mark = ","), "USD", sep=" "),
             xaxis_label = "Year",
             yaxis_label = "Sales in US Dollars")
  
  
  
  ## US Finfish Aquaculture Baseline Metrics ##
  callModule(summary_stats, "fish_metrics",
             number_boxes = 3,
             statistic = list("51%", "$203 M", "35%"),
             text = list("of sales in USD are from catfish, followed by trout at 15%, and bass at 7%.",
                         "in finfish aquaculture products were sold in Mississippi, the highest food fish producing state.",
                         "of food fish farms were located in Mississippi, Alabama, and North Carolina."))
  
  ## Finfish Aquaculture US Map ##
  callModule(card_map, "fish_us_map",
             data = fish_us_map,
             field = "input",
             filter_field = type, # type of data to plot
             popup_value = "map_data",
             popup_units = "units",
             color_palette = ygb,
             color_palette_type = "discrete",
             legend_title = "Legend",
             popup_label = "state")
  

  
  ## US Mollusk Aquaculture Baseline Metrics ##
  callModule(summary_stats, "shell_metrics",
             number_boxes = 3,
             statistic = list("55%", "45%", "52%"),
             text = list("of US mollusk sales are oysters, 38% are clams and 4% are mussels.",
                         "of mollusk aquaculture sales were produced in Washington during 2013.",
                         "of mollusk farms are in Florida, Massachusetts, and Washington."))
  
  
  
  ## Mollusk Aquaculture US Map ##
  callModule(card_map, "shell_us_map",
             data = shell_us_map,
             field = "input",
             filter_field = type, # type of data to plot
             popup_value = "map_data",
             popup_units = "units",
             color_palette = ygb,
             color_palette_type = "discrete",
             legend_title = "Legend",
             popup_label = "state")
  
  
  
  ## FDA Shrimp Import Refusal ##
  callModule(card_map, "shrimp_refuse_map",
             data = shrimp_refuse_map,
             field = "input",
             filter_field = YEAR, # slider data filter
             color_palette = OrRd,
             color_palette_type = "quantile",
             popup_label = "COUNTRY_NAME",
             popup_value = "REFUSALS",
             popup_units = "Units",
             legend_title = "Legend",
             lon = 12,
             lat = 30,
             zoom = 2)
  
  
  callModule(card_mapmini, "shrimp_refuse_pie",
             data = shrimp_refuse_pie,
             field = "input",
             mini_chart = "pie", # what type of minichart
             categories = c("SALMONELLA", "VETDRUGES", "NITROFURAN", "FILTHY"), # columns in data for chart categories
             filter_field = YEAR, # user will select year
             lon_field = "LON", # col name of lon
             lat_field = "LAT", # col name of lat
             chart_width = "REFUSAL_NUM", # width determined by
             label_title = "COUNTRY_NAME",
             label_value = "REFUSAL_NUM",
             label_unit = "Refusals",
             cols = ygb[c(50,100,150,197)], # chose four dispersed values in my ygb color palette
             lon = 12, # default is US center
             lat = 30, # default is US center
             zoom = 2)
  
  
  
  
  
  
  
  ## Download Data ##

  # Two ways to render DT
  
  output$usdaTable <- renderDataTable(
    datatable(data = usdaTable,
              extensions = 'Buttons'
              ,
              options = list(
                 dom = "Blfrtip",
                 buttons =
                   list("copy", list(
                     extend = "collection",
                     buttons = "csv",
                     text = "Download"
                   ) ), # end of buttons customization

              # customize the length menu
              lengthMenu = list( c(10, 20, -1) # declare values
                                   , c(10, 20, "All") # declare titles
              ), # end of lengthMenu customization
              pageLength = 10
              ) # end of options
               ) # end of datatables
  ) # end render data table

  output$noaaimportTable <- renderDataTable(
    datatable(data = noaaimportTable,
              extensions = 'Buttons',
              options = list(
                dom = "Blfrtip",
                buttons =
                  list("copy", list(
                    extend = "collection",
                    buttons = "csv",
                    text = "Download"
                  ) ), # end of buttons customization

                # customize the length menu
                lengthMenu = list( c(10, 20, -1) # declare values
                                   , c(10, 20, "All") # declare titles
                ), # end of lengthMenu customization
                pageLength = 10
              ) # end of options
    ) # end of datatables
    ) # end render DT
  
  
  
  
  
  # ## Contact Page ##
  # observe({
  #   if(is.null(input$send) || input$send==0) return(NULL)
  #   from <- "du.iwensu@gmail.com" #isolate(input$from)
  #   to <- "du.iwensu@gmail.com" #isolate(input$to)
  #   subject <-  "test" #isolate(input$subject)
  #   msg <-"test"  #isolate(input$message)
  #   sendmail(from, to, subject, msg, control=list(smtpServer="serverinfo"))
  # })
  
  
  
  # testing int data download button
  # output$downloadData <- downloadHandler(
  #   filename="shellfish.csv",  # desired file name on client 
  #   content=function(con) {
  #     file.copy("data/int/usda_mollusk/US_sales_2013.csv", con)
  #   }
  # )



  }
