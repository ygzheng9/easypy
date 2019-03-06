library(shiny)

ui <- fluidPage(
  h1("Example app 4"),
  sidebarLayout(
    sidebarPanel(
      actionButton("rnorm", "Normal"),
      actionButton("runif", "Uniform")
    ),
    mainPanel(
      plotOutput("plot")
    )
  )
)

server <- function(input, output, session) {
  # Assignment: When "rnorm" button is clicked, the plot should
  # show a new batch of rnorm(100). When "runif" button is clicked,
  # the plot should show a new batch of runif(100).
  
  rv <- reactiveValues(data = rnorm(100))
  
  observeEvent(input$rnorm, {
    rv$data <- rnorm(100)
  })
  
  observeEvent(input$runif, {
    rv$data <- runif(100)
  })
  
  
  output$plot <- renderPlot({
      hist(rv$data)
  })
}

shinyApp(ui, server)
