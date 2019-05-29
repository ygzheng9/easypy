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
    titlePanel("出库数据分析"),

    sidebarLayout(
        sidebarPanel(
            width = 3,

            selectInput("year", h3("年份"),
                        choices = list("2016" = "YR2016", "2017" =  "YR2017")),

            selectInput("treemap_type", h3("显示类型"),
                        choices = list("按经销商数量" = "1", "按出库量差异" = "2")),

            uiOutput("selectProvince")
        ),

        mainPanel(
            plotOutput("treePlot", click = "tree_click"),

            br(),

            h2(textOutput("selected_province")),
            plotOutput("barPlot", height = "auto")
        )
    )

))
