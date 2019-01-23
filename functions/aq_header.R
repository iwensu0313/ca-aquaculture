
## Custom Header for CA Aquaculture Dashboard
## Note to self: header created in Word (aq_header_shiny.docx)
aq_header =
  ## Adds a basic header, that will only display
  ##  if the page is not embedded as an iframe.
  function() div(id = "aq-header",
                 div(class = "aq-brand",
                     tags$a(class = "aq-brand", href = "https://iwensu0313.github.io",
                            title = "Shiny by Iwen Su",
                            tags$img(src = "aq-header.jpg",
                                     alt = "Dashboard by Iwen Su"))
                 )
  )