### shownotification.R ---------------------------------------
# https://shiny.rstudio.com/articles/notifications.html

shinyApp(
  ui = fluidPage(
    actionButton("show", "Show")
  ),
  server = function(input, output) {
    observeEvent(input$show, {
      showNotification("This is a notification.")
    })
  }
)


#############################################################################

shinyApp(
  ui = fluidPage(
    actionButton("show", "Show"),
    actionButton("remove", "Remove")
  ),
  server = function(input, output) {
    # A notification ID
    id <- NULL
    
    observeEvent(input$show, {
      # If there's currently a notification, don't add another
      if (!is.null(id))
        return()
      # Save the ID for removal later
      id <<- showNotification(paste("Notification message"), duration = 0)
    })
    
    observeEvent(input$remove, {
      if (!is.null(id))
        removeNotification(id)
      id <<- NULL
    })
  }
)
