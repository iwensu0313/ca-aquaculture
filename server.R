
function(input, output, session) {

  ## Mariculture Production ##
  # callModule(card_plot, "mar_prod",
  #            df = mar_harvest,
  #            x = "year",
  #            y = "tonnes",
  #            color_group = "species",
  #            filter_field = "country",
  #            colors = cols,
  #            plot_type = "scatter",
  #            mode = "lines+markers",
  #            tooltip_text = ~paste("Tonnes:", prettyNum(tonnes, big.mark=","), # format numbers > 1,000
  #                                  "<br>Species:", species, sep=" "),
  #            xaxis_label = "Year",
  #            yaxis_label = "Annual Production (tonnes)")
  
  
  ## US Finfish Aquaculture Baseline Metrics ##
  callModule(summary_stats, "fish_baseline",
             number_boxes = 3,
             statistic = list("30%", "$703 M", "15%"),
             text = list("of US finfish aquaculture sales in USD are from catfish, followed by unidentified fish at 23%, and trout at 17%.",
                         "in finfish aquaculture products was sold in Alabama, the highest finfish producing state in 2013.",
                         "of finfish farms were located in Mississippi, but Alabama had greater sales per farm at an average of $1.5M."))
  
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


  }
