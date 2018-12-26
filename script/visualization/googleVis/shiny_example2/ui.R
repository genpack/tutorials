# ui.R:

library(shiny)
library(googleVis)

shinyUI(pageWithSidebar(
  headerPanel("Example 2: pageable Table"),
  sidebarPanel(
    checkboxInput(inputId = 'pageable', label = "pageable"),
    conditionalPanel("input.pageable == True", 
                     numericInput(inputId = 'pagesize', 
                                  label = 'Countries per page', 10))
  ), 
  mainPanel(
    htmlOutput("myTable")
  )
))
