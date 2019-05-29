#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

library(tidyverse)
library(readxl)
library(treemapify)

rm(list = ls())

# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {

    # 读取原始数据
    df1 <- loadRawData(filePath = "./data/pd_sales.xlsx")

    # 按年份过滤
    dtl_byYear <- reactive({
        # 在 selectinput 设置的 value 要和 df 中列的值一致
        df2 <- df1 %>%
            filter(year == input$year)

        df2
    })

    # 把省一级的数据准备好
    # 根据用户选择的年份，过滤数据
    by_province <- reactive({
        # 按照 level1 汇总
        df2 <- dtl_byYear()  %>%
            group_by(level1) %>%
            summarise(
                n = n(),
                total_qty = sum(qty),
                score = myScore(qty)
            ) %>%
            arrange(desc(total_qty))

        ## 省公司
        # 拼接字符串-出库量: 四川 330
        df2$msg <- paste(df2$level1, sprintf("%6.2f", df2$total_qty))

        # 拼接字符串-销售差异：四川 3.48
        df2$msg2 <- paste(df2$level1, sprintf("%4.2f ", df2$score))

        df2
    })

    # 根据 df 的某一列，加载 selection 的可选项
    output$selectProvince <- renderUI(
        selectInput("province", h3("选择区域"),
                    choices = as.character(unique(unlist(by_province()$level1))))
    )

    # 计算 treemap 的坐标，注意，这里 area 要和 treemap 的设置完全一样
    tmapCoords <- reactive({
        treemapify(by_province(), area = "total_qty",
                   xlim = c(0, 1), ylim = c(0, 1))
    })

    # 绘制省级的 teeemap
    output$treePlot <- renderPlot({
        req(input$treemap_type)

        if (input$treemap_type == "1") {
            # 省公司的 treemap
            # 按照经销商数量
            drawTreemap1(by_province())
        } else {
            # 按销量差异
            drawTreemap2(by_province())
        }
    })

    # 获取点击 treemap 的省份，更新 下拉框 中选中项
    # observeEvent 没有返回值，而 eventReactive 返回一个 reactive
    observeEvent(input$tree_click, {
        s <- tmapCoords() %>%
                 filter(xmin < input$tree_click$x) %>%
                 filter(xmax > input$tree_click$x) %>%
                 filter(ymin < input$tree_click$y) %>%
                 filter(ymax > input$tree_click$y)

         if (nrow(s) == 0) {
             return
         }

         province <- s[1]$level1

         # 更新下拉框中选中项，后续都是依赖与 下拉框的选中项 更新水平的柱状图
         updateSelectInput(session, "province", selected = province)
    })

    # 显示当前选中的省份
    output$selected_province <- renderText({
        return(input$province)
    })

    # 根据 select 中选中的省份，计算其下城市数量，返回图形的高度
    city_height <- reactive({
        req(input$province)

        # 显示省公司下面的市信息
        df3 <- dtl_byYear() %>%
            filter(level1 == input$province)

        n <- nrow(df3)
        if (n < 3) {
            n = 5
        }

        n * 12
    })

    output$barPlot <- renderPlot({
        req(input$province)

        # 显示省公司下面的市信息
        df3 <- dtl_byYear() %>%
            filter(level1 == input$province)

        drawBar(df3, "地区",  "reorder(level2, qty)", "出库量",  "qty")
    }, height = city_height, units="px")
})


#################################################

# 读取本地 excel，格式固定
loadRawData <- function(filePath) {
    # read from excel file
    df <-  read_excel(filePath, sheet = "Sheet1")

    # 只保留需要的列
    df <- subset(df, select = c(level1, level2, YR2016, YR2017))

    # 原本两列表示两年，转成两行
    df2 <- gather(df, key="year", value="qty", -level1, -level2)

    # 转换成数字
    df2$qty = as.numeric(df2$qty)

    return(df2)
}

# 每个区域：第一名量 / 第二名
myScore <-  function(x) {
    s <- sort(x, decreasing = TRUE)
    num <- length(s)

    if (num <= 1) {
        1
    } else if (num >= 2) {
        s[1L] / s[2L]
    }
}

# barchar order by yQty desc
# usage: drawBar(df2, "省份", "reorder(level1, -QTY2)", "出库量", "QTY2")
drawBar <- function(df, labx, xName, laby, yQty, hLayout = TRUE) {
    font <- "MicrosoftYaHei"

    # use string for column name
    p <- ggplot(df, aes_string(x=xName, y = yQty)) +
        geom_bar(stat='identity', fill='dodgerblue') +
        scale_y_continuous(expand = expand_scale(mult = c(0, .05))) +
        theme_bw() +
        theme(
            text = element_text(family = font),
            # plot.title = element_text(size=26, face="bold", hjust=0, color="#666666"),
            axis.title = element_text(size=10,  face="bold", color="#666666"),
            # axis.title.y = element_text(angle=0, vjust = 0.5),
            axis.text.x = element_text(size=6,  face="bold", color="#666666"),
            legend.title = element_text(size=8),
            legend.text = element_text(size=6),
            legend.position = "bottom") +
        xlab(labx) + ylab(laby)

    if (hLayout) {
        p <- p + coord_flip()
    }

    return(p)
}

# treemap for single level
# 按经销商数量
drawTreemap1 <- function(df) {
    font <- "MicrosoftYaHei"

    ggplot(df, aes(area = total_qty, fill = n, label = msg)) +
        geom_treemap() +
        geom_treemap_text(colour = "black", place = "center", reflow = T,
                          padding.x = grid::unit(1.5, "mm"),  padding.y = grid::unit(2, "mm"),
                          alpha = .6,
                          fontface = "italic", family = font) +
        theme(text = element_text(family = font),
              legend.title = element_text(size = 8, family = font)) +
        scale_fill_distiller("经销商数量", palette = "Greens", direction = 1)
}

# 按销量差异占比
drawTreemap2 <- function(df) {
    font <- "MicrosoftYaHei"

    ggplot(df, aes(area = total_qty, fill = score, label = msg2)) +
        geom_treemap() +
        geom_treemap_text(colour = "black", place = "center", reflow = T,
                          padding.x = grid::unit(1.5, "mm"),  padding.y = grid::unit(2, "mm"),
                          alpha = .6,
                          fontface = "italic", family = font) +
        theme(text = element_text(family = font),
              legend.title = element_text(size = 8, family = font)) +
        scale_fill_distiller("出库量差异", palette = "YlOrRd", direction = 1)
}

