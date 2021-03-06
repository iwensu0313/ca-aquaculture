#' 
#' Map Minichart Card Module
#'
#' This script contains two functions:
#' \code{mapmini_ui} generates the user interface for each card
#' \code{card_mapmini} generates the plot shown in a card
#' 
#' The functions together generate a box within a fluid row that has a width 
#' of 12 (the whole page), title text, source text, a select input if applicable, 
#' and an interactive map built using leaflet. 
#' 

## Load libraries ##
library(shiny)
library(shinydashboard)
library(leaflet)
library(rgdal)
library(dplyr)
library(RColorBrewer)
library(sf)
library(rworldmap)
library(leaflet.minicharts)

#'
#' @title mapmini_ui function
#' 
#' @description Generates the ui for cards.
#' 
#' @return A fluidRow containing a tagList and a box with items specified by 
#' the function inputs.
#' 
#' @details
#' \code{mapmini_ui} needs the text that will surround the map on 
#' the card as well as information about the select inputs if 
#' applicable.
#' 
#' @param id character. Used to match to ui function to the associated
#' server function. Must be unique across cards.
#' @param title_text character, optional. Title text for map.
#' @param sub_title_text character, optional. Subtitle text for map if applicable.
#' @param select_type character, optional.  Determines the type of shiny input to be used. 
#' Must be one of the following:
#' \itemize{
#'   \item "radio"
#'   \item "drop_down"
#'   \item "checkboxes"
#'   \item NULL
#' }
#' @seealso \url{https://shiny.rstudio.com/reference/shiny/latest/selectInput.html}, 
#' @seealso \url{https://shiny.rstudio.com/reference/shiny/latest/checkboxInput.html},
#' @seealso \url{https://shiny.rstudio.com/reference/shiny/latest/radioButtons.html}
#' @param select_location character, optional. Determines if the select input will
#' be located above or below the map. Must be one of the following:
#' \itemize{
#'   \item "above"
#'   \item "below"
#'   \item NULL
#' } 
#' @param slider_min numeric, optional. Only specify if using slider input. Indicates the minimum value that can be selected.
#' @param slider_max numeric, optional. Only specify if using slider input. Indicates the maximum value that can be selected.
#' @param slider_start numeric, optional. Only specify if using slider input. Indicates the initial value of the slider.
#' @param slider_sep character, optional. Slider numeric values are by default separated by "," at the thousands. Can set to "" if slider values are numeric but Year values. 
#' @param select_choices list, optional. List of choices for the select input. Can be 
#' defined in the global.r file as a variable in passed here 
#' (e.g. in global.r: choices <- sort(unique(df$column)), in ui.r: select_choices=choices).
#' Can also be a defined list (e.g. select_choices = list("Choice 1" = "choice_1", "Choice 2" = "choice_2")). 
#' See \url{https://shiny.rstudio.com/reference/shiny/latest/selectInput.html}, for more information.
#' @param select_label character, optional, text for above select input (e.g. "Select Gender")
#' @param selected list, optional - unless using checkbox or slider input, Defines the default selections 
#' for the map. Default checkbox inputs must be defined otherwise the map will default to
#' no data.
#' @param source_text character or list, optional. Data source information for map. If 
#' additional notes need to be added beyond data source information below the map 
#' they can be added by passing a list or html elements to this function 
#' (e.g. source_text = list(p("Note 1"), p("Note 2"), p("Data Source: 2010 Census")))
#' 

## Card UI Function ##
mapmini_ui <- function(id, 
                   title_text = NULL,
                   sub_title_text = NULL,
                   select_type = c(NULL, "radio", "drop_down", "slider", "checkboxes"),
                   select_location = c(NULL, "above", "below"),
                   slider_min = NULL, 
                   slider_max = NULL, 
                   slider_start = NULL,
                   slider_sep = ",",
                   select_choices = NULL, 
                   select_label = NULL, 
                   selected = NULL,
                   source_text = NULL,
                   box_width = NULL) {
  
  ns <- NS(id)
  
  # Output w/o selection
  if (missing(select_type) == TRUE) {
    items <- leafletOutput(ns("plot"), height=450)
  } 
  else {
    # Select layout
    if (select_type == "radio") {
      select <- radioButtons(ns("select"),
                             choices = select_choices,
                             label = p(select_label),
                             selected = selected,
                             inline = TRUE)
    } else if (select_type == "drop_down") {
      select <- selectInput(ns("select"),
                            choices = select_choices,
                            label = p(select_label),
                            selected = selected)
    } else if (select_type == "slider") {
      select <- sliderInput(ns("select"),
                            label = p(select_label),
                            min = slider_min,
                            max = slider_max,
                            value = slider_start,
                            sep = slider_sep)
    } else {
      select <- checkboxGroupInput(ns("select"),
                                   choices = select_choices,
                                   label = p(select_label),
                                   selected = selected)
    }
    
    # Chart layout
    if (select_location == "above") {
      items <- list(select,
                    leafletOutput(ns("plot"), height=450))
    } else if (select_location == "below") {
      items <- list(leafletOutput(ns("plot"), height=450),
                    select)
    }
  }
  
  # Put together in box
  box_content <- list(h4(title_text), p(sub_title_text), items, p(source_text))
  
  # return box
  tagList(box(box_content, width = box_width))
}

