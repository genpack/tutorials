
# server.R:

library(datasets)
library(shiny)
library(googleVis)

shinyServer(function(input, output){
  myOptions <- reactive({
    list(
      page = ifelse(input$pageable == TRUE, 'enable', 'disable'),
      pagesize = input$pagesize,
      height = 400
    )
  })
  output$myTable <- renderGvis({gvisTable(Population[,1:5], options = myOptions())})
})
