library(shiny)

ui <- fluidPage(
  sidebarLayout(
    sidebarPanel(
      selectInput("xcol", "X variable", names(iris)),
      selectInput("ycol", "Y variable", names(iris), names(iris)[2]),
      numericInput("rows", "Rows to show", 10)
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Data", br(),
          tableOutput("table")
        ),
        tabPanel("Summary", br(),
          verbatimTextOutput("dataInfo"),
          verbatimTextOutput("modelInfo")
        ),
        tabPanel("Plot", br(),
          plotOutput("plot")
        )
      )
    )
  )
)

server <- function(input, output, session) {
  # Assignment: Remove duplication of `selected` and `model`
  # code/calculations.
  
  selected <- reactive({
    iris[, c(input$xcol, input$ycol)]
  })
  
  output$plot <- renderPlot({
    model <- lm(paste(input$ycol, "~", input$xcol), selected())
    
    plot(selected)
    abline(model)
  })
  
  output$modelInfo <- renderPrint({
    model <- lm(paste(input$ycol, "~", input$xcol), selected())
    
    summary(model)
  })
  
  output$dataInfo <- renderPrint({
    summary(selected())
  })
  
  output$table <- renderTable({
    head(selected(), input$rows)
  })
}

shinyApp(ui, server)
