# ui.R
ui = shinyUI(pageWithSidebar(
  headerPanel("googleVis on Shiny"),
  sidebarPanel(
    selectInput("dataset", "Choose a dataset:",
                choices = c("rock", "pressure", "cars"))
  ),
  mainPanel(
    htmlOutput("view")
  )
))
## End(Not run)

#g = gvisScatterChart(rock, options=list(title=paste('Data:','rock')))
#plot(g)
