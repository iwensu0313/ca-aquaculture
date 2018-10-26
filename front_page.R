frontp = function() 
  
  div(class = "master",
      
      # Create homepage title banner and image
      div(class = "front-banner",
          tags$img(src = "img/home-banner-crop.jpg", style="width:100%"),
          div(class = "content-box", 
              tags$p(class = "text", "Farming the Ocean"))
        ),
      
      
      # Home page text
      tags$p(h4("Cultivating food from the nutrient-rich waters of California.")),
      
      div(class = "intro-divider"), 
      
      # Additional information
      tags$p("Aquaculture is gaining popularity with the new generation. "),
      
      tags$p("Currently, you can explore data for global mariculture production."),
      
      # Two hyperlink boxes: more info
      div(class = "box-con",
          
          tags$a(target = "_blank",
                 href = "https://aquaculturematters.ca.gov/",
                 div(class = "float box box-more",
                     tags$p(class = "intro-text", "Stay Up to Date"),
                     tags$p("Why aquaculture matters.")
                     )),
          
          tags$a(target = "_blank",
                 href = "https://www.greenwave.org/california-permitting-analysis/",
                 div(class = "float box box-rear",
                     tags$p(class = "intro-text", "Getting Started"),
                     tags$p("GreenWave has outlined the permitting process for setting up an ocean farm in California.") 
                     ))
          )
      )
