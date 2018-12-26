# ui.R

library(googleVis)
library(shiny)

shinyUI(fluidPage(
  titlePanel(" Tool"),
  sidebarLayout(
    sidebarPanel(
      radioButtons(inputId="choice", label="What would you like to see?", 
                   choices= c("Overall ","Individual"))
    ),
    mainPanel(
      htmlOutput("view")
      
    )
  )
))
