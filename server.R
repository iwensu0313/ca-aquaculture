
function(input, output, session) {
  
  
  ## California Mollusk Baseline Metrics ##
  callModule(summary_stats, "ca_metrics",
             number_boxes = 3,
             statistic = list("22%", "20%", "29%"),
             text = list("of aquaculture farms in California were cultivating shellfish in 2013. 67% of them were selling Pacific Oysters.",
                         "of California aquaculture sales came from shellfish, totalling approximately $17 M in 2013.",
                         "increase in farms from 21 to 27 operations over 8 years, but sales declined by 15%."))
  
  ## California Mollusk Farm Plot ##
  callModule(card_plot, "ca_shell_plot",
             df = ca_operations_plot,
             x = "Species",
             y = "Value",
             color_group = "Species",
             filter_field = "Year",
             colors = cols,
             plot_type = "bar",
             mode = NULL,
             tooltip_text = ~paste("No. of Farms:", Value, sep=" "),
             xaxis_label = "Type of Shellfish",
             yaxis_label = "Number of Shellfish Farms")
  
  
  
  
  ## US Finfish Aquaculture Baseline Metrics ##
  callModule(summary_stats, "fish_metrics",
             number_boxes = 3,
             statistic = list("51%", "$202 M", "35%"),
             text = list("of US food fish aquaculture sales in USD are from catfish, followed by trout at 15%, and bass at 7%.",
                         "in finfish aquaculture products was sold in Mississippi, the highest food fish producing state in 2013.",
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
  
  
  
  
  
  # output$downloadData <- downloadHandler(
  #   filename="shellfish.csv",  # desired file name on client 
  #   content=function(con) {
  #     file.copy("data/int/mollusk_totals/US_sales_2013.csv", con)
  #   }
  # )



    


  }
