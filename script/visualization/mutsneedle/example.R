
### lolipop.R -------------------------
library(magrittr)
library(dplyr)
library(mutsneedle)
library(reshape2)

source('C:/Nima/RCode/packages/master/niragen-master/R/niragen.R')
source('C:/Nima/RCode/packages/master/niravis-master/R/visgen.R')

source('C:/Nima/RCode/packages/master/niravis-master/R/niraPlot.R')
source('C:/Nima/RCode/packages/master/niravis-master/R/jscripts.R')

### Simple dataset:
library(shiny)
library(mutsneedle)
library(htmlwidgets)

shinyApp(
  ui = mutsneedleOutput("id",width=800,height=500),
  server = function(input, output) {
    output$id <- renderMutsneedle(
      data <- exampleMutationData(),
      regiondata <- exampleRegionData(),
      mutsneedle(mutdata=data,domains=regiondata)
    )
  }
)
