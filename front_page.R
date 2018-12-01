frontp = function() 
  
  div(class = "master",
      
      # Create homepage title banner and image
      div(class = "front-banner",
          tags$img(src = "img/home-banner-crop.jpg", style="width:100%"),
          div(class = "content-box", 
              tags$p(class = "text", "Farming our Waters"))
        ),
      
      
      # Home page text
      tags$p(h4("The US Aquaculture Data Explorer lets you directly interact with information from a variety of publicly available sources.")),
      
      div(class = "intro-divider"), 
      
      # Additional information
      tags$p("We strive to provide the most relevant and current information. Sources of aquaculture data include the USDA Quick Stats and NOAA Fish Stats database. Currently you can explore data for US finfish production. We will continue to add to this site over time and welcome any suggestions."),

      
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
