###### Package shinySky: =============================

### app.R ---------------------

library(shiny)
library(shinysky)


ui = shinyUI(basicPage(headerPanel("ShinySky Examples"),  br(),
                       tabsetPanel(selected = "Action Buttons",
                                   tabPanel("Action Buttons",
                                            
                                            div(class="row-fluid",h4("ActionButtons")),
                                            div(class="row-fluid",
                                                div(class="well container-fluid" , div(class="container span3",
                                                                                       actionButton("id_blank","blank",size="large"),
                                                                                       actionButton("id_primary","primary",styleclass="primary",size="mini"),
                                                                                       actionButton("id_info","info",styleclass="info",size="small"),
                                                                                       actionButton("id_success","success",styleclass="success",icon = "ok"),
                                                                                       actionButton("id_warning","warning",styleclass="warning",icon="plus"),
                                                                                       actionButton("id_danger","danger",styleclass="danger"),
                                                                                       actionButton("id_inverse","inverse",styleclass="inverse"),
                                                                                       actionButton("id_link","link",styleclass="link")    
                                                ),
                                                div(class=" span3","Buttons that fill a block",
                                                    actionButton("id_inverse2","inverse2",styleclass="inverse",block=T),
                                                    actionButton("id_warning2","warning2",styleclass="warning",block=T)),
                                                div(class="container-fluid span6", 
                                                    shiny::helpText("Click any button to show an alert. The alert will automatically close after 5 seconds"),
                                                    shinyalert("shinyalert1", FALSE,auto.close.after = 5)
                                                )
                                                )
                                            ))
                                   ,tabPanel("Select2",
                                             h4("Select2")
                                             ,div(class="row-fluid ",
                                                  div(class="well container-fluid"   ,  
                                                      div(class="container span3",
                                                          select2Input("select2Input1","This is a multiple select2Input. The items are re-arrangeable",
                                                                       choices=c("a","b","c"),
                                                                       selected=c("b","a"))
                                                      ),
                                                      div(class="container span3"
                                                          ,helpText("Select2Input")
                                                          ,actionButton("updateselect2","Update")
                                                          ,shinyalert("shinyalert4")
                                                      ),
                                                      div(class="container span3",
                                                          select2Input("select2Input2","This is a multiple select2Input type = select. The items are NOT re-arrangeable",
                                                                       choices=c("a","b","c"),selected=c("b","a"),
                                                                       type="select",multiple=TRUE)
                                                      ),
                                                      div(class="container span3"
                                                          ,helpText("Select2Input2")
                                                          ,shinyalert("shinyalert5")
                                                      )
                                                      ,     div(class="container span3",
                                                                select2Input("select2Input3","This is a multiple select2Input type = select",choices=c("a","b","c"),selected=c("b","a"),type="select")
                                                      ),
                                                      div(class="container span3"
                                                          ,helpText("Select2Input2")
                                                          ,shinyalert("shinyalert6")
                                                      ))
                                             ))
                                   
                                   ,tabPanel("Typeahead",
                                             h4("Typeahead Text Input ")
                                             ,div(class="row-fluid ", div(class="well container-fluid",     div(class="container span3",
                                                                                                                helpText("Type 'name' or '2' to see the features. "),
                                                                                                                textInput.typeahead(
                                                                                                                  id="thti"
                                                                                                                  ,placeholder="type 'name' or '2'"
                                                                                                                  ,local=data.frame(name=c("name1","name2"),info=c("info1","info2"))
                                                                                                                  ,valueKey = "name"
                                                                                                                  ,tokens=c(1,2)
                                                                                                                  ,template = HTML("<p class='repo-language'>{{info}}</p> <p class='repo-name'>{{name}}</p> <p class='repo-description'>You need to learn more CSS to customize this further</p>")
                                                                                                                ),
                                                                                                                actionButton("update_typeahead_btn","Update Typeahead", styleclass= "primary")
                                             ),
                                             div(class="container span9"
                                                 ,shinyalert("shinyalert3")
                                             ))
                                             ))
                                   
                                   ,tabPanel("EventsButtons"
                                             ,h4("EventsButtons")
                                             ,div(class="row-fluid",
                                                  div(class="container-fluid well",div(class="container span2",
                                                                                       eventsButton("id_double_click_event","Double click me!",styleclass="danger",events=c("dblclick","mouseenter"))
                                                  ),
                                                  div(class="container span10",
                                                      shinyalert("shinyalert2")
                                                  ))
                                             ))
                                   ,tabPanel("Handsontable"
                                             ,h4("Handsontable Input/Output")
                                             ,div(class="well container-fluid"
                                                  ,hotable("hotable1")
                                             ))
                                   
                                   
                                   ,tabPanel("Busy Indicator",
                                             h4("Busy Indicator")
                                             ,busyIndicator("Calculation In progress",wait = 0)
                                             ,actionButton("busyBtn","Show busyInidcator")
                                             ,plotOutput("plot1")
                                   )
                                   
                       ))
)


