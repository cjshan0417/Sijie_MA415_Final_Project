
# MA415 Final Project: Visualizing Twitter Using Shiny
# Date: Dec. 12, 2017
# Author: CJ/Sijie Shan

### Shiny app

shinyUI(fluidPage(
  titlePanel("Settings"),
  
  # progress indicator
  sidebarLayout(
    sidebarPanel(
      tags$style(type = "text/css", "
           #loadmessage {
             position: fixed;
             top: 0px;
             left: 0px;
             width: 100%;
             padding: 5px 0px 5px 0px;
             text-align: center;
             font-weight: bold;
             font-size: 100%;
             color: #000000;
             background-color: #338BFF;
             z-index: 105;
            }
                 "),
      conditionalPanel(condition = "$('html').hasClass('shiny-busy')",
                       tags$div("Loading...",id = "loadmessage")
                       ),
      
      # slider to control frequency
      sliderInput("min_freq",
                  "Minimum Frequency:",
                  min = 3,
                  max = 20,
                  value = 5
                  ),
      
      # input box for new twitter account
      textInput("new_user_id",
                "Enter a Twitter User Name:", 
                value = "", width = NULL, 
                placeholder = "e.g., @BarackObama"
                ),
      
      # action button to rerun script
      actionButton(inputId = "refresh",
                   label = "Refresh", 
                   icon = icon("fa fa-refresh")
                   )
      ),
    
    # title
    mainPanel(
      h2(textOutput("user_id")),
      plotOutput("word_cloud")
    )
  )
))
