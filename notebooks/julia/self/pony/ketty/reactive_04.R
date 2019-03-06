library(shiny)
library(ggplot2)
library(dplyr)
library(tools)

# load(url("http://s3.amazonaws.com/assets.datacamp.com/production/course_4850/datasets/movies.Rdata"))
load("./movies.Rdata")


# UI
ui <- fluidPage(
  sidebarLayout(

    # Input
    sidebarPanel(

      # Numeric input for number of rows to show
      numericInput(inputId = "n_rows",
                   label = "How many rows do you want to see?",
                   value = 10),

      # Action button to show
      actionButton(inputId = "button",
                   label = "Show")

    ),

    # Output:
    mainPanel(
      tableOutput(outputId = "datatable")
    )
  )
)

# Define server function required to create the scatterplot-
server <- function(input, output, session) {

  # Print a message to the console every time button is pressed
  # 在 console 中有输出，这是副作用
  # 没有返回值
  observeEvent(input$button, {
    cat("Showing", input$n_rows, "rows\n")
  })

  # Take a reactive dependency on input$button, but not on any other inputs
  #  reactive({ ... }) 只能定义对 值 的依赖，比如：下拉框选中值，inputValue；
  #  eventReactive({ ... }) 从名字可以看出，是对 event 的依赖，所以第一个参数是 button
  #  都有返回值
  df <- eventReactive(input$button, {
    head(movies, input$n_rows)
  })

  output$datatable <- renderTable({
    df()
  })

}

# Create a Shiny app object
shinyApp(ui = ui, server = server, options=list(port=8899))