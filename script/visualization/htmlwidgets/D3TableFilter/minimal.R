### minimal.R ------------------------
# https://github.com/ThomasSiegmund/D3TableFilter
# --------------------------------------------------------
# Minimal shiny app demonstrating the D3TableFilter widget

library(shiny)
library(htmlwidgets)
library(D3TableFilter)
library(magrittr)
library(dplyr)

source('C:/Nima/R/projects/libraries/developing_packages/niragen.R')
source('C:/Nima/R/projects/libraries/developing_packages/linalg.R')
source('C:/Nima/R/projects/libraries/developing_packages/visgen.R')

source('C:/Nima/R/projects/libraries/developing_packages/d3TableFilter.R')

data(mtcars)

# ui.R
# --------------------------------------------------------
ui <- shinyUI(fluidPage(
  title = 'Basic usage of D3TableFilter in Shiny',
  fluidRow(
    column(width = 12, d3tfOutput('mtcars'))
  )
))

# server.R
# --------------------------------------------------------
server <- shinyServer(function(input, output, session) {
  output$mtcars <- renderD3tf({
    
    # Define table properties. See http://tablefilter.free.fr/doc.php
    # for a complete reference
    tableProps <- list(
      btn_reset = TRUE,
      # alphabetic sorting for the row names column, numeric for all other columns
      col_types = c("string", rep("number", ncol(mtcars)))
    );
    
    # d3tf(mtcars,
    #      tableProps = tableProps,
    #      extensions = list(
    #        list(name = "sort")
    #      ),
    #      showRowNames = TRUE,
    #      tableStyle = "table table-bordered");
    mtcars %>% D3TableFilter.table(tableProps = tableProps,
                                   extensions = list(
                                     list(name = "sort")
                                   ),
                                   config = list(withRowNames = TRUE),
                                   tableStyle = "table table-bordered")
  })
})


runApp(list(ui=ui,server=server))