### basic.R ------------------------
# https://thomassiegmund.shinyapps.io/basic/

library(magrittr)
library(dplyr)
source('C:/Nima/R/projects/libraries/developing_packages/niragen.R')
source('C:/Nima/R/projects/libraries/developing_packages/visgen.R')



# Define table properties. See http://tablefilter.free.fr/doc.php
# for a complete reference
tableProps <- list(
  btn_reset = TRUE,
  sort = TRUE,
  sort_config = list(
    # alphabetic sorting for the row names column, numeric for all other columns
    sort_types = c("String", rep("Number", ncol(mtcars)))
  )
);

tbl <- 
  d3tf(mtcars,
       tableProps = tableProps,
       showRowNames = TRUE,
       tableStyle = "table table-bordered")

# Translation:

tbl = mtcars %>% arrange(cyl, disp) %>% D3TableFilter.table(label = names(mtcars) %>% as.list)

### server.R ------------------------
# --------------------------------------------------------
# Minimal shiny app demonstrating the D3TableFilter widget
# server.R
# --------------------------------------------------------
library(shiny)
library(htmlwidgets)
library(D3TableFilter)

data(mtcars);

shinyServer(function(input, output, session) {
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
    #       list(name = "sort")
    #      ),
    #      showRowNames = TRUE,
    #      tableStyle = "table table-bordered");
    tbl
  })
})

### ui.R ------------------------
# Shiny app to show the table:

# --------------------------------------------------------
# Minimal shiny app demonstrating the D3TableFilter widget
# ui.R
# --------------------------------------------------------
# --------------------------------------------------------
library(shiny)
library(htmlwidgets)
library(D3TableFilter)

shinyUI(fluidPage(
  title = 'Basic usage of D3TableFilter in Shiny',
  fluidRow(
    column(width = 12, d3tfOutput('mtcars', height = "auto"))
  )
))

