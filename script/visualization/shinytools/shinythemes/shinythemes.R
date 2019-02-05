### shinythemes.R -------------------
shinyApp(
  ui = navbarPage("Cerulean",
                  theme = shinytheme("cerulean"),
                  tabPanel("Plot", "Plot tab contents..."),
                  navbarMenu("More",
                             tabPanel("Summary", "Summary tab contents..."),
                             tabPanel("Table", "Table tab contents...")
                  )
  ),
  server = function(input, output) { }
)

# A more complicated app with the flatly theme

shinyApp(
  ui = fluidPage(
    theme = shinytheme("flatly"),
    titlePanel("Tabsets"),
    sidebarLayout(
      sidebarPanel(
        radioButtons("dist", "Distribution type:",
                     c("Normal" = "norm",
                       "Uniform" = "unif",
                       "Log-normal" = "lnorm",
                       "Exponential" = "exp")),
        br(),
        sliderInput("n", "Number of observations:",
                    value = 500, min = 1, max = 1000)
      ),
      mainPanel(
        tabsetPanel(type = "tabs",
                    tabPanel("Plot", plotOutput("plot")),
                    tabPanel("Summary", verbatimTextOutput("summary")),
                    tabPanel("Table", tableOutput("table"))
        )
      )
    )
  ),
  server = function(input, output) {
    data <- reactive({
      dist <- switch(input$dist,
                     norm = rnorm,
                     unif = runif,
                     lnorm = rlnorm,
                     exp = rexp,
                     rnorm)
      dist(input$n)
    })
    
    output$plot <- renderPlot({
      dist <- input$dist
      n <- input$n
      hist(data(), main=paste('r', dist, '(', n, ')', sep=''))
    })
    
    output$summary <- renderPrint({
      summary(data())
    })
    
    output$table <- renderTable({
      data.frame(x=data())
    })
  }
)
