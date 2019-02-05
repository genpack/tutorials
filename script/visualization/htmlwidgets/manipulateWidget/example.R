### examples.R -------------------------------

library(manipulateWidget)
library(plotly)

# Example 1: Single Charts dashboard:
data(iris)

plotClusters <- function(xvar, yvar, nclusters) {
  clusters <- kmeans(iris[, 1:4], centers = nclusters)
  clusters <- paste("Cluster", clusters$cluster)
  
  plot_ly(x = ~iris[[xvar]], y = ~iris[[yvar]], color = ~clusters,
          type = "scatter", mode = "markers") %>%
    layout(xaxis = list(title=xvar), yaxis = list(title=yvar))
}

plotClusters("Sepal.Width", "Sepal.Length", 3)


varNames <- names(iris)[1:4]

manipulateWidget(
  plotClusters(xvar, yvar, nclusters),
  xvar = mwSelect(varNames),
  yvar = mwSelect(varNames, value = "Sepal.Width"),
  nclusters = mwSlider(1, 10, value = 3)
)


# Example 2: Multiple Charts dashboard:


myPlotFun <- function(distribution, range, title) {
  randomFun <- switch(distribution, gaussian = rnorm, uniform = runif)
  myData <- data.frame(
    year = seq(range[1], range[2]),
    value = randomFun(n = diff(range) + 1)
  )
  combineWidgets(
    ncol = 2, colsize = c(2, 1),
    dygraph(myData, main = title),
    combineWidgets(
      plot_ly(x = myData$value, type = "histogram"),
      paste(
        "The graph on the left represents a random time series generated using a <b>",
        distribution, "</b>distribution function.<br/>",
        "The chart above represents the empirical distribution of the generated values."
      )
    )
  )
  
}

manipulateWidget(
  myPlotFun(distribution, range, title),
  distribution = mwSelect(choices = c("gaussian", "uniform")),
  range = mwSlider(2000, 2100, value = c(2000, 2100), label = "period"),
  title = mwText()
)


# Example 3: Use as a module in shiny:

if (interactive() & require("dygraphs")) {
  require("shiny")
  ui <- fillPage(
    fillRow(
      flex = c(NA, 1),
      div(
        textInput("title", label = "Title", value = "glop"),
        selectInput("series", "series", choices = c("series1", "series2", "series3"))
      ),
      mwModuleUI("ui", height = "100%")
    ))
  
  server <- function(input, output, session) {
    mydata <- data.frame(
      year = 2000+1:100,
      series1 = rnorm(100),
      series2 = rnorm(100),
      series3 = rnorm(100)
    )
    
    c <- manipulateWidget(
      {
        dygraph(mydata[range[1]:range[2] - 2000, c("year", series)], main = title)
      },
      range = mwSlider(2001, 2100, c(2001, 2050)),
      series = mwSharedValue(),
      title = mwSharedValue(), .runApp = FALSE,
      .compare = "range"
    )
    #
    mwModule("ui", c, title = reactive(input$title), series = reactive(input$series))
  }
  
  shinyApp(ui, server)
  
  
}



# Example 4: shared value:

if (require(plotly)) {
  # Plot the characteristics of a car and compare with the average values for
  # cars with same number of cylinders.
  # The shared variable 'subsetCars' is used to avoid subsetting multiple times
  # the data: this value is updated only when input 'cylinders' changes.
  colMax <- apply(mtcars, 2, max)
  
  plotCar <- function(cardata, carName) {
    carValues <- unlist(cardata[carName, ])
    carValuesRel <- carValues / colMax
    
    avgValues <- round(colMeans(cardata), 2)
    avgValuesRel <- avgValues / colMax
    
    plot_ly() %>%
      add_bars(x = names(cardata), y = carValuesRel, text = carValues,
               hoverinfo = c("x+text"), name = carName) %>%
      add_bars(x = names(cardata), y = avgValuesRel, text = avgValues,
               hoverinfo = c("x+text"), name = "average") %>%
      layout(barmode = 'group')
  }
  
  c <- manipulateWidget(
    plotCar(subsetCars, car),
    cylinders = mwSelect(c("4", "6", "8")),
    subsetCars = mwSharedValue(subset(mtcars, cylinders == cyl)),
    car = mwSelect(choices = row.names(subsetCars))
  )
}


