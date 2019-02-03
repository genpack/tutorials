### themeSelector.R -------------------
library(shiny)
library(shinythemes)

shinyApp(
  ui = fluidPage(
    shinythemes::themeSelector(),
    sidebarPanel(
      textInput("txt", "Text input:", "text here"),
      sliderInput("slider", "Slider input:", 1, 100, 30),
      actionButton("action", "Button"),
      actionButton("action2", "Button2", class = "btn-primary")
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Tab 1"),
        tabPanel("Tab 2")
      )
    )
  ),
  server = function(input, output) {}
)


shinyApp(
  ui = tagList(
    shinythemes::themeSelector(),
    navbarPage(
      "Theme test",
      tabPanel("Navbar 1",
               sidebarPanel(
                 textInput("txt", "Text input:", "text here"),
                 sliderInput("slider", "Slider input:", 1, 100, 30),
                 actionButton("action", "Button"),
                 actionButton("action2", "Button2", class = "btn-primary")
               ),
               mainPanel(
                 tabsetPanel(
                   tabPanel("Tab 1"),
                   tabPanel("Tab 2")
                 )
               )
      ),
      tabPanel("Navbar 2")
    )
  ),
  server = function(input, output) {}
)



