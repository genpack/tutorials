### shinyWidget spinner example ------------------------
library(shiny)
library(shinyWidgets)
library(rvis)

spinner = c('circle', 'bounce', 'folding-cube', 'rotating-plane', 'cube-grid', 'fading-circle', 'double-bounce', 'dots', 'cube')
spinclr = c("#E41A1C", "#FFFF33", "#377EB8", "#A65628", "#4DAF4A", "#F781BF", "#984EA3", "#999999", "#FF7F00")
II = list()
# Containers:
II$main  = list(type = 'fluidPage', layout = list('head1', 'refresh1', list('plot' %>% paste0(2*0:4+1), 'plot' %>% paste0(2*1:4)), 'refresh2'))
# Inputs:
for(i in paste0('refresh', 1:2)){II[[i]] = list(type = 'actionButton', title = 'Refresh', width = "100%")}
# Outputs:
for(i in 1:9){II[[paste0('plot', i)]] = list(type = 'plotOutput', spinner = spinner[i], spinner.color = spinclr[i], service = paste("input$refresh", "input$refresh2", "Sys.sleep(1)", "Sys.time()", "plot(sin, -pi, ", sep = '\n') %>% paste0(i, "*pi)"))}
II$head1 = list(type = 'static', object = tags$h2("Exemple spinners"))

dash = new('DASHBOARD', items = II, king.layout = list('main'))

shinyApp(ui = dash$dashboard.ui(), server = dash$dashboard.server())
