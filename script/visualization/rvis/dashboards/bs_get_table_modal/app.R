### bs_get_table_modal_example ------------------------
# get table bs modal example with rvis:


# Example:
classes = list(event_id = c('character', 'factor'), case_id = c('character', 'factor'), event_type = c('character', 'factor'), time_stamp = 'POSIXct')

dashItems = list()
dashItems$main   = list(type = 'fluidPage', layout = list('action', 'my_dialog'))
dashItems$action = list(type = 'actionButton', title = 'Click me!')
dashItems = dashItems %<==>% 
  build.container.get.table(name = 'my_dialog', classes = classes, containerType = 'bsModal', title = 'Get file dialog', trigger = 'action', size = 'small')

dash   <- new('DASHBOARD', items = dashItems, king.layout = list('main'))
ui     <- dash$dashboard.ui()
server <- dash$dashboard.server()
shinyApp(ui, server)

