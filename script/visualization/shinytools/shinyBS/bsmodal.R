### bsmodal.R ------------------------
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
          actionButton("tabBut", "View Table")
        ),
        
        mainPanel(
          plotOutput("distPlot"),
          bsModal("modalExample", "Data Table", "tabBut", size = "large",
                  dataTableOutput("distTable"))
        )
      )
    ),
  server =
    function(input, output, session) {
      
      output$distPlot <- renderPlot({
        
        x    <- faithful[, 2]
        bins <- seq(min(x), max(x), length.out = input$bins + 1)
        
        # draw the histogram with the specified number of bins
        hist(x, breaks = bins, col = 'darkgray', border = 'white')
        
      })
      
      output$distTable <- renderDataTable({
        
        x    <- faithful[, 2]
        bins <- seq(min(x), max(x), length.out = input$bins + 1)
        
        # draw the histogram with the specified number of bins
        tab <- hist(x, breaks = bins, plot = FALSE)
        tab$breaks <- sapply(seq(length(tab$breaks) - 1), function(i) {
          paste0(signif(tab$breaks[i], 3), "-", signif(tab$breaks[i+1], 3))
        })
        tab <- as.data.frame(do.call(cbind, tab))
        colnames(tab) <- c("Bins", "Counts", "Density")
        return(tab[, 1:3])
        
      }, options = list(pageLength=10))
      
    }
)

# Translation to viser:

I = list()
I$main     = list(type = 'sidebarLayout', layout.side = c('bins', 'tabBut'), layout.main = c('distPlot', 'modalExample'))
I$bins     = list(type = 'sliderInput' , title = "Number of bins:", min = 1, max = 50, value = 30)
I$tabBut   = list(type = 'actionButton', title = "View Table")
I$distPlot = list(type = 'plotOutput', service = 'get.plot(input$bins)')
I$modalExample = list(type = 'bsModal', title = 'Data Table', trigger = "tabBut", size = "large", layout = 'distTable')
I$distTable = list(type = 'dataTableOutput', service = 'get.dt(input$bins)', options = list(pageLength=10), width = '100%')

get.dt = function(bins){
  x    <- faithful[, 2]
  bins <- seq(min(x), max(x), length.out = bins + 1)
  
  # draw the histogram with the specified number of bins
  tab <- hist(x, breaks = bins, plot = FALSE)
  tab$breaks <- sapply(seq(length(tab$breaks) - 1), function(i) {
    paste0(signif(tab$breaks[i], 3), "-", signif(tab$breaks[i+1], 3))
  })
  tab <- as.data.frame(do.call(cbind, tab))
  colnames(tab) <- c('Bins', 'Counts', 'Density')
  return(tab[, 1:3])
}

get.plot = function(bins){
  x    <- faithful[, 2]
  bins <- seq(min(x), max(x), length.out = bins + 1)
  
  # draw the histogram with the specified number of bins
  hist(x, breaks = bins, col = 'darkgray', border = 'white')
}

dash = new('DASHBOARD', items = I, king.layout = list('main'))
shinyApp(dash$dashboard.ui(), dash$dashboard.server())
