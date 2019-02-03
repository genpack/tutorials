## login_example_app.R -------------------------
require(shiny)
require(shinydashboard)

header <- dashboardHeader(title = "my heading")
sidebar <- dashboardSidebar(uiOutput("sidebarpanel"))
body <- dashboardBody(uiOutput("body"))
ui <- dashboardPage(header, sidebar, body)


login_details <- data.frame(user = c("sam", "pam", "ron"),
                            pswd = c("123", "123", "123"))
login <- box(
  title = "Login",
  textInput("userName", "Username"),
  passwordInput("passwd", "Password"),
  br(),
  actionButton("Login", "Log in")
)

server <- function(input, output, session) {
  # To logout back to login page
  login.page = paste(
    isolate(session$clientData$url_protocol),
    "//",
    isolate(session$clientData$url_hostname),
    ":",
    isolate(session$clientData$url_port),
    sep = ""
  )
  histdata <- rnorm(500)
  USER <- reactiveValues(Logged = F)
  observe({
    if (USER$Logged == FALSE) {
      if (!is.null(input$Login)) {
        if (input$Login > 0) {
          Username <- isolate(input$userName)
          Password <- isolate(input$passwd)
          Id.username <- which(login_details$user %in% Username)
          Id.password <- which(login_details$pswd %in% Password)
          if (length(Id.username) > 0 & length(Id.password) > 0){
            if (Id.username == Id.password) {
              USER$Logged <- TRUE
            }
          }
        }
      }
    }
  })
  output$sidebarpanel <- renderUI({
    if (USER$Logged == TRUE) {
      div(
        sidebarUserPanel(
          isolate(input$userName),
          subtitle = a(icon("usr"), "Logout", href = login.page)
        ),
        selectInput(
          "in_var",
          "myvar",
          multiple = FALSE,
          choices = c("option 1", "option 2")
        ),
        sidebarMenu(
          menuItem(
            "Item 1",
            tabName = "t_item1",
            icon = icon("line-chart")
          ),
          menuItem("Item 2",
                   tabName = "t_item2",
                   icon = icon("dollar"))
        )
      )
    }
  })
  
  output$body <- renderUI({
    if (USER$Logged == TRUE) {
      tabItems(
        # First tab content
        tabItem(tabName = "t_item1",
                fluidRow(
                  output$plot1 <- renderPlot({
                    data <- histdata[seq_len(input$slider)]
                    hist(data)
                  }, height = 300, width = 300) ,
                  box(
                    title = "Controls",
                    sliderInput("slider", "observations:", 1, 100, 50)
                  )
                )),
        
        # Second tab content
        tabItem(
          tabName = "t_item2",
          fluidRow(
            output$table1 <- renderDataTable({
              iris
            }),
            box(
              title = "Controls",
              sliderInput("slider", "observations:", 1, 100, 50)
            )
          )
        )
      )
    } else {
      login
    }
  })
}

shinyApp(ui, server)
