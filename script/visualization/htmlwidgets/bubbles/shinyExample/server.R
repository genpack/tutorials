### shiny/server.R ------------------------------------
library(bubbles)
library(dplyr)
library(shinySignals)

function(input, output, session) {
  output$bubbles <- renderBubbles({b})
  output$bubbles2 <- renderBubbles({b2})
  output$summary <- renderPrint({paste(input$bubbles_click, input$bubbles2_click)})
}
