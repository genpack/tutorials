### popover.R ------------------------
library(magrittr)
library(shiny)
library(shinyBS)
library(gener)


shinyApp(
  ui =
    fluidPage(
      sidebarLayout(
        sidebarPanel(
          sliderInput("bins",
                      "Number of bins:",
                      min = 1,
                      max = 50,
                      value = 30),
          bsTooltip("bins", "The wait times will be broken into this many equally spaced bins",
                    "right", options = list(container = "body"))
        ),
        mainPanel(
          plotOutput("distPlot")
        )
      )
    ),
  server =
    function(input, output, session) {
      output$distPlot <- renderPlot({
        
        # generate bins based on input$bins from ui.R
        x    <- faithful[, 2]
        bins <- seq(min(x), max(x), length.out = input$bins + 1)
        
        # draw the histogram with the specified number of bins
        hist(x, breaks = bins, col = 'darkgray', border = 'white')
        
      })
      addPopover(session, "distPlot", "Data", content = paste0("
                                                               Waiting time between ",
                                                               "eruptions and the duration of the eruption for the Old Faithful geyser ",
                                                               "in Yellowstone National Park, Wyoming, USA.
                                                               
                                                               Azzalini, A. and ",
                                                               "Bowman, A. W. (1990). A look at some data on the Old Faithful geyser. ",
                                                               "Applied Statistics 39, 357-365.
                                                               
                                                               "), trigger = 'click')
    }
      )




# Option 2: Does not work! Eric said he has fixed it but he has not!!!!!!
# https://github.com/ebailey78/shinyBS/issues/22

library(shiny)
library(shinyBS)
shinyApp(
  ui =
    fluidPage(
      sidebarLayout(
        sidebarPanel(
          sliderInput("bins",
                      "Number of bins:",
                      min = 1,
                      max = 50,
                      value = 30),
          bsTooltip("bins", "The wait times will be broken into this many equally spaced bins",
                    "right", options = list(container = "body"))
        ),
        mainPanel(
          plotOutput("distPlot"),
          bsPopover("distPlot", "Data", content = paste0("
                                                         Waiting time between ",
                                                         "eruptions and the duration of the eruption for the Old Faithful geyser ",
                                                         "in Yellowstone National Park, Wyoming, USA.
                                                         
                                                         Azzalini, A. and ",
                                                         "Bowman, A. W. (1990). A look at some data on the Old Faithful geyser. ",
                                                         "Applied Statistics 39, 357-365.
                                                         
                                                         "), trigger = 'click', options = list(container = "body"))
          
          )
          )
      ),
  server =
    function(input, output, session) {
      output$distPlot <- renderPlot({
        
        # generate bins based on input$bins from ui.R
        x    <- faithful[, 2]
        bins <- seq(min(x), max(x), length.out = input$bins + 1)
        
        # draw the histogram with the specified number of bins
        hist(x, breaks = bins, col = 'darkgray', border = 'white')
        
      })
    }
      )





# Translation to viser:
get.plot = function(bins){
  x    <- faithful[, 2]
  bins <- seq(min(x), max(x), length.out = bins + 1)
  hist(x, breaks = bins, col = 'darkgray', border = 'white')
}

I = list()
I$main     = list(type = 'sidebarLayout', layout.side = 'bins', layout.main = 'distPlot')
I$bins     = list(type = 'sliderInput', title = "Number of bins:", min = 1, max = 50, value = 30, tooltip = 'The wait times will be broken into this many equally spaced bins', tooltip.placement = "right", tooltip.options = list(container = "body"))
I$distPlot = list(type = 'plotOutput', service = 'get.plot(input$bins)', 
                  popover = c(
                    "\n Waiting time between ", "eruptions and the duration of the eruption for the Old Faithful geyser ", 
                    "in Yellowstone National Park, Wyoming, USA.", "", 
                    "Azzalini, A. and ",
                    "Bowman, A. W. (1990). A look at some data on the Old Faithful geyser. ",
                    "Applied Statistics 39, 357-365.", "", ""), 
                  popover.trigger = 'click', popover.title = 'Data')

dash = new('DASHBOARD', items = I, king.layout = list('main'))
shinyApp(dash$dashboard.ui(), dash$dashboard.server())
