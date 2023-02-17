library(shiny)
library(htmlwidgets)
library(D3TableFilter)
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
    
    d3tf(mtcars,
         tableProps = tableProps,
         extensions = list(
           list(name = "sort")
         ),
         showRowNames = TRUE,
         tableStyle = "table table-bordered");
  })
})


runApp(list(ui=ui,server=server))