
function(input, output, session) {
  
  
  ## California Baseline Metrics ##
  callModule(summary_stats, "ca_metrics",
             number_boxes = 3,
             statistic = list("67%", "64%", "$84M"),
             text = list("of shellfish farms in CA cultivated Pacific Oysters and 59% of food fish farms grew Catfish.",
                         "of CA aquaculture sales in 2013 came from food fish and shellfish, totalling $37 M and $17 M respectively.",
                         "Sales of all California aquaculture products in 2013, witha total of 124 operating farms."))
  
  ## California Mollusk Plot ##
  callModule(card_plot, "ca_shell_plot",
             df = ca_shell_plot,
             x = "Species",
             y = "Value",
             color_group = "Species",
             filter_field = "Year",
             colors = cols,
             plot_type = "bar",
             mode = NULL,
             tooltip_text = ~paste("No. of Farms:", Value, 
                                   "<br>Species:", StrCap(tolower(Species), method="word"), sep=" "),
             xaxis_label = "Type of Shellfish",
             yaxis_label = "Number of Shellfish Farms")
  
  ## California Food Fish Plot ##
  callModule(card_plot, "ca_fish_plot",
             df = ca_fish_plot,
             x = "Species",
             y = "Value",
             color_group = "Species",
             filter_field = "Year",
             colors = cols,
             plot_type = "bar",
             mode = NULL,
             tooltip_text = ~paste("No. of Farms:", Value,
                                   "<br>Species:", StrCap(tolower(Species), method="word"), sep=" "),
             xaxis_label = "Type of Food Fish",
             yaxis_label = "Number of Fish Farms")
  
  ## California Seafood Import Plot ##
  callModule(card_plot, "ca_import_plot",
             df = ca_import_plot,
             x = "Year",
             y = "Dollars",
             color_group = "Country",
             filter_field = "Product",
             colors = cols,
             plot_type = "scatter",
             mode = "lines+markers",
             tooltip_text = ~paste("Product:", StrCap(tolower(Country), method="word"),
                                   "<br>Sales:", prettyNum(Dollars, big.mark = ","), "USD", sep=" "),
             xaxis_label = "Year",
             yaxis_label = "Sales in US Dollars")
  
  
  
  
  ## US Finfish Aquaculture Baseline Metrics ##
  callModule(summary_stats, "fish_metrics",
             number_boxes = 3,
             statistic = list("51%", "$202 M", "35%"),
             text = list("of sales in USD are from catfish, followed by trout at 15%, and bass at 7%.",
                         "in finfish aquaculture products was sold in Mississippi, the highest food fish producing state.",
                         "of food fish farms were located in Mississippi, Alabama, and North Carolina."))
  
  ## Finfish Aquaculture US Map ##
  callModule(card_map, "fish_us_map",
             data = fish_us_map,
             field = "input",
             filter_field = type, # type of data to plot
             display_field = "map_data",
             display_units = "units",
             color_palette = ygb,
             legend_title = "Legend",
             popup_title = "state")
  

  
  
  ## US Shellfish Aquaculture Baseline Metrics ##
  callModule(summary_stats, "shell_metrics",
             number_boxes = 3,
             statistic = list("55%", "39%", "52%"),
             text = list("of US shellfish sales are oysters, 38% are clams and 4% are mussels.",
                         "of shellfish aquaculture sales was produced in Washington during 2013.",
                         "of shellfish farms are in Florida, Massachusetts, and Washington."))
  
  ## Shellfish Aquaculture US Map ##
  callModule(card_map, "shell_us_map",
             data = shell_us_map,
             field = "input",
             filter_field = type, # type of data to plot
             display_field = "map_data",
             display_units = "units",
             color_palette = ygb,
             legend_title = "Legend",
             popup_title = "state")
  
  
  # testing int data download button
  # output$downloadData <- downloadHandler(
  #   filename="shellfish.csv",  # desired file name on client 
  #   content=function(con) {
  #     file.copy("data/int/mollusk_totals/US_sales_2013.csv", con)
  #   }
  # )



  }
