# ui.R

require(googleVis)
shinyUI(pageWithSidebar(
  headerPanel("", windowTitle = "Example 4: GoogleVis with Interaction"),
  sidebarPanel(
    tags$head(tags$style(type = 'text/css', "#selected{ display:none; }")),
    selectInput("dataset", "Choose a dataset:", 
                choices = c("pressure", "cars")),
    uiOutput("selectedOut")
  ),
  mainPanel(tabsetPanel(
    tabPanel("Main",
             htmlOutput("view"),
             plotOutput("distPlot", width = "300px", height = "200px")),
    tabPanel("About", includeMarkdown('README.md'))
  ))  
))
