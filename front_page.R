frontp = function() 
  
  div(class = "master",
      
      # Create homepage title banner and image
      div(class = "front-banner",
          tags$img(src = "img/home-banner-crop.jpg", title = "Photo by Charlotte Coneybeer on Unsplash", style="width:100%"),
          div(class = "content-box", 
              tags$p(class = "text", "Farming our Waters"))
        ),
      
      
      # Home page text
      tags$p(h4("The California Aquaculture Data Explorer lets you directly interact with information from a variety of publicly available sources.")),
      
      div(class = "intro-divider"), 
      
      # Additional information
      tags$p("This project strives to provide the most relevant and accurate information. Sources of aquaculture data include the US Department of Agriculture Quick Stats and the NOAA Fisheries Statistics Cumulative Trade database. Currently you can explore data on what California is farming and importing. Data will continuously be added to this site over time!"),
      
      tags$p("Contact",
             tags$a(href="https://iwensu0313.github.io", "Iwen Su"), 
             "with any questions or feedback. For US-specific data, check out the",
             tags$a(href="https://iwensu.shinyapps.io/us-aqculture-data", "US Aquaculture Dashboard.")),
      
      # Two hyperlink boxes: more info
      div(class = "box-con",
          
          tags$a(target = "_blank",
                 href = "https://aquaculturematters.ca.gov/",
                 div(class = "float box box-more",
                     tags$p(class = "intro-text", "Stay Up to Date"),
                     tags$p("Why aquaculture matters.")
                     )),
          
          tags$a(target = "_blank",
                 href = "https://conversationaboutaquaculture.weebly.com/",
                 div(class = "float box box-rear",
                     tags$p(class = "intro-text", "Getting Started"),
                     tags$p("Presentations from leading researchers and industry experts on current trends in aquaculture.") 
                     ))
          )
      )

       
