#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

library(shinythemes)

# Define UI for application that draws a histogram
shinyUI(
    fluidPage(
        tabsetPanel(
            tabPanel("Tab 1",
                     fluidPage(
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

                                 br(),

                                 sliderInput("priceInput", "Price", 0, 100, c(25, 40), pre = "$"),

                                 radioButtons("typeInput", "Product type",
                                              choices = c("BEER", "REFRESHMENT", "SPIRITS", "WINE"),
                                              selected = "WINE"),

                                 # selectInput("countryInput", "Country",
                                 #             choices = c("CANADA", "FRANCE", "ITALY")),
                                 # 根据 dataframe 创建下拉可选项
                                 uiOutput("countryOutput"),

                                 br(),
                                 numericInput("num", "Maximum slider value", 5),
                                 uiOutput("slider"),

                                 ## conditional ui
                                 numericInput("numCond", "Number", 5, 1, 10),
                                 conditionalPanel(
                                     condition = "input.numCond >=5",
                                     h3("Hello!")
                                 )
                             ),

                             # Show a plot of the generated distribution
                             mainPanel(
                                 plotOutput("distPlot"),

                                 br(),

                                 plotOutput("coolplot"),
                                 br(), br(),
                                 tableOutput("results")
                             )
                         )
                     )
            ),
            tabPanel("Tab 2", fluidPage(
                sliderInput("sliderChanged", "Move me", value = 5, 1, 10),
                numericInput("numChanged", "Number", value = 5, 1, 10)
            )),
            tabPanel("Volcano", fluidPage(
                # Choose a theme
                theme = shinytheme("readable"),

                # Application title
                titlePanel("A quick view of volcano plot"),

                # Sidebar for number of class outputs :
                # Input file; Threshold of foldchange and p.adj
                sidebarPanel(
                    row = 2,

                    #    textInput("txt", "Text input:", "text here"),
                    fileInput("filename",
                              "Choose File to Upload:",
                              accept = c(".csv")),
                    hr(),
                    numericInput("foldchange",
                                 label = "Threshold of foldchage is:",
                                 value = 1,
                                 min = 0,
                                 max = 5),
                    numericInput("padj",
                                 label = "Threshold of p.adj is:",
                                 value = 2,
                                 min = 0,
                                 max = 100),
                    hr(),
                    submitButton("Update View")
                ),

                # Tab1 for sample plot, Tab2 for lable plot
                mainPanel(
                    tabsetPanel(
                        tabPanel("Tab 1",
                                 fluidRow(
                                     column(width = 10, plotOutput("sampleplot", height = 500)),
                                     column(width = 2,
                                            downloadButton("download_plot",label = "Download Volcano Plot")
                                     )
                                 )),
                        tabPanel("Tab 2",
                                 fluidRow(
                                     column(width = 11,
                                            plotOutput("signplot", height = 500)
                                     )
                                 ))
                    )
                )
            ))
        )
    )
)