options(shiny.trace = F)  # cahnge to T for trace
require(shiny)
require(shinysky)

server = shinyServer(function(input, output, session) {
  
  
  # actionButtons
  observe({
    if (input$id_blank == 0) 
      return()
    showshinyalert(session, "shinyalert1", paste("You have clicked", "blank"))
  })
  observe({
    if (input$id_primary == 0) 
      return()
    showshinyalert(session, "shinyalert1", paste("You have clicked", "primary"), 
                   styleclass = "primary")
  })
  observe({
    if (input$id_info == 0) 
      return()
    showshinyalert(session, "shinyalert1", paste("You have clicked", "info"), styleclass = "info")
  })
  observe({
    if (input$id_success == 0) 
      return()
    showshinyalert(session, "shinyalert1", paste("You have clicked", "success"), 
                   styleclass = "success")
  })
  observe({
    if (input$id_warning == 0) 
      return()
    showshinyalert(session, "shinyalert1", paste("You have clicked", "warning"), 
                   styleclass = "warning")
  })
  observe({
    if (input$id_danger == 0) 
      return()
    showshinyalert(session, "shinyalert1", paste("You have clicked", "danger", "<button type='button' class='btn btn-danger'>Danger</button>"), 
                   styleclass = "danger")
  })
  observe({
    if (input$id_inverse == 0) 
      return()
    showshinyalert(session, "shinyalert1", paste("You have clicked", "inverse"), 
                   styleclass = "inverse")
  })
  observe({
    if (input$id_link == 0) 
      return()
    showshinyalert(session, "shinyalert1", paste("You have clicked", "link"), styleclass = "link")
  })
  observe({
    if (input$id_inverse2 == 0) 
      return()
    showshinyalert(session, "shinyalert1", paste("You have clicked", "inverse2"), 
                   styleclass = "inverse")
  })
  observe({
    if (input$id_warning2 == 0) 
      return()
    showshinyalert(session, "shinyalert1", paste("You have clicked", "warning2"), 
                   styleclass = "warning")
  })
  
  # eventsButtons
  observe({
    if (is.null(input$id_double_click_event)) {
      return()
    }
    print(input$id_double_click_event)
    if (input$id_double_click_event$event == "dblclick") {
      showshinyalert(session, "shinyalert2", "You have double clicked! Event button can handle doubleclicks")
    } else if (input$id_double_click_event$event == "mouseenter") {
      showshinyalert(session, "shinyalert2", "You came in! Single click won't change me", 
                     styleclass = "info")
    }
    # updateSelectInput(session,'select2Input1',choices=c('a','b','c'),selected=c('c','b'))
  })
  
  # typeahead
  observe({
    input$thti
    showshinyalert(session, "shinyalert3", sprintf("Typeahead Text Input Value: '%s'", 
                                                   input$thti), "error")
  })
  
  # select2
  observe({
    if (input$updateselect2 == 0) 
      return()
    
    updateSelect2Input(session, "select2Input1", choices = c("d", "e", "f"), selected = c("f", 
                                                                                          "d"), label = "hello")
    updateSelectInput(session, "select2Input2", choices = c("d", "e", "f"), selected = c("f", 
                                                                                         "d"), label = "hello")
    updateSelectInput(session, "select2Input3", choices = c("d", "e", "f"), selected = "f", 
                      label = "hello")
  })
  
  observe({
    showshinyalert(session, "shinyalert4", paste(input$select2Input1, collapse = ","), 
                   "info")
  })
  
  observe({
    showshinyalert(session, "shinyalert5", paste(input$select2Input2, collapse = ","), 
                   "info")
  })
  
  observe({
    showshinyalert(session, "shinyalert6", paste(input$select2Input3, collapse = ","), 
                   "info")
  })
  
  # busyIndicator
  output$plot1 <- renderPlot({
    if (input$busyBtn == 0) 
      return()
    Sys.sleep(3)
    hist(rnorm(10^3))
  })
  
  # typeahead
  observe({
    if (input$update_typeahead_btn == 0) {
      return()
    }
    dataset <- data.frame(firstname = c("ZJ", "Mitchell"), lastname = c("Dai", "Joblin"))
    valueKey <- "lastname"
    tokens <- c("zd", "mj", dataset$firstname)
    template <- HTML("First Name: <em>{{firstname}}</em> Last Name: <em>{{lastname}}</em>")
    updateTextInput.typeahead(session, "thti", dataset, valueKey, tokens, template, 
                              placeholder = "type 'm' or 'z' to see the updated table")
  })
  
  # hotable
  output$hotable1 <- renderHotable({
    head(iris)
  }, readOnly = FALSE)
  
  observe({
    df <- hot.to.df(input$hotable1)
    print(head(df))
  })
  
  
}) 

shinyApp(ui, server)


# todo: viser translation:
