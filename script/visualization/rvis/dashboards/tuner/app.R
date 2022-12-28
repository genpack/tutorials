source('global.R')

inputs = yaml::read_yaml('config.yml')

inputs$items$pick_seg$choices = segments
inputs$items$pick_exfeat$choices = features
inputs$items$pick_exfeat$selected = c()

dash = new('DASHBOARD', items = inputs$items, king.layout = list('main'), observers = inputs$observers, values = reactive_values)
shinyApp(dash$dashboard.ui(), dash$dashboard.server())

