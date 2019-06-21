#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

library(ggplot2)
library(dplyr)
library(ggrepel)

bcl <- read.csv("./data/bcl-data.csv", stringsAsFactors = FALSE)

# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {

    output$distPlot <- renderPlot({

        # generate bins based on input$bins from ui.R
        x    <- faithful[, 2]
        bins <- seq(min(x), max(x), length.out = input$bins + 1)

        # draw the histogram with the specified number of bins
        hist(x, breaks = bins, col = 'darkgray', border = 'white')

    })
###################
    # 根据 ui 生成数据，然后供其他 ui 使用
    filtered <- reactive({
        if (is.null(input$countryInput)) {
            return(NULL)
        }

        bcl %>%
            filter(Price >= input$priceInput[1],
                   Price <= input$priceInput[2],
                   Type == input$typeInput,
                   Country == input$countryInput
            )
    })

    # 动态生成 ui
    output$countryOutput <- renderUI({
        selectInput("countryInput", "Country",
                    sort(unique(bcl$Country)),
                    selected = "CANADA")
    })

    output$coolplot <- renderPlot({
        if (is.null(filtered())) {
            return()
        }

        ggplot(filtered(), aes(Alcohol_Content)) +
            geom_histogram()
    })

    output$results <- renderTable({
        filtered()
    })
#####################
    # 动态生成 ui
    output$slider <- renderUI({
        sliderInput("slider", "Slider", min = 0,
                    max = input$num, value = 0)
    })

#######################
    # 两个 ui element 联动
    observe({
        updateNumericInput(session, "numChanged", value = input$sliderChanged)
    })

#######################
    # file upload
    filedata <- reactive({
        infile <- input$filename
        if (is.null(infile)){
            return(NULL)
        }
        read.csv(infile$datapath,sep = ",", header = T, stringsAsFactors = F)
    })

    #function
    sample_plot <- function(){
        df <- filedata() %>% as.data.frame()
        names(df) <- c("geneid", "log2foldchage", "padj")
        df$padj <- -log10(df$padj)
        df$change <- as.factor(ifelse(df$padj > input$padj & abs(df$log2foldchage) > input$foldchange,
                                      ifelse(df$log2foldchage > input$foldchange,'UP','DOWN'),'NOT'))

        p <- ggplot(data = df, aes(x = log2foldchage, y = padj, color = change)) +
            geom_point(alpha=0.8, size = 1) +
            theme_bw(base_size = 15) +
            theme(
                panel.grid.minor = element_blank(),
                panel.grid.major = element_blank()) +
            scale_color_manual(name = "", values = c("red", "green", "black"), limits = c("UP", "DOWN", "NOT")) +
            geom_hline(yintercept = input$padj, linetype = "dashed", color = "grey", size = 1) +
            geom_vline(xintercept = -input$foldchange, linetype = "dashed", color = "grey", size = 1) +
            geom_vline(xintercept = input$foldchange, linetype = "dashed", color = "grey", size = 1)
        p
    }

    signed_plot <- function(){
        df <- filedata() %>% as.data.frame()
        names(df) <- c("geneid", "log2foldchage", "padj")
        df$padj <- -log10(df$padj)
        df$change <- as.factor(ifelse(df$padj > input$padj & abs(df$log2foldchage) > input$foldchange,
                                      ifelse(df$log2foldchage > input$foldchange,'UP','DOWN'),'NOT'))
        df$sign <- ifelse(df$padj > input$padj & abs(df$log2foldchage) > input$foldchange, df$geneid,NA)

        p <- ggplot(data = df, aes(x = log2foldchage, y = padj, color = change)) +
            geom_point(alpha=0.8, size = 1) +
            theme_bw(base_size = 15) +
            theme(
                panel.grid.minor = element_blank(),
                panel.grid.major = element_blank()) +
            scale_color_manual(name = "", values = c("red", "green", "black"), limits = c("UP", "DOWN", "NOT")) +
            geom_text_repel(aes(label = sign), box.padding = unit(0.2, "lines"), point.padding = unit(0.2, "lines"), show.legend = F, size = 3) +
            geom_hline(yintercept = input$padj, linetype = "dashed", color = "grey", size = 1) +
            geom_vline(xintercept = -input$foldchange, linetype = "dashed", color = "grey", size = 1) +
            geom_vline(xintercept = input$foldchange, linetype = "dashed", color = "grey", size = 1)
        p
    }

    #simple volcano plot
    output$sampleplot <- renderPlot({
        if (!is.null(filedata())){
            sample_plot()
        }
    })

    #signed volcano plot
    output$signplot <- renderPlot({
        if (!is.null(filedata())){
            signed_plot()
        }
    })

    #Download
    output$downloadplot <- downloadHandler(
        filename = function(){
            paste0("volcano", ".png")
        },
        contentType = "image/png",
        content = function(file){
            png(file)
            print(sample_plot())
            dev.off()
        }
    )
})
