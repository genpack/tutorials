### gettablemodal.R ------------------------
# get table bs modal example with viser:


# Example:
classes = list(caseID = c('character', 'factor'), activity = c('character', 'factor'), status = c('character', 'factor'), timestamp = 'POSIXct')

dashItems = list()
dashItems$main   = list(type = 'fluidPage', layout = list('action', 'my_dialog'))
dashItems$action = list(type = 'actionButton', title = 'Click me!')
dashItems = dashItems %<==>% 
  build.container.get.table(name = 'my_dialog', classes = classes, containerType = 'bsModal', title = 'Get file dialog', trigger = 'action', size = 'small')

dash   <- new('DASHBOARD', items = dashItems, king.layout = list('main'))
ui     <- dash$dashboard.ui()
server <- dash$dashboard.server()
shinyApp(ui, server)

