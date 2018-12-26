# server.R
library(googleVis)
library(shiny)

shinyServer(function(input, output) {
  
  n = 100 
  dates = seq(Sys.Date(), by = 'day', length = n)
  x = 10 * rnorm(n)
  y = 3 * x + 1 + rnorm(n)
  label = rep(LETTERS[1:4], each=25)
  label[1] = "D"
  
  my.data = data.frame(Date = dates, x, y, label)
  
  output$view <- renderGvis({
    gvisMotionChart(my.data, 
                    idvar ='label', 
                    xvar = 'x', 
                    yvar = 'y', 
                    timevar= 'Date')
  })
  
})