#'
#' @title card_mapmini function
#' 
#' @description Generates the leaflet map on each card.
#' 
#' @return A leaflet map object.
#' 
#' @details
#' \code{card_mapmini} needs the data, fields, colors, and labels for the map
#' 
#' @param input autofilled by shiny.
#' @param output autofilled by shiny.
#' @param session character, must be the exact same as the id passed to the card_ui function.
#' @param data name of dataset to be mapped by the OHI regions. 
#' @param field character, this field is set up to handle one of two scenarios - the map changes
#' based on user input or it doesn't.
#' \itemize{
#'   \item{If there is an input, this field is set to "input" and the field the user selects will be used
#'   to select the data.}
#'   \item{If there is no input, this field is set to the name of the column being visualized.}
#' }
#' @param filter_field column name, this field defines the column on which to filter. Use this when `field` is set to "input"
#' @param popup_value column name, this field defines the column containing data to display
#' @param color_palette character, defines the color palette for the map. The palette options come 
#' from the RColorBrewer library, and the options can be viewed here: \url{http://www.datavis.ca/sasmac/brewerpal.html}
#' @param legend_title character, optional. Defines the legend title for the map.
#' @param popup_label character, optional. Defines the popup title for the map.
#' @param popup_add_field column name, optional. Option to put another field in the popups. The field
#' must be defined with the name of the dataframe and a "$" symbol (e.b. popup_add_field = tracts$neighborhood)
#' @param popup_add_field_title character, title text for additional pop-up field. 
#' 

## Card Server Function ##
card_mapmini <- function(input,
                     output,
                     session,
                     data,
                     field,
                     mini_chart = c("pie", "bar", "polar-radius", "polar-area"),
                     categories = NULL,
                     filter_field = NULL,
                     lon_field,
                     lat_field,
                     chart_width = NULL,
                     label_title = NULL,
                     label_value = NULL,
                     label_unit = NULL,
                     cols = ygb,
                     lon = -95.7128906, # US longitudinal center
                     lat = 37.0902, # US latitudinal center
                     zoom = 4
) {
  
    # if allowing user to select multiple input data
    # `select` corresponds to `select` in UI above
    filter_field <- enquo(filter_field)
    
    selected_data <- reactive({
      df <- data %>% 
        filter(!!filter_field == input$select)
      return(df)
      
    })
    
    
    # render the map plot based on the selected data
    output$plot <- renderLeaflet({
      
      leaflet(options = leafletOptions(zoomControl = FALSE)) %>%
        addProviderTiles(providers$CartoDB.Positron) %>%
        setView(lon, lat, zoom) %>% 
        addMarkers(selected_data()[[lon_field]],
                   selected_data()[[lat_field]],
                   label = paste(selected_data()[[label_title]],
                                 ": ",
                                 selected_data()[[label_value]],
                                 label_unit)) %>%
        # addLabelOnlyMarkers(
        #   selected_data()[[lon_field]],
        #   selected_data()[[lat_field]],
        #   label = paste(selected_data()[[label_title]], ": ",
        #                  as.character(selected_data()[[label_value]]),
        #                 label_unit),
        #   labelOptions = labelOptions(textsize = "13px")) %>%
        addMinicharts(
          selected_data()[[lon_field]], 
          selected_data()[[lat_field]],
          type = mini_chart,
          chartdata = selected_data()[, categories], 
          colorPalette = cols, 
          width = 60 * sqrt(selected_data()[[chart_width]]) / sqrt(max(selected_data()[[chart_width]])),
          transitionTime = 0)
        
    })
    
  
  
}