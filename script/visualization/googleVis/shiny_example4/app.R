# click as shiny input:
library(shiny)

library(googleVis)

server <- function(input, output) {
  output$dates_plot <- renderGvis({
    
    gvisCalendar(Cairo,
                 
                 options = list(
                   
                   colorAxis = "{
                   
                   minValue: 0,
                   
                   colors: ['E9967A', 'A52A2A']
                   
  }",
  
                   gvis.listener.jscode = "
                   
                   var row = chart.getSelection()[0].row;
                   
                   var selected_date = data.getValue(row, 0);
                   
                   var parsed_date = selected_date.getFullYear()+'-'+(selected_date.getMonth()+1)+'-'+selected_date.getDate();
                   
                   Shiny.onInputChange('selected_date',parsed_date)
                   Shiny.onInputChange('id',row)
                   ")
                 
                 )
    
})
  output$date <- renderText({
    
    paste0(input$selected_date, ' -- ', ' Date : ', Cairo[input$id + 1, 'Date'], 'Temperature = ', Cairo$Temp[input$id + 1])
    
  })
  }


ui <- shinyUI(fluidPage(
  
  htmlOutput("dates_plot"),
  
  textOutput("date")
))



shinyApp(ui = ui, server = server)

