source('global.R')
# Containers:
II = list()
II$main  = list(type = 'fluidPage', layout = c('linef', 'btnsgrup', 'res1', 'res2', 'res3'))
# Inputs:
II$linef    = list(type = 'static', object = tags$br())
II$btnsgrup = list(type = 'actionGroupButtons', inputIds = c("btn1", "btn2", "btn3"),
                   labels = list("Action 1", "Action 2", tags$span(icon("gear"), "Action 3")), status = 'primary')
# Outputs:
II$res1 = list(type = 'verbatimTextOutput', service = "input$btn1")
II$res2 = list(type = 'verbatimTextOutput', service = "input$btn2")
II$res3 = list(type = 'verbatimTextOutput', service = "input$btn3")

dash = new('DASHBOARD', items = II, king.layout = list('main'))

shinyApp(ui = dash$dashboard.ui(), server = dash$dashboard.server())
