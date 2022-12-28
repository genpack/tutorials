source('global.R')

inputs = yaml::read_yaml('config.yml')
dash = new('DASHBOARD', items = inputs, king.layout = list('main'))
shinyApp(dash$dashboard.ui(), dash$dashboard.server())
