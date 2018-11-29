library(shiny)
library(shinydashboard)

tab_title_ui <- function(title, 
                         lead,
                         subtitle,
                         description) {
  
  fluidRow(box(
    h1(strong(title)),
    tags$div(class = "title_section", h3(lead)),
    tags$br(),
    h4(paste(subtitle)),
    tags$i(description),
    width = 12)
  )
  
}