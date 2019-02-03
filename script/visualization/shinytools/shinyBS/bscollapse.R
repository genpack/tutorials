### bscollapse.R ------------------------
library(shiny)
library(shinyBS)

shinyApp(
  ui =
    fluidPage(
      sidebarLayout(
        sidebarPanel(HTML("This button will open Panel 1 using updateCollapse."),
                     actionButton("p1Button", "Push Me!"),
                     selectInput("styleSelect", "Select style for Panel 1",
                                 c("default", "primary", "danger", "warning", "info", "success"))
        ),
        mainPanel(
          bsCollapse(id = "collapseExample", open = "Panel 2",
                     bsCollapsePanel("Panel 1", "This is a panel with just text ",
                                     "and has the default style. You can change the style in ",
                                     "the sidebar.", style = "info"),
                     bsCollapsePanel("Panel 2", "This panel has a generic plot. ",
                                     "and a 'success' style.", plotOutput("genericPlot"), style = "success")
          )
        )
      )
    ),
  server =
    function(input, output, session) {
      output$genericPlot <- renderPlot(plot(rnorm(100)))
      observeEvent(input$p1Button, ({
        updateCollapse(session, "collapseExample", open = "Panel 1")
      }))
      observeEvent(input$styleSelect, ({
        updateCollapse(session, "collapseExample", style = list("Panel 1" = input$styleSelect))
      }))
    }
)


# Translation to viser:

I = list()
I$main            = list(type = 'sidebarLayout', layout.side = c('htmlText', 'p1Button', 'styleSelect'), layout.main = 'collapseExample')
I$htmlText        = list(type = 'static' , object = HTML("This button will open Panel 1 using updateCollapse."))
I$p1Button        = list(type = 'actionButton', title = "Push Me!", service = "updateCollapse(session, 'collapseExample', open = 'Panel 1')")
I$styleSelect     = list(type = 'selectInput' , title = "Select style for Panel 1", choices = c("default", "primary", "danger", "warning", "info", "success"), 
                         service = "updateCollapse(session, 'collapseExample', style = list('Panel 1' = input$styleSelect))")
I$collapseExample = list(type = 'bsCollapse', open = "Panel 2", layout = c('panel1', 'panel2'))
I$panel1          = list(type = 'bsCollapsePanel', title = 'Panel 1', style = "info", layout = 'text1')
I$panel2          = list(type = 'bsCollapsePanel', title = 'Panel 2', style = "success", layout = c('text2', 'genericPlot'))
I$text1           = list(type = 'static', object = "This is a panel with just text and has the default style. You can change the style in the sidebar")
I$text2           = list(type = 'static', object = "This panel has a generic plot and a 'success' style.")
I$genericPlot     = list(type = 'plotOutput', service = "plot(rnorm(100))", width = '100%', height = '400px')

dash = new('DASHBOARD', items = I, king.layout = list('main'))
shinyApp(dash$dashboard.ui(), dash$dashboard.server())

