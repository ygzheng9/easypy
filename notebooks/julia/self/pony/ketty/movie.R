library(shiny)
library(ggplot2)
library(dplyr)
library(DT)
library(readr)

# load(url("http://s3.amazonaws.com/assets.datacamp.com/production/course_4850/datasets/movies.Rdata"))

load("./movies.Rdata")

# Define UI for application that plots features of movies
ui <- fluidPage(

  br(),

  # Sidebar layout with a input and output definitions
  sidebarLayout(
    # Inputs
    sidebarPanel(
      # Select variable for y-axis
      selectInput(inputId = "y", label = "Y-axis:",
                  choices = c("imdb_rating", "imdb_num_votes", "critics_score", "audience_score", "runtime"),
                  selected = "audience_score"),

      # Select variable for x-axis
      selectInput(inputId = "x", label = "X-axis:",
                  choices = c("imdb_rating", "imdb_num_votes", "critics_score", "audience_score", "runtime"),
                  selected = "critics_score"),

      # Select filetype
      radioButtons(inputId = "filetype",
                   label = "Select filetype:",
                   choices = c("csv", "tsv"),
                   selected = "csv"),

      # Select variables to download
      checkboxGroupInput(inputId = "selected_var",
                  label = "Select variables:",
                  choices = names(movies),
                  selected = c("title"))
    ),

    # Output:
    mainPanel(
      downloadButton(outputId = "download_data", label = "Download data"),

      # Show scatterplot with brushing capability
      # plotOutput(outputId = "scatterplot", brush = "plot_brush"),
      plotOutput(outputId = "scatterplot", hover = "plot_hover"),

      # Show data table
      dataTableOutput(outputId = "moviestable"),
      br(),

      textOutput(outputId = "avg_x"), # avg of x
      textOutput(outputId = "avg_y"), # avg of y
      verbatimTextOutput(outputId = "lmoutput"), # regression output

      br(),

      htmlOutput(outputId = "avgs")
    )
  )
)

# Define server function required to create the scatterplot
server <- function(input, output) {

  # Create scatterplot object the plotOutput function is expecting
  output$scatterplot <- renderPlot({
    ggplot(data = movies, aes_string(x = input$x, y = input$y)) +
      geom_point()
  })

  # Create data table
  # output$moviestable <- DT::renderDataTable({
  #   brushedPoints(movies, brush = input$plot_brush) %>%
  #     select(title, audience_score, critics_score)
  # })

    output$moviestable <- DT::renderDataTable({
      nearPoints(movies, coordinfo = input$plot_hover) %>%
        select(title, audience_score, critics_score)
  })

  # Calculate average of x
  output$avg_x <- renderText({
    avg_x <- movies %>% pull(input$x) %>% mean() %>% round(2)
    paste("Average", input$x, "=", avg_x)
  })

  # Calculate average of y
  output$avg_y <- renderText({
    avg_y <- movies %>% pull(input$y) %>% mean() %>% round(2)
    paste("Average", input$y, "=", avg_y)
  })

  # Create regression output
  output$lmoutput <- renderPrint({
    x <- movies %>% pull(input$x)
    y <- movies %>% pull(input$y)
    summ <- summary(lm(y ~ x, data = movies))
    print(summ, digits = 3, signif.stars = FALSE)
  })

  output$avgs <- renderUI({
    avg_x <- movies %>% pull(input$x) %>% mean() %>% round(2)
    avg_y <- movies %>% pull(input$y) %>% mean() %>% round(2)
    HTML(
      paste("Average", input$x, "=", avg_x),
      "<br/>",
      paste("Average", input$y, "=", avg_y)
    )
  })

  # Download file
  output$download_data <- downloadHandler(
    filename = function() {
      paste0("movies.", input$filetype)
      },
    content = function(file) {
      if(input$filetype == "csv"){
        write_csv(movies %>% select(input$selected_var), path = file)
        }
      if(input$filetype == "tsv"){
        write_tsv(movies %>% select(input$selected_var), path = file)
        }
    }
  )

}


# Create a Shiny app object
shinyApp(ui = ui, server = server, options=list(port=8899))