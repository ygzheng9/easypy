#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Old Faithful Geyser Data"),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
       sliderInput("bins",
                   "Number of bins:",
                   min = 1,
                   max = 50,
                   value = 30), 
       
       selectInput("dataset", "Choose a dataset:", 
                   choices = c("rock", "pressure", "cars")),
       
       numericInput("obs", "Number of observations to view:", 10), 
       
       selectInput("variable", "Variable:",
                   list("Cylinders" = "cyl", 
                        "Transmission" = "am", 
                        "Gears" = "gear")),
       
       checkboxInput("outliers", "Show outliers", FALSE)
       
    ),
      
    
    # Show a plot of the generated distribution
    mainPanel(
       plotOutput("distPlot"), 
       
       verbatimTextOutput("summary"),
       
       tableOutput("view"),
       
       h3(textOutput("caption")),
       
       plotOutput("mpgPlot")
    
    )
  )
))
