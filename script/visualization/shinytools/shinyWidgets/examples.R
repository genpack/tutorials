###### Package shinyWidgets: ======================

### examples.R -------------------------

library(magrittr)
library(shiny)
library(shinyWidgets)
library(rutils)

#############################################################################################################################
# Example 1: actionBttn

library(shiny)
library(shinyWidgets)

ui <- fluidPage(
  tags$h2("Awesome action button"),
  tags$br(),
  actionBttn(
    inputId = "bttn1",
    label = "Go!",
    color = "primary",
    style = "bordered"
  ),
  tags$br(),
  verbatimTextOutput(outputId = "res_bttn1"),
  tags$br(),
  actionBttn(
    inputId = "bttn2",
    label = "Go!",
    color = "success",
    style = "material-flat",
    icon = icon("sliders"),
    block = TRUE
  ),
  tags$br(),
  verbatimTextOutput(outputId = "res_bttn2")
)

server <- function(input, output, session) {
  output$res_bttn1 <- renderPrint(input$bttn1)
  output$res_bttn2 <- renderPrint(input$bttn2)
}

shinyApp(ui = ui, server = server)



# viser translation:
# Containers:
II = list()
II$main  = list(type = 'fluidPage', layout = c('txt1', 'linef', 'bttn1', 'linef', 'res_bttn1', 'bttn2', 'linef', 'res_bttn2'))
# Inputs:
II$txt1  = list(type = 'static', object = tags$h2("Awesome action button"))
II$linef = list(type = 'static', object = tags$br())
II$bttn1 = list(type = 'actionBttn', title = 'Go!', status = 'primary', style = 'bordered')
II$bttn2 = list(type = 'actionBttn', title = 'Go!', status = 'success', style = 'material-flat', block = T, icon = "sliders")
# Outputs:
II$res_bttn1 = list(type = 'verbatimTextOutput', service = "input$bttn1")
II$res_bttn2 = list(type = 'verbatimTextOutput', service = "input$bttn2")

dash = new('DASHBOARD', items = II, king.layout = list('main'))
ui = dash$dashboard.ui()
server = dash$dashboard.server()

shinyApp(ui = ui, server = server)

#############################################################################################################################
# Example 2: actionGroupButtons

ui <- fluidPage(
  br(),
  actionGroupButtons(
    inputIds = c("btn1", "btn2", "btn3"),
    labels = list("Action 1", "Action 2", tags$span(icon("gear"), "Action 3")),
    status = "primary"
  ),
  verbatimTextOutput(outputId = "res1"),
  verbatimTextOutput(outputId = "res2"),
  verbatimTextOutput(outputId = "res3")
)

server <- function(input, output, session) {
  
  output$res1 <- renderPrint(input$btn1)
  
  output$res2 <- renderPrint(input$btn2)
  
  output$res3 <- renderPrint(input$btn3)
  
}

shinyApp(ui = ui, server = server)


# viser translation:
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


##############################################################################################################################
# Example 3: addSpinner

ui <- fluidPage(
  tags$h2("Exemple spinners"),
  actionButton(inputId = "refresh", label = "Refresh", width = "100%"),
  fluidRow(
    column(
      width = 5, offset = 1,
      addSpinner(plotOutput("plot1"), spin = "circle", color = "#E41A1C"),
      addSpinner(plotOutput("plot3"), spin = "bounce", color = "#377EB8"),
      addSpinner(plotOutput("plot5"), spin = "folding-cube", color = "#4DAF4A"),
      addSpinner(plotOutput("plot7"), spin = "rotating-plane", color = "#984EA3"),
      addSpinner(plotOutput("plot9"), spin = "cube-grid", color = "#FF7F00")
    ),
    column(
      width = 5,
      addSpinner(plotOutput("plot2"), spin = "fading-circle", color = "#FFFF33"),
      addSpinner(plotOutput("plot4"), spin = "double-bounce", color = "#A65628"),
      addSpinner(plotOutput("plot6"), spin = "dots", color = "#F781BF"),
      addSpinner(plotOutput("plot8"), spin = "cube", color = "#999999")
    )
  ),
  actionButton(inputId = "refresh2", label = "Refresh", width = "100%")
)

server <- function(input, output, session) {
  
  dat <- reactive({
    input$refresh
    input$refresh2
    Sys.sleep(3)
    Sys.time()
  })
  
  lapply(
    X = seq_len(9),
    FUN = function(i) {
      output[[paste0("plot", i)]] <- renderPlot({
        dat()
        plot(sin, -pi, i*pi)
      })
    }
  )
  
}

shinyApp(ui, server)



# viser translation:
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



##############################################################################################################################
# Example 3: airDatepickerInput

ui <- fluidPage(
  airDatepickerInput(
    inputId = "multiple",
    label = "Select multiple dates:",
    placeholder = "You can pick 5 dates",
    multiple = 5, clearButton = TRUE
  ),
  verbatimTextOutput("res")
)

server <- function(input, output, session) {
  output$res <- renderPrint(input$multiple)
}

shinyApp(ui, server)

# viser translation:
II = list()
# Containers:
II$main     = list(type = 'fluidPage', layout = list('multiple', 'res'))
II$multiple = list(type = 'airDatepickerInput', title = "Select multiple dates:", placeholder = "You can pick 5 dates", multiple = 5, clearButton = T)
II$res      = list(type = 'verbatimTextOutput', service = "input$multiple")

dash = new('DASHBOARD', items = II, king.layout = list('main'))

shinyApp(ui = dash$dashboard.ui(), server = dash$dashboard.server())
# todo: change input name for airDatepickerInput! define separate input types like monthInput, yearInput, monthRangeInput, dateTimeInput, ...
# translate other demoes: # examples of different options to select dates:
demoAirDatepicker("datepicker")

# select month(s)
# demoAirDatepicker("months")

# select year(s)
# demoAirDatepicker("years")

# select date and time
# demoAirDatepicker("timepicker")



##############################################################################################################################
# Example 4: awesomeCheckbox
ui <- fluidPage(
  awesomeCheckbox(inputId = "somevalue",
                  label = "A single checkbox",
                  value = TRUE,
                  status = "danger"),
  verbatimTextOutput("value")
)
server <- function(input, output) {
  output$value <- renderText({ input$somevalue })
}
shinyApp(ui, server)



