source('global.R')

inputs = yaml::read_yaml('config.yml')

# Make it beautiful:
inputs$txt1$object %<>% tags$h2()
inputs$linef$object %<>% tags$br()

dash = new('DASHBOARD', items = inputs, king.layout = list('main'))
shinyApp(dash$dashboard.ui(), dash$dashboard.server())
