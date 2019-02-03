
##### Package: shiny =================================================
### progressbar.R ---------------------------------------
# https://shiny.rstudio.com/reference/shiny/1.0.0/Progress.html


# Example 1:
# https://shiny.rstudio.com/articles/progress.html

server <- function(input, output) {
  output$plot <- renderPlot({
    input$goPlot # Re-run when button is clicked
    
    # Create 0-row data frame which will be used to store data
    dat <- data.frame(x = numeric(0), y = numeric(0))
    
    withProgress(message = 'Making plot', value = 0, {
      # Number of times we'll go through the loop
      n <- 10
      
      for (i in 1:n) {
        # Each time through the loop, add another row of data. This is
        # a stand-in for a long-running computation.
        dat <- rbind(dat, data.frame(x = rnorm(1), y = rnorm(1)))
        
        # Increment the progress bar, and update the detail text.
        incProgress(1/n, detail = paste("Doing part", i))
        
        # Pause for 0.1 seconds to simulate a long computation.
        Sys.sleep(0.1)
      }
    })
    
    plot(dat$x, dat$y)
  })
}

ui <- shinyUI(basicPage(
  plotOutput('plot', width = "300px", height = "300px"),
  actionButton('goPlot', 'Go plot')
))

shinyApp(ui = ui, server = server)

#################################################################################################################################
# https://jackolney.github.io/blog/post/2016-04-01-shiny/
# Example 2:

server <- function(input, output) {
  output$myplot <- renderPlot({
    
    # The detail to be captured by the progress bar should be contained within this function and its braces
    withProgress(message = 'Creating plot', value = 0, {
      
      # Create an empty data.frame
      dat <- data.frame(x = numeric(0), y = numeric(0))
      
      for (i in 1:10) {
        # Add to it
        dat <- rbind(dat, data.frame(x = rnorm(1), y = rnorm(1)))
        
        # Incremental Progress Bar (add some more info if neccessary)
        incProgress(1/n, detail = paste0(i/n, "%"))
        
        # Pause
        Sys.sleep(0.1)
      }
    })
    
    plot(dat$x, dat$y)
  })
}

ui <- shinyUI(basicPage(plotOutput('myplot', width = "300px", height = "300px")))

shinyApp(ui = ui, server = server)

#################################################################################################################################
# Example 3
# https://shiny.rstudio.com/gallery/progress-bar-example.html
# This function computes a new data set. It can optionally take a function,
# updateProgress, which will be called as each row of data is added.
# ui.R
ui = basicPage(
  plotOutput('plot', width = "300px", height = "300px"),
  tableOutput('table'),
  radioButtons('style', 'Progress bar style', c('notification', 'old')),
  actionButton('goPlot', 'Go plot'),
  actionButton('goTable', 'Go table')
)

# server.R
compute_data <- function(updateProgress = NULL) {
  # Create 0-row data frame which will be used to store data
  dat <- data.frame(x = numeric(0), y = numeric(0))
  
  for (i in 1:10) {
    Sys.sleep(0.25)
    
    # Compute new row of data
    new_row <- data.frame(x = rnorm(1), y = rnorm(1))
    
    # If we were passed a progress update function, call it
    if (is.function(updateProgress)) {
      text <- paste0("x:", round(new_row$x, 2), " y:", round(new_row$y, 2))
      updateProgress(detail = text)
    }
    
    # Add the new row of data
    dat <- rbind(dat, new_row)
  }
  
  dat
}

server = function(input, output) {
  
  # This example uses the withProgress, which is a simple-to-use wrapper around
  # the progress API.
  output$plot <- renderPlot({
    input$goPlot # Re-run when button is clicked
    
    style <- isolate(input$style)
    
    withProgress(message = 'Creating plot', style = style, value = 0.1, {
      Sys.sleep(0.25)
      
      # Create 0-row data frame which will be used to store data
      dat <- data.frame(x = numeric(0), y = numeric(0))
      
      # withProgress calls can be nested, in which case the nested text appears
      # below, and a second bar is shown.
      withProgress(message = 'Generating data', detail = "part 0", value = 0, {
        for (i in 1:10) {
          # Each time through the loop, add another row of data. This a stand-in
          # for a long-running computation.
          dat <- rbind(dat, data.frame(x = rnorm(1), y = rnorm(1)))
          
          # Increment the progress bar, and update the detail text.
          incProgress(0.1, detail = paste("part", i))
          
          # Pause for 0.1 seconds to simulate a long computation.
          Sys.sleep(0.1)
        }
      })
      
      # Increment the top-level progress indicator
      incProgress(0.5)
      
      # Another nested progress indicator.
      # When value=NULL, progress text is displayed, but not a progress bar.
      withProgress(message = 'And this also', detail = "This other thing",
                   style = style, value = NULL, {
                     
                     Sys.sleep(0.75)
                   })
      
      # We could also increment the progress indicator like so:
      # incProgress(0.5)
      # but it's also possible to set the progress bar value directly to a
      # specific value:
      setProgress(1)
    })
    
    plot(cars$speed, cars$dist)
  })
  
  
  # This example uses the Progress object API directly. This is useful because
  # calls an external function to do the computation.
  output$table <- renderTable({
    input$goTable
    
    style <- isolate(input$style)
    
    # Create a Progress object
    progress <- shiny::Progress$new(style = style)
    progress$set(message = "Computing data", value = 0)
    # Close the progress when this reactive exits (even if there's an error)
    on.exit(progress$close())
    
    # Create a closure to update progress.
    # Each time this is called:
    # - If `value` is NULL, it will move the progress bar 1/5 of the remaining
    #   distance. If non-NULL, it will set the progress to that value.
    # - It also accepts optional detail text.
    updateProgress <- function(value = NULL, detail = NULL) {
      if (is.null(value)) {
        value <- progress$getValue()
        value <- value + (progress$getMax() - value) / 5
      }
      progress$set(value = value, detail = detail)
    }
    
    # Compute the new data, and pass in the updateProgress function so
    # that it can update the progress indicator.
    compute_data(updateProgress)
  })
  
}

shinyApp(ui, server)





#################################################################################################################################
# Example 4


library(shiny)
library(data.table)

dt2 <- NULL
dt3 <- NULL
dt4 <- NULL
dt5 <- NULL

readData <- function(session, dt2, dt3, dt4, dt5) {
  progress <- Progress$new(session)
  progress$set(value = 0, message = 'Loading...')
  # dt2 <<- readRDS("dt2.rds")
  delay
  progress$set(value = 0.25, message = 'Loading...')
  dt3 <<- readRDS("dt3.rds")
  progress$set(value = 0.5, message = 'Loading...')
  dt4 <<- readRDS("dt4.rds")
  progress$set(value = 0.75, message = 'Loading...')
  dt5 <<- readRDS("dt5.rds")
  progress$set(value = 1, message = 'Loading...')
  progress$close()
}

ui <- fluidPage(
  ...
)

server <- function(input, output, session) {
  if(is.null(dt5)){
    readData(session, dt2, dt3, dt4, dt5)
  }
}

# Run the application 
shinyApp(ui = ui, server = server)
