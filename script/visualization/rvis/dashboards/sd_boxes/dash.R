### shinydashboard_boxes ------------------------
library(shiny)
library(shinydashboard)
library(rvis)

greenBox.1 = list(type = 'infoBox', title = "Hello1", icon = 'credit-card', subtitle = 'SUBTITLE', color = 'green')
greenBox.2 = list(type = 'infoBox', title = "Hello2", icon = 'fas fa-chart-line' , subtitle = 'SUBTITLE', fill = T, color = 'green')
purpleBox  = list(type = 'infoBox', title = "Hello3", icon = 'fas fa-chart-line' , subtitle = 'SUBTITLE', fill = T, color = 'purple')
cloth.1   = list(type = 'valueBox', icon = 'credit-card', href = "http://google.com")
cloth.2   = list(type = 'valueBox', icon = 'fas fa-chart-line', href = "http://yahoo.com", title = 'Approval Rating', color = "green")
cloth.3   = list(type = 'valueBox', icon = 'users', colour = "yellow")
cloth.4   = list(type = 'box', status = "warning", solidHeader = TRUE, collapsible = TRUE)
cloth.5   = list(type = 'box', status = "warning", background = 'green', width = 4)
cloth.6   = list(type = 'box', background = 'olive', width = 4)

items = list(
  
  # inputs:
  orders  = list(type = "sliderInput", title = "Orders"  , title = 'Orders', min = 1, max = 2000, value = 650),
  progress  = list(type = "selectInput", title = 'Progress (%)', title = "Progress", choices = c("0%", "20%", "40%", "60%", "80%", "100%")),
  
  # containers:
  dashboard = list(type = 'dashboardPage', layout.head = c(), layout.side = c('orders', 'progress'), layout.body = 'body'),
  body = list(type = 'fluidPage'  , layout = list(c('orderNum2', 'apr', 'progress2'), c('orderNum', 'empty', 'prog'), 'plotbox', c('status', 'status2'))),
  plotbox = list(type = 'box'           , status = "primary", layout = 'plot'),

  # outputs:
  orderNum2 = list(type = "uiOutput"  , title = "Orders"         , cloth = greenBox.1, service = "input$orders"),
  apr = list(type = "static"    , title = "Approval Rating", cloth = greenBox.2, object = "%60"),
  progress2 = list(type = "uiOutput"  , title = "Progress"       , cloth = purpleBox, service = "input$progress"),
  orderNum = list(type = "uiOutput"  , title = "New Orders"     , cloth = cloth.1, service = "input$orders"),
  empty = list(type = "static"    , title = "Approval Rating", cloth = cloth.2, object = tagList("60", tags$sup(style="font-size: 20px", "%"))),
  prog = list(type = "htmlOutput", title = "Progress"       , cloth = cloth.3, service = "input$progress"),
  plot = list(type = "plotOutput", title = "Histogram box title", cloth = cloth.4, height = '250px', service = "hist(rnorm(input$orders))"),
  status = list(type = "textOutput", title = "Status summary",   cloth = cloth.5, 
                service = "paste0('There are ', input$orders, ' orders, and so the current progress is ', input$progress, '.')"),
  status2 = list(type = "htmlOutput"  , title = "Status summary 2", cloth = cloth.6, 
                 service = "p('Current status is: ', icon(switch(input$progress, '100%' = 'ok', '0%' = 'remove','road'), lib = 'glyphicon'))")
  
)


dash = new('DASHBOARD', items = items, king.layout = list('dashboard'))


ui <- dash$dashboard.ui()
server <- dash$dashboard.server()

shinyApp(ui, server)
