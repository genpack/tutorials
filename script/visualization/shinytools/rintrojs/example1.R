##### Package rintrojs ================================
### example.R ---------------------------
library(rintrojs)
library(shiny)

# Define UI for application that draws a histogram
ui <- shinyUI(fluidPage(
  introjsUI(),
  
  # Application title
  introBox(
    titlePanel("Old Faithful Geyser Data"),
    data.step = 1,
    data.intro = "This is the title panel"
  ),
  
  # Sidebar with a slider input for number of bins
  sidebarLayout(sidebarPanel(
    introBox(
      introBox(
        sliderInput(
          "bins",
          "Number of bins:",
          min = 1,
          max = 50,
          value = 30
        ),
        data.step = 3,
        data.intro = "This is a slider",
        data.hint = "You can slide me"
      ),
      introBox(
        actionButton("help", "Press for instructions"),
        data.step = 4,
        data.intro = "This is a button",
        data.hint = "You can press me"
      ),
      data.step = 2,
      data.intro = "This is the sidebar. Look how intro elements can nest"
    )
  ),
  
  # Show a plot of the generated distribution
  mainPanel(
    introBox(
      plotOutput("distPlot"),
      data.step = 5,
      data.intro = "This is the main plot"
    )
  ))
))

# Define server logic required to draw a histogram
server <- shinyServer(function(input, output, session) {
  # initiate hints on startup with custom button and event
  hintjs(session, options = list("hintButtonLabel"="Hope this hint was helpful"),
         events = list("onhintclose"=I('alert("Wasn\'t that hint helpful")')))
  
  output$distPlot <- renderPlot({
    # generate bins based on input$bins from ui.R
    x    <- faithful[, 2]
    bins <- seq(min(x), max(x), length.out = input$bins + 1)
    
    # draw the histogram with the specified number of bins
    hist(x,
         breaks = bins,
         col = 'darkgray',
         border = 'white')
  })
  
  # start introjs when button is pressed with custom options and events
  observeEvent(input$help,
               {introjs(session, options = list("nextLabel"="Onwards and Upwards",
                                                "prevLabel"="Did you forget something?",
                                                "skipLabel"="Don't be a quitter"),
                        events = list("oncomplete"=I('alert("Glad that is over")')))}
  )
})

# Run the application
shinyApp(ui = ui, server = server)

# viser translation:

library(rutils)
library(rvis)
#source('C:/Nicolas/RCode/packages/master/viser-master/R/visgen.R')
#source('C:/Nicolas/RCode/packages/master/viser-master/R/dashboard.R')

E = list()

E$main   = list(type = 'fluidPage', layout = c('intro', 'introbox', 'sbl'))
E$sbl    = list(type = 'sidebarLayout' , layout.side = 'tutor1', layout.main = 'plot')
E$tutor1 = list(type = 'tutorBox', layout = c('bins', 'help'), tutor.step = 2, tutor.lesson = "This is the sidebar. Look how intro elements can nest")
E$bins   = list(type = 'sliderInput' , title = "Number of bins:", min = 1, max = 50, value = 30, tutor.step = 3, tutor.lesson = 'This is a slider!', tutor.hint = 'You can slide me')
E$help   = list(type = 'actionButton', title = 'Press for instructions', tutor.step = 4, tutor.lesson = "This is a button", tutor.hint = "You can press me")
E$plot   = list(type = 'plotOutput'  , title = 'distPlot', service = "get.plot(input$bins)", tutor.step = 5, tutor.lesson = "This is the main plot")
E$intro  = list(type = 'static', object = introjsUI())
E$introbox = list(type = 'static', object = introBox(
  titlePanel("Old Faithful Geyser Data"),
  data.step = 1,
  data.intro = "This is the title panel"
))

get.plot = function(bins){
  x    <- faithful[, 2]
  bins <- seq(min(x), max(x), length.out = bins + 1)
  hist(x, breaks = bins, col = 'darkgray', border = 'white')
}
E$help$service = 
  "
introjs(session, options = list(nextLabel = 'Onwards and Upwards', prevLabel = 'Did you forget something?', skipLabel = 'Dont be a quitter'),
events = list(oncomplete = I('alert(\"Glad that is over\")')))
"

E$help$service = "introjs(session, options = list(nextLabel = 'Forward', prevLabel = 'Back', skipLabel = 'Skip'))"
E$help$service = "introjs(session)"

dash     = new('DASHBOARD', items = E, king.layout = list('main'))
ui       = dash$dashboard.ui()  
server   = dash$dashboard.server()  

shinyApp(ui, server)

###################################################################################################


library(shiny)
library(rintrojs)

ui <- shinyUI(fluidPage(
  introjsUI(),
  mainPanel(
    textInput("intro","Enter an introduction"),
    actionButton("btn","Press me")
  )
)
)

server <- shinyServer(function(input, output, session) {
  
  steps <- reactive(data.frame(element = c(NA,"#btn"),
                               intro = c(input$intro,"This is a button")))
  
  observeEvent(input$btn,{
    introjs(session,options = list(steps=steps()))
    
  })
  
})

# Run the application
shinyApp(ui = ui, server = server)

