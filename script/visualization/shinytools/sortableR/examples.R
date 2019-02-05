### examples.R  --------------------

library(sortableR)
library(htmltools)

html_print(tagList(
  tags$ul(id = "uniqueId01"
          ,tags$li("can you move me?")
          ,tags$li("sure, touch me.")
          ,tags$li("do you know my powers?")
  )
  ,sortableR("uniqueId01") # use the id as the selector
))

# Example 2:
library(DiagrammeR)
html_print(tagList(
  tags$div(id="aUniqueId"
           ,tags$div(style = "border: solid 0.2em gray; float:left;"
                     ,mermaid("graph LR; S[Sortable.js] -->|sortableR| R ",height=200,width = 200)
           )
           ,tags$div(style = "border: solid 0.2em gray; float:left;"
                     ,mermaid("graph TD; js -->|htmlwidgets| R ",height=200,width = 200)
           )
  )
  ,sortableR("aUniqueId")
))





# shiny app:

library(shiny)
library(sortableR)

ui = shinyUI(fluidPage(
  fluidRow(
    column( width = 4
            ,tags$h4("sortableR in Shiny + Bootstrap")
            ,tags$div(id="veryUniqueId", class="list-group"
                      ,tags$div(class="list-group-item","bootstrap 1")
                      ,tags$div(class="list-group-item","bootstrap 2")
                      ,tags$div(class="list-group-item","bootstrap 3")
            )
    )
  )
  ,sortableR( "veryUniqueId")
))

server = function(input,output){
  
}

shinyApp(ui=ui,server=server)


# ahiny app 2:

library(shiny)
library(sortableR)

ui = shinyUI(fluidPage(
  fluidRow(
    column( width = 4
            ,tags$h4("sortableR in Shiny + Bootstrap")
            ,tags$div(id="veryUniqueId", class="list-group"
                      ,tags$div(class="list-group-item","bootstrap 1")
                      ,tags$div(class="list-group-item","bootstrap 2")
                      ,tags$div(class="list-group-item","bootstrap 3")
            )
    )
  )
  ,verbatimTextOutput("results")
  ,sortableR(
    "veryUniqueId"
    ,options = list(onSort = htmlwidgets::JS('
                                             function(evt){
                                             debugger
                                             Shiny.onInputChange("mySort", this.el.textContent)
                                             }
                                             '))
  )
))

server = function(input,output){
  output$results <- renderPrint({input$mySort})
}

shinyApp(ui=ui,server=server)
