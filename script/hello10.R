
###### package googlevis: ====================================

### gauge.R: ------------------------------------------

library(googleVis)

Gauge <-  gvisGauge(CityPopularity, 
                    options=list(min=0, max=800, greenFrom=500,
                                 greenTo=800, yellowFrom=300, yellowTo=500,
                                 redFrom=0, redTo=300, width=400, height=300))
plot(Gauge)

# niravis Translation:
cfg = list(theta.min = 0, theta.max = 800, thetaAxis.tick.step = 100, aggrigator.function = mean,
           thetaAxis.zone = 
             list(list(min = 500, max = 800, color = 'green'))  %>% 
             list.add(list(min = 300, max = 500, color = 'yellow')) %>% 
             list.add(list(min = 0  , max = 300, color = 'red'))
)
CityPopularity %>% googleVis.gauge(theta = 'Popularity', label = 'City', config = cfg) %>% plot


# with rAmCharts:

CityPopularity %>% amCharts.gauge(theta = 'Popularity', label = 'City', config = cfg)

# Using old niraVis:

g = googleVis.gauge.old(CityPopularity, theta = 'Popularity', label = 'City')
plot(g)

### linechart.R --------------------------
library(niragen)
library(googleVis)

source('../../packages/master/niravis-master/R/visgen.R')
source('../../packages/master/niravis-master/R/googleVis.R')

# Example 1:

df=data.frame(country=c("US", "GB", "BR"), 
              val1=c(10,13,14), 
              val2=c(23,12,32))

df %>% gvisLineChart(xvar = 'val1', yvar = 'val2') %>% plot


# niravis Translation:
df %>% googleVis.line(x = 'val1', y = 'val2') %>% plot


# Example 2:

df=data.frame(
  country = c("US", "GB", "US", "BR"), 
  val1=c(10,13,14, 18), 
  val2=c(15,12,6, 11), 
  val3=c(23,12,32, 9))

gvisLineChart(df, "country", c("val1","val2", "val3"),
              options=list(
                series="[{targetAxisIndex: 0},
                                 {targetAxisIndex:1}]",
                vAxes="[{title:'Val 1'}, {title:'Val 2'}, {title:'Val 3'}]"
              )) %>% plot

# niravis Translation:
df %>% googleVis.line(x = 'val1', y = 'val2') %>% plot

### merge.R --------------------------------
## Please note that by default the googleVis plot command
## will open a browser window and requires Internet
## connection to display the visualisation.

Pie1 <- gvisPieChart(CityPopularity)

## Doughnut chart - a pie with a hole
Pie2 <- gvisPieChart(CityPopularity, options=list(
  slices="{4: {offset: 0.2}, 0: {offset: 0.3}}",
  title='City popularity',
  legend='none',
  pieSliceText='label',
  pieHole=0.5))

plot(gvisMerge(Pie2, Pie1, 
               tableOptions = "cellspacing=\"20\" bgcolor=\"#AABBCC\"",
               horizontal=TRUE))

## Nested charts               

G <- gvisGeoChart(Exports, "Country", "Profit", 
                  options=list(width=250, height=100))
T <- gvisTable(Exports, 
               options=list(width=250, height=300))

GT <- gvisMerge(G,T, horizontal=FALSE) 
plot(GT)

M <- gvisMotionChart(Fruits, "Fruit", "Year",
                     options=list(width=400, height=410))

GTM <- gvisMerge(GT, M, horizontal=TRUE,
                 tableOptions="cellspacing=10")
plot(GTM)


line <- gvisLineChart(OpenClose, "Weekday", c("Open", "Close"), 
                      options=list(legend='none', width=300, height=150))
column <- gvisColumnChart(OpenClose, "Weekday", c("Open", "Close"),
                          options=list(legend='none', width=300, height=150))
area <- gvisAreaChart(OpenClose, "Weekday", c("Open", "Close"),
                      options=list(legend='none', width=300, height=150))
bar <- gvisBarChart(OpenClose, "Weekday", c("Open", "Close"),
                    options=list(legend='none', width=300, height=150))
LBCA <- gvisMerge(gvisMerge(line, bar), gvisMerge(column, area),
                  horizontal=TRUE, tableOptions="bgcolor=\"#AABBCC\"") 

plot(LBCA)

## Applying gvisMerge successively

p <- Reduce(gvisMerge, list(line, column, area, bar))
plot(p)               



### motionchart.R ------------------------
Motion=gvisMotionChart(Fruits, 
                       idvar="Fruit", 
                       timevar="Year")
plot(Motion)


myStatusSettings  = '
{
iconKeySettings":[{"key":{"dim0":"RDFN"}}, {"key":{"dim0":"FFPE"}}]  # specifies which items to be visible initially 
"xLambda":1,
"xZoomedIn":false,
"xZoomedDataMin":0,  # min value of x axis
"xZoomedDataMax":16, # max value of x axis
"xAxisOption":"_ALPHABETICAL",  # Other options: "_TIME", 
"orderedByX":true,

"yLambda":0,   # dont know yet
"yZoomedIn":false,  # dont know yet
"yZoomedDataMin":0, # min value of y axis
"yZoomedDataMax":40000, # max value of y axis
"yAxisOption":"2",
"orderedByY":false,

"dimensions":{"iconDimensions":["dim0"]},
"colorOption":"_UNIQUE_COLOR"
"showTrails":false,
"nonSelectedAlpha":0, # color intensity of non-selected items. If 0, non-selected items become invisible
"uniColorForNonSelected":false,

"iconType":"VBAR",
"sizeOption":"_UNISIZE",
"time":"2016-05-27", # which time to start with

"playDuration":15000,
"duration":{"timeUnit":"D","multiplier":1},
"stateVersion":3 
}'
  
#  ,"time":"notime","xAxisOption":"_NOTHING","playDuration":15,"iconType":"BUBBLE","sizeOption":"_NOTHING","xZoomedDataMin":null,"xZoomedIn":false,"duration":{"multiplier":1,"timeUnit":"none"},"yZoomedDataMin":null,"xLambda":1,"colorOption":"_NOTHING","nonSelectedAlpha":0.4,"dimensions":{"iconDimensions":[]},"yZoomedIn":false,"yAxisOption":"_NOTHING","yLambda":1,"yZoomedDataMax":null,"showTrails":true,"xZoomedDataMax":null};'
  

# rmd example

### test.rmd -----------------------------------------------------------------------

<!--
  %\VignetteEngine{knitr::knitr}
%\VignetteIndexEntry{Markdown example with knitr and googleVis}
-->
# Markdown example with knitr and googleVis
===========================================
This is a little Markdown example output. The Markdown source file is hosted on [GitHub](https://github.com/mages/googleVis/blob/master/vignettes/Using_googleVis_with_knitr.Rmd).

Set the googleVis options first to change the behaviour of plot.gvis, so that only the chart component of the HTML file is written into the output file.

```{r setOptions, message=FALSE}
library(googleVis)
op <- options(gvis.plot.tag='chart')
```
The following plot statements will automatically return  the HTML
required for the 'knitted' output. 

## Combo chart
```{r ComboExample, results='asis', tidy=FALSE}
## Add the mean
CityPopularity$Mean=mean(CityPopularity$Popularity)
CC <- gvisComboChart(CityPopularity, xvar='City',
yvar=c('Mean', 'Popularity'),
options=list(seriesType='bars',
width=450, height=300,
title='City Popularity',
series='{0: {type:\"line\"}}'))
  plot(CC)
  ```
  Example of gvisComboChart with R code shown above.
  
  ## Place two charts next to each other
  ```{r gvisMergeExample, results='asis', echo=FALSE}
  Geo <- gvisGeoChart(Exports, locationvar='Country', colorvar='Profit', 
  options=list(height=300, width=350)) 
  Tbl <- gvisTable(Exports, options=list(height=300, width=200))
  plot(gvisMerge(Geo, Tbl, horizontal=TRUE))
  ``````
  Example of a gvisGeoChart with gvisTable and R code hidden.
  
  ## Motion Chart
  ```{r MotionChartExample, results='asis', tidy=FALSE}
  M <- gvisMotionChart(Fruits, 'Fruit', 'Year',
  options=list(width=400, height=350))
  plot(M)
  ```
  Please note that the Motion Chart is only displayed when hosted on a
  web server, or if placed in a directory which has been added to the 
  trusted sources in the [security settings of Macromedia]
  (http://www.macromedia.com/support/documentation/en/flashplayer/help/settings_manager04.html). 
  See the googleVis package vignette for more details. 
  
  ```{r resetOptions}
  ## Set options back to original options
  options(op)
  ```

### test2.rmd -------------------------------------------------------------------

# Embedded googleVis plots

Some text here

```{r}
library(googleVis)
op <- options(gvis.plot.tag="chart")
```

And now the plot

```{r result='asis', tidy=TRUE}
mark_func <- function(data) {
    data$Mean=mean(data$Popularity)
    CC <- gvisComboChart(data, xvar='City',
          yvar=c('Mean', 'Popularity'),
          options=list(seriesType='bars',
                       width=450, height=300,
                       title='City Popularity',
                       series='{0: {type:"line"}}'))
    return(CC)
}
```

```{r results='asis', tidy=TRUE}
plt <- mark_func(CityPopularity)
plot(plt)
# This does not work due to connection errors, must work in personal environment!
```  

### shinydashboard ---------------------------
# Example 1

# server.R
library(googleVis)
library(shiny)

shinyServer(function(input, output) {
  
  n = 100 
  dates = seq(Sys.Date(), by = 'day', length = n)
  x = 10 * rnorm(n)
  y = 3 * x + 1 + rnorm(n)
  label = rep(LETTERS[1:4], each=25)
  label[1] = "D"
  
  my.data = data.frame(Date = dates, x, y, label)
  
  output$view <- renderGvis({
    gvisMotionChart(my.data, 
                    idvar ='label', 
                    xvar = 'x', 
                    yvar = 'y', 
                    timevar= 'Date')
  })
  
})

# ui.R

library(googleVis)
library(shiny)

shinyUI(fluidPage(
  titlePanel(" Tool"),
  sidebarLayout(
    sidebarPanel(
      radioButtons(inputId="choice", label="What would you like to see?", 
                   choices= c("Overall ","Individual"))
    ),
    mainPanel(
      htmlOutput("view")
      
    )
  )
))

# Example 2:

# ui.R:

library(shiny)
library(googleVis)

shinyUI(pageWithSidebar(
  headerPanel("Example 2: pageable Table"),
  sidebarPanel(
    checkboxInput(inputId = 'pageable', label = "pageable"),
    conditionalPanel("input.pageable == True", 
                     numericInput(inputId = 'pagesize', 
                                  label = 'Countries per page', 10))
    ), 
  mainPanel(
    htmlOutput("myTable")
  )
))

# server.R:

library(datasets)
library(shiny)
library(googleVis)

shinyServer(function(input, output){
  myOptions <- reactive({
    list(
      page = ifelse(input$pageable == TRUE, 'enable', 'disable'),
      pagesize = input$pagesize,
      height = 400
      )
  })
  output$myTable <- renderGvis({gvisTable(Population[,1:5], options = myOptions())})
})

#example 4:



# ui.R

require(googleVis)
shinyUI(pageWithSidebar(
  headerPanel("", windowTitle = "Example 4: GoogleVis with Interaction"),
  sidebarPanel(
    tags$head(tags$style(type = 'text/css', "#selected{ display:none; }")),
    selectInput("dataset", "Choose a dataset:", 
                choices = c("pressure", "cars")),
    uiOutput("selectedOut")
    ),
  mainPanel(tabsetPanel(
    tabPanel("Main",
             htmlOutput("view"),
             plotOutput("distPlot", width = "300px", height = "200px")),
    tabPanel("About", includeMarkdown('README.md'))
    ))  
  ))

# server.R
require(shiny)

shinyServer(function(input, output){
  datasetInput <- reactive({
    switch(input$dataset, "pressure" = pressure, "cars" = cars)
  })
  output$view <- renderGvis({
    jscode <- "var sel  = chart.getSelection();
      var row = sel[0].row;
      var text = data.getValue(row, 1);
      $('input#selected').val(text);
  $('input#selected').trigger('change');"
    gvisScatterChart(data.frame(datasetInput()),
                                option = list(gvis.listener.jscode = jscode,
                                              height = 200, width = 300))
  })
  output$distPlot <- renderPlot({
    if (is.null(input$selected)) {return(NULL)}
    dist <- rnorm(input$selected)
    hist(dist, main = input$selected)
  })
  output$selectedOut <- renderUI({
    textInput("selected", "", value = "10")
  })
  outputOptions(output, "selectedOut", suspendWhenHidden = F)
})

# example 5:
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


### scatterapp.R --------------------------------------------------------

## Not run:
# To run this example:
# shiny::runApp(system.file("shiny/", package="googleVis"))
# server.R
library(googleVis)

server = shinyServer(function(input, output) {
datasetInput <- reactive({
switch(input$dataset,
"rock" = rock,
"pressure" = pressure,
"cars" = cars)
})

output$view <- renderGvis({
gvisScatterChart(datasetInput(),
options=list(title=paste('Data:',input$dataset)))
})
})

# ui.R
ui = shinyUI(pageWithSidebar(
headerPanel("googleVis on Shiny"),
sidebarPanel(
selectInput("dataset", "Choose a dataset:",
choices = c("rock", "pressure", "cars"))
),
mainPanel(
htmlOutput("view")
)
))
## End(Not run)

#g = gvisScatterChart(rock, options=list(title=paste('Data:','rock')))
#plot(g)

shinyApp(ui, server)

###### Package graphics =========================================================

### art.R ------------------------------------
# http://www.r-graph-gallery.com/portfolio/data-art/
### barPlots.R ------------------------------------

set.seed(112)
data=matrix(sample(1:30,15) , nrow=3)
colnames(data)=c("A","B","C","D","E")
rownames(data)=c("var1","var2","var3")

# Get the stacked barplot
barplot(data, col=colors()[c(23,89,12)] , border="white", space=0.04, font.axis=2, xlab="group")

# Grouped barplot
barplot(data, col=colors()[c(23,89,12)] , border="white", font.axis=2, beside=T, legend=rownames(data), xlab="group", font.lab=2)




#Create data
set.seed(1124)
data=matrix(sample(1:30,15) , nrow=3)
colnames(data)=c("A","B","C","D","E")
rownames(data)=c("var1","var2","var3")

#create color palette:
library(RColorBrewer)
coul = brewer.pal(3, "Pastel2") 

#Transform this data in %
data_percentage=apply(data, 2, function(x){x*100/sum(x,na.rm=T)})

# Make a stacked barplot--> it will be in %!
barplot(data_percentage, col=coul , border="white", xlab="group")



#Let's build a dataset : height of 10 sorgho and poacee sample in 3 environmental conditions (A, B, C)
A=c(rep("sorgho" , 10) , rep("poacee" , 10) )
B=rnorm(20,10,4)
C=rnorm(20,8,3)
D=rnorm(20,5,4)
data=data.frame(A,B,C,D)
colnames(data)=c("specie","cond_A","cond_B","cond_C")

#Let's calculate the average value for each condition and each specie with the *aggregate* function
bilan=aggregate(cbind(cond_A,cond_B,cond_C)~specie , data=data , mean)
rownames(bilan)=bilan[,1]
bilan=as.matrix(bilan[,-1])

#Then it is easy to make a classical barplot :
lim=1.2*max(bilan)
ze_barplot = barplot(bilan , beside=T , legend.text=T , col=c("blue" , "skyblue") , ylim=c(0,lim))

#I becomes a bit more tricky when we want to add the error bar representing the confidence interval.

#First I create a smell function that takes...in entry
error.bar <- function(x, y, upper, lower=upper, length=0.1,...){
  arrows(x,y+upper, x, y-lower, angle=90, code=3, length=length, ...)
}

#Then I calculate the standard deviation for each specie and condition :
stdev=aggregate(cbind(cond_A,cond_B,cond_C)~specie , data=data , sd)
rownames(stdev)=stdev[,1]
stdev=as.matrix(stdev[,-1]) * 1.96 / 10

# I am ready to add the error bar on the plot using my "error bar" function !
ze_barplot = barplot(bilan , beside=T , legend.text=T,col=c("blue" , "skyblue") , ylim=c(0,lim) , ylab="height")
error.bar(ze_barplot,bilan, stdev)

### best_examples.R ------------------------------------
# http://www.r-graph-gallery.com/portfolio/basics/
### event_handler_example.R ------------------------------------
# This currently only works on the Windows
# and X11(type = "Xlib") screen devices...
## Not run: 
savepar <- par(ask = FALSE)
dragplot <- function(..., xlim = NULL, ylim = NULL, xaxs = "r", yaxs = "r") {
  plot(..., xlim = xlim, ylim = ylim, xaxs = xaxs, yaxs = yaxs)
  startx <- NULL
  starty <- NULL
  prevx <- NULL
  prevy <- NULL
  usr <- NULL
  
  devset <- function()
    if (dev.cur() != eventEnv$which) dev.set(eventEnv$which)
  
  dragmousedown <- function(buttons, x, y) {
    startx <<- x
    starty <<- y
    prevx <<- 0
    prevy <<- 0
    devset()
    usr <<- par("usr")
    eventEnv$onMouseMove <- dragmousemove
    NULL
  }
  
  dragmousemove <- function(buttons, x, y) {
    devset()
    deltax <- diff(grconvertX(c(startx, x), "ndc", "user"))
    deltay <- diff(grconvertY(c(starty, y), "ndc", "user"))
    if (abs(deltax-prevx) + abs(deltay-prevy) > 0) {
      plot(..., xlim = usr[1:2]-deltax, xaxs = "i",
           ylim = usr[3:4]-deltay, yaxs = "i")
      prevx <<- deltax
      prevy <<- deltay
    }
    NULL
  }
  
  mouseup <- function(buttons, x, y) {
    eventEnv$onMouseMove <- NULL
  }	
  
  keydown <- function(key) {
    if (key == "q") return(invisible(1))
    eventEnv$onMouseMove <- NULL
    NULL
  }
  
  setGraphicsEventHandlers(prompt = "Click and drag, hit q to quit",
                           onMouseDown = dragmousedown,
                           onMouseUp = mouseup,
                           onKeybd = keydown)
  eventEnv <- getGraphicsEventEnv()
}

x11()
dragplot(rnorm(1000), rnorm(1000))
getGraphicsEvent()
par(savepar)

## End(Not run)

### example.R ------------------------------------
# This currently only works on the Windows
# and X11(type = "Xlib") screen devices...
## Not run: 
savepar <- par(ask = FALSE)
dragplot <- function(..., xlim = NULL, ylim = NULL, xaxs = "r", yaxs = "r") {
  plot(..., xlim = xlim, ylim = ylim, xaxs = xaxs, yaxs = yaxs)
  startx <- NULL
  starty <- NULL
  prevx <- NULL
  prevy <- NULL
  usr <- NULL
  
  devset <- function()
    if (dev.cur() != eventEnv$which) dev.set(eventEnv$which)
  
  dragmousedown <- function(buttons, x, y) {
    startx <<- x
    starty <<- y
    prevx <<- 0
    prevy <<- 0
    devset()
    usr <<- par("usr")
    eventEnv$onMouseMove <- dragmousemove
    NULL
  }
  
  dragmousemove <- function(buttons, x, y) {
    devset()
    deltax <- diff(grconvertX(c(startx, x), "ndc", "user"))
    deltay <- diff(grconvertY(c(starty, y), "ndc", "user"))
    if (abs(deltax-prevx) + abs(deltay-prevy) > 0) {
      plot(..., xlim = usr[1:2]-deltax, xaxs = "i",
           ylim = usr[3:4]-deltay, yaxs = "i")
      prevx <<- deltax
      prevy <<- deltay
    }
    NULL
  }
  
  mouseup <- function(buttons, x, y) {
    eventEnv$onMouseMove <- NULL
  }	
  
  keydown <- function(key) {
    if (key == "q") return(invisible(1))
    eventEnv$onMouseMove <- NULL
    NULL
  }
  
  setGraphicsEventHandlers(prompt = "Click and drag, hit q to quit",
                           onMouseDown = dragmousedown,
                           onMouseUp = mouseup,
                           onKeybd = keydown)
  eventEnv <- getGraphicsEventEnv()
}

dragplot(rnorm(1000), rnorm(1000))
getGraphicsEvent()
par(savepar)

## End(Not run)

### graphics.R ------------------------------------
# http://www.r-graph-gallery.com/portfolio/circular-plot/


## A function to use function identify() to select points, and overplot the
## points with another symbol as they are selected
identifyPch <- function(x, y = NULL, n = length(x), pch = 19, ...)
{
  xy <- xy.coords(x, y); x <- xy$x; y <- xy$y
  sel <- rep(FALSE, length(x)); res <- integer(0)
  while(sum(sel) < n) {
    ans <- identify(x[!sel], y[!sel], n = 1, plot = FALSE, ...)
    if(!length(ans)) break
    ans <- which(!sel)[ans]
    points(x[ans], y[ans], pch = pch)
    sel[ans] <- TRUE
    res <- c(res, ans)
  }
  res
}

### likert.R ------------------------------------
# http://www.r-graph-gallery.com/202-barplot-for-likert-type-items/







###### Package: ioslide ===============================================
### tutorial.md ------------------
---
  title: "Habits"
author: John Doe
date: March 22, 2005
output:
  ioslides_presentation
---
  
  # In the morning
  
  ## Getting up {.build}
  
  - Turn off alarm
- Get out of bed

## Breakfast | What I like to do first thing

> - Eat eggs
> - Drink coffee

# In the evening

## Dinner {.smaller}

- Eat spaghetti
- Drink wine

----
  
  ![picture of spaghetti](images/spaghetti.jpg)

## Going to sleep

- Get in bed
- Count sheep

## Next Steps {.emphasized}

- Watch dreams
- Wake up the next day
### tutorial.Rmd ------------------------------
---
  title: "Habits"
author: John Doe
date: March 22, 2005
output:
  ioslides_presentation
---
  
  # In the morning
  
  ## Getting up {.build}
  
  - Turn off alarm
- Get out of bed

## Breakfast | What I like to do first thing

> - Eat eggs
> - Drink coffee

# In the evening

## Dinner {.smaller}

- Eat spaghetti
- Drink wine

----
  
  ![picture of spaghetti](images/spaghetti.jpg)

## Going to sleep

- Get in bed
- Count sheep

## Next Steps {.emphasized}

- Watch dreams
- Wake up the next day

###### Package: nirats ========================
### nirats.Rmd ----------------------------------
---
  title: "nirats: BI&A R Package for handling time series"
author: "Nima Ramezani"
date: "19 December 2016"
output: html_document
---
  
  ```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```

## What is nirats?

**nirats** is an R package produced in the Business Intelligent and Analytics team in CBA. 
This package is written to deal with various uni-variate and multi-variate time series.
This tutorial is to help you use this package.
...

Let's start with a simple example:

First import required packages:
```{r echo = TRUE, message = FALSE}
library(niragen)
library(nirats)
```
Now, let's make a TIME.SERIES object:
  <p>To create an instance of TIME.SERIES, you need to have your data in a data.frame.
The data.frame can be read from a .csv file or directly from ODBC server and must have one column containing time values (Date, POSIXlt, POSIXct, timeDate, ...).</p>
  
  You can also convert a ts object into a TIME.SERIES object:
  
  ```{r echo = TRUE, message = FALSE}
x = as.TIME.SERIES(AirPassengers)
names(x) <- 'PassCount'
```
Now, `x` is a TIME.SERIES object. It supports some generic functions like:
  
  ```{r}
length(x)
dim(x)
head(x)
tail(x)
names(x)
summary(x)
```

With a TIME.SERIES object, you can move on the time-line axis. To see the current time:
  ```{r}
x$now()
```

To jump to the next time stamp, use method `jump()`:
  ```{r}
x$jump()
x$now()
x$jump(10)
x$now()
```
To see the current value of a variable:
  ```{r}
x$current('PassCount')
```
You can change in time by refering to a specific time. You will jump to the first time stamp which is equal or greater than the specified time. If the given time is after than the latest time in the time series, you will jump to the last time-stamp:
  ```{r}
x$goto('1953-11-23')
x$now()
x$goto('2015-11-23')
x$now()
```
The current time number is stored in property `ctn`. 
Another property named as `stn` is used when you like to focus on a specific window within the time series.
To change the value of `stn` you should first go to your desired time and call method `reset()`:
  
  (NOte: Try to avoid changing property values directly as much as possible)
```{r}
x$stn
x$ctn
x$goto('1951-07-01')
x$ctn
x$reset()
x$stn
```

## Basic Visualisation:

The basic generic function `plot()` works on TIME.SERIES as well:
  ```{r echo=TRUE}
x$goto('1956-12-01')
plot(x)
```
Note that all plot functions, plot from starting time number until the current time number.

## Forecasting:
To predict future values of any figure in your time series, a predictive model needs to be trained with history data. It is assumed that all data prior to the current time (including current values) are included in the training. To train an *ARIMA* model, just go to the desired time at which you like to run the preduction and use method `updateForecast()`:
  
  ```{r echo=TRUE, message = FALSE}
x$goto('1957-01-31')
x$now()
x$updateForecast(figure = 'PassCount')
```
Now that the model has been trained, we use method `updateForecast()` to get forecasts for future:
  ```{r echo=TRUE}
x$predictNext(10, figure = 'PassCount')
```

## Advanced Visualisation:
You can employ various packages to draw elegant html-based plots. Various plots are available.
To use these features, you will need to have package *niravis* installed.
```{r echo=TRUE, message = FALSE}
library(niravis)
x$plot.history()
```

###### Package: notes ========================


### file:///C:/Nima/RCode/projects/tutorials/notes/09 November 2017 (Machine Learning with Spark).txt  ----------------------

https://spark.apache.org/docs/latest/ml-guide.html
### file:///C:/Nima/RCode/projects/tutorials/notes/10 Feb 2016 (Tableau Class).docx ------------------------
### file:///C:/Nima/RCode/projects/tutorials/notes/10 Jul 2017 (How I published a shiny dashboard for the first time).txt  ----------------------
Create ui and server objects: ui = dash.ui
Create an app object appobj = shinyApp(ui, server)
run the application: runApp(appobj, host = "0.0.0.0", port = '8080')

Then find your ip address: everybody should be able to see it: 
  example:   http://10.47.167.132:8080/
  
### file:///C:/Nima/RCode/projects/tutorials/notes/11 Jan 2016 (Steps to create a R package).txt  ----------------------
# Step 1: install and library devtools
install.packages('devtools')
library(devtools)
# step 2: Make a blank directory with the name of your package (without version) and setwd() to that path
# step 3: make a blank package devtools::document() --> select 1-yes
devtools::document()
# step 4: copy your roxygen documented .R file(s) to folder R in the package and run devtools::document() again
devtools::document()
# step 5: from RStudio menu --> build --> build and reload
# I received a warning:
# WARNING: Rtools is required to build R packages but is not currently installed. Please download and install
# the appropriate version of Rtools before proceeding:

# http://cran.rstudio.com/bin/windows/Rtools/
# I downloaded and installed it. It was known by devtools but not by detected by R Studio
# To check if Rtools is detected by devtools:
devtools::find_rtools(T)
# Scanning path...
# Scanning registry...
# Found c:/Rtools for 3.3
# VERSION.txt
# Rtools version 3.3.0.1959
# [1] TRUE
#
# To check if Rtools is in the R Studio path list:
Sys.getenv()['PATH']

# step 6: Check all your functions are available in the package, if not make sure they are mentioned in the NAMESPACE file in the root of your package

# Use function devtools::build() to build a compressed package ready to be installed by install.packages()
devtools::build()

http://r-pkgs.had.co.nz/man.html

http://r-pkgs.had.co.nz/data.html

### file:///C:/Nima/RCode/projects/tutorials/notes/12 June 2018 (My Performance Review).txt  ----------------------
I believe I have exceptionally demonstrated CBA values:
  
  Integrity: I always work with honesty and integrity. This has been acknowledged by the people who know me or have worked with me.

Excellence: I focus on using the best and latest technology to provide customized technical solutions to my customers. Innovation and out-of-the-box thinking, is a key attribute of my methodologies. I have the confidence to claim that my models are customised for specific business requirements and cannot be outperformed by other data scientists in terms of performance and accuracy!
  
  Smart Optimiser is a great example for this: 
  I reformulated the problem and changed solution space because the problem as formulated based on the definition of requirements could be extremely computationally expensive and not solvable by even fastest processors. The BMO team acknowledged that their initial methodologies failed to find the solution in a reasonable time.
The model is customized for CBA business requirements which makes it kind of unique in the world. 

Collaboration: Working closely with delivery team as well as end-user customers helped them understand the model and become familiar with it. This was achieved via lots of meetings (formal and informal) and training sessions. Just for Smart Optimiser, I spent more than 200 hours working with multiple model users down to the lowest level of details trying to help them go through various scenarios. These sessions also helped me to understand issues in the developed model as well as business requirements. I tried to hide complexities and designed the model to be as user‐friendly as possible so that it can be tuned, used in a proper and efficient way and implemented easily by a non‐technical user. 

Accountability: Supported by many examples, some of which outlined in my KPI reviews, I have demonstrated consistent accountability in all my projects as I believe everybody must be accountable for whatever he/she does. I dedicate to the projects and continuously work with the end customer or delivery team to address new requirement and rectify issues.

Judgement: I was trusted to be the leading data scientist in both my projects: ATM Optimisation and Smart Optimiser, which makes clear that my judgment capability was demonstrated. Fast and decisive decision making in ambiguous conditions is a key requirement in a data science project. Some examples are outlined in my KPI reviews.

Service: Smart Optimiser aims to improve the service we offer to our internal customers directly and external customers indirectly. I have seen through the project right up to when the business starts using the model on a regular basis. An example is the time I spent at Parramatta with the document custody team in GLS east aiming to fully understand their specific requirements and existing business constraints. This helped me to be able to customize the model to meet their requirements as much as possible. As a result of this service, I received a quarterly awards nomination from this team for whom we implemented the pilot run. 


RISK:
  
  Being accountable for risks associated with my models, I always spend adequate time to find out and list all possible incidents and issues which can be resulted from my models in all stages of design, delivery and production. For example, I am cautious of over‐trusting outputs of ML or optimisation models I train and build by testing and validating them multiple times before issuing the product to minimize unexpected and unreasonable outputs. 

I am aware of risks related to data security and do not share ant part of the data, information or insights with any party outside the team. 
As a career policy, I always complete my scheduled trainings before due date and follow standard operational procedures within CBA group.

KPIs:
  
  In this financial year, I have been leading the Smart Optimiser project which demonstrated results and benefits to the business. I was the only technical accountable person for the model. Most of evidences and examples I bring are therefore related to this project:
  
  Operating Model - following GDS operating model and ways of working:
  Being in the Group Function spoke within the hub & spoke operating model, we are expected to be the frontiers and have more interaction with the business.  This is what I emphasis in all my projects. As stated in the values section, I have held regular sessions with my stakeholders to ensure clear understanding of business requirements. I also share and exchange ideas with the hub and other spoke colleagues.  

Risk Culture:
  I have added my model, Smart Optimiser to the GDS risk register outlining all the risks associated with the project in delivery and production phase and appropriate controls. (You can find Smart Optimiser in the GDS risk register)

GDS Brand:
  
  Following core competency framework enabling clear skill enhancement
I enhanced my knowledge in the following areas:
  
  Recent vector-based NLP techniques for improved word metric determination.
Latest techniques of using elastic net and ridge regression techniques in improving the accuracy of ML models.
Improved visualisation techniques with D3 and Java-script based packages.  
New process mining algorithms.
Predictive process monitoring through ML and simulation.
BPMN standard, understanding semantics and data structure.


Delivery of projects within time and budget:
  
  Smart Optimiser model has been delivered successfully. The project has been productionized and is used by the business (FCO team and a few teams in GLS east and Bankwest). We are working on productionizing in enterprise level. In addition, I developed front-end UI to replace existing excel based UI giving business more control on using the model and improve task allocation in their teams. 
A web-based application integrated with a live running model is an essential requirement for delivery and productionizing of a data science project which extremely helps to deliver within budget.

Expand and deepen customer relationship:
  I shared details of technical solutions and methodologies behind Smart Optimiser with different staff in the BMO team. I had such technical sessions with Tim Pope, Eliot Dawson, Kelumi and Suraj himself.
I helped them build their custom settings and data input/output pipelines to use the model in their customized way. As a result, BankWest, FCO and GLS teams each use the model in their won customized way with different settings. 

Evidence of ensuring project focus on the financial wellbeing of people, businesses and communities:
  
  Smart Optimiser is currently used daily to allocate work to 100 FTE of 3 teams in GLS East, FCO team and one team in Bank-West. It is in progress to be deployed to 3 more teams in GLS East and 5 teams in Bank-West.
The last report generated by the Business Modelling and optimisation team in Group operations states that the FTE benefit realisation for FY 2018 is 13.3 FTE, which results in a cost savings of $590,000. This saving has been achieved via improving team throughput which means the productivity (count of jobs completed) in the same time and with the same amount of resources have improved by almost 13%. This has direct impact on our customer satisfaction.

For three of the teams in GLS east the values are:
  "	Document Custody team: Capacity creation of 1.3 FTE (45 hours per week) in a team of 26 FTE.
"	Aftercare NSW: Allocations done for 30 FTE with 2 FTE benefit realisation.
"	Credit Card: 2.5 FTE benefit realisation in a team of 30 FTE.

Discipline of 100% completion of PPMC when required:

Done timely mostly, Only a few examples of delay.

Improving productivity: focus on outputs that promotes self-service functionality and reusability:

The Smart Optimiser model and its UI are presented as a set of packages with API documentation provided for any developer. The documentation is clear, and the model is simple to use and exploit. This feature, enables the BMO team to run the model for different teams, each team by its own set of constraints and customized requirements with minimal coding efforts required. 

Experimentation - identify efficient ways of working and capabilities to improve velocity and profitability:

Culture - Participation in group and analytical initiatives to improve people engagement and drive one team culture:

"	Aries:
  A couple of sessions with Aries in which we discussed and brainstormed methodologies for AML and gain valuable features by building a network of transaction data.
"	Mohammad Multiple sessions and meetings with Mohammad regarding the Branch cash optimisation project. I tried to understand business requirements and share my experiences in the ATM cash optimisation project.
"	Event Miner peer review

Development - proactive self drive of own learning and development.

"	Process mining
"	Linux systems and Docker containers/Shiny Server/ application hosting/ product administration/ database connection/
  "	Visualisation techniques/ packages 


"	One day training on PKW
"	Constantly reading

Diversity and Community- Contribute and support the Group's expanding diversity and inclusion agenda:

"	Regular Interviews: I am a member of the interview panel and have had multiple stages 1 & 2 interviews with new Potential candidates. Example: Brad was interviewed by me and Stephan and is now a data scientist of GDS team.

Safety:
  
  I believe I have achieved expectations with respect to my KPIs over the last financial year. My efforts to build a mathematical optimisation model to solve the problem of optimal task allocation is an example where I have performed to the expectations set in the cost and advanced analytics KPIs.
The novel approach developed for the SO project was key to the model being used on a daily basis as the model run time reduced to seconds from hours.
Such a huge cost has now been eliminated from the business.
My model was instrumental in making the pilot implementation successful. Using this model Group Operations achieved
significant improvement in team throughput improving resource utilisation and significant reduction in backlogs as
demonstrated in their metrics.
The model led to improved service outcomes, significant reduction in team leader's time potentially increasing coaching
and other activities.



I was also a trusted advisor to the Business Modelling and Optimisation (BMO) team in group operations. 



The feedback from these teams have been consistently glowing and
the Smart Optimiser project would not be successful without Nima. The CEO award highlights what an asset he is to the
Group and how much of a role model he is.
In addition, Nima has demonstrated his ability to lead people. This has included working closely with Mustafizur initially on
the project, and now in his leading of Ryan, the new intern. Nima was also a mentor to many others in the team including
other associate data scientists. Many a time, these data scientists would comment that Nima was the most technically skilled
person they had worked with and sought his guidance often.
Lastly, Nima's resilience and unfailing attitude means that he is able to see his projects through from start to
implementation. Where a lot of people would be inclined to get frustrated or give up, Nima shows that he can stick with
any problem and find new ways and approaches. Nima has also become much more engaged with the business, working
hand‐in‐glove with them to understand what is needed.
Well done Nima!
  
### file:///C:/Nima/RCode/projects/tutorials/notes/13 Jan 2016 (Export data in a package).txt  ----------------------

To export data in a package, load it in the workspace and then
use

devtools::use_data(...)
... is list of items in the workspace you like to be available.
By default it is available external (For a user outside your package)

?use_data for more information:
  
  http://r-pkgs.had.co.nz/data.html

After this, you need to add the name of those variables in the namespace to be exported:
  
  example:
  
  use_data(wdlabel)

in NAMESPASE:
  
  export(wdlabel)

You don't need to define the variable in the code


### file:///C:/Nima/RCode/projects/tutorials/notes/14 May 2018 (ODBC in Linux).txt  ----------------------
To connect a linux machine to a database server by odbc, you need to have iodbc installed.

This should give you all your defined DSNs: 
odbcinst -q ?s

For example if SODEV2 is a DSN, you can check and see if you can connect to this database:

isql SODEV2 [uid] [pwd] ?v

Example:

isql SODEV2 rshinyuser smart1Optimiser2 ?v

Connect to databse in R using RODBC package:

go to R and type:

library(RODBC)
odbcConnect(dsn, uid, pwd) 
Example:
odbcConnect(dsn = 'SODEV2', uid = 'rshinyuser', pwd = 'smart1Optimiser2') 

### file:///C:/Nima/RCode/projects/tutorials/notes/16 May 2016 (get shiny input from gvis plot)
This is wonderful!
QUESTION:


Basically, I have a gvisCalendar Chart from the googleVis package in a Shiny app, and 
I want to display a dataTable underneath the chart that corresponds to a selected box.


I can add an event listener by setting the gvis.listener.jscode argument to a variable that holds a string 
of javascript code. 

For example, using this code, I can pull up the wikipedia page for a selected calendar date:


output$dates_plot <- renderGvis({

gvisCalendar(calendar.ddply,

options = list(

colorAxis = "{

minValue: 0,

colors: ['E9967A', 'A52A2A']

}",

gvis.listener.jscode = jscode2 )

)

})


jscode2<- "window.open('http://en.wikipedia.org/wiki/'

+ data.getValue(chart.getSelection()[0].row,0));

"


Using this code, I ran my program, selected the "June 16, 2015" box, and a new tab came up on my browser 
for this website: 
https://en.wikipedia.org/wiki/Tue_Jun_16_2015_00:00:00_GMT-0400_(EDT)


I don't actually want to do anything with wikipedia, 
I was just using that as an example.


All I want to do is save the date of the selected calendar box as an R object so that I can then display 
a data table of data that corresponds to that date.


I have almost no experience with javascript. 
Thank you!
  
  
  
  
  ANSWER:
  
  
  
  You can use Shiny.onInputChange to send data back to the server. 
Here is an example:
  
  
  
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
                   
                   var selected_date = data.getValue(chart.getSelection()[0].row,0);
                   
                   var parsed_date = selected_date.getFullYear()+'-'+(selected_date.getMonth()+1)+'-'+selected_date.getDate();
                   
                   Shiny.onInputChange('selected_date',parsed_date)")
                 
                 )
    
})
  
  output$date <- renderText({
    
    input$selected_date
    
  })
  }


ui <- shinyUI(fluidPage(
  
  htmlOutput("dates_plot"),
  
  textOutput("date")
))



shinyApp(ui = ui, server = server)






In this example I parsed the date to YYYY/M/D, if you want to keep the javascript long date format you can also
return selected_date.toString() instead of parsed_date.

to handle events by java script:
  
  
  https://developers.google.com/chart/interactive/docs/events

look 
at these links:
  
  
  https://ryouready.wordpress.com/2013/11/20/sending-data-from-client-to-server-and-back-using-shiny/
  
  
  http://stackoverflow.com/questions/31375480/using-observe-function-in-shiny-r



### file:///C:/Nima/RCode/projects/tutorials/notes/17 May 2017 (How to create a repository in stash with R Studio).txt  ----------------------

# If your R package or project is already written and in a folder:
Setp 1: Create an empty repository in stash:
  1.1: goto: https://stash.odp.cba/users/ramezani/ and click on 'Create repository'
1.2: select a name for your repo
Step 2: goto R studio and load your project/package: File --> Open project 
Step 3: goto Tools --> Version control --> Project setup --> Git/Svn , 
3.1: select Version Control System as 'Git'
3.2: Confirm new git repository (click Yes)
3.3: R will Restart or restart manually
(You should see tab 'Git' in the upper right panel)

Step 4: Select files to be added and commit with a message like "First Commit"
Step 5: In the upper-right panel menue, goto more --> shell
5.1: write: git config --global user.name "Nima Ramezani Taghiabadi"
5.2: git config --global user.email "nima.ramezani@gmail.com"
5.3: git remote add origin https://ramezani@stash.odp.cba/scm/~ramezani/atm_optimization.git
5.4: git config remote.origin.url https://ramezani@stash.odp.cba/scm/~ramezani/atm_optimization.git
5.5: git push -u origin master

You have Successfully transferred your project into a stash repository!
  
  
### file:///C:/Nima/RCode/projects/tutorials/notes/19 Feb 2018 (Advanced R programming).txt  ----------------------
Advances R programming:
  
  https://adv-r.hadley.nz/r6.html
### file:///C:/Nima/RCode/projects/tutorials/notes/19 Nov 2015 (Comments to Megan).txt  ----------------------
You don't need to write a loop to convert each text. Function gsub() applies conversion to a text vector as well.
So you can sinply use for example:

Corpus_Cont <- gsub("customers", "customer", Corpus_Cont)

### file:///C:/Nima/RCode/projects/tutorials/notes/19 Nov 2015 (R Version Problem).txt  ----------------------
What did I learn today:

to change the version of R underneath R Studio:
goto Tools --> Global Options --> General --> R Version --> Chaneg
Select the folder to your new R versio
Example:  [64-bit] \\naunsw001\ramezani\R\R-3.2.2

Note: Good to know that you can extract the latest versin of R any where in your computer without having administrator access.


### file:///C:/Nima/RCode/projects/tutorials/notes/20 Dec 2017 (Goodbye letter to Kelumi).txt  ----------------------
Kelumi,
Thank you for your contribution in Smart Optimiser.
It was a pleasure working with You. 
I have the best wishes for your future career.
### file:///C:/Nima/RCode/projects/tutorials/notes/20 Jan 2016 (Task page on confluence).txt  ----------------------
To add a task list on a page:
Edit the page.
Choose the task-list icon in the editor toolbar, or press [ and then ] on your keyboard.
Type the description of the task.
If you want to assign a task to someone, type '@' and the person's name in the task description. ...
To end the list, press Enter twice.
### file:///C:/Nima/RCode/projects/tutorials/notes/20 September 2017 (My farewell note for Rajesh).txt  ----------------------
Rajesh,

Working with you was a great advantage for me. I learned a lot from you.
I found a great leader, a good friend and a knowledgeable data scientist in you! 
  Thanks for everything and I really hope our paths cross again soon.
Wish you best of success in your future career and great happiness in your life with esteemed family.
### file:///C:/Nima/RCode/projects/tutorials/notes/21 Jan 2016 (R6 classes in R).txt  ----------------------
How to make R6 classes in R:
  
  https://cran.r-project.org/web/packages/R6/vignettes/Introduction.html
### file:///C:/Nima/RCode/projects/tutorials/notes/21 September 2017 (My farewell note for Mahesh).txt  ----------------------
Hey Magician!
  
  Your contribution was truly valuable for the team. I don't think there is even one person in 
BI&A who has not worked with you or used your magic in his/her project! 
You were always fostering our models with good quality data and without you, it will be hard to provide food for them!
I wish the best for you in your future career. You will be missed a lot.
Regards
### file:///C:/Nima/RCode/projects/tutorials/notes/22 Jan 2016 (extend a data.frame with a ref class).txt  ----------------------
Today I did some research on how to extend a data.frame with a ref class in R
I found this:


[Rd] how to properly extend s3 data.frames with s4 classes?

Ulf Martin ulfmartin at web.de 
Wed Jan 24 12:28:46 CET 2007
Previous message: [Rd] Useful statusbar in RGui
Next message: [Rd] how to trace what crashes R
Messages sorted by: [ date ] [ thread ] [ subject ] [ author ]
Dear R Programmers!

After some time of using R I decided to work through John Chambers book 
"Programming with Data" to learn what these S4 classes are all about and 
how they work in R. (I regret not having picked up this rather fine book 
earlier!)

I know from the documentation and the mailing archives that S4 in R is 
not 100% the book and that there are issues especially with dataframes, 
but to my knowledge the following has not been reported yet.


Summary
-------
(a) When extending a S3 data.frame with a S4 class adding a slot, it 
seems to be impossible to initialize objects of these 
"ExtendedDataframes" (XDF) with S3 data.frames.

(b) Extending data.frames with an S4 class without a slot, i.e. creating 
a "WrappedDataframe" (WDF), seems to allow initialization with a 
data.frame, but the behaviour appears to be somewhat inconsistent.

(c) Trying to be "smart" by extending the WrappedDataframe from (b) by 
adding a slot, yields a similar behaviour than (a), i.e. initialization 
with a WDF object fails although WDF is an instance of an S4 class.

It is actually (c) that surprises me most.


Code
----
# (Should be pastable into an R session)
# R version is 2.4.1
#
# === Preliminaries ===
# (">" indicates output)
#
library("methods")
setOldClass("data.frame")
tdf <- data.frame(x=c(1,2), y=c(TRUE,FALSE)) # For testing purposes
#
# === (a) Exdended Dataframe Case ===
#
XDF <- "ExtendedDataframe" # Convenient shortcut
setClass(XDF, representation("data.frame", info="character"))
getClass(XDF)
#
# > Slots:
# >
# > Name:       info
# > Class: character
# >
# > Extends:
# > Class "data.frame", directly
# > Class "oldClass", by class "data.frame", distance 2
#
# So far everything looks good.
# But now,
#
new(XDF)                                 # a1)
new(XDF, data.frame())                   # a2)
new(XDF, tdf, info="Where is the data?") # a3)
#
# all yield:
#
# > An object of class "ExtendedDataframe"
# > NULL
# > <0 rows> (or 0-length row.names)
#
# Only (a3) additionally has
#
# > Slot "info":
# > [1] "Where is the data?"
#
# === (b) Wrapped Dataframe ===
#
WDF <- "WrappedDataframe"
setClass(WDF, representation("data.frame"))
getClass(WDF)
#
# > No Slots, prototype of class "S4"  # N.B.!
# >
# > Extends:
# > Class "data.frame", directly
# > Class "oldClass", by class "data.frame", distance 2
#
new(WDF)
#
# > <S4 Type Object>
# > attr(,"class")
# > [1] "WrappedDataframe"
# > attr(,"class")attr(,"package")
# > [1] ".GlobalEnv"
#
# Now we have attributes -- there wheren't any with XDF.
# Thus, not supplying a slot adds attributes -- confusing.
#
# Now: Initialization with an empty data.frame instead of nothing:
#
new(WDF, data.frame())
#
# > An object of class "WrappedDataframe"
# > Slot "row.names":
# > character(0)
# > Warning message:
# > missing package slot (.GlobalEnv) in object of class
# > "WrappedDataframe" (package info added) in: initialize(value, ...)
#
# OBS! Now there is
#  (i) a slot "row.names" -- which is wrong
#      since WDFs aren't suposed to have any slots;
# (ii) an odd warning about another missing slot
#      (presumably called "package" but the message is
#      somewhat ambigous).
#
# But at least
#
new(WDF, tdf)
#
# yields:
#
# > $x
# > [1] 1 2
# >
# > $y
# > [1]  TRUE FALSE
# >
# > attr(,"row.names")
# > [1] 1 2
# > attr(,"class")
# > [1] "WrappedDataframe"
# > attr(,"class")attr(,"package")
# > [1] ".GlobalEnv"
# > Warning message:
# > missing package slot (.GlobalEnv) in object of class
# > "WrappedDataframe" (package info added) in: initialize(value, ...)
#
# So, at least the data seems to be there. Let's use this one.
#
wdf <- new(WDF, tdf)
#
# === (c) "Smart" Dataframes ===
#
SDF <- "SmartDataframe"
setClass(SDF, representation(WDF, info="character"))
getClass(SDF)
#
# > Slots:
# >
# > Name:       info
# > Class: character
# >
# > Extends:
# > Class "WrappedDataframe", directly
# > Class "data.frame", by class "WrappedDataframe", distance 2
# > Class "oldClass", by class "WrappedDataframe", distance 3
#
# Now I would expect this:
#
new(SDF,wdf)
#
# to show the data in wdf, but in fact I get:
#
# > An object of class "SmartDataframe"
# > NULL
# > <0 rows> (or 0-length row.names)
# > Slot "info":
# > character(0)
#
# which is the same as:
#
# new(SDF)
# #
# # or
# #
# new(SDF, data.frame())
# #
# # The slot does get initialized, though
# #
# new(SDF,wdf,info="Where is the data?")
# new(SDF,tdf,info="Where is the data?")
# #
# END OF CODE


# Further Remarks
# ---------------
#   The rationale behind being able to extend S3 data.frames with S4 classes 
# is that
# (a) there is so much legacy code for data.frames (they are the 
#                                                   foundation of the data part in "programming with data");
# (b) S4 classes allow for validation, multiple dispatch, etc.
# 
# I also wonder why the R developers chose this "setOldClass" way of 
# making use of S3 classes rather than adding a clean set of wrapper 
# classes that delegate calls to them cleanly down to their resp. S3 
# companions (i.e. a "Methods" package (capital "M") with "Character", 
#             "Numeric", "List", "Dataframe", etc.). The present situation appears to 
# be somewhat messy.
# 
# 
# Anyway -- a great tool and great work!
#   Cheers!
#   Ulf Martin
# 
# Previous message: [Rd] Useful statusbar in RGui
# Next message: [Rd] how to trace what crashes R
# Messages sorted by: [ date ] [ thread ] [ subject ] [ author ]
# More information about the R-devel mailing list
# 
# 
# 
# 
# Also, read this:
#   http://www.carlboettiger.info/2013/09/11/extending-data-frame-class.html

### file:///C:/Nima/RCode/projects/tutorials/notes/22 May 2018 (How I created Personal Access token in Github Entherprise).txt  ----------------------

### file:///C:/Nima/RCode/projects/tutorials/notes/22 Nov 2017 (How I bought a ticket to Perth).txt  ----------------------
Buy Tickets:
  
  one.cba --> commnet --> tools --> travel (Under Administration)

Takes you to Concur Travel Agent website

You will need a corporate card to pay,
If you need a hotel reservation as well, you should tick the hotel reservataion before searching for the flight


### file:///C:/Nima/RCode/projects/tutorials/notes/28 Jun 2016 (Importing a R package within another).txt  ----------------------
If your package is using a function from another package, you should import that function in the namespace
For example:
  By putting this line in the code:
  #' import timeDate
  #' import niragen
  
  Roxygen will add it to the namespace

Also in the 
DESCRIPTION file of your package:
  You should add a line like this:
  Import:
  timeDate, nirgaen, ...


### file:///C:/Nima/RCode/projects/tutorials/notes/30 Jan 2018 (How I dockerized my app).txt  ----------------------
* How I installed docker on the linux machine:
  
  1- run putty and ssh to the ODP Linux server: s029ndpl0703.s4.chp.cba
2- login with your credentials: username and LDAP pass: R1d@mBeGh@breB@b@t
3- Installed docker on the attached drive: 
  
  [ramezani@s029ndpl0703 ~]$sudo yum -y install docker --installroot=/mnt/test/ --nogpgcheck

If you want to find which versions of each software is available on the satellite:
  $sudo yum list docker  --showduplicates | sort -r
$sudo yum list R  --showduplicates | sort -r


### file:///C:/Nima/RCode/projects/tutorials/notes/30 Nov 2015 (Payment Blue sky ideas).txt  ----------------------

In terms of the process:
  
  Bottle necks
process graph
Quality measure
E2E process time

Descriptive:
  
  Associative Rule
Identify Transaction Patterns  
Fraud Pattern Detection


Prediction:
  
  Spends
Transaction Types (Volume and Frequency)
Location        

### file:///C:/Nima/RCode/projects/tutorials/notes/links.txt  ----------------------
Group Emergency Hotline: 1800 643 410 
Speak Up: 1800 SPEAKUP

Windows Server: s029ncww4185.s4.chp.cba
Use Remote Desktop Connection --> Advanced --> Settings --> Use these RD gateway server settings:
  Server name: remoteaccess.s4.chp.cba
Log-on method: Allow me to select later
Check Use my RD Gateway credentials --> Ok


BI&A Linux RHEL ODP Server for shiny: s029ndpl0703.s4.chp.cba
user: ramezani
pass: ridam be ghabre babat

SQL Server: s029npcw9515.s4.chp.cba

Analytics Community:
  https://confluence.prod.cba/display/CAN/Analytics+Capabilities+and+Community+of+Practice
https://confluence.prod.cba/display/CAN/Analytics+Initiatives+and+Networking+Events

Analytics Chatter Group:
  https://commbank.my.salesforce.com/_ui/core/chatter/groups/GroupProfilePage?g=0F9D0000000TplX

Whereabouts:
  http://myteamspace.cba/sites/es/OIA/OurTeam/Team%20Information/Forms/AllItems.aspx?RootFolder=%2fsites%2fes%2fOIA%2fOurTeam%2fTeam%20Information%2fBusiness%20Intelligence%20and%20Analytics%20%2d%20Team%20Whereabouts&FolderCTID=&View=%7b01105085%2d5A99%2d4FCC%2d988E%2d7A7A37703A8D%7d

Our Shared Space:
  M:\CDO_MTK_SMT\Business Performance Reporting

Guide to use mobile:
  http://commnet2.cba/Main/IT/workplace_IT/mobility_services/mymobilesync/overview/Documents/iPhone%20Starter%20Guide%20190315.pdf

Apply for leave:
  commnet2 --> tools --> Peoplesoft (HR) --> user (00369390) & pass --> Self Service --> Time Reporting --> Report Time --> Absence Request 

My Commbank account number:
  BSB: 062-140
Account Number: 10860729
SWIFT: CTBAAU2S
Complete International Account Numebr: CTBAAU2S-062140-10860729

How to create timeSheet:
  
  1- Goto: https://ppmc.cba/itg/tm/ShowCreateTimeSheet.do?resourceHV=232067&periodId=100029&changeDescription=Y  use credentials to login
2- Open --> time management --> time sheets --> create time sheet --> 
  3- select time period --> click on create 
4- Click on Add Items --> Miscellaneous 
5- Starts with Core Administration
6- Fill hours and submit
hours should add up to 18 hours

Parallel model building in R:
  https://stash.odp.cba/projects/OMNIA/repos/datascience.gists/browse/R_parallel_data_frame


GDW Dictionary:
  http://gdwdictionary.cba/mpa/SelectionGeneric.aspx?app=erw&ex=GDW+Master+Model&md=b&vID=1
http://gdwdictionary.cba/mpa/SelectionGeneric.aspx?app=erw&ex=GDW+Master+Model&md=b&vID=1

Markov Renewal Process:
  https://en.wikipedia.org/wiki/Markov_renewal_process#References_and_Further_Reading

Continuous-time Markov chain
https://en.wikipedia.org/wiki/Continuous-time_Markov_chain

https://en.wikipedia.org/wiki/Master_equation

SQL Tutorial:
  http://www.w3schools.com/sql/sql_and_or.asp

Link to ATM optimization folder:
  M:\CDO_MTK_SMT\Business Performance Reporting\Tableau Dashboards\VCC\PS\Cash and ATM\Off Premise ATM Cash Rebanks\Opportunity Sizing Presentation\National\Optimization Model

Link to Call Center data:
  \\flsy04\G_TS_SY$\CDO_MTK_SMT\Business Performance Reporting\Tableau Dashboards\VCC\PS\Call Centre

ATM (Analytics Team Meeting)
\\flsy04\G_TS_SY$\CDO_MTK_SMT\Business Performance Reporting\Team Information\Team Meetings\Decision Science and Insights Team

Link to Contact Center Data:
  \\Flsy04\G_ts_sy$\CDO_MTK_SMT\Business Performance Reporting\Rajesh Thiagarajan\Contact Centre\PropensityToCallPrediction\CC_PREDICTION_DATA

KPI performance reviews:
  https://cba.csod.com/EPM/Reviews/UserReview.aspx

1- find my phone app


IP address of server: teradata.gdw.cba
10.25.111.248
10.25.111.250

Can Coaching

Algorithms:
  
  10 Top algorithms in data mining:
  http://rayli.net/blog/data/top-10-data-mining-algorithms-in-plain-english/
  
  
  Shiny Apps as Analytics Tools:
  https://www.rstudio.com/products/shiny/shiny-user-showcase/
  
  R Documentations:
  http://www.rdocumentation.org/packages/shinydashboard

GitHub ShinyDash:
  https://github.com/trestletech/ShinyDash


http://walkerke.github.io/2014/03/tfr-in-europe/
  
  to change your password in teradata:
  control panel --> administrative tools --> ODBC Data Sources (64-bit) --> find and select your source and click on configure(example: Teradata_Prod) 
or add one,
--> 
  put a name and description --> write the server name or its IP address 
--> Authentication: mechanism = Idap, put username and password

To see your payslips:
  HR --> Peoplesoft HR --> enter employee ID & password --> Payroll and Compensation --> view payslips

stash:
  https://stash.odp.cba/login?nextUrl=%2Fdashboard

My repositories in stash:
  
  https://stash.odp.cba/users/ramezani

Repos for cloning:
  niragen: https://ramezani@stash.odp.cba/scm/~ramezani/niragen.git

My repos in cba github:
  
  https://github.source.internal.cba/ramezani?tab=repositories


JPs in CBA:
  
  CBP (1 Harbour Street):
  Adam Crabbe
Kathryn Cheal
Sanoja Chand


150 George Street



Yammer:
  https://www.yammer.com/cba.com.au/#/Threads/show?threadId=904302923 
  
  Where should I go on holidays?
  1- https://thegrounds.com.au/make-a-reservation/
  
  
  
  Exetel NBN reference number 11743951  $100 for non-locked activation fee, with 30 days of notice

Look:
  https://www.adma.com.au/
  https://www.yhat.com/
  https://rapidminer.com/products/studio/
  databricks

Yammer:
  https://www.yammer.com/cba.com.au/#/threads/inGroup?type=in_group&feedId=13780441&view=all
  
  
  Smart Optimiser agile board:
  
  VMB: Agile Board:
  https://jira.odp.cba/secure/RapidBoard.jspa?rapidView=4392&projectKey=SOPT&view=detail&selectedIssue=SOPT-73
List of Tasks:
  https://jira.odp.cba/secure/RapidBoard.jspa?rapidView=4392&view=planning.nodetail

R Package Archive:
  https://cran.r-project.org/src/contrib/Archive/
  
  
  CBA Tableaue Dashboards:
  https://tableau.cba/#/site/ESInfMgmt/projects
  
  
  Link to i360 and DPA data:
  https://wfm.awfm.cba:7002/wfo/control/signinSSO

All R packages:
  https://mran.revolutionanalytics.com/snapshot/2018-01-19/web/packages/available_packages_by_name.html


Generic username and password for teradata:
  SUOPSANA01
Service#15Connect

CBA Github:
  https://github.ai.cba/organizations/gds/repositories/new

My latest token (30 Oct 2018):
  ab6afeab8c82a544a97f7422c34a42aac8d92024

https://github.ai.cba/ramezani/niraprom-master.git

CBA RStudio:
  https://rstudio.aiaa.ai.cba/s/eb7b9cfc78a311bf6f45b/
  
  RSConnect:
  http://connect.aiaa.ai.cba

R Artifactory:
  Repos = ‘cran.dev.cba’
http://artifactory.dev.cba/artifactory/au.csiro.cran/
  
  
  link to Group Model Register (GMR):
  https://rmportal.cba/gmr/Lists/ModelRegister/Model%20Register.aspx

Guestwifi pass: ^-0cr0ssw1re5

Web link to omnia: 
  http://hueui-omniadatascience.cba/beeswax/execute/query/604069#query/logs

Link to Systemic Issues project:
  https://github.ai.cba/gds/operations.systemicissues/blob/master/POC/Documentation.md


Javascript Charting libraries:
  http://leebyron.com/streamgraph/
  https://tmroyal.github.io/Chart.Streamgraph/
  
  
  
  Hi, this is Nima Ramezani
Unforetunately, I am not available at the moment, so please leave your details and I will contact you as soon as I can, Thank you
### file:///C:/Nima/RCode/projects/tutorials/notes/tutorialsall.R

### file:///C:/Nima/RCode/projects/tutorials/notes/04 Jan 2018 (Created smart optimiser repo in github.io.cba).txt  ----------------------
# Disable Git SSL verification in the server hosting FishEye/Crucible with the following commands:
# git config --global http.sslVerify false
### file:///C:/Nima/RCode/projects/tutorials/notes/04 September 2017 (How I built niragen package in linux RHEL6.txt  ----------------------
* Make a local clone of the repo on the hard disk:
  
  1- run putty and ssh to the ODP Linux server: s029ndpl0703.s4.chp.cba
2- login with your credentials: username and LDAP pass
3- ls to the folder you like to put the repo
4- git clone https://ramezani@stash.odp.cba/scm/~ramezani/niragen.git

* Install required packages in R if they are not installed:
  
  1-  type R (enter) to goto R console
2-  options(repos=structure(c(CRAN="http://cran.dev.cba/")))
3-  install.packages('devtools')
- to get lib directories that R uses: in R call this function: .libPaths()
- to get the default library: .Library
- to call a R function or run a R script outside R: R -e 'your R script comes here'
Example: sudo R -e 'install.packages("curl", repos = "http://cran.dev.cba/", lib = "/usr/lib64/R/library/")'

to download a file from a url to current directory: example:
  wget "http://domain.com/directory/4?action=AttachFile&do=view&target=file.tgz"

to download to a specific directory (example)
wget  -O /home/omio/Desktop/ "http://thecanadiantestbox.x10.mx/CC.zip"

3-1: Installing package devtools failed! Because package 'curl' could not be unpacked. When tried to  install 'curl', faced this error:
  
  Configuration failed because libcurl was not found. Try installing:
  * deb: libcurl4-openssl-dev (Debian, Ubuntu, etc)
* rpm: libcurl-devel (Fedora, CentOS, RHEL)
* csw: libcurl_dev (Solaris)
If libcurl is already installed, check that 'pkg-config' is in your
PATH and PKG_CONFIG_PATH contains a libcurl.pc file. If pkg-config
is unavailable you can set INCLUDE_DIR and LIB_DIR manually via:
  R CMD INSTALL --configure-vars='INCLUDE_DIR=... LIB_DIR=...'
--------------------------------------------------------------------
  ERROR: configuration failed for package ?curl?
  * removing ?/usr/lib64/R/library/curl?
  
  3-1-1) sudo yum -y install libcurl libcurl-devel
3-1-2) sudo R -e 'install.packages("curl", repos = "http://cran.dev.cba/", lib = "/usr/lib64/R/library/")'
3-1-3) install package httr 
3-1-3-1) you need to download the source .tar.gz manually from cran. Goto where you downloaded the file and then goto R
3-1-3-2) > install.packages("httr_1.3.1.tar.gz", repos = NULL, type = "source")	

3-1-4) sudo R -e 'install.packages("devtools", repos = "http://cran.dev.cba/", lib = "/usr/lib64/R/library/")'

4- install 'roxygen2'
4-1) install 'xml2' and 'commonmark' manually
4-2) sudo yum -y install libxml2 libxml2-devel
4-3) sudo R -e 'install.packages("xml2_1.1.1.tar.gz", repos = NULL, type = "source")'
4-4) sudo R -e 'install.packages("commonmark_1.4.tar.gz", repos = NULL, type = "source")'
4-5) sudo R -e 'install.packages("roxygen2", repos = "http://cran.dev.cba/", lib = "/usr/lib64/R/library/")'

5- Now you are ready to build packages: goto the root folder of your package and type R: devtools::build(binary = TRUE, args = c('--preclean'))
(build all packages like that) 
Start building and installing niragen:	
  5-1) git clone https://ramezani@stash.odp.cba/scm/~ramezani/niragen.git
5-2) build niragen: cd niragen --> R --> devtools::build(binary = TRUE, args = c('--preclean')) --> q()
5-3) sudo R -e 'install.packages("niragen_2.1.2_R_x86_64-redhat-linux-gnu.tar.gz", repos = NULL, type = "source")'
Start building and installing niraprom:	
  5-4) install tibble manually: version >= 1.3.4 is required --> copy the .tar.gz file from cran and cd to where it is copied 
5-5) sudo R -e 'install.packages("rlang", repos = "http://cran.dev.cba/", lib = "/usr/lib64/R/library/")'
5-6) sudo R -e 'install.packages("tibble_1.3.4.tar.gz", repos = NULL, type = "source")'
5-7) sudo R -e 'install.packages("dplyr", repos = "http://cran.dev.cba/", lib = "/usr/lib64/R/library/")'
5-4) cd niraprom --> R > options(repos=structure(c(CRAN="http://cran.dev.cba/"))) --> devtools::build(binary = TRUE, args = c('--preclean'))
5-5) cd niravis	--> R >  options(repos=structure(c(CRAN="http://cran.dev.cba/"))) --> devtools::build(binary = TRUE, args = c('--preclean'))

6- Other required packages:
  6-1) lpSolve: install.packages("lpSolve", repos = "http://cran.dev.cba/")


Latest CBA R Artifactory: http://artifactory.dev.cba/artifactory/com-revolutionanalytics-mran-remote/2017-02-14/
  
  to get the version of an installed package in R: example: packageVersion('shiny')

to disable connection timeout, send packets every 10 seconds:
  putty --> change settings --> connection --> Seconds between keepalives(0 to turn off): 10


R1d@mBeGh@breB@b@t

export ODBCSYSINI=/usr/local/etc
export ODBCINI=/usr/local/etc/odbcini
export LD_LIBRARY_PATH=/usr/local/lib


LD_LIBRARY_PATH look for /usr/loccal/lib

look for unixodbc
### file:///C:/Nima/RCode/projects/tutorials/notes/05 Feb 2018 (Some RHEL terminal commands).txt  ----------------------

# To change read/write permission:
#   sudo chmod 755 -R /srv/shiny-server/<foldername>
#   
#   To change the mode of a file, use the chmod command. The general form is
# 
# chmod X@Y file1 file2 ...
# where: X is any combination of the letters `u' (for owner), `g' (for group), `o' (for others), `a' (for all; that is, for `ugo'); @ is either `+' to add permissions, `-' to remove permissions, or `=' to assign permissions absolutely; and Y is any combination of `r', `w', `x'. Following are some examples:

# chmod u=rx file        (Give the owner rx permissions, not w)
# chmod go-rwx file      (Deny rwx permission for group, others)
# chmod g+w file         (Give write permission to the group)
# chmod a+x file1 file2  (Give execute permission to everybody)
# chmod g+rx,o+x file    (OK to combine like this with a comma)
# 
# go here for more information:
# https://www.washington.edu/computing/unix/permissions.html
# 
# Load docker image from docker image file
# $ sudo docker load < my_r_image.docker
# 
# To build the docker image:
# $ cd dockerTest/
# $ sudo docker build -t test .
# 
# To launch the docker image:
# $ sudo docker run -it <docker_image>
# Example:
# $ sudo docker run -it docker.artifactory.ai.cba/aiaa/r-essential:3.4.2r1-mran
# 
# 
# You can launch an image and run a command or a series of commands in the container:
# Example:
# $ sudo docker run -p 8080:8080 test R -e "library(shiny);runApp('projects', host = '0.0.0.0', port = 8080)

Example of a shiny ui in docker container:
# https://github.com/flaviobarros/shiny-wordcloud/blob/master/Dockerfile

To get the list of all repositories: 
$ sudo yum repolist all

Gives you a list of all files:
$ du -h | sort -r

Gives you the current folder:
$ pwd

Gives you a list of mounted drives:

$ df
$ df -h (gives better view)
$ df -Th (also gives the file system of each drive)
File systems are like: xfs, devtmpfs, tmpfs, ext3, ext4, ...
Some file systems are limited to a certain total space

Command du(disk usage) gives you a list of files and folders with their sizes:
$ du
$ du -sh *  (Summaraizes and makes more human readable)


Gives you list of files and folders with user rights 
$ ls -ltr

Gives you where a program is installed (address the program is called from)
$ which yum

Where rpm has installed a package?
$ rpm -ql <package_name>

Link to agility:
https://agility.s4.chp.cba:8443/agility/login.html

to copy a folder recursively with all attributes:
sudo cp -rp smartoptimiser sodc
### file:///C:/Nima/RCode/projects/tutorials/notes/07 Feb 2018 (How to publish shiny app with shiny-server in Linux).txt  ----------------------
You need to first install shiny-server

After installation:
- To start or stop shiny server:
$ sudo systemctl stop shiny-server
$ sudo systemctl start shiny-server

The config file is usually here:
etc/shiny-server/shiny-server.conf

There is a text file containing important commands like which port should the app be published or the physical address of the apps:
This file is named shiny-server.conf and is usually in: /etc/shiny-server/
Contents of shiny-server.conf:
# Define the user we should use when spawning R Shiny processes
run_as shiny;

# Define a top-level server which will listen on a port
server {
# Instruct this server to listen on port 80. The app at dokku-alt need expose PORT 80, or 500 e etc. See the docs
listen 80;

# Define the location available at the base URL
location / {

# Run this location in 'site_dir' mode, which hosts the entire directory
# tree at '/srv/shiny-server'
site_dir /srv/shiny-server;

# Define where we should put the log files for this location
log_dir /var/log/shiny-server;

# Should we list the contents of a (non-Shiny-App) directory when the user 
# visits the corresponding URL?
directory_index on;

After copying each app in a folder in the shiny-server site directory: usually: srv/shiny-server/
start shiny-server and all the apps will be deployed:
<server_name or http://ip_address>:<port_number>/<app_dirname>
Example:
http://10.39.4.184:3838/simple_app_test/
or
http://s029ndpl0703.s4.chp.cba:3838/simple_app_test/


#### file:///C:/Nima/RCode/projects/tutorials/notes/07 Jul 2017 (I got my access to the Redhat ODP Server).txt  ----------------------


###### Package Officer ======================================================================
### Example.R ---------------------------
library('mschart')
linec <- ms_linechart(data = iris, x = "Sepal.Length",
                      +                       y = "Sepal.Width", group = "Species")
linec <- chart_ax_y(linec, num_fmt = "0.00", rotation = -90)
linec
# https://davidgohel.github.io/officer/

####### Folder presentations/brokers/script: ================================
### brokers_v3.R: -----------------------
---
  title: "Broker Segmentation (Version 3)"
author: "Nima Ramezani"
date: "13 June 2017"
output: html_document
runtime: shiny
---
  
  ```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
library(magrittr)
library(ggplot2)
library(plotly)
source('C:/Nima/RCode/projects/libraries/developing_packages/niragen.R')
source('C:/Nima/RCode/projects/libraries/developing_packages/visgen.R')
source('C:/Nima/RCode/projects/libraries/developing_packages/plotly.R')
```

## Broker Segmentation

**Brokers** are currently clustered to five different grades: 
  `r brokers = read.csv('../data/brokers.csv'); brokers$BROKER_GRADE %>% levels`

We are trying to cluster the brokers based on seven dimensions reflecting different aspects of broker performance. These metrics include:
  
  * Settlement Value (in dollar)
* Settled Volume (Count of settled apps)
* Count of Calls
* Exception Rate (Ratio of apps with exception to total)
* Conversion to Approved (Ratio of approved to Submitted)
* Conversion to Settled (Ratio of settled to submitted)
* Risk based on ratio of IO Deals to total (IO & PI)

To remove outliers and normalize the data, we smart-mapped the first three metrics into the range of 0 and 1. Smartmap is a special mapping which devides the mapping range into a number of weighted intervals  based on the count of values in various qunatiles where each interval is associated with one quantile. So we build a new table with normalized values:
  
  ```{r echo = FALSE}
# Reading and Preparation:
broker <- read.csv('../data/brokers4.csv', stringsAsFactors = F)

# broker = broker[, -1]

broker$IO_VOL[broker$IO_VOL == '?'] = NA
broker$PI_VOL[broker$PI_VOL == '?'] = NA
broker$EXCEP_APP[broker$EXCEP_APP == '?'] = NA
broker$NO_EXCEP_APP[broker$NO_EXCEP_APP == '?'] = NA
broker$TOTAL_APP[broker$TOTAL_APP == '?'] = NA

broker %<>% na.omit

broker$APPT_VOL[broker$APPT_VOL == '?'] = 0
broker$APRD_VOL[broker$APRD_VOL == '?'] = 0
broker$SETT_VOL[broker$SETT_VOL == '?'] = 0
broker$SETT_VAL[broker$SETT_VAL == '?'] = 0
broker$CALL_NUM[broker$CALL_NUM == '?'] = 0

broker$APPT_VOL %<>% as.numeric
broker$APRD_VOL %<>% as.numeric
broker$SETT_VOL %<>% as.numeric
broker$SETT_VAL %<>% as.numeric
broker$IO_VOL %<>% as.numeric
broker$PI_VOL %<>% as.numeric
broker$EXCEP_APP %<>% as.numeric
broker$NO_EXCEP_APP %<>% as.numeric
broker$TOTAL_APP %<>% as.numeric
broker$CALL_NUM %<>% as.numeric

broker = broker[broker$APRD_VOL <= broker$APPT_VOL,]
broker = broker[broker$SETT_VOL <= broker$APPT_VOL,]
broker = broker[(broker$APPT_VOL > 0) & (broker$IO_VOL + broker$PI_VOL > 0),]

broker$CPA = broker$CALL_NUM/broker$APPT_VOL


brk = data.frame(amount    = broker$SETT_VAL %>% smartMap, 
                 volume    = broker$SETT_VOL %>% smartMap, 
                 approved  = broker$APRD_VOL/broker$APPT_VOL,
                 settled   = broker$SETT_VOL/broker$APPT_VOL, 
                 exception = broker$EXCEP_APP/(broker$EXCEP_APP + broker$NO_EXCEP_APP),
                 risk      = broker$IO_VOL/ (broker$IO_VOL + broker$PI_VOL), 
                 calls     = broker$CPA %>% smartMap) 

W.brk = brk %>% mutate(
  amount    = 5.0*amount, 
  volume    = 1.0*volume, 
  approved  = 2.0*approved,
  settled   = 1.0*settled,
  exception = 2.0*exception,
  risk      = 1.0*risk,
  calls     = 1.0*calls)

```

## Using kmeans to cluster the brokers into 5 clusters:

```{r echo = FALSE}
kmn = W.brk %>% as.matrix %>% kmeans(5)
u = W.brk %>% prcomp 
broker$Cluster = "Cluster" %>% paste0(kmn$cluster) %>% as.factor

# With ggplot:
u$x %>% as.data.frame %>% ggplot(aes(PC1, PC2, color = broker$Cluster)) + geom_point() + 
  labs(x = 'Principal Component dim 1', y = 'Principal Component dim 2') +
  scale_colour_discrete(name = 'Cluster Number', breaks = 1:5 %>% as.character, labels = 'Cluster' %>% paste(1:5))
```

## Clustered brokers with metrics in actual scale:

```{r echo = FALSE}
broker %<>% cbind(brk)

chs = c('Settlement Value'       = 'SETT_VAL',
        'Settlement Volume'      = 'SETT_VOL', 
        'Conversion to Approved' = 'approved', 
        'Conversion to Settled'  = 'settled', 
        'Exception Rate'  = 'exception', 
        'Risk'     = 'risk',
        'Calls'    = 'CPA'
)

selectInput('xAxis', label = 'X Axis', choices = chs, selected = 'SETT_VAL')
selectInput('yAxis', label = 'Y Axis', choices = chs, selected = 'exception')
selectInput('group', label = 'Grouping', choices = c('Cluster', 'Broker Grade' = 'BROKER_GRADE', 'Head Group' = 'HEAD_GRUP', 'Relative Manager' = 'REL_MNGR'), selected = 'Cluster')

renderPlotly({broker %>% plotly.scatter(x = input$xAxis, y = input$yAxis, color = input$group)})
```

## Actual-scaled distribution of various metrics within the clusters:

```{r echo = FALSE}
chs = c('Settlement Value'       = 'SETT_VAL',
        'Settlement Volume'      = 'SETT_VOL', 
        'Conversion to Approved' = 'approved', 
        'Conversion to Settled'  = 'settled', 
        'Exception Rate'  = 'exception', 
        'Risk'     = 'risk',
        'Calls'    = 'CPA'
)

selectInput('metric', label = 'Metric', choices = chs, selected = 'SETT_VAL')
selectInput('group2', label = 'Grouping', choices = c('Cluster', 'Broker Grade' = 'BROKER_GRADE', 'Head Group' = 'HEAD_GRUP', 'Relative Manager' = 'REL_MNGR'), selected = 'Cluster')

renderPlotly({plot_ly(broker, x = as.formula('~' %+% input$metric), color = as.formula('~' %+% input$group2), type = "box")})
```



### generate.R -------------------------
# generate.R

broker <- read.csv('/data/brokers4.csv', stringsAsFactors = F)

broker$IO_VOL[broker$IO_VOL == '?'] = NA
broker$PI_VOL[broker$PI_VOL == '?'] = NA
broker$EXCEP_APP[broker$EXCEP_APP == '?'] = NA
broker$NO_EXCEP_APP[broker$NO_EXCEP_APP == '?'] = NA
broker$TOTAL_APP[broker$TOTAL_APP == '?'] = NA

broker %<>% na.omit

broker$APPT_VOL[broker$APPT_VOL == '?'] = 0
broker$APRD_VOL[broker$APRD_VOL == '?'] = 0
broker$SETT_VOL[broker$SETT_VOL == '?'] = 0
broker$SETT_VAL[broker$SETT_VAL == '?'] = 0
broker$CALL_NUM[broker$CALL_NUM == '?'] = 0

broker$APPT_VOL %<>% as.numeric
broker$APRD_VOL %<>% as.numeric
broker$SETT_VOL %<>% as.numeric
broker$SETT_VAL %<>% as.numeric
broker$IO_VOL %<>% as.numeric
broker$PI_VOL %<>% as.numeric
broker$EXCEP_APP %<>% as.numeric
broker$NO_EXCEP_APP %<>% as.numeric
broker$TOTAL_APP %<>% as.numeric
broker$CALL_NUM %<>% as.numeric

broker = broker[broker$APRD_VOL <= broker$APPT_VOL,]
broker = broker[broker$SETT_VOL <= broker$APPT_VOL,]
broker = broker[(broker$APPT_VOL > 0) & (broker$IO_VOL + broker$PI_VOL > 0),]

broker$CPA = broker$CALL_NUM/broker$APPT_VOL

brk = data.frame(amount    = broker$SETT_VAL %>% smartMap, 
                 volume    = broker$SETT_VOL %>% smartMap, 
                 approved  = broker$APRD_VOL/broker$APPT_VOL,
                 settled   = broker$SETT_VOL/broker$APPT_VOL, 
                 exception = broker$EXCEP_APP/(broker$EXCEP_APP + broker$NO_EXCEP_APP),
                 risk      = broker$IO_VOL/ (broker$IO_VOL + broker$PI_VOL), 
                 calls     = broker$CPA %>% smartMap) 

W.brk = brk %>% mutate(
  amount    = 5.0*amount, 
  volume    = 1.0*volume, 
  approved  = 2.0*approved,
  settled   = 1.0*settled,
  exception = 2.0*exception,
  risk      = 1.0*risk,
  calls     = 1.0*calls)

kmn = W.brk %>% as.matrix %>% kmeans(5)
u = W.brk %>% prcomp 
broker$Cluster = "Cluster" %>% paste0(kmn$cluster) %>% as.factor



####### Folder presentations/brokers/view2: ================================

### dashboard.Rmd -------------------------
---
  title: "Broker Segmentation Dashboard"
author: "Nima Ramezani (Data Scientist in A&I)"
date: "04 July 2017"
output: 
  flexdashboard::flex_dashboard:
  orientation: rows
social: menu
runtime: shiny
---
  
  ```{r setup, include=T}
# rmarkdown::run("View_2/dashboard.Rmd", shiny_args=list(host = "0.0.0.0", port = 8080))
knitr::opts_chunk$set(echo = F)

library(flexdashboard)
library(timeDate)
library(dygraphs)
library(plotly)
library(magrittr)
library(DT)
library(niragen)
source('C:/Nima/RCode/projects/libraries/developing_packages/niragen.R')
source('C:/Nima/RCode/projects/libraries/developing_packages/visgen.R')
source('C:/Nima/RCode/projects/libraries/developing_packages/plotly.R')
source('C:/Nima/RCode/projects/libraries/developing_packages/DT.R')

# prepare objects:
val      = reactiveValues()
val$BRKID = c()
chs = c('Settlement Value'       = 'SETT_VAL',
        'Settlement Volume'      = 'SETT_VOL', 
        'Conversion to Approved' = 'approved', 
        'Conversion to Settled'  = 'settled', 
        'Exception Rate'  = 'exception', 
        'Risk'     = 'risk',
        'Calls'    = 'CPA'
)

broker = readRDS('brokers.rds')

```


Metrics
-----------------------------------------------------------------------
  ### Submitted Applications {.value-box}
  ```{r}
renderValueBox({
  if(val$BRKID %>% is.empty){brkid = broker %>% nrow %>% sequence} else {brkid = val$BRKID}
  valueBox(
    value = prettyNum(broker[brkid, 'APPT_VOL'] %>% sum, big.mark = ','),
    icon = "fa-task",
  )
})
```

### Approved Applications{.value-box}
```{r}
renderValueBox({
  if(val$BRKID %>% is.empty){brkid = broker %>% nrow %>% sequence} else {brkid = val$BRKID}
  valueBox(
    value = prettyNum(broker[brkid, 'APRD_VOL'] %>% sum, big.mark = ','),
    icon = "fa-task",
  )
})
```

### Settled Applications{.value-box}
```{r}
renderValueBox({
  if(val$BRKID %>% is.empty){brkid = broker %>% nrow %>% sequence} else {brkid = val$BRKID}
  valueBox(
    value = prettyNum(broker[brkid, 'SETT_VOL'] %>% sum, big.mark = ','),
    icon = "fa-task",
  )
})
```

### Total Settlement Value {.value-box}
```{r}
# Shows the average amount of time (per case) spent in this status
renderValueBox({
  if(val$BRKID %>% is.empty){brkid = broker %>% nrow %>% sequence} else {brkid = val$BRKID}
  valueBox(
    value = '$' %+% formatC(broker[brkid, 'SETT_VAL'] %>% sum, digits = 2, big.mark = ',', format = 'f'),
    icon = "fa-task",
  )
})
```

### Risk (IO Rate) {.value-box}

```{r}
renderValueBox({
  if(val$BRKID %>% is.empty){brkid = broker %>% nrow %>% sequence} else {brkid = val$BRKID}
  val = 100.0*(broker[brkid, 'IO_VOL'] %>% sum)/(broker[brkid, 'APRD_VOL'] %>% sum)
  val %<>%  formatC(digits = 2, big.mark = ',', format = 'f')
  valueBox(val %+% '%' , icon = "fa-user")
})
```

### Exception Rate {.value-box}

```{r}
renderValueBox({
  if(val$BRKID %>% is.empty){brkid = broker %>% nrow %>% sequence} else {brkid = val$BRKID}
  val = 100.0*(broker[brkid, 'EXCEP_APP'] %>% sum)/(broker[brkid, 'TOTAL_APP'] %>% sum)
  val %<>% formatC(digits = 2, big.mark = ',', format = 'f')
  valueBox(val %+% '%', icon = "fa-user")
})
```


Info {.tabset .tabset-fade data-height=950}
-----------------------------------------------------------------------
  ### Scatter Plot
  ```{r}
fillCol(
  fillRow(
    selectInput('xAxis', label = 'X Axis', choices = chs, selected = 'SETT_VAL'),
    selectInput('yAxis', label = 'Y Axis', choices = chs, selected = 'exception'),
    selectInput('group', label = 'Grouping', choices = c('Cluster', 'Broker Grade' = 'BROKER_GRADE', 'Head Group' = 'HEAD_GRUP', 'Relative Manager' = 'REL_MNGR'), selected = 'Cluster')),
  plotlyOutput('scatter'),
  flex = c(1, 5))

output$scatter <- renderPlotly({broker %>% plotly.scatter(x = input$xAxis, y = input$yAxis, color = input$group, source = 'scatter')})

observe({
  click  = event_data(event = "plotly_click", source = "scatter")
  isolate({
    if(is.null(click)){val$BRKID = character()} else {val$BRKID = broker %>% getClick(click)}
  })
})

#observe({
#   select = event_data(event = "plotly_selected", source = "scatter")
#   isolate({
#     if(is.null(select)){val$BRKID = character()} else {val$BRKID = broker %>% getSelect(select)}
#   })
#})
```

### Box Plot
```{r}
fillCol(
  fillRow(selectInput('metric', label = 'Metric', choices = chs, selected = 'SETT_VAL'),
          selectInput('group2', label = 'Grouping', choices = c('Cluster', 'Broker Grade' = 'BROKER_GRADE', 'Head Group' = 'HEAD_GRUP', 'Relative Manager' = 'REL_MNGR'), selected = 'Cluster')),
  plotlyOutput('boxplot'),
  flex = c(1, 5))

output$boxplot <- renderPlotly({plot_ly(broker, x = as.formula('~' %+% input$metric), color = as.formula('~' %+% input$group2), type = "box")})
```


### Performance trend 
```{r}
# renderDygraph({v$plot.history(period = 1:v$N.int, figures = x$agents[1:5])})
```

BrokerList
-----------------------------------------------------------------------
  
  ```{r}
#dataTableOutput('brklist')
#renderDataTable({
#  if(is.null(val$BRKID)){val$BRKID = broker %>% nrow %>% sequence}
#  broker[val$BRKID, 1:8]  %>% DT.table  })
# tableOutput('brklist')  
renderTable({
  tbl = broker[val$BRKID, c('BROKER', 'BROKER_GRADE', 'HEAD_GRUP', 'REL_MNGR', 'STATE', 'APPT_VOL', 'APRD_VOL', 'SETT_VOL', 'SETT_VAL', 'EXCEP_APP', 'IO_VOL', 'CALL_NUM', 'Cluster')]
  names(tbl) <- c('Name', 'Grade', 'Head Group', 'Manager', 'State', 'Submitted', 'Approved', 'Settled', 'Settlement Value', 'Deals with Execption', 'IO deals', 'Calls', 'Cluster')
  tbl[val$BRKID, ]})
#textOutput('txt')
#renderText('Hello')
```




### global.R -------------------------

getSelect = function(tbl, plotly_select_event){
  brkids = character()
  if(is.null(plotly_select_event)){return(brkids)}
  nclass = 5 
  for (i in sequence(nclass)){
    indx = subset(plotly_select_event, curveNumber = i - 1)$pointNumber
    brki = subset(tbl, Cluster == 'Cluster' %+% i) 
    brkids = c(brkids, rownames(brki)[indx])
  }
  return(brkids)
}

getClick = function(tbl, plotly_click_event){
  if(is.null(plotly_click_event)){return(character())}
  i     = plotly_click_event$curveNumber + 1
  brki  = subset(tbl, Cluster == 'Cluster' %+% i) 
  click = rownames(brki)[plotly_click_event$pointNumber + 1]
  return(click)
}

### index.Rmd -------------------------
#   title: Testing ImpressJS
# author: Ramnath Vaidyanathan
# mode  : selfcontained
# framework: impressjs
# github:
#   user: ramnathv
# repo: slidify
# twitter:
#   text: "Slidify with impress.js!"
# url:
#   lib: ../libraries
# --- .slide x:-1000 y:-1500
# 
# <q>Aren't you just **bored** with all those slides-based presentations?</q>
# 
# --- .slide x:0 y:-1500
# 
# <q>Don't you think that presentations given **in modern browsers** shouldn't **copy the limits** of 'classic' slide decks?</q>
# 
# --- .slide x:1000 y:-1500
# 
# <q>Would you like to **impress your audience** with **stunning visualization** of your talk?</q>
# 
# --- #title x:0 y:0 scale:4
# 
# <span class="try">then you should try</span>
# # impressjs^*
# <span class="footnote">^* no rhyme intended</span>
# 
# --- #its x:850 y:3000 rot:45 scale:5
# 
# It's a **presentation tool** <br/>
#   inspired by the idea behind [prezi.com](http://prezi.com) <br/>
#   and based on the **power of CSS3 transforms and transitions** in modern browsers.
# 
# --- #big x:3500 y:2100 rot:180 scale:6
#   
#   visualize your <b>big</b> <span class="thoughts">thoughts</span>
#   
#   --- #ghablame x:2825 y:2325 z:-3000 rot:300 scale:1
#   
#   and **tiny** ideas
# 
# --- #ing x:3500 y:-850 rot:270 scale:6
#   by <b class="positioning">positioning</b>, <b class="rotating">rotating</b> and <b class="scaling">scaling</b> them on an infinite canvas
# 
# --- #imagination x:6700 y:-300 scale:6
#   
#   the only **limit** is your <b class="imagination">imagination</b>
#   
#   --- #source x:6300 y:2000 rot:20 scale:4
#   
#   want to know more?
#   
#   <q>[use the source](http://github.com/bartaz/impress.js), Luke</q>
#   
#   --- #one-more-thing x:6000 y:4000 scale:2
#   
#   one more thing...
# 
# --- #its-in-3d x:6200 y:4300 z:-100 rotx:-40 roty:-10 scale:2
#   
#   <span class="have">have</span> <span class="you">you</span> <span class="noticed">noticed</span> <span class="its">it's</span> <span class="in">in</span> <b>3D<sup>*</sup></b>?
# 
# <span class="footnote">* beat that, prezi ;)</span>
# 
# --- #rstats x:-1000 y:5000
# 
# ```{r echo = T, eval = F}
# library(ggplot2)
# qplot(wt, mpg, data = mtcars)
# ```
# 
# --- x:-1500 y:5500
# 
# ```{r echo = F, eval = T, message = F}
# opts_chunk$set(fig.path = 'assets/fig/')
# library(ggplot2)
# qplot(wt, mpg, data = mtcars)
# ```
# 

###### Package: rCharts =============================

### examples.R ----------------------------------
library(niragen)
library(dplyr)
library(htmlwidgets)
library(rCharts)

source('../../packages/master/niravis-master/R/visgen.R')
source('../../packages/master/niravis-master/R/jscripts.R')
source('../../packages/master/niravis-master/R/rCharts.R')
source('../../packages/master/niravis-master/R/dimple.R')
source('../../packages/master/niravis-master/R/candela.R')
source('../../packages/master/niravis-master/R/plotly.R')
source('../../packages/master/niravis-master/R/billboarder.R')
source('../../packages/master/niravis-master/R/coffeewheel.R')
source('../../packages/master/niravis-master/R/morrisjs.R')
source('../../packages/master/niravis-master/R/nvd3.R')
source('../../packages/master/niravis-master/R/amCharts.R')

# write.csv(data, data.path %+% 'pmsi.R')
data = read.csv('../data/' %++% 'pmsi.R')

#eliminate . to avoid confusion in javascript
colnames(data) <- gsub("[.]","",colnames(data))

#example 1 vt bar
d1 <- dPlot(
  x ="Month" ,
  y = "UnitSales",
  data = data,
  type = "bubble"
)
d1$xAxis(orderRule = "Date")
d1 %>% show

#### Translation:

# todo: does it know all shapes?
data %>% dimple.combo(x = "Month", y = "UnitSales", shape = 'bubble') %>% show


# Other packages
data$Month %<>% as.character 
data$Month %<>% factor(levels = unique(data$Month))
# Note: THis table was already sorted! Otherwise, this would not work. You would need a date format reader!

df = data %>% group_by(Month) %>% summarize(UnitSales = mean(UnitSales)) %>% as.data.frame %>% arrange(Month)

df %>% dygraphs.combo(x = 'Month', y = 'UnitSales', config = list(shape = list(UnitSales = 'line')))
df %>% plotly.combo(x = 'Month', y = 'UnitSales', shape = 'point')

#example 2 vt stacked bar
d1 <- dPlot(
  x ="Month" ,
  y = "UnitSales",
  groups = "Channel",
  data = data,
  type = "bar"
)
d1$xAxis(orderRule = "Date")
d1$legend(
  x = 60,
  y = 10,
  width = 700,
  height = 20,
  horizontalAlign = "right"
)
d1

cfg = list(legend.enabled = T)
data %>% dimple.combo(x = "Month", y = "UnitSales", group = "Channel", shape = 'bar', config = cfg) %>% show
data %>% dimple.combo(y = "Month", x = "UnitSales", group = "Channel", shape = 'bar', config = cfg) %>% show

data %>% dimple.combo(x = 'Brand', y = list('UnitSales', 'CostofSales'), shape = list('area', 'bar'), config = cfg) %>% show



### Translation:
cfg = list(legend.enabled = T, legend.position.x = 100, legend.position.y = 0, legend.width = 200, legend.height = 10, legend.horizontalAlign = "right", colorize = F)
data %>% dimple.combo(x = list("Month"), y = "UnitSales", group = 'Channel', config = cfg, shape = 'bar') %>% show

data %>% dimple.combo(x = list("Month"), y = "UnitSales", group = 'Channel', config = list(barMode = 'stack'), shape = 'area') %>% show


# Other packages
data %>% candela.bar(x = "Month", y = "UnitSales", color = 'Channel', config = list(barMode = 'stack'))
# Candela does not show anything!!!



#example 3 vertical 100% bar
#use from above and just change y axis type
d1$yAxis(type = "addPctAxis")
d1

todo: Translation

#example 4 vertical grouped bar
d1 <- dPlot(
  x = c("PriceTier", "Channel"),
  y = "UnitSales",
  groups = "Channel",
  data = data,
  type = "bar"
)
d1$legend(
  x = 60,
  y = 10,
  width = 700,
  height = 20,
  horizontalAlign = "right"
)
d1

## Translation
data %>% dimple.combo(x = list("PriceTier","Channel"), y = "UnitSales", group = 'Channel', shape = 'bar', config = cfg) %>% show
# todo: do it through barMode


#example 5 vertical stack grouped bar
d1 <- dPlot(
  x = c("PriceTier","Channel"),
  y = "UnitSales",
  groups = "Owner",
  data = data,
  type = "bar"
)
d1$legend(
  x = 200,
  y = 10,
  width = 400,
  height = 20,
  horizontalAlign = "right"
)
d1

cfg %<>% list.edit(legend.enabled = T, legend.position.x = 200, legend.position.y = 10, legend.width = 400, legend.height = 20)
## NIRAVIS Translation:
d1 = data %>% dimple.combo(x = list("PriceTier","Channel"), y = "UnitSales", group = 'Owner', shape = 'bar', config = cfg)
d1 %>% show()

#example 6 vertical 100% Grouped Bar
#just change y Axis
d1$yAxis(type = "addPctAxis")
d1 %>% show()

#example 7 horizontal bar
d1 <- dPlot(
  x = 'UnitSales',
  y = 'Month',
  data = data,
  type = "bar"
)
d1$xAxis(type = "addMeasureAxis")
#good test of orderRule on y instead of x
d1$yAxis(type = "addCategoryAxis", orderRule = "Date")
d1

data %>% dimple.combo(x = list("UnitSales"), y = "Month", shape = 'bar', config = cfg) %>% show

#example 8 horizontal stacked bar
d1 <- dPlot(
  Month ~ UnitSales,
  groups = "Channel",
  data = data,
  type = "bar"
)
d1$xAxis(type = "addMeasureAxis")
#good test of orderRule on y instead of x
d1$yAxis(type = "addCategoryAxis", orderRule = "Date")
d1$legend(
  x = 200,
  y = 10,
  width = 400,
  height = 20,
  horizontalAlign = "right"
)
d1


data %>% dimple.combo(x = list("UnitSales"), y = "Month", group = 'Channel', shape = 'bar', config = cfg) %>% show


#example 9 horizontal 100% bar
d1$xAxis(type = "addPctAxis")
d1


#example 10 horizontal group bar
d1 <- dPlot(
  x = "UnitSales", 
  y = c("PriceTier","Channel"),
  groups = "Channel",
  data = data,
  type = "bar"
)
d1$xAxis(type = "addMeasureAxis")
#good test of orderRule on y instead of x
d1$yAxis(type = "addCategoryAxis")
d1$legend(
  x = 200,
  y = 10,
  width = 400,
  height = 20,
  horizontalAlign = "right"
)
d1

### Translation
d1 = data %>% dimple.combo(x = list("UnitSales"), y = list("PriceTier","Channel"), group = 'Channel', shape = 'bar', config = cfg)
d1 %>% show



#example 11 horizontal stacked grouped bar
d1 <- dPlot(
  x = "UnitSales", 
  y = c("PriceTier","Channel"),
  groups = "Owner",
  data = data,
  type = "bar"
)
d1$xAxis(type = "addMeasureAxis")
#good test of orderRule on y instead of x
d1$yAxis(type = "addCategoryAxis")
d1$legend(
  x = 200,
  y = 10,
  width = 400,
  height = 20,
  horizontalAlign = "right"
)
d1


### Translation
cfg %<>% list.edit(legend.position.x = 200, legend.position.y = 10, legend.width = 400, legend.height = 20, legend.horizontalAlign = "right")
d1 = data %>% dimple.combo(x = list("UnitSales"), y = list('PriceTier', "Channel"), group = 'Owner', shape = 'bar', config = cfg)
d1 %>% show

#example 12 horizontal 100% grouped bar
d1$xAxis(type = "addPctAxis")
d1 %>% show


#example 13 vertical marimekko
d1 <- dPlot(
  UnitSales ~ Channel,
  groups = "Owner",
  data = data,
  type = "bar"
)
d1$xAxis(type = "addAxis", measure = "UnitSales", showPercent = F)
d1$yAxis(type = "addPctAxis")
d1$legend(
  x = 200,
  y = 10,
  width = 400,
  height = 20,
  horizontalAlign = "right"
)
#test with storyboard
d1$set(storyboard = "Date")
d1

cfg = list(legend.enabled = T, legend.position.x = 200, legend.position.y = 10, legend.width = 400, legend.height = 20)
data %>% dimple.combo(x = 'Channel', y = 'UnitSales', t = 'Date', group = 'Owner', shape = 'bar', config = cfg) %>% show

#example 14 horizontal marimekko
d1 <- dPlot(
  Channel ~ UnitSales,
  groups = "Owner",
  data = data,
  type = "bar"
)
d1$yAxis(type = "addAxis", measure = "UnitSales", showPercent = TRUE)
d1$xAxis(type = "addPctAxis")
d1$legend(
  x = 200,
  y = 10,
  width = 400,
  height = 20,
  horizontalAlign = "right"
)
d1




#example 15 block matrix
d1 <- dPlot(
  x = c("Channel","PriceTier"),
  y = "Owner",
  groups = "PriceTier",
  data = data,
  type = "bar"
)
d1$yAxis(type = "addCategoryAxis")
d1$xAxis(type = "addCategoryAxis")
d1$legend(
  x = 200,
  y = 10,
  width = 400,
  height = 20,
  horizontalAlign = "right"
)
d1


### Translation
cfg = list(legend.enabled = T, legend.position.x = 200, legend.position.y = 10, legend.width = 400, legend.height = 20)
data %>% dimple.combo(x = list("Channel","PriceTier"), y = "Owner", group = "PriceTier", shape = 'bar', config = cfg) %>% show


#example 16 Scatter
d1 <- dPlot(
  OperatingProfit~UnitSales,
  groups = c("SKU","Channel"),
  data = subset(data, Date == "01/12/2012"),
  type = "bubble"
)
d1$xAxis( type = "addMeasureAxis" )
d1$yAxis( type = "addMeasureAxis" )
d1$legend(
  x = 100,
  y = 0,
  width = 200,
  height = 20,
  horizontalAlign = "right"
)
d1

# Translation:
cfg %<>% list.edit(legend.position.x = 600, legend.position.y = 0, legend.width = 200, legend.height = 10, legend.horizontalAlign = "right")
data %>% dimple.combo(y = 'OperatingProfit', x = 'UnitSales', t = 'Date', group = list("SKU","Channel"), shape = 'bubble', config = cfg) %>% show

#example 17 Vertical Lollipop
d1 <- dPlot(
  UnitSales ~ Month,
  groups = "Channel",
  data = data,
  type = "bubble"
)
#defaults to yAxis (Measure) and xAxis (Category)
# d1$xAxis( orderRule = "Date")
d1$legend(
  x = 200,
  y = 10,
  width = 500,
  height = 20,
  horizontalAlign = "right"
)
d1

# Translation:

data %>% dimple.combo(y = 'UnitSales', x = 'Month', group = 'Channel', shape = 'bubble', config = cfg) %>% show

#example 18 Vertical Grouped Lollipop
d1 <- dPlot(
  y = "UnitSales",
  x = c("PriceTier","Channel"),
  groups = "Channel",
  data = data,
  type = "bubble"
)
#defaults to yAxis (Measure) and xAxis (Category)
d1$legend(
  x = 200,
  y = 10,
  width = 500,
  height = 20,
  horizontalAlign = "right"
)
d1

data %>% dimple.combo(y = 'UnitSales', x = list("PriceTier","Channel"), group = 'Channel', shape = 'bubble', config = cfg)

#example 19 Horizontal Lollipop
d1 <- dPlot(
  x = "UnitSales",
  y = "Month",
  groups = "Channel",
  data = data,
  type = "bubble"
)
d1$xAxis( type = "addMeasureAxis" )
d1$yAxis( type = "addCategoryAxis", orderRule = "Date")
d1$legend(
  x = 200,
  y = 10,
  width = 500,
  height = 20,
  horizontalAlign = "right"
)
d1

data %>% dimple.combo(x = 'UnitSales', y = 'Month', group = 'Channel', shape = 'bubble', config = cfg) %>% show

#example 20 Horizontal Grouped Lollipop
d1 <- dPlot(
  x = "UnitSales",
  y = c("PriceTier","Channel"),
  groups = "Channel",
  data = data,
  type = "bubble"
)
d1$xAxis( type = "addMeasureAxis" )
d1$yAxis( type = "addCategoryAxis")
d1$legend(
  x = 200,
  y = 10,
  width = 500,
  height = 20,
  horizontalAlign = "right"
)
d1

data %>% dimple.combo(x = 'UnitSales', y = list("PriceTier","Channel"), group = 'Channel', shape = 'bubble', config = cfg) %>% show


#example 21 Dot Matrix
d1 <- dPlot(
  y = "Owner",
  x = c("Channel","PriceTier"),
  groups = "PriceTier",
  data = data,
  type = "bubble"
)
d1$xAxis( type = "addCategoryAxis" )
d1$yAxis( type = "addCategoryAxis")
d1$legend(
  x = 200,
  y = 10,
  width = 500,
  height = 20,
  horizontalAlign = "right"
)
d1

data %>% dimple.combo(y = 'Owner', x = list("Channel","PriceTier"), group = 'PriceTier', shape = 'bubble', config = cfg) %>% show


#example 22 Bubble
d1 <- dPlot(
  x = "UnitSalesMonthlyChange",
  y = "PriceMonthlyChange",
  z = "OperatingProfit",
  groups = c("SKU","Channel"),
  data = subset(data, Date == "01/12/2012"),
  type = "bubble"
)
d1$xAxis( type = "addMeasureAxis" )
d1$yAxis( type = "addMeasureAxis" )
d1$zAxis( type = "addMeasureAxis" )
d1$legend(
  x = 200,
  y = 10,
  width = 500,
  height = 20,
  horizontalAlign = "right"
)
d1

# niravis translation:

data %>% dimple.combo(x = "UnitSalesMonthlyChange", y = "PriceMonthlyChange", size = "OperatingProfit", group = list("SKU","Channel"), shape = 'bubble') %>% show

d2 = data %>% subset(Date == "01/12/2012") %>% 
  dimple.combo(x = 'UnitSalesMonthlyChange', y = "PriceMonthlyChange", size = "OperatingProfit", group = list("SKU","Channel"), shape = 'bubble', config = cfg)
d2 %>% show

#example 23 Vertical Bubble Lollipop
d1 <- dPlot(
  x = "Month",
  y = "UnitSales",
  z = "OperatingProfit",
  groups = "Channel",
  data = subset(
    data,
    Date %in% c(
      "01/07/2012",
      "01/08/2012",
      "01/09/2012",
      "01/10/2012",
      "01/11/2012",
      "01/12/2012"
    )
  ),
  type = "bubble"
)
d1$xAxis( type = "addCategoryAxis", orderRule = "Date" )
d1$yAxis( type = "addMeasureAxis" )
d1$zAxis( type = "addMeasureAxis" )
d1$legend(
  x = 200,
  y = 10,
  width = 500,
  height = 20,
  horizontalAlign = "right"
)
d1

# niravis translation:
data %>% subset(Date %in% c("01/07/2012","01/08/2012","01/09/2012","01/10/2012","01/11/2012", "01/12/2012")) %>% 
  dimple.combo(x = 'Month', y = "UnitSales", size = "OperatingProfit", group = "Channel", shape = 'bubble', config = cfg) %>% show

##example 24 Vertical Grouped Bubble Lollipop
d1 <- dPlot(
  x = c("PriceTier","Channel"),
  y = "UnitSales",
  z = "OperatingProfit",
  groups = "Channel",
  data = subset(
    data,
    Date %in% c(
      "01/07/2012",
      "01/08/2012",
      "01/09/2012",
      "01/10/2012",
      "01/11/2012",
      "01/12/2012"
    )
  ),
  type = "bubble"
)
d1$xAxis( type = "addCategoryAxis" )
d1$yAxis( type = "addMeasureAxis" )
d1$zAxis( type = "addMeasureAxis" )
d1$legend(
  x = 200,
  y = 10,
  width = 500,
  height = 20,
  horizontalAlign = "right"
)
d1

### Translation:
data %>% subset(Date %in% c("01/07/2012","01/08/2012","01/09/2012","01/10/2012","01/11/2012", "01/12/2012")) %>% 
  dimple.combo(x = list("PriceTier","Channel"), y = "UnitSales", size = "OperatingProfit", group = "Channel", shape = 'bubble', config = cfg) %>% show

#example 25 Horizontal Bubble Lollipop
d1 <- dPlot(
  y = "Month",
  x = "UnitSales",
  z = "OperatingProfit",
  groups = "Channel",
  data = subset(
    data,
    Date %in% c(
      "01/07/2012",
      "01/08/2012",
      "01/09/2012",
      "01/10/2012",
      "01/11/2012",
      "01/12/2012"
    )
  ),
  type = "bubble"
)
d1$yAxis( type = "addCategoryAxis", orderRule = "Date" )
d1$xAxis( type = "addMeasureAxis" )
d1$zAxis( type = "addMeasureAxis" )
d1$legend(
  x = 200,
  y = 10,
  width = 500,
  height = 20,
  horizontalAlign = "right"
)
d1

##example 26 Horizontal Grouped Bubble Lollipop
d1 <- dPlot(
  y = c("PriceTier","Channel"),
  x = "UnitSales",
  z = "OperatingProfit",
  groups = "Channel",
  data = subset(
    data,
    Date %in% c(
      "01/07/2012",
      "01/08/2012",
      "01/09/2012",
      "01/10/2012",
      "01/11/2012",
      "01/12/2012"
    )
  ),
  type = "bubble"
)
d1$yAxis( type = "addCategoryAxis" )
d1$xAxis( type = "addMeasureAxis" )
d1$zAxis( type = "addMeasureAxis" )
d1$legend(
  x = 200,
  y = 10,
  width = 500,
  height = 20,
  horizontalAlign = "right"
)
d1


#example 27 Bubble Matrix
d1 <- dPlot(
  x = c( "Channel", "PriceTier"),
  y = "Owner",
  z = "Distribution",
  groups = "PriceTier",
  data = data,
  type = "bubble",
  aggregate = "dimple.aggregateMethod.max"
)
d1$xAxis( type = "addCategoryAxis" )
d1$yAxis( type = "addCategoryAxis" )
d1$zAxis( type = "addMeasureAxis", overrideMax = 200 )
d1$legend(
  x = 200,
  y = 10,
  width = 500,
  height = 20,
  horizontalAlign = "right"
)
d1

### Translation:
cfg$maxSizeOverride = 200

data %>% 
  dimple.combo(x = list( "Channel", "PriceTier"), y = "Owner", size = "Distribution", group = "PriceTier", shape = 'bubble', config = cfg, aggregate = "dimple.aggregateMethod.max") %>% show


#example 28 Area
d1 <- dPlot(
  UnitSales ~ Month,
  data = subset(data, Owner %in% c("Aperture","Black Mesa")),
  type = "area"
)
d1$xAxis(type = "addCategoryAxis", orderRule = "Date")
d1$yAxis(type = "addMeasureAxis")
d1

data %>% subset(Owner %in% c("Aperture","Black Mesa")) %>%
  dimple.combo(y = "UnitSales", x = "Month", shape = 'area', config = cfg %>% list.edit(legend.enabled = F)) %>% show

#example 29 Stacked Area
d1 <- dPlot(
  UnitSales ~ Month,
  groups = "Channel",
  data = subset(data, Owner %in% c("Aperture","Black Mesa")),
  type = "area"
)
d1$xAxis(type = "addCategoryAxis", orderRule = "Date")
d1$yAxis(type = "addMeasureAxis")
d1$legend(
  x = 200,
  y = 10,
  width = 500,
  height = 20,
  horizontalAlign = "right"
)
d1


### Translation
d2 = data %>% subset(Owner %in% c("Aperture","Black Mesa")) %>%
  dimple.combo(y = "UnitSales", x = "Month", shape = 'area', group = 'Channel', config = cfg) %>% show

#example 30 100% Stacked Area
#just change type for y axis
d1$yAxis( type = "addPctAxis" )
d1

d2$yAxis( type = "addPctAxis" )
d2
# todo: percentage axis should be added for other plotters by changing dataset values and adding percentage suffix


#example 31 Grouped Area
d1 <- dPlot(
  y = "UnitSales",
  x = c("Owner","Month"),
  groups = "Owner",
  data = subset(data, Owner %in% c("Aperture","Black Mesa")),
  type = "area"
)
d1$xAxis(type = "addCategoryAxis", grouporderRule = "Date")
d1$yAxis(type = "addMeasureAxis")
d1$legend(
  x = 200,
  y = 10,
  width = 500,
  height = 20,
  horizontalAlign = "right"
)
d1


### Translation
data %>% subset(Owner %in% c("Aperture","Black Mesa")) %>%
  dimple.combo(y = "UnitSales", x = list("Owner", "Month"), shape = 'area', group = 'Owner', config = cfg) %>% show

#example 32 Grouped Stacked Area
d1 <- dPlot(
  y = "UnitSales",
  x = c("Owner","Month"),
  groups = "SKU",
  data = subset(data, Owner %in% c("Aperture","Black Mesa")),
  type = "area",
  bounds = list(x=70,y=30,height=340,width=330),
  barGap = 0.05,
  lineWeight = 1,
  height = 400,
  width = 590
)
d1$xAxis(type = "addCategoryAxis", grouporderRule = "Date")
d1$yAxis(type = "addMeasureAxis")
d1$legend(
  x = 430,
  y = 20,
  width = 100,
  height = 300,
  horizontalAlign = "left"
)
d1

### Translation

cfg %<>% list.edit(legend.position.x = 600, legend.position.y = 20, legend.width = 100, legend.height = 300, legend.horizontalAlign = "left")
data %>% subset(Owner %in% c("Aperture","Black Mesa")) %>%
  dimple.combo(y = "UnitSales", x = list("Owner", "Month"), shape = 'area', group = 'SKU', config = cfg, bounds = list(x=70,y=30,height=340,width=530)) %>% show

# todo: add chartbounds as config properties

#example 33 Grouped 100% Area
d1$yAxis( type = "addPctAxis" )
d1




#example 34 Horizontal Area
d1 <- dPlot(
  x = "UnitSales",
  y = "Month",
  data = subset(data, Owner %in% c("Aperture","Black Mesa")),
  type = "area",
  bounds = list(x=80,y=30,width=330,height=480),
  height = 590,
  width = 400
)
d1$xAxis(type = "addMeasureAxis")
d1$yAxis(type = "addCategoryAxis", orderRule = "Date")
d1

data %>% subset(Owner %in% c("Aperture","Black Mesa")) %>%
  dimple.combo(y = "Month", x = "UnitSales", shape = 'area', config = cfg %>% list.edit(legend.enabled = F))

#example 35 Horizontal Stacked Area
d1 <- dPlot(
  x = "UnitSales",
  y = "Month",
  groups = "Channel",
  data = subset(data, Owner %in% c("Aperture","Black Mesa")),
  type = "area",
  bounds = list(x=80,y=30,width=330,height=480),
  height = 590,
  width = 400
)
d1$xAxis(type = "addMeasureAxis")
d1$yAxis(type = "addCategoryAxis", grouporderRule = "Date")
d1$legend(
  x = 80,
  y = 10,
  width = 330,
  height = 20,
  horizontalAlign = "right"
)
d1


#example 36 Horizontal 100% Stacked Area
d1$xAxis(type = "addPctAxis")
d1


#example 37 Horizontal Grouped Area
d1 <- dPlot(
  x = "UnitSales",
  y = c("Owner","Month"),
  groups = "Owner",
  data = subset(data, Owner %in% c("Aperture","Black Mesa")),
  type = "area",
  bounds = list(x=90,y=30,width=470,height=330),
  lineWeight = 1,
  barGap = 0.05,
  height = 400,
  width = 590
)
d1$xAxis(type = "addMeasureAxis")
d1$yAxis(type = "addCategoryAxis", grouporderRule = "Date")
d1

#example 38 Horizontal Grouped Stacked Area
d1 <- dPlot(
  x = "UnitSales",
  y = c("Owner","Month"),
  groups = "SKU",
  data = subset(data, Owner %in% c("Aperture","Black Mesa")),
  type = "area",
  bounds = list(x=90,y=30,width=320,height=330),
  lineWeight = 1,
  barGap = 0.05,
  height = 400,
  width = 590
)
d1$xAxis(type = "addMeasureAxis")
d1$yAxis(type = "addCategoryAxis", grouporderRule = "Date")
d1$legend(
  x = 430,
  y = 20,
  width = 100,
  height = 300,
  horizontalAlign = "left"
)
d1



#example 39 Horizontal Group 100% Area
d1$xAxis( type = "addPctAxis" )
d1





#example 40 Line
d1 <- dPlot(
  UnitSales ~ Month,
  data = subset(data, Owner %in% c("Aperture","Black Mesa")),
  type = "line"
)
d1$xAxis(type = "addCategoryAxis", orderRule = "Date")
d1$yAxis(type = "addMeasureAxis")
d1


#example 41 Multiple Line
d1 <- dPlot(
  UnitSales ~ Month,
  groups = "Channel",
  data = subset(data, Owner %in% c("Aperture","Black Mesa")),
  type = "line"
)
d1$xAxis(type = "addCategoryAxis", orderRule = "Date")
d1$yAxis(type = "addMeasureAxis")
d1$legend(
  x = 200,
  y = 10,
  width = 500,
  height = 20,
  horizontalAlign = "right"
)
d1


#example 42 Grouped Single Line
d1 <- dPlot(
  y = "UnitSales",
  x = c("Owner","Month"),
  groups = "Owner",
  data = subset(data, Owner %in% c("Aperture","Black Mesa")),
  type = "line",
  barGap = 0.05
)
d1$xAxis(type = "addCategoryAxis", grouporderRule = "Date")
d1$yAxis(type = "addMeasureAxis")
d1

# niravis translation:

subset(data, Owner %in% c("Aperture","Black Mesa")) %>% 
  dimple.combo(x = list('Owner', 'Month'), y = 'UnitSales', group = 'Owner', config = cfg, barGap = 0.05) %>% show


#example 43 Grouped Multiple line
d1 <- dPlot(
  y = "UnitSales",
  x = c("Owner","Month"),
  groups = "Brand",
  data = subset(data, Owner %in% c("Aperture","Black Mesa")),
  type = "line",
  bounds = list(x=70,y=30,width=420,height=330),
  barGap = 0.05,
  height = 400,
  width = 590
)
d1$xAxis(type = "addCategoryAxis", grouporderRule = "Date")
d1$yAxis(type = "addMeasureAxis")
d1$legend(
  x = 510,
  y = 20,
  width = 100,
  height = 300,
  horizontalAlign = "left"
)
d1



#example 44 Horizontal LineChart
d1 <- dPlot(
  x = "UnitSales",
  y = "Month",
  data = subset(data, Owner %in% c("Aperture","Black Mesa")),
  type = "line",
  bounds = list(x=80,y=30,width=480,height=330),
  height = 400,
  width = 590
)
d1$xAxis(type = "addMeasureAxis")
d1$yAxis(type = "addCategoryAxis", orderRule = "Date")
d1



#example 45 Vertical Multiple Line
d1 <- dPlot(
  x = "UnitSales",
  y = "Month",
  groups = "Channel",
  data = subset(data, Owner %in% c("Aperture","Black Mesa")),
  type = "line",
  bounds = list(x=80,y=30,width=480,height=330),
  height = 400,
  width = 590
)
d1$xAxis(type = "addMeasureAxis")
d1$yAxis(type = "addCategoryAxis", orderRule = "Date")
d1$legend(
  x = 60,
  y = 10,
  width = 500,
  height = 20,
  horizontalAlign = "right"
)
d1



#example 46 Vertical Grouped Line
d1 <- dPlot(
  x = "UnitSales",
  y = c("Owner","Month"),
  groups = "Owner",
  data = subset(data, Owner %in% c("Aperture","Black Mesa")),
  type = "line",
  bounds = list(x=90,y=30,width=470,height=330),
  barGap = 0.05,
  height = 400,
  width = 590
)
d1$xAxis(type = "addMeasureAxis")
d1$yAxis(type = "addCategoryAxis", grouporderRule = "Date")
d1



#example 47 Vertical Grouped Multi Line
d1 <- dPlot(
  x = "UnitSales",
  y = c("Owner","Month"),
  groups = "Brand",
  data = subset(data, Owner %in% c("Aperture","Black Mesa")),
  type = "line",
  bounds = list(x=90,y=30,width=320,height=330),
  barGap = 0.05,
  height = 400,
  width = 590
)
d1$xAxis(type = "addMeasureAxis")
d1$yAxis(type = "addCategoryAxis", grouporderRule = "Date")
d1$legend(
  x = 430,
  y = 20,
  width = 100,
  height = 300,
  horizontalAlign = "left"
)
d1

#show how to change defaultColors

require(latticeExtra)
d1$defaultColors(theEconomist.theme()$superpose.line$col, replace=T)
d1
d1$defaultColors(brewer.pal(n=9,"Blues"), replace=T)
d1
d1$defaultColors("#!d3.scale.category20()!#", replace=T)
d1
d1$defaultColors("#!d3.scale.category20b()!#", replace=T)
d1
d1$defaultColors("#!d3.scale.category20c()!#", replace=T)
d1
d1$defaultColors("#!d3.scale.category10()!#", replace=T)
d1


#example 48 timeAxis
data( economics, package = "ggplot2" )
economics %<>% as.data.frame
economics$date = format(economics$date, "%Y-%m-%d")
d1 <- dPlot(
  x = "date",
  y = "uempmed",
  data = economics,
  type = "line",
  height = 500,
  width = 800,
  bounds = list(x=50,y=20,width=650,height=400)
)
d1$xAxis(
  type = "addTimeAxis",
  inputFormat = "%Y-%m-%d",
  outputFormat = "%y-%b-%d"
)
d1


economics %>% mutate(date = date %>% as.Date) %>% 
  dimple.combo(x = "date", y = "uempmed", height = 600, width = 900, config = list(xAxis.tick.label.format = "%Y")) %>% show


#test out additional layer/series functionality
d1$layer(
  x = "date",
  y = "psavert",
  data = NULL,
  type = "bar"
)
d1


economics %>% mutate(date = date %>% as.Date) %>% 
  dimple.combo(x = "date", y = list("uempmed", "psavert"), height = 600, width = 900, config = list(xAxis.tick.label.format = "%Y")) %>% show



# example 49 multiple layers qq style plot with 2 datasets
df <- data.frame(
  id = 1:100,
  x=ppoints(100),
  y=sort(rnorm(100)),   #100 random normal distributed points  
  normref=qnorm(ppoints(100))#lattice uses ppoints for the x
)
d1 <- dPlot(
  y ~ x,  #x ~ id for a different look
  groups = c("id", 'sample'),
  data = df[,c("id","x","y")],  #specify columns to prove diff data
  type = "bubble"
)
d1$xAxis(type="addMeasureAxis",orderRule="x")
d1  #just one layer

#now add a layer with a line to represent normal distribution
d1$layer(
  x = "x",
  y = "normref",
  groups = c("id","sample2"),
  data=df[,c("id","x","normref")],  #specify columns to prove diff data
  type="line"
)
d1$legend(
  x = 200,
  y = 10,
  width = 500,
  height = 20,
  horizontalAlign = "right"
)
d1

df %>% dimple.scatter(x = 'x', y = 'y')

df %>% dimple.scatter(x = 'x', y = list('y', 'normref'), group = 'Type', config = cfg, shape = 'bar')

### examples.rPlot.R ----------------------------------
# Examples in page:
# http://rdatascience.io/rCharts/

#### Chart 1:

names(iris) = gsub("\\.", "", names(iris))
rPlot(SepalLength ~ SepalWidth | Species, data = iris, color = 'Species', type = 'point')

r1 <- rPlot(mpg ~ wt | am + vs, data = mtcars, type = "point", color = "gear")
r1$print("chart1")


#### Chart 2:

data(economics, package = "ggplot2")
econ <- transform(economics, date = as.character(date))
m1 <- mPlot(x = "date", y = c("psavert", "uempmed"), type = "Line", data = econ)
m1$set(pointSize = 0, lineWidth = 1)
m1$print("chart2")



#### Chart 3:

hair_eye_male <- subset(as.data.frame(HairEyeColor), Sex == "Male")
n1 <- nPlot(Freq ~ Hair, group = "Eye", data = hair_eye_male, type = "multiBarChart")

nPlot(y = 'Freq', x = 'Hair', group = "Eye", data = hair_eye_male, type = "multiBarChart")

n1$print("chart3")

### examples_2.R ----------------------------------
# Examples in page:
# http://rdatascience.io/rCharts/

library(rCharts)

source('C:/Nima/R/projects/libraries/developing_packages/niragen.R')
source('C:/Nima/R/projects/libraries/developing_packages/visgen.R')
source('C:/Nima/R/projects/libraries/developing_packages/rCharts.R')

## Example 1 Facetted Scatterplot
names(iris) = gsub("\\.", "", names(iris))
rPlot(SepalLength ~ SepalWidth | Species, data = iris, color = 'Species', type = 'point')

# Translation:
# rCharts.scatter.molten  : group:color
# type = line ham mitoone bashe


## Example 2 Facetted Barplot
hair_eye = as.data.frame(HairEyeColor)
rPlot(Freq ~ Hair | Eye, color = 'Eye', data = hair_eye, type = 'bar')

# Translation:
# rcharts?
# Type, line, bar, point !!!


# Chart 1
r1 <- rPlot(mpg ~ wt | am + vs, data = mtcars, type = "point", color = "gear")
r1$print("chart1")


# Chart 2:
data(economics, package = "ggplot2")
econ <- transform(economics, date = as.character(date))
m1 <- mPlot(x = "date", y = c("psavert", "uempmed"), type = "Line", data = econ)
m1$set(pointSize = 0, lineWidth = 1)
m1$print("chart2")



# Chart3:

hair_eye_male <- subset(as.data.frame(HairEyeColor), Sex == "Male")
n1 <- nPlot(y = 'Freq', x = 'Hair', group = "Eye", data = hair_eye_male, type = "multiBarChart")

n1$print("chart3")

# Translation:
HairEyeColor %>% as.data.frame %>% subset(Sex == "Male") %>%
  rCharts.bar.molten(x = 'Hair', y = 'Freq', group = 'Eye')


# Chart 4:
require(reshape2)
uspexp <- melt(USPersonalExpenditure)
names(uspexp)[1:2] = c("category", "year")
x1 <- xPlot(value ~ year, group = "category", data = uspexp, type = "line-dotted")
x1$print("chart4")
# Translation
# legend & setTemplete don't work
# Other valid types unknown
# Other classes unknown

# Translation:
uspexp %>% rCharts.area.molten(x = 'year', y = 'value', group = 'category')


# Chart 5:
options(warn = -1)
h1 <- hPlot(x = "Wr.Hnd", y = "NW.Hnd", data = MASS::survey, 
            type = c("bar", "bubble", "scatter"), group = "Clap", size = "Age")
options(warn = 1)
h1$print("chart5")

# Translation
# legend & setTemplete don't work
# valid types: bar, line, scatter, bubble, column
# can be horizontal if bar selected, swaps x & y

MASS::survey %>% rCharts.scatter.molten(x = "Wr.Hnd", y = "NW.Hnd", group = "Clap", size = "Age", shape = list('', 'bar', 'point'))


options(warn = -1)
h1 <- hPlot(x = "Wr.Hnd", y = "NW.Hnd", data = df, 
            type = df$shp, group = "Clap", size = "Age")
options(warn = 1)


usp = reshape2::melt(USPersonalExpenditure)
# get the decades into a date Rickshaw likes
usp$Var2 <- as.numeric(as.POSIXct(paste0(usp$Var2, "-01-01")))
p4 <- Rickshaw$new()
p4$layer(value ~ Var2, group = "Var1", data = usp, type = "bar", width = 560)
# add a helpful slider this easily; other features TRUE as a default
p4$set(slider = TRUE)
p4$print("chart6")

# rCharts.rickshaw.molten


### nvd3.examples.R ----------------------------------
# This module translates rCharts plots in the pdf documentation in niravis language:
# https://media.readthedocs.org/pdf/rcharts/latest/rcharts.pdf

library(dplyr)
library(htmlwidgets)
library(rCharts)

data.path = 'C:/Nima/R/projects/tutorial/htmlwidget/data/'
source('../../packages/master/niravis-master/R/visgen.R')
source('../../packages/master/niravis-master/R/rCharts.R')
source('../../packages/master/niravis-master/R/nvd3.R')

source('../../packages/master/niravis-master/R/dygraphs.R')
source('../../packages/master/niravis-master/R/plotly.R')


rPlot(mpg ~ wt, data = mtcars, type = 'point')
# # Alternative:
# rPlot(x = 'mpg', y = 'wt', data = mtcars, type = 'point')
# # Change Type:
# rPlot(x = 'mpg', y = 'wt', data = mtcars, type = 'line')
# rPlot(x = 'mpg', y = c('wt','disp'), data = mtcars, type = 'bar') # does not work
# # Multi:
# rPlot(x = 'mpg', y = c('wt','disp'), data = mtcars, type = 'point') # does not work 
# # Molten:
# rPlot(x = 'mpg', y = 'disp', data = mtcars, group = 'vs', type = 'point') # does not work 
# rPlot(x = 'mpg', y = 'disp', data = mtcars, color = 'vs', type = 'point') # works

# Translation:
# Not completed yet!
mtcars %>% rCharts.scatter(x = 'mpg', y = 'disp', color = 'vs', shape = 'point')



# nvd3 scatter Chart:

p1 <- nPlot(mpg ~ wt, group = 'cyl', data = mtcars, type = 'scatterChart')
# Alternative
p1 <- nPlot(x = "wt", y = "mpg", group = 'cyl', data = mtcars, type = 'scatterChart')
p1$xAxis(axisLabel = 'Weight')

mtcars %>% nvd3.scatter(x = "wt", y = "mpg", group = 'cyl', shape = 'point', config = list(xAxis.label = 'Weight', yAxis.label = 'MPG'))


# nvd3 Multibar Chart:

hair_eye = as.data.frame(HairEyeColor)
p2 <- nPlot(Freq ~ Hair, group = 'Eye',
            data = subset(hair_eye, Sex == "Female"),
            type = 'multiBarChart'
)
p2$chart(color = c('brown', 'blue', '#594c26', 'green'))

# Translation:

subset(hair_eye, Sex == "Female") %>% 
  nvd3.bar(x = 'Hair', y = 'Freq', group = "Eye", 
           config = list(palette = list(colorize = T, color = c('brown', 'blue', '#594c26', 'green'))))

# Horizontal:
subset(hair_eye, Sex == "Female") %>% 
  nvd3.bar(y = 'Hair', x = 'Freq', group = "Eye")


# nvd3 Pie Chart:
p4 <- nPlot(~ cyl, data = mtcars, type = 'pieChart')
p4

# Translation:
mtcars %>% nvd3.pie.molten(group = 'cyl')

# nvd3 Donut:
p5 <- nPlot(~ cyl, data = mtcars, type = 'pieChart')
p5$chart(donut = TRUE)

# Make it a donut:
mtcars %>% nvd3.pie.molten(group = 'cyl', config = list(donut = T))

# nvd3 pieChart (Not Molten:)
D = data.frame(x = c(1.2,3.6,7.5, 1.9), y = c("A", "B", "C", "A"))
D %<>% group_by(y) %>% summarise(x = mean(x))
np = nPlot(x ~ y, data = D, type = 'pieChart')
# You can apply color palette to any chart in package rCharts ???!!!
np$chart(color = c('brown', 'blue', '#594c26', 'green'))

D %>% nvd3.pie(theta = 'x', label = 'y', 
               config = list(palette = list(color = c('brown', 'blue', '#594c26', 'green'))))

# nvd3 lineChart:
data(economics, package = 'ggplot2') 

p6 <- nPlot(uempmed ~ date, data = economics, type = 'lineChart')
# Alternative
p6 <- nPlot(y = 'uempmed', x = 'date', data = economics, type = 'lineChart')

# Translation:

economics %>% as.data.frame %>% nvd3.scatter(x = 'date', y = 'uempmed', shape = 'line')

# nvd3 Line with Focus Chart

economics %<>% as.data.frame
ecm <- reshape2::melt(
  economics[,c('date', 'uempmed', 'psavert')],
  id = 'date'
)
p7 <- nPlot(value ~ date, group = 'variable',
            data = ecm,
            type = 'lineWithFocusChart'
)


# Translation:
ecm %>% as.data.frame %>% nvd3.scatter(x = 'date', y = 'value', group = 'variable', shape = 'line', config = list(zoomWindow = T))





# nvd3 Multi Chart
p12 <- nPlot(value ~ date, group = 'variable', data = ecm, type = 'multiChart')
p12$set(multi = list(
  uempmed = list(type="area", yAxis=1),
  psavert = list(type="line", yAxis=2)
))
p12$setTemplate(script = system.file(
  "/libraries/nvd3/layouts/multiChart.html",
  package = "rCharts"
))
p12



### rchart.examples/doc.examples.R ----------------------------------
# This module translates rCharts plots in the pdf documentation in niravis language:
# https://media.readthedocs.org/pdf/rcharts/latest/rcharts.pdf

library(dplyr)
library(htmlwidgets)
library(rCharts)

data.path = 'C:/Nima/R/projects/tutorial/htmlwidget/data/'
source('C:/Nima/R/projects/libraries/developing_packages/niragen.R')

source('C:/Nima/R/projects/libraries/developing_packages/visgen.R')
source('C:/Nima/R/projects/libraries/developing_packages/rCharts.R')
source('C:/Nima/R/projects/libraries/developing_packages/nvd3.R')

source('C:/Nima/R/projects/libraries/developing_packages/dygraphs.R')
source('C:/Nima/R/projects/libraries/developing_packages/plotly.R')


rPlot(mpg ~ wt, data = mtcars, type = 'point')
# # Alternative:
# rPlot(x = 'mpg', y = 'wt', data = mtcars, type = 'point')
# # Change Type:
# rPlot(x = 'mpg', y = 'wt', data = mtcars, type = 'line')
# rPlot(x = 'mpg', y = c('wt','disp'), data = mtcars, type = 'bar') # does not work
# # Multi:
# rPlot(x = 'mpg', y = c('wt','disp'), data = mtcars, type = 'point') # does not work 
# # Molten:
# rPlot(x = 'mpg', y = 'disp', data = mtcars, group = 'vs', type = 'point') # does not work 
# rPlot(x = 'mpg', y = 'disp', data = mtcars, color = 'vs', type = 'point') # works

# Translation:
# Not completed yet!
mtcars %>% rCharts.scatter(x = 'mpg', y = 'disp', color = 'vs', shape = 'point')



# nvd3 scatter Chart:

p1 <- nPlot(mpg ~ wt, group = 'cyl', data = mtcars, type = 'scatterChart')
# Alternative
p1 <- nPlot(x = "wt", y = "mpg", group = 'cyl', data = mtcars, type = 'scatterChart')
p1$xAxis(axisLabel = 'Weight')

mtcars %>% nvd3.scatter.molten(x = "wt", y = "mpg", group = 'cyl', shape = 'point', config = list(xAxis.label = 'Weight', yAxis.label = 'MPG'))


# nvd3 Multibar Chart:


hair_eye = as.data.frame(HairEyeColor)
p2 <- nPlot(Freq ~ Hair, group = 'Eye',
            data = subset(hair_eye, Sex == "Female"),
            type = 'multiBarChart'
)
p2$chart(color = c('brown', 'blue', '#594c26', 'green'))

# Translation:

subset(hair_eye, Sex == "Female") %>% 
  nvd3.bar.molten(x = 'Hair', y = 'Freq', group = "Eye", 
                  config = list(palette = list(color = c('brown', 'blue', '#594c26', 'green'))))

# Horizontal:
subset(hair_eye, Sex == "Female") %>% 
  nvd3.bar.molten(y = 'Hair', x = 'Freq', group = "Eye")


# nvd3 Pie Chart:
p4 <- nPlot(~ cyl, data = mtcars, type = 'pieChart')
p4

mtcars %>% nvd3.pie.molten(group = 'cyl')

# nvd3 Donut:
p5 <- nPlot(~ cyl, data = mtcars, type = 'pieChart')
p5$chart(donut = TRUE)

# Make it a donut:
mtcars %>% nvd3.pie.molten(group = 'cyl', config = list(donut = T))

# nvd3 pieChart (Not Molten:)
D = data.frame(x = c(1.2,3.6,7.5, 1.9), y = c("A", "B", "C", "A"))
D %<>% group_by(y) %>% summarise(x = mean(x))
np = nPlot(x ~ y, data = D, type = 'pieChart')
# You can apply color palette to any chart in package rCharts ???!!!
np$chart(color = c('brown', 'blue', '#594c26', 'green'))

D %>% nvd3.pie(theta = 'x', label = 'y', 
               config = list(palette = list(color = c('brown', 'blue', '#594c26', 'green'))))

# nvd3 lineChart:
data(economics, package = 'ggplot2') 

p6 <- nPlot(uempmed ~ date, data = economics, type = 'lineChart')
# Alternative
p6 <- nPlot(y = 'uempmed', x = 'date', data = economics, type = 'lineChart')

# Translation:

economics %>% as.data.frame %>% nvd3.scatter.molten(x = 'date', y = 'uempmed', shape = 'line')

# nvd3 Line with Focus Chart

economics %<>% as.data.frame
ecm <- reshape2::melt(
  economics[,c('date', 'uempmed', 'psavert')],
  id = 'date'
)
p7 <- nPlot(value ~ date, group = 'variable',
            data = ecm,
            type = 'lineWithFocusChart'
)


# Translation:
ecm %>% as.data.frame %>% nvd3.scatter.molten(x = 'date', y = 'value', group = 'variable', shape = 'line', config = list(zoomWindow = T))





# nvd3 Multi Chart
p12 <- nPlot(value ~ date, group = 'variable', data = ecm, type = 'multiChart')
p12$set(multi = list(
  uempmed = list(type="area", yAxis=1),
  psavert = list(type="line", yAxis=2)
))
p12$setTemplate(script = system.file(
  "/libraries/nvd3/layouts/multiChart.html",
  package = "rCharts"
))
p12

### rchart.examples/links.txt ----------------------------------
# http://rcharts.io/gallery/#visualizationType=all

# http://walkerke.github.io/2014/06/rcharts-pyramids/


### rchart.examples/scripts/dash.hPlot/app.R ----------------------------------
require(rCharts)
require(shiny)
require(data.table)
runApp(list(
  ui = mainPanel( span="span6", 
                  showOutput("chart2", "Highcharts"),
                  showOutput("chart3", "Highcharts"),
                  showOutput("chart4", "Highcharts")
  ),
  server = function(input, output){
    output$chart3 <- renderChart({
      a <- hPlot(Pulse ~ Height, data = MASS::survey, type = "bubble", title = "Zoom demo", subtitle = "bubble chart", size = "Age", group = "Exer")
      a$chart(zoomType = "xy")
      a$chart(backgroundColor = NULL)
      a$set(dom = 'chart3')
      return(a)
    })
    output$chart2 <- renderChart({
      survey <- as.data.table(MASS::survey)
      freq <- survey[ , .N, by = c('Sex', 'Smoke')]
      a <- hPlot(x = 'Smoke', y = 'N', data = freq, type = 'column', group = 'Sex')
      a$chart(backgroundColor = NULL)
      a$set(dom = 'chart2')
      return(a)
    })
    output$chart4 <- renderChart({
      survey <- as.data.table(MASS::survey)
      freq <- survey[ , .N, by = c('Smoke')]
      a <- hPlot(x = "Smoke", y = "N", data = freq, type = "pie")
      a$plotOptions(pie = list(size = 150))
      a$chart(backgroundColor = NULL)
      a$set(dom = 'chart4')
      return(a)
    })
  }
))
### rchart.examples/scripts/dash.rPlot/app.R ----------------------------------
require(shiny)
require(rCharts)
require(datasets)

server<-function(input,output){
  output$myChart<-renderChart({
    p1<-rPlot(input$x,input$y, data=mtcars,type="point",color=input$color,facet=input$facet)
    p1$addParams(dom="myChart")
    return(p1)
  })
}

ui<-pageWithSidebar(
  headerPanel("Motor Trend Cars data with rCharts"),
  sidebarPanel(
    selectInput(inputId="y",
                label="Y Variable",
                choices=names(mtcars),
    ),
    selectInput(inputId="x",
                label="X Variable",
                choices=names(mtcars),
    ),
    selectInput(inputId="color",
                label="Color by Variable",
                choices=names(mtcars[,c(2,8,9,10,11)]),
    ),
    selectInput(inputId="facet",
                label="Facet by Variable",
                choices=names(mtcars[,c(2,8,9,10,11)]),
    )    
  ),
  mainPanel(
    showOutput("myChart","polycharts")
  )
)

shinyApp(ui=ui,server=server)

### rchart.examples/scripts/dashboard.2/ui.R ----------------------------------
options(RCHART_LIB = 'dimple')

shinyUI(pageWithSidebar(
  
  headerPanel("rCharts and shiny"),
  
  sidebarPanel(),
  
  mainPanel(
    h4("Graph here"),
    showOutput("test", "dimple")
  )
))
### rchart.examples/scripts/dashboard.2/server.R ----------------------------------
library(rCharts)
library(reshape2)
options(RCHART_WIDTH = 1700)
meansconferences <-read.csv("https://raw.github.com/patilv/ESPNBball/master/meansconferences.csv")

shinyServer(function(input, output) {
  output$test <- renderChart2({
    meltmeansconferences=melt(meansconferences[-c(1,10:14)], id.vars=c("Conference","Year"))
    d1=dPlot(y="Year", x="value",data=meltmeansconferences, groups="variable",type="bar")
    d1$yAxis(type="addCategoryAxis", orderRule="Year")
    d1$xAxis(type="addPctAxis")
    return(d1)
  })
}
)




# https://github.com/metagraf/rVega
# http://rstudio.github.io/leaflet/

# http://rcharts.io/viewer/?7979341#.Vuejrvl95aQ
# http://timelyportfolio.github.io/rCharts_systematic_cluster/pimco_pcplots.html
# https://ramnathv.github.io/rChartsShiny/
# http://slidify.org/

### rchart.examples/scripts/dashboard.iris/ui.R ----------------------------------
require(rCharts)
shinyUI(pageWithSidebar(
  headerPanel("rCharts: Interactive Charts from R using polychart.js"),
  
  sidebarPanel(
    selectInput(inputId = "x",
                label = "Choose X",
                choices = c('SepalLength', 'SepalWidth', 'PetalLength', 'PetalWidth'),
                selected = "SepalLength"),
    selectInput(inputId = "y",
                label = "Choose Y",
                choices = c('SepalLength', 'SepalWidth', 'PetalLength', 'PetalWidth'),
                selected = "SepalWidth")
  ),
  mainPanel(
    showOutput("myChart", "polycharts")
  )
))
### rchart.examples/scripts/dashboard.iris/server.R ----------------------------------
## server.r
require(rCharts)
shinyServer(function(input, output) {
  output$myChart <- renderChart({
    names(iris) = gsub("\\.", "", names(iris))
    p1 <- rPlot(input$x, input$y, data = iris, color = "Species", 
                facet = "Species", type = 'point')
    p1$addParams(dom = 'myChart')
    return(p1)
  })
})

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

# niravis translation:

library(niragen)
source('C:/Nima/RCode/packages/master/niravis-master/R/visgen.R')
source('C:/Nima/RCode/packages/master/niravis-master/R/dashboard.R')

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





### example2.R ---------------------------
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

# niravis translation:

library(niragen)
source('C:/Nima/RCode/packages/master/niravis-master/R/visgen.R')
source('C:/Nima/RCode/packages/master/niravis-master/R/dashboard.R')

E = list()

E$main   = list(type = 'fluidPage', layout = c('intro', 'sbl'))
# E$sbl    = list(type = 'sidebarLayout' , layout.side = 'tutor1', layout.main = 'plot')
E$sbl    = list(type = 'sidebarLayout' , layout.side = c('bins', 'help'), layout.main = 'plot')
# E$tutor1 = list(type = 'tutorBox', layout = c('bins', 'help'), tutor.step = 2, tutor.lesson = "This is the sidebar. Look how intro elements can nest")
E$bins   = list(type = 'sliderInput' , title = "Number of bins:", min = 1, max = 50, value = 30, tutor.step = 3, tutor.lesson = 'This is a slider!', tutor.hint = 'You can slide me')
E$help   = list(type = 'actionButton', title = 'Press for instructions', tutor.step = 4, tutor.lesson = "This is a button", tutor.hint = "You can press me")
E$plot   = list(type = 'plotOutput'  , title = 'distPlot', service = "get.plot(input$bins)", tutor.step = 5, tutor.lesson = "This is the main plot")
E$intro  = list(type = 'static', object = introjsUI())

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

# E$help$service = NULL

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





### example_simpler.R ---------------------------
library(rintrojs)
library(shiny)

# Define UI for application that draws a histogram
ui <- shinyUI(fluidPage(
  introjsUI(),
  
  # Sidebar with a slider input for number of bins
  sidebarLayout(sidebarPanel(
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
    )
  ),
  
  # Show a plot of the generated distribution
  mainPanel(
    plotOutput("distPlot")
  ))
))

# Define server logic required to draw a histogram
server <- shinyServer(function(input, output, session) {
  
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
               {introjs(session, options = list("nextLabel"="Forward",
                                                "prevLabel"="Back",
                                                "skipLabel"="Skip"))}
  )
})

# Run the application
shinyApp(ui = ui, server = server)

# niravis translation:

library(niragen)
source('C:/Nima/RCode/packages/master/niravis-master/R/visgen.R')
source('C:/Nima/RCode/packages/master/niravis-master/R/dashboard.R')

E = list()

E$main   = list(type = 'fluidPage', layout = c('intro', 'sbl'))
E$sbl    = list(type = 'sidebarLayout' , layout.side = c('bins', 'help'), layout.main = 'plot')
E$bins   = list(type = 'sliderInput' , title = "Number of bins:", min = 1, max = 50, value = 30, tutor.step = 3, tutor.lesson = 'This is a slider!', tutor.hint = 'You can slide me')
E$help   = list(type = 'actionButton', title = 'Press for instructions', tutor.step = 4, tutor.lesson = "This is a button", tutor.hint = "You can press me")
E$plot   = list(type = 'plotOutput'  , title = 'distPlot', service = "get.plot(input$bins)", tutor.step = 5, tutor.lesson = "This is the main plot")
E$intro  = list(type = 'static', object = introjsUI())

get.plot = function(bins){
  x    <- faithful[, 2]
  bins <- seq(min(x), max(x), length.out = bins + 1)
  hist(x, breaks = bins, col = 'darkgray', border = 'white')
}

E$help$service = "introjs(session, options = list(nextLabel = 'Forward', prevLabel = 'Back', skipLabel = 'Skip'))"

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


###### Package: rjson ========================
### convert.R -----------------------------
dataset <- read.csv("C:/Nima/RCode/projects/tutorials/rjson/data/Data_DISCHARGES_Exceptions_Working_File.csv")

fail = c(706,5141, 12491, 13745:13748, 25244)
a = jsonlite::fromJSON(paste0('[', dataset$data[- fail] %>% paste(collapse = ','), ']'), flatten = T)

for(i in names(a)){if(inherits(a[,i],'list')){a[,i] <- NULL}}

write.csv(a, 'converted.csv')

###### Package: rook:

### exampleWithGoogleVis:
require(Rook)
require(googleVis)
s <- Rhttpd$new()
s$start(listen='127.0.0.1')

my.app <- function(env){
  ## Start with a table and allow the user to upload a CSV-file
  req <- Request$new(env)
  res <- Response$new()
  
  ## Provide some data to start with
  ## Exports is a sample data set of googleVis
  data <- Exports[,1:2] 
  ## Add functionality to upload CSV-file
  if (!is.null(req$POST())) {
    ## Read data from uploaded CSV-file
    data <- req$POST()[["data"]]
    data <- read.csv(data$tempfile)
  }
  ## Create table with googleVis
  tbl <- gvisTable(data, 
                   options=list(gvis.editor="Edit me!",
                                height=350),
                   chartid="myInitialView")
  ## Write the HTML output and
  ## make use of the googleVis HTML output.
  ## See vignette('googleVis') for more details
  res$write(tbl$html$header) 
  res$write("<h1>My first Rook app with googleVis</h1>")
  res$write(tbl$html$chart)
  res$write('
            Read CSV file:<form method="POST" enctype="multipart/form-data">
            <input type="file" name="data">
            <input type="submit" name="Go">\n</form>')            
  res$write(tbl$html$footer)
  res$finish()
}
s$add(app=my.app, name='googleVisTable')


## Open a browser window and display the web app
s$browse('googleVisTable')

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
### modalDialog.R ---------------------------------------
shinyApp(
  ui = basicPage(
    actionButton("show", "Show modal dialog")
  ),
  server = function(input, output) {
    observeEvent(input$show, {
      showModal(modalDialog(
        title = "Important message",
        "This is an important message!"
      ))
    })
  }
)


# Display a message that can be dismissed by clicking outside the modal dialog,
# or by pressing Esc.
shinyApp(
  ui = basicPage(
    actionButton("show", "Show modal dialog")
  ),
  server = function(input, output) {
    observeEvent(input$show, {
      showModal(modalDialog(
        title = "Somewhat important message",
        "This is a somewhat important message.",
        easyClose = TRUE,
        footer = NULL
      ))
    })
  }
)


# Display a modal that requires valid input before continuing.
shinyApp(
  ui = basicPage(
    actionButton("show", "Show modal dialog"),
    verbatimTextOutput("dataInfo")
  ),
  
  server = function(input, output) {
    # reactiveValues object for storing current data set.
    vals <- reactiveValues(data = NULL)
    
    # Return the UI for a modal dialog with data selection input. If 'failed' is
    # TRUE, then display a message that the previous value was invalid.
    dataModal <- function(failed = FALSE) {
      modalDialog(
        textInput("dataset", "Choose data set",
                  placeholder = 'Try "mtcars" or "abc"'
        ),
        span('(Try the name of a valid data object like "mtcars", ',
             'then a name of a non-existent object like "abc")'),
        if (failed)
          div(tags$b("Invalid name of data object", style = "color: red;")),
        
        footer = tagList(
          modalButton("Cancel"),
          actionButton("ok", "OK")
        )
      )
    }
    
    # Show modal when button is clicked.
    observeEvent(input$show, {
      showModal(dataModal())
    })
    
    # When OK button is pressed, attempt to load the data set. If successful,
    # remove the modal. If not show another modal, but this time with a failure
    # message.
    observeEvent(input$ok, {
      # Check that data object exists and is data frame.
      if (!is.null(input$dataset) && nzchar(input$dataset) &&
          exists(input$dataset) && is.data.frame(get(input$dataset))) {
        vals$data <- get(input$dataset)
        removeModal()
      } else {
        showModal(dataModal(failed = TRUE))
      }
    })
    
    # Display information about selected data
    output$dataInfo <- renderPrint({
      if (is.null(vals$data))
        "No data selected"
      else
        summary(vals$data)
    })
  }
)

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

### links.R ---------------------------------------


http://enhancedatascience.com/2017/02/15/next-previous-button-shiny-app-tabbox/
  
  https://github.com/daattali/shinyjs

https://github.com/Yang-Tang/shinyjqui

https://dreamrs.github.io/shinyWidgets/
  
  http://enhancedatascience.com/2017/02/21/three-r-shiny-tricks-to-make-your-shiny-app-shines-23-semi-collapsible-sidebar/
  
  https://demo.appsilondatascience.com/shiny-semantic-components/#tabset
  
  http://enhancedatascience.com/2017/07/10/the-packages-you-need-for-your-r-shiny-application/
  
  
###### Package shinyBS ===================================
### popover.R ------------------------
library(magrittr)
library(shiny)
library(shinyBS)
library(niragen)


shinyApp(
  ui =
    fluidPage(
      sidebarLayout(
        sidebarPanel(
          sliderInput("bins",
                      "Number of bins:",
                      min = 1,
                      max = 50,
                      value = 30),
          bsTooltip("bins", "The wait times will be broken into this many equally spaced bins",
                    "right", options = list(container = "body"))
        ),
        mainPanel(
          plotOutput("distPlot")
        )
      )
    ),
  server =
    function(input, output, session) {
      output$distPlot <- renderPlot({
        
        # generate bins based on input$bins from ui.R
        x    <- faithful[, 2]
        bins <- seq(min(x), max(x), length.out = input$bins + 1)
        
        # draw the histogram with the specified number of bins
        hist(x, breaks = bins, col = 'darkgray', border = 'white')
        
      })
      addPopover(session, "distPlot", "Data", content = paste0("
                                                               Waiting time between ",
                                                               "eruptions and the duration of the eruption for the Old Faithful geyser ",
                                                               "in Yellowstone National Park, Wyoming, USA.
                                                               
                                                               Azzalini, A. and ",
                                                               "Bowman, A. W. (1990). A look at some data on the Old Faithful geyser. ",
                                                               "Applied Statistics 39, 357-365.
                                                               
                                                               "), trigger = 'click')
    }
      )




# Option 2: Does not work! Eric said he has fixed it but he has not!!!!!!
# https://github.com/ebailey78/shinyBS/issues/22

library(shiny)
library(shinyBS)
shinyApp(
  ui =
    fluidPage(
      sidebarLayout(
        sidebarPanel(
          sliderInput("bins",
                      "Number of bins:",
                      min = 1,
                      max = 50,
                      value = 30),
          bsTooltip("bins", "The wait times will be broken into this many equally spaced bins",
                    "right", options = list(container = "body"))
        ),
        mainPanel(
          plotOutput("distPlot"),
          bsPopover("distPlot", "Data", content = paste0("
                                                         Waiting time between ",
                                                         "eruptions and the duration of the eruption for the Old Faithful geyser ",
                                                         "in Yellowstone National Park, Wyoming, USA.
                                                         
                                                         Azzalini, A. and ",
                                                         "Bowman, A. W. (1990). A look at some data on the Old Faithful geyser. ",
                                                         "Applied Statistics 39, 357-365.
                                                         
                                                         "), trigger = 'click', options = list(container = "body"))
          
          )
          )
      ),
  server =
    function(input, output, session) {
      output$distPlot <- renderPlot({
        
        # generate bins based on input$bins from ui.R
        x    <- faithful[, 2]
        bins <- seq(min(x), max(x), length.out = input$bins + 1)
        
        # draw the histogram with the specified number of bins
        hist(x, breaks = bins, col = 'darkgray', border = 'white')
        
      })
    }
      )





# Translation to niravis:
get.plot = function(bins){
  x    <- faithful[, 2]
  bins <- seq(min(x), max(x), length.out = bins + 1)
  hist(x, breaks = bins, col = 'darkgray', border = 'white')
}

I = list()
I$main     = list(type = 'sidebarLayout', layout.side = 'bins', layout.main = 'distPlot')
I$bins     = list(type = 'sliderInput', title = "Number of bins:", min = 1, max = 50, value = 30, tooltip = 'The wait times will be broken into this many equally spaced bins', tooltip.placement = "right", tooltip.options = list(container = "body"))
I$distPlot = list(type = 'plotOutput', service = 'get.plot(input$bins)', 
                  popover = c(
                    "\n Waiting time between ", "eruptions and the duration of the eruption for the Old Faithful geyser ", 
                    "in Yellowstone National Park, Wyoming, USA.", "", 
                    "Azzalini, A. and ",
                    "Bowman, A. W. (1990). A look at some data on the Old Faithful geyser. ",
                    "Applied Statistics 39, 357-365.", "", ""), 
                  popover.trigger = 'click', popover.title = 'Data')

dash = new('DASHBOARD', items = I, king.layout = list('main'))
shinyApp(dash$dashboard.ui(), dash$dashboard.server())

### bsmodal.R ------------------------
library(shiny)
library(shinyBS)

shinyApp(
  ui =
    fluidPage(
      sidebarLayout(
        sidebarPanel(
          sliderInput("bins",
                      "Number of bins:",
                      min = 1,
                      max = 50,
                      value = 30),
          actionButton("tabBut", "View Table")
        ),
        
        mainPanel(
          plotOutput("distPlot"),
          bsModal("modalExample", "Data Table", "tabBut", size = "large",
                  dataTableOutput("distTable"))
        )
      )
    ),
  server =
    function(input, output, session) {
      
      output$distPlot <- renderPlot({
        
        x    <- faithful[, 2]
        bins <- seq(min(x), max(x), length.out = input$bins + 1)
        
        # draw the histogram with the specified number of bins
        hist(x, breaks = bins, col = 'darkgray', border = 'white')
        
      })
      
      output$distTable <- renderDataTable({
        
        x    <- faithful[, 2]
        bins <- seq(min(x), max(x), length.out = input$bins + 1)
        
        # draw the histogram with the specified number of bins
        tab <- hist(x, breaks = bins, plot = FALSE)
        tab$breaks <- sapply(seq(length(tab$breaks) - 1), function(i) {
          paste0(signif(tab$breaks[i], 3), "-", signif(tab$breaks[i+1], 3))
        })
        tab <- as.data.frame(do.call(cbind, tab))
        colnames(tab) <- c("Bins", "Counts", "Density")
        return(tab[, 1:3])
        
      }, options = list(pageLength=10))
      
    }
)

# Translation to niravis:

I = list()
I$main     = list(type = 'sidebarLayout', layout.side = c('bins', 'tabBut'), layout.main = c('distPlot', 'modalExample'))
I$bins     = list(type = 'sliderInput' , title = "Number of bins:", min = 1, max = 50, value = 30)
I$tabBut   = list(type = 'actionButton', title = "View Table")
I$distPlot = list(type = 'plotOutput', service = 'get.plot(input$bins)')
I$modalExample = list(type = 'bsModal', title = 'Data Table', trigger = "tabBut", size = "large", layout = 'distTable')
I$distTable = list(type = 'dataTableOutput', service = 'get.dt(input$bins)', options = list(pageLength=10), width = '100%')

get.dt = function(bins){
  x    <- faithful[, 2]
  bins <- seq(min(x), max(x), length.out = bins + 1)
  
  # draw the histogram with the specified number of bins
  tab <- hist(x, breaks = bins, plot = FALSE)
  tab$breaks <- sapply(seq(length(tab$breaks) - 1), function(i) {
    paste0(signif(tab$breaks[i], 3), "-", signif(tab$breaks[i+1], 3))
  })
  tab <- as.data.frame(do.call(cbind, tab))
  colnames(tab) <- c('Bins', 'Counts', 'Density')
  return(tab[, 1:3])
}

get.plot = function(bins){
  x    <- faithful[, 2]
  bins <- seq(min(x), max(x), length.out = bins + 1)
  
  # draw the histogram with the specified number of bins
  hist(x, breaks = bins, col = 'darkgray', border = 'white')
}

dash = new('DASHBOARD', items = I, king.layout = list('main'))
shinyApp(dash$dashboard.ui(), dash$dashboard.server())

### bscollapse.R ------------------------
library(shiny)
library(shinyBS)

shinyApp(
  ui =
    fluidPage(
      sidebarLayout(
        sidebarPanel(HTML("This button will open Panel 1 using updateCollapse."),
                     actionButton("p1Button", "Push Me!"),
                     selectInput("styleSelect", "Select style for Panel 1",
                                 c("default", "primary", "danger", "warning", "info", "success"))
        ),
        mainPanel(
          bsCollapse(id = "collapseExample", open = "Panel 2",
                     bsCollapsePanel("Panel 1", "This is a panel with just text ",
                                     "and has the default style. You can change the style in ",
                                     "the sidebar.", style = "info"),
                     bsCollapsePanel("Panel 2", "This panel has a generic plot. ",
                                     "and a 'success' style.", plotOutput("genericPlot"), style = "success")
          )
        )
      )
    ),
  server =
    function(input, output, session) {
      output$genericPlot <- renderPlot(plot(rnorm(100)))
      observeEvent(input$p1Button, ({
        updateCollapse(session, "collapseExample", open = "Panel 1")
      }))
      observeEvent(input$styleSelect, ({
        updateCollapse(session, "collapseExample", style = list("Panel 1" = input$styleSelect))
      }))
    }
)


# Translation to niravis:

I = list()
I$main            = list(type = 'sidebarLayout', layout.side = c('htmlText', 'p1Button', 'styleSelect'), layout.main = 'collapseExample')
I$htmlText        = list(type = 'static' , object = HTML("This button will open Panel 1 using updateCollapse."))
I$p1Button        = list(type = 'actionButton', title = "Push Me!", service = "updateCollapse(session, 'collapseExample', open = 'Panel 1')")
I$styleSelect     = list(type = 'selectInput' , title = "Select style for Panel 1", choices = c("default", "primary", "danger", "warning", "info", "success"), 
                         service = "updateCollapse(session, 'collapseExample', style = list('Panel 1' = input$styleSelect))")
I$collapseExample = list(type = 'bsCollapse', open = "Panel 2", layout = c('panel1', 'panel2'))
I$panel1          = list(type = 'bsCollapsePanel', title = 'Panel 1', style = "info", layout = 'text1')
I$panel2          = list(type = 'bsCollapsePanel', title = 'Panel 2', style = "success", layout = c('text2', 'genericPlot'))
I$text1           = list(type = 'static', object = "This is a panel with just text and has the default style. You can change the style in the sidebar")
I$text2           = list(type = 'static', object = "This panel has a generic plot and a 'success' style.")
I$genericPlot     = list(type = 'plotOutput', service = "plot(rnorm(100))", width = '100%', height = '400px')

dash = new('DASHBOARD', items = I, king.layout = list('main'))
shinyApp(dash$dashboard.ui(), dash$dashboard.server())


### tooltip.R ------------------------
library(shiny)
library(shinyBS)
shinyApp(
  ui =
    fluidPage(
      sidebarLayout(
        sidebarPanel(
          sliderInput("bins",
                      "Number of bins:",
                      min = 1,
                      max = 50,
                      value = 30),
          bsTooltip("bins", "The wait times will be broken into this many equally spaced bins",
                    "right", options = list(container = "body"))
        ),
        mainPanel(
          plotOutput("distPlot")
        )
      )
    ),
  server =
    function(input, output, session) {
      output$distPlot <- renderPlot({
        
        # generate bins based on input$bins from ui.R
        x    <- faithful[, 2]
        bins <- seq(min(x), max(x), length.out = input$bins + 1)
        
        # draw the histogram with the specified number of bins
        hist(x, breaks = bins, col = 'darkgray', border = 'white')
        
      })
      addPopover(session, "distPlot", "Data", content = paste0("
                                                               Waiting time between ",
                                                               "eruptions and the duration of the eruption for the Old Faithful geyser ",
                                                               "in Yellowstone National Park, Wyoming, USA.
                                                               
                                                               Azzalini, A. and ",
                                                               "Bowman, A. W. (1990). A look at some data on the Old Faithful geyser. ",
                                                               "Applied Statistics 39, 357-365.
                                                               
                                                               "), trigger = 'click')
    }
      )

### gettablemodal.R ------------------------
# get table bs modal example with niravis:


# Example:
classes = list(caseID = c('character', 'factor'), activity = c('character', 'factor'), status = c('character', 'factor'), timestamp = 'POSIXct')

dashItems = list()
dashItems$main   = list(type = 'fluidPage', layout = list('action', 'my_dialog'))
dashItems$action = list(type = 'actionButton', title = 'Click me!')
dashItems = dashItems %<==>% 
  build.container.get.table(name = 'my_dialog', classes = classes, containerType = 'bsModal', title = 'Get file dialog', trigger = 'action', size = 'small')

dash   <- new('DASHBOARD', items = dashItems, king.layout = list('main'))
ui     <- dash$dashboard.ui()
server <- dash$dashboard.server()
shinyApp(ui, server)


###### Package shinyDash: ================================
### server.R -----------------------
library(shiny)
library(ShinyDash)
library(XML)
library(httr)

shinyServer(function(input, output, session) {
  
  all_values <- 100  # Start with an initial value 100
  max_length <- 80   # Keep a maximum of 80 values
  
  # Collect new values at timed intervals and adds them to all_values
  # Returns all_values (reactively)
  values <- reactive({
    # Set the delay to re-run this reactive expression
    invalidateLater(input$delay, session)
    
    # Generate a new number
    isolate(new_value <- last(all_values) * (1 + input$rate + runif(1, min = -input$volatility, max = input$volatility)))
    
    # Append to all_values
    all_values <<- c(all_values, new_value)
    
    # Trim all_values to max_length (dropping values from beginning)
    all_values <<- last(all_values, n = max_length)
    
    all_values
  })
  
  
  output$weatherWidget <- renderWeather(2487956, "f", session=session)
  
  # Set the value for the gauge
  # When this reactive expression is assigned to an output object, it is
  # automatically wrapped into an observer (i.e., a reactive endpoint)
  output$live_gauge <- renderGauge({
    running_mean <- mean(last(values(), n = 10))
    round(running_mean, 1)
  })
  
  # Output the status text ("OK" vs "Past limit")
  # When this reactive expression is assigned to an output object, it is
  # automatically wrapped into an observer (i.e., a reactive endpoint)
  output$status <- reactive({
    running_mean <- mean(last(values(), n = 10))
    if (running_mean > 200)
      list(text="Past limit", widgetState="alert", subtext="", value=running_mean)
    else if (running_mean > 150)
      list(text="Warn", subtext = "Mean of last 10 approaching threshold (200)",
           widgetState="warning", value=running_mean)
    else
      list(text="OK", subtext="Mean of last 10 below threshold (200)", value=running_mean)
  })
  
  
  # Update the latest value on the graph
  # Send custom message (as JSON) to a handler on the client
  sendGraphData("live_line_graph", {
    list(
      # Most recent value
      y0 = last(values()),
      # Smoothed value (average of last 10)
      y1 = mean(last(values(), n = 10))
    )
  })
  
})


# Return the last n elements in vector x
last <- function(x, n = 1) {
  start <- length(x) - n + 1
  if (start < 1)
    start <- 1
  
  x[start:length(x)]
}

### ui.R -----------------------
library(shiny)
library(ShinyDash)

shinyUI(bootstrapPage(
  h1("ShinyDash Example"),
  
  gridster(tile.width = 250, tile.height = 250,
           gridsterItem(col = 1, row = 1, size.x = 1, size.y = 1,
                        
                        sliderInput("rate", "Rate of growth:",
                                    min = -0.25, max = .25, value = .02, step = .01),
                        
                        sliderInput("volatility", "Volatility:",
                                    min = 0, max = .5, value = .25, step = .01),
                        
                        sliderInput("delay", "Delay (ms):",
                                    min = 250, max = 5000, value = 3000, step = 250),
                        
                        tags$p(
                          tags$br(),
                          tags$a(href = "https://github.com/trestletech/ShinyDash-Sample", "Source code")
                        )
           ),
           gridsterItem(col = 2, row = 1, size.x = 2, size.y = 1,
                        lineGraphOutput("live_line_graph",
                                        width=532, height=250, axisType="time", legend="topleft"
                        )
           ),
           gridsterItem(col = 1, row = 2, size.x = 1, size.y = 1,
                        gaugeOutput("live_gauge", width=250, height=200, units="CPU", min=0, max=200, title="Cost per Unit")
           ),
           gridsterItem(col = 2, row = 2, size.x = 1, size.y = 1,
                        tags$div(class = 'grid_title', 'Status'),
                        htmlWidgetOutput('status', 
                                         tags$div(id="text", class = 'grid_bigtext'),
                                         tags$p(id="subtext"),
                                         tags$p(id="value", 
                                                `data-filter`="round 2 | prepend '$' | append ' cost per unit'",
                                                `class`="numeric"))
           ),
           gridsterItem(col = 3, row = 2, size.x = 1, size.y = 1,
                        weatherWidgetOutput("weatherWidget", width="100%", height="90%")
           )
  )
))
### readme.md -----------------------
# ShinyDash-Sample
# ================
#   
#   Example shiny app built on the [ShinyDash](https://github.com/trestletech/ShinyDash) package. This application is hosted online at http://spark.rstudio.com/trestletech/ShinyDash-Sample/.
# 
# Credits
# =======
#   
#   Many thanks to [Winston Chang](https://github.com/wch) who provided much of the scaffolding for this package. Two helpful repositories in particular were:
#   
#   * [shinyGridster](https://github.com/wch/shiny-gridster), the R package wrapping up Gridster for use with Shiny, is released under the GPL-3 license.
# * [shiny-jsdemo](https://github.com/wch/shiny-jsdemo), an R package demonstrating the various techniques to integrate third-party JavaScript libraries into Shiny.
# 
# 
# License information
# ===================
#   
#   * All code in this package is licensed under GPL-3


###### Package shinyDashboard ==========================================

## box.example.app.R -------------------------
htmlStrN = function(str, N, suffix = ""){
  paste0(str, repeat.char('&#160', N - nchar(str) - nchar(suffix)), suffix)
}


library(shinydashboard)

## Only run this example in interactive R sessions
if (interactive()) {
  library(shiny)
  
  # A dashboard body with a row of infoBoxes and valueBoxes, and two rows of boxes
  body <- dashboardBody(
    
    # infoBoxes
    fluidRow(
      infoBox(
        "Orders", uiOutput("orderNum2"), "Subtitle", icon = icon("credit-card")
      ),
      infoBox(
        "Approval Rating", "60%", icon = icon("line-chart"), color = "green",
        fill = TRUE
      ),
      infoBox(
        "Progress", uiOutput("progress2"), icon = icon("users"), color = "purple"
      )
    ),
    
    # valueBoxes
    fluidRow(
      valueBox(
        uiOutput("orderNum"), "New Orders", icon = icon("credit-card"),
        href = "http://google.com"
      ),
      valueBox(
        tagList("60", tags$sup(style="font-size: 20px", "%")),
        "Approval Rating", icon = icon("line-chart"), color = "green"
      ),
      valueBox(
        htmlOutput("progress"), "Progress", icon = icon("users"), color = "purple"
      )
    ),
    
    # Boxes
    fluidRow(
      box(status = "primary",
          sliderInput("orders", "Orders", min = 1, max = 2000, value = 650),
          selectInput("progress", "Progress",
                      choices = c("0%" = 0, "20%" = 20, "40%" = 40, "60%" = 60, "80%" = 80,
                                  "100%" = 100)
          )
      ),
      box(title = "Histogram box title",
          status = "warning", solidHeader = TRUE, collapsible = TRUE,
          plotOutput("plot", height = 250)
      )
    ),
    
    # Boxes with solid color, using `background`
    fluidRow(
      # Box with textOutput
      box(
        title = "Status summary",
        background = "green",
        width = 4,
        textOutput("status")
      ),
      
      # Box with HTML output, when finer control over appearance is needed
      box(
        title = "Status summary 2",
        width = 4,
        background = "red",
        uiOutput("status2")
      ),
      
      box(
        width = 4,
        background = "light-blue",
        p("This is content. The background color is set to light-blue")
      )
    )
  )
  
  server <- function(input, output) {
    output$orderNum <- renderText({
      paste(htmlStrN("Order", 10, suffix = ':'), 
            prettyNum(input$orders, big.mark=","), 
            "<br>", 
            htmlStrN("Balance", 10, suffix = ':'),
            prettyNum(2589*input$orders, big.mark=","))
    })
    
    output$orderNum2 <- renderText({
      paste("Jingul  :", prettyNum(input$orders, big.mark=","), "<br>", "Min&#160&#160&#160:", prettyNum(129087663746, big.mark = ",", small.mark = "/"))
    })
    
    output$progress <- renderUI({
      tagList(input$progress, tags$sup(style="font-size: 20px", "%"))
    })
    
    output$progress2 <- renderUI({
      paste0(input$progress, "%")
    })
    
    output$status <- renderText({
      paste0("There are ", input$orders,
             " orders, and so the current progress is ", input$progress, "%.")
    })
    
    output$status2 <- renderUI({
      iconName <- switch(input$progress,
                         "100" = "ok",
                         "0" = "remove",
                         "road"
      )
      p("Current status is: ", icon(iconName, lib = "glyphicon"))
    })
    
    
    output$plot <- renderPlot({
      hist(rnorm(input$orders))
    })
  }
  
  shinyApp(
    ui = dashboardPage(
      dashboardHeader(),
      dashboardSidebar(),
      body
    ),
    server = server
  )
}
## login.example.app.R -------------------------
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

## header.example.app.R -------------------------
## Only run this example in interactive R sessions
if (interactive()) {
  library(shiny)
  
  # A dashboard header with 3 dropdown menus
  header <- dashboardHeader(
    title = "Dashboard Demo",
    
    # Dropdown menu for messages
    dropdownMenu(type = "messages", badgeStatus = "success",
                 messageItem("Support Team",
                             "This is the content of a message.",
                             time = "5 mins"
                 ),
                 messageItem("Support Team",
                             "This is the content of another message.",
                             time = "2 hours"
                 ),
                 messageItem("New User",
                             "Can I get some help?",
                             time = "Today"
                 )
    ),
    
    # Dropdown menu for notifications
    dropdownMenu(type = "notifications", badgeStatus = "warning",
                 notificationItem(icon = icon("users"), status = "info",
                                  "5 new members joined today"
                 ),
                 notificationItem(icon = icon("warning"), status = "danger",
                                  "Resource usage near limit."
                 ),
                 notificationItem(icon = icon("shopping-cart", lib = "glyphicon"),
                                  status = "success", "25 sales made"
                 ),
                 notificationItem(icon = icon("user", lib = "glyphicon"),
                                  status = "danger", "You changed your username"
                 )
    ),
    
    # Dropdown menu for tasks, with progress bar
    dropdownMenu(type = "tasks", badgeStatus = "danger",
                 taskItem(value = 20, color = "aqua",
                          "Refactor code"
                 ),
                 taskItem(value = 40, color = "green",
                          "Design new layout"
                 ),
                 taskItem(value = 60, color = "yellow",
                          "Another task"
                 ),
                 taskItem(value = 80, color = "red",
                          "Write documentation"
                 )
    )
  )
  
  shinyApp(
    ui = dashboardPage(
      header,
      dashboardSidebar(),
      dashboardBody()
    ),
    server = function(input, output) { }
  )
}

## tabbox.example.app.R -------------------------
## Only run this example in interactive R sessions
if (interactive()) {
  library(shiny)
  
  body <- dashboardBody(
    fluidRow(
      tabBox(
        title = "First tabBox",
        # The id lets us use input$tabset1 on the server to find the current tab
        id = "tabset1", height = "250px",
        tabPanel("Tab1", "First tab content"),
        tabPanel("Tab2", "Tab content 2")
      ),
      tabBox(
        side = "right", height = "250px",
        selected = "Tab3",
        tabPanel("Tab1", "Tab content 1"),
        tabPanel("Tab2", "Tab content 2"),
        tabPanel("Tab3", "Note that when side=right, the tab order is reversed.")
      )
    ),
    fluidRow(
      tabBox(
        # Title can include an icon
        title = tagList(shiny::icon("gear"), "tabBox status"),
        tabPanel("Tab1",
                 "Currently selected tab from first box:",
                 verbatimTextOutput("tabset1Selected")
        ),
        tabPanel("Tab2", "Tab content 2")
      )
    )
  )
  
  shinyApp(
    ui = dashboardPage(dashboardHeader(title = "tabBoxes"), dashboardSidebar(), body),
    server = function(input, output) {
      # The currently selected tab from the first box
      output$tabset1Selected <- renderText({
        input$tabset1
      })
    }
  )
}

###### Package shinyFiles ============================

### examples.R -------------------

## Not run:
# File selections
ui <- shinyUI(bootstrapPage(
  shinyFilesButton('files', 'File select', 'Please select a file', FALSE)
))
server <- shinyServer(function(input, output) {
  shinyFileChoose(input, 'files', roots=c(wd='..'), filetypes=c('', 'R', 'txt', '*'))
})
runApp(list(
  ui=ui,
  server=server
))
## End(Not run)
## Not run:
# Folder selections
ui <- shinyUI(bootstrapPage(
  shinyDirButton('folder', 'Folder select', 'Please select a folder', FALSE)
))
server <- shinyServer(function(input, output) {
  shinyDirChoose(input, 'folder', roots=c(wd='..'), filetypes=c('', 'txt'))
})
runApp(list(
  ui=ui,
  server=server
))
## End(Not run)
## Not run:
# File selections
ui <- shinyUI(bootstrapPage(
  shinySaveButton('save', 'Save', 'Save as...')
))
server <- shinyServer(function(input, output) {
  shinyFileSave(input, 'save', roots=c(wd='..'))
})

runApp(list(
  ui=ui,
  server=server
))
## End(Not run)

app    <- shinyApp(ui, server)
runApp(app, host = "0.0.0.0", port = 8080)

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


# todo: niravis translation:

###### Package shinythemes =============================

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

### themeSelector.R -------------------
library(shiny)
library(shinythemes)

shinyApp(
  ui = fluidPage(
    shinythemes::themeSelector(),
    sidebarPanel(
      textInput("txt", "Text input:", "text here"),
      sliderInput("slider", "Slider input:", 1, 100, 30),
      actionButton("action", "Button"),
      actionButton("action2", "Button2", class = "btn-primary")
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Tab 1"),
        tabPanel("Tab 2")
      )
    )
  ),
  server = function(input, output) {}
)


shinyApp(
  ui = tagList(
    shinythemes::themeSelector(),
    navbarPage(
      "Theme test",
      tabPanel("Navbar 1",
               sidebarPanel(
                 textInput("txt", "Text input:", "text here"),
                 sliderInput("slider", "Slider input:", 1, 100, 30),
                 actionButton("action", "Button"),
                 actionButton("action2", "Button2", class = "btn-primary")
               ),
               mainPanel(
                 tabsetPanel(
                   tabPanel("Tab 1"),
                   tabPanel("Tab 2")
                 )
               )
      ),
      tabPanel("Navbar 2")
    )
  ),
  server = function(input, output) {}
)




###### Package shinyWidgets: ======================

### examples.R -------------------------

library(magrittr)
library(shiny)
library(shinyWidgets)
library(niragen)

source('../../../packages/master/niravis-master/R/visgen.R')
source('../../../packages/master/niravis-master/R/dashboard.R')


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



# niravis translation:
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


# niravis translation:
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



# niravis translation:
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

# niravis translation:
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


###### Package sortableR: ===============================
 
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

###### Package sweave ===================

### examples.Rnw ------------------
#' \documentclass{article}
#' \usepackage{graphicx}
#' \usepackage{hyperref}
#' \usepackage{amsmath}
#' \usepackage{times}
#' 
#' \textwidth=6.2in
#' \textheight=8.5in
#' %\parskip=.3cm
#' \oddsidemargin=.1in
#' \evensidemargin=.1in
#' \headheight=-.3in
#' 
#' 
#' %------------------------------------------------------------
#'   % newcommand
#' %------------------------------------------------------------
#'   \newcommand{\scscst}{\scriptscriptstyle}
#' \newcommand{\scst}{\scriptstyle}
#' \newcommand{\Robject}[1]{{\texttt{#1}}}
#'   \newcommand{\Rfunction}[1]{{\texttt{#1}}}
#'     \newcommand{\Rclass}[1]{\textit{#1}}
#'       \newcommand{\Rpackage}[1]{\textit{#1}}
#'         \newcommand{\Rexpression}[1]{\texttt{#1}}
#'           \newcommand{\Rmethod}[1]{{\texttt{#1}}}
#'             \newcommand{\Rfunarg}[1]{{\texttt{#1}}}
#'               
#'               \begin{document}
#'               \SweaveOpts{concordance=TRUE}
#'               
#'               %------------------------------------------------------------
#'                 \title{Simple example of Sweave}
#'               %------------------------------------------------------------
#'                 \author{Aedin Culhane}
#'               %\date{}
#'               
#'               \SweaveOpts{highlight=TRUE, tidy=TRUE, keep.space=TRUE, keep.blank.space=FALSE, keep.comment=TRUE}
#'               \SweaveOpts{prefix.string=Fig}
#'               
#'               
#'               \maketitle
#'               \tableofcontents
#'               
#'               
#'               %-------------------------------------------
#'                 \section{Introduction}
#'               %--------------------------------------------
#'                 
#'                 Just a simple introduction to Sweave.
#'               
#'               <<test1>>=
#'                 a=1
#'                 b=4
#'                 a+b
#'                 print("hello")
#'                 @
#'                   
#'                   We can call R commands from the text. For example a+b= \Sexpr{a+b}
#'                 
#'                 %-------------------------------------------
#'                   \section{Including a Plot}
#'                 %--------------------------------------------
#'                   Now for a plot.  Note we include fig=TRUE, which prints the plot within the document
#'                 
#'                 
#'                 <<test2, fig=TRUE>>=
#'                   plot(1:10, col="red", pch=19)
#'                 @
#'                   
#'                   Thats it.... simple hey!
#'                   
#'                   
#'                   %------------------------------------
#'                   \subsection{More on Plots}
#'                 %-------------------------------------
#'                   
#'                   To make the plot a little nicer, we can add a caption. Also lets change the size of the plot to be 4" in height and 6" in width
#'                 
#'                 \begin{figure}
#'                 <<test3, fig=TRUE, height=4, width=6>>=
#'                   par(mfrow=c(1,2))
#'                 plot(1:10, col="green", pch=21)
#'                 barplot(height=sample(1:10,5), names=LETTERS[1:5], col=1:5)
#'                 @
#'                   
#'                   \caption{Plot of 1:10 and a bar plot beside it in a figure that is 4x6 inches}
#'                 
#'                 \end{figure}
#'                 
#'                 \newpage
#'                 %------------------------------------
#'                   \subsection{Creating a table}
#'                 %-------------------------------------
#'                   
#'                   Lets include a table using the dataset,  which is included in the default core installation of R. It contains the height and weight of 15 women.
#'                 
#'                 <<women>>=
#'                   require(xtable)
#'                 myTable<-summary(women)
#'                 @
#'                   
#'                   We can manually encode a table in latex
#'                 
#'                 
#'                 \begin{center}
#'                 \begin{tabular}{rrrrrrrr}
#'                 
#'                 <<manualtab, results=tex,echo=FALSE>>=
#'                   nr = nrow(myTable); nc = ncol(myTable)
#'                 for (i in 1:nr)
#'                   for(j in 1:nc) {
#'                     cat("$", myTable[i,j], "$")
#'                     if(j < nc)
#'                       cat("&")
#'                     else
#'                       cat("\\\\\n")
#'                   }
#'                 @
#'                   \end{tabular}
#'                 \end{center}
#'                 
#'                 But it is much easier to use the package \Rpackage{xtable}. We use the function \Rfunction{require} to load the package.
#'                 
#'                 <<xtable1, results=tex>>=
#'                   xtab<-xtable(myTable)
#'                 print(xtab, floating=FALSE)
#'                 @
#'                   
#'                   
#'                   %------------------------------------
#'                   \subsection{More on tables}
#'                 %-------------------------------------
#'                   
#'                   Let make the table nice.  Lets exclude the row numbers and include a caption on the table. We can also tag the table so we reference Table~\ref{Table:women} in the text
#'                 
#'                 
#'                 <<xtable2, results=tex>>=
#'                   xtab2<-xtable(myTable, caption="Summary of women data",  label="Table:women")
#'                 print(xtab2,include.rownames = FALSE)
#'                 @
#'                   
#'                   \newpage
#'                 %------------------------------------
#'                   %handy to include this at the end
#'                 %------------------------------------
#'                   \section{SessionInfo}
#'                 %-------------------------------------
#'                   
#'                   <<sessionInfo>>=
#'                   
#'                   sessionInfo();
#'                 
#'                 @
#'                   
#'                   \end{document}
#'                 
### cars.Rmd ------------------

###### Folder test.packages: =================================
                

### test.niragen.optim.bubblesCoord.R -------------------
                
x0 = c(1,-1,3)
y0 = c(-1,2,7)
r  = c(1,2,3)

bubblesCoordCCD(x0,y0,r)


r = rnorm(n = 50, mean = 100, sd = 20)

x0 = r
y0 = r

N = length(r)
D = matrix(0, nrow = N, ncol = N)
for(i in 1:nrow(D)){
  D[i,] = r[i] + r
}

res = cmdscale(D, k = 2)
df = data.frame(x = res[,1], y = res[,2], z = r)

highcharter.scatter.molten(obj = df, x = 'x', y = 'y', size = 'z')

# Minimize (x - mean(x))^2 + (y - mean(y))^2
# S.T: 
# (x[i] - x[j])^2 +  (y[i] - y[j])^2 <= (r[i] + r[j])^2



### test.niragen.scalarQP.R -------------------
# Minimize 3*x^2 - 41*x + 25
# S.t.:

# C1: (x - 1)(x - 3)  = x^2 - 4*x  + 3  >= 0
# C2: (x + 2)(x - 5)  = x^2 - 3*x  - 10 >= 0
# C3: (x - 7)(x - 12) = x^2 - 19*x + 84 >= 0
# C4: (x + 3)(x - 1)  = x^2 + 2*x  - 3  >= 0
# C5: (x + 6)(x - 2)  = x^2 + 4*x  - 12 >= 0
# C6: (x + 2)(x - 2)  = x^2        - 4  >= 0
# C7:                   x^2 + 2*x  + 5  >= 0
# C8:                       - 2*x  + 14 >= 0    

A = c(  1,   1,  1,    1,   1,  1, 1,  0)
B = c( -4,  -3, -19,   2,   4,  0, 2, -2)
C = c(  3, -10,  84,  -3, -12, -4, 5, 14)

source('C:/Nima/R/projects/libraries/developing_packages/niragen.R')
source('C:/Nima/R/projects/libraries/developing_packages/optim.R')

scalarQP(a = 3, b = -44, A = A, B = B, C = C)

### test.corpus2tdmConverter.R -------------------

tv  = c("I want to study and understand", "I am studying and understanding", "my brother and sister studies good", "Studying is really good")
dic = data.frame(input = c('want','study', 'studying', 'studies'), output = c('study','study', 'study', 'study'))

extra_stopwords = c('sister')

tdm = text.vect.to.term.document.matrix(tv, dictionary = dic)


crp = Corpus(VectorSource(tv))

for (j in seq(crp)){
  for (i in 1:(dim(dic)[1])){
    crp[[j]]$content <- gsub(dic[i,1], dic[i,2], crp[[j]]$content)  
  }
}

stoplist = c(stopwords('english'), letters, extra_stopwords)
ctrl     = list(removePunctuation = TRUE, stopwords = stoplist, removeNumbers = TRUE, tolower = TRUE,stemming = TRUE)

tdm      = TermDocumentMatrix(crp, control = ctrl)
tdm = as.matrix(tdm)

### predictorPowerOptimiser.R -------------------
opt.pred.power = function(x, y){
  p       = 1
  landa   = 1
  rsq.min = 1
  
  while (landa > 0.00001){
    x       = x^p
    reg     = lm( y ~ x)
    sum.reg = summary(reg)
    rsq     = sum.reg$r.squared
    if (rsq < rsq.min){
      rsq.min = rsq
      p.min   = p
      p       = p + landa
    } else {landa = landa*0.1}
  }
}
### predictorBooster.R -------------------


source("init.R")

lib.set = c()

# input files:
input.fname        = paste(data.path, 'sl_prediction', 'input_data.csv', sep='/')

D                  = read.csv(input.fname, as.is = TRUE)

D = D[D$FTE > 0, ]

Num.Preds          = D[, c(3,5,6)]
Cat.Preds          = D[, 2]
output             = D[, 4]

M                  = cbind(Num.Preds, output)

names(M)
res = evaluate(M, start = 1, history.intervals = dim(M)[1])


x  = M[,2]
y  = M[,4]

reg     = lm( y ~ x)
sum.reg = summary(reg)
rsq.min = sum.reg$r.squared


debug(opt.pred.power)
opt.pred.power(x,y)

###### Folder test.niravis: ==========================

### 201_shinydashboard_boxes.R ------------------------
library(shiny)
library(shinydashboard)
source('C:/Nima/R/packages/niravis/R/tools.R')
source('C:/Nima/R/packages/niragen/R/niragen.R')
source('C:/Nima/R/packages/niravis/R/dashboard.R')


greenBox.1 = list(type = 'InfoBox', title = "Hello1", icon = 'credit-card', subtitle = 'SUBTITLE')
greenBox.2 = list(type = 'InfoBox', title = "Hello2", icon = 'line-chart' , subtitle = 'SUBTITLE', fill = T)
purpleBox  = list(type = 'InfoBox', title = "Hello3", icon = 'line-chart' , subtitle = 'SUBTITLE', fill = T, colour = 'purple')
cloth.1   = list(type = 'ValueBox', icon = 'credit-card', href = "http://google.com")
cloth.2   = list(type = 'ValueBox', icon = 'line-chart', href = "http://yahoo.com", title = 'Approval Rating', color = "green")
cloth.3   = list(type = 'ValueBox', icon = 'users', colour = "yellow")
cloth.4   = list(type = 'Box', status = "warning", solidHeader = TRUE, collapsible = TRUE)
cloth.5   = list(type = 'Box', status = "warning", background = 'green', width = 4)
cloth.6   = list(type = 'Box', background = 'red', width = 4)

# inputs:
in.1  = list(ID = 'orders'  , type = "SliderInput", label = "Orders"  , min = 1, max = 2000, value = 650)
in.2  = list(ID = 'progress', type = "SelectInput", label = "Progress", choices = c("0%" = 0, "20%" = 20, "40%" = 40, "60%" = 60, "80%" = 80, "100%" = 100))

# containers:
in.3 = list(ID = 'dashboard', type = 'DashboardPage', layout.head = c(), layout.side = c(), layout.body = -5)
in.4 = in.3
in.5 = list(ID = 'body'     , type = 'FluidRCPanel'  , layout = list(c(1,2,3), c(4,5,6), c(-6, 7), c(8,9)))
in.6 = list(ID = 'plotbox'  , type = 'Box'           , status = "primary", layout = c(-1, -2))

# outputs:
out.1 = list(ID = 'orderNum2', type = "uiOutput"  , label = "Orders"         , cloth = greenBox.1, srv.func = "prettyNum(input$orders, big.mark=',')")
out.2 = list(ID = 'apr'      , type = "static"    , label = "Approval Rating", cloth = greenBox.2, object = "%60")
out.3 = list(ID = 'progress2', type = "uiOutput"  , label = "Progress"       , cloth = purpleBox, srv.func = "paste0(input$progress, '%')")
out.4 = list(ID = 'orderNum' , type = "uiOutput"  , label = "New Orders"     , cloth = cloth.1, srv.func = "prettyNum(input$orders, big.mark=',')")
out.5 = list(ID = 'empty'    , type = "static"    , label = "Approval Rating", cloth = cloth.2, object = tagList("60", tags$sup(style="font-size: 20px", "%")))
out.6 = list(ID = 'progress' , type = "htmlOutput", label = "Progress"       , cloth = cloth.3, srv.func = "paste0(input$progress, '%')")
out.7 = list(ID = 'plot'     , type = "plotOutput", label = "Histogram box title", cloth = cloth.4, height = 250, srv.func = "hist(rnorm(input$orders))")
out.8 = list(ID = 'status'   , type = "textOutput", label = "Status summary",   cloth = cloth.5, 
             srv.func = "paste0('There are ', input$orders, ' orders, and so the current progress is ', input$progress, '%.')")
out.9 = list(ID = 'status2'  , type = "uiOutput"  , label = "Status summary 2", cloth = cloth.6, 
             srv.func = "p('Current status is: ', icon(switch(input$progress,'100' = 'ok','0' = 'remove','road'), lib = 'glyphicon'))")

inputs  = list(in.1 , in.2, in.3, in.4, in.5, in.6)
outputs = list(out.1, out.2, out.3, out.4, out.5, out.6, out.7, out.8, out.9)



dash = DASHBOARD(obj = NULL, inputs = inputs, outputs = outputs, layout = list(3))

ui <- dash$dashboard.ui()
server <- dash$dashboard.server()

shinyApp(ui, server)

### 052_navbar_example.R ------------------------
library(shiny)
library(shinydashboard)

source('C:/Nima/R/packages/niravis/R/tools.R')
source('C:/Nima/R/packages/niragen/R/niragen.R')
source('C:/Nima/R/packages/niravis/R/dashboard.R')

inputs  = list()
outputs = list()

# containers:
inputs[[1]]  = list(ID = 'main'  , type = 'NavbarPage'   , title = "NIRAVIS:NAVBAR!", layout = c(-2, -3, -6)) 
inputs[[2]]  = list(ID = 'tab.1' , type = 'TabPanel'     , title = 'Plot'           , layout = -7)
inputs[[3]]  = list(ID = 'tab.2' , type = 'TabPanel'     , title = 'Summary'        , layout = 2)
inputs[[4]]  = list(ID = 'tab.3' , type = 'TabPanel'     , title = 'Table'          , layout = 3)
inputs[[5]]  = list(ID = 'tab.4' , type = 'TabPanel'     , title = 'About'          , layout = -8)
inputs[[6]]  = list(ID = 'menu.1', type = 'NavbarMenu'   , title = 'More'           , layout = c(-4, -5))
# inputs[[7]]  = list(ID = 'page.1', type = 'SidebarLayout', title = 'Plot of Cars'   , layout.side = -9, layout.main = 1)
inputs[[7]]  = list(ID = 'page.1', type = 'DashboardPage', title = 'Plot of Cars'   , layout.side = -9, layout.body = 1)
inputs[[8]]  = list(ID = 'page.2', type = 'FluidRCPanel' , title = 'About NIRAVIS'  , layout = list(list(4, c(5,6))))

cloth.4   = list(type = 'Box', status = "warning", solidHeader = TRUE, collapsible = TRUE, width = 12, title = "This is your plot:")

# Inputs:

inputs[[9]] = list(ID = 'plotType', type = 'RadioButton', title = 'Plot type', choices = c("Scatter"="p", "Line"="l"))

# Outputs:

outputs[[1]] = list(ID = 'plot'   , type = 'plotOutput', srv.func = "plot(cars, type=input$plotType)", cloth = cloth.4)
# outputs[[1]] = list(ID = 'plot'   , type = 'plotOutput', srv.func = "plot(cars)")
outputs[[2]] = list(ID = 'summary', type = 'verbatimTextOutput', srv.func = "summary(cars)")
outputs[[3]] = list(ID = 'table'  , type = 'dataTableOutput', srv.func = "DT::datatable(cars)")
outputs[[4]] = list(ID = 'about'  , type = 'static', object = includeMarkdown("about.md"))
outputs[[5]] = list(ID = 'image'  , type = 'static', object = img(class="img-polaroid", src=paste0("http://upload.wikimedia.org/", "wikipedia/commons/9/92/", "1919_Ford_Model_T_Highboy_Coupe.jpg")))
outputs[[6]] = list(ID = 'link'   , type = 'static', object = tags$small("Source: Photographed at the Bay State Antique ", "Automobile Club's July 10, 2005 show at the ", "Endicott Estate in Dedham, MA by ", a(href="http://commons.wikimedia.org/wiki/User:Sfoskett", "User:Sfoskett")))

dash = DASHBOARD(obj = NULL, inputs = inputs, outputs = outputs, layout = list(1))

ui     <- dash$dashboard.ui()
server <- dash$dashboard.server()

shinyApp(ui, server)


### app.R ------------------------
library(shiny)
library(ggplot2)
library(Cairo)   # For nicer ggplot2 output when deployed on Linux

# We'll use a subset of the mtcars data set, with fewer columns
# so that it prints nicely

obj <- DF.VIS(dataset = mtcars[, c("mpg", "cyl", "disp", "hp", "wt", "am", "gear")])

input.srv.func.1 = NA
input.srv.func.2 = NA

output.srv.func.1 = "objects[[1]]$ggplot.out()"
output.srv.func.2 = "nearPoints(objects[[1]]$data, input$plot1_click, addDist = TRUE)"
output.srv.func.3 = "brushedPoints(objects[[1]]$data, input$plot1_brush)"

layout = list(4)

# input ID must be unique
inputs  <<- list(list(ID    = "plot1_click", type  = "PlotClick", srv.func = input.srv.func.1), 
                 list(ID    = "plot1_brush", type  = "PlotBrush", srv.func = input.srv.func.2),
                 list(ID    = "mainPanel"  , type  = "FluidRowColumnPanel", title = 'MTCARS DASHBOARD', layout = list(c(1, 2), list(c(4,5,4,4,5), c(5,3)))),
                 list(ID    = "mainLayout" , type  = "SidebarLayout", title = 'MTCARS DASHBOARD', layout.side = c(4, 5), layout.main = c(-3)))

outputs <<- list(list(ID    = "plot1",      type   = "plotOutput", click = "plot1_click", brush = "plot1_brush", srv.func = output.srv.func.1),
                 list(ID    = "click_info", type   = "verbatimTextOutput",  srv.func = output.srv.func.2),
                 list(ID    = "brush_info", type   = "verbatimTextOutput",  srv.func = output.srv.func.3),
                 list(ID    = "Note.1"    , type   = "Static",        object = h4("This is the Row Title")),
                 list(ID    = "Note.2"    , type   = "Static",        object = h4("This is column Title"))
)

dash = DASHBOARD(obj, inputs = inputs, outputs = outputs, layout = layout, dash.title = "MTCARS DASHBOARD", win.title = "NIRAWIN")


ui <- dash$dashboard.ui()

server <- dash$dashboard.server()

shinyApp(ui, server)


### 081_widgets_gallery.R ------------------------

TXT.1 = p("For each widget below, the Current Value(s) window displays the value that the widget provides to shinyServer.
          Notice that the values change as you interact with the widgets.", style = "font-family: 'Source Sans Pro';")
TXT.2 = br()
TXT.3 = h3("Action button")
TXT.4 = hr()
TXT.5 = p("Current Value:", style = "color:#888888;")
TXT.6 = a("See Code", class = "btn btn-primary btn-md", href = "https://gallery.shinyapps.io/068-widget-action-button/")
TXT.7 = h3("Single checkbox")

in.1 = list(ID = 'action'  ,   type = "ActionButton"       , label = "Press me!")
in.2 = list(ID = 'checkbox',   type = "CheckboxInput"      , label = "Choice A", value = T)
in.3 = list(ID = 'checkGroup', type = "CheckboxGroupInput" , label = h3(), choices = list("Choice 1" = 1, "Choice 2" = 2, "Choice 3" = 3), selected = 1)
in.4 = list(ID = 'date'      , type = "DateInput"          , label = h3("Date input"), value = "2014-01-01")
in.5 = list(ID = 'dates'     , type = "DateRangeInput"     , label = h3("Date range"))
in.6 = list(ID = 'file'      , type = "FileInput"          , label = h3("File input"))
in.7 = list(ID = 'num'       , type = "NumericInput"       , label = h3("Numeric input"), value = 1)
in.8 = list()
in.9 = list()
in.10 = list()

# Container Inputs
in.11 = list(ID = 'headnote',   type = "Column", width = 6, offset = 3, layout = 1)
in.12 = list(ID = 'headnote',   type = "FluidRCPanel", label = "Widgets Gallery",
             layout = list(-11, list( c(3,-1,4,5,11,6), c(7,-2,4,5,12,6), c(-3,4,5,13,6)), 
                           list( c(-4,4,5,14,6)  , c(-5,4,5,15,6)  , c(-6,4,5,16,6)),
                           list( c(-7,4,5,17,6))))

out.1  = list(ID = 'Note.1', type = "ConstantText", object = TXT.1)
out.2  = list(ID = 'Note.2', type = "ConstantText", object = TXT.2)
out.3  = list(ID = 'Note.3', type = "ConstantText", object = TXT.3)
out.4  = list(ID = 'Note.4', type = "ConstantText", object = TXT.4)
out.5  = list(ID = 'Note.5', type = "ConstantText", object = TXT.5)
out.6  = list(ID = 'Note.6', type = "ConstantText", object = TXT.6)
out.7  = list(ID = 'Note.7', type = "ConstantText", object = TXT.7)
out.8  = list()
out.9  = list()
out.10 = list()
out.11 = list(ID = 'action'    , type = "verbatimTextOutput", srv.func = 'input$action')
out.12 = list(ID = 'checkbox'  , type = "verbatimTextOutput", srv.func = 'input$checkbox')
out.13 = list(ID = 'checkGroup', type = "verbatimTextOutput", srv.func = 'input$checkGroup')
out.14 = list(ID = 'date'      , type = "verbatimTextOutput", srv.func = 'input$date')
out.15 = list(ID = 'dates'     , type = "verbatimTextOutput", srv.func = 'input$dates')
out.16 = list(ID = 'file'      , type = "verbatimTextOutput", srv.func = 'input$file')
out.17 = list(ID = 'num'       , type = "verbatimTextOutput", srv.func = 'input$num')

inputs  = list(in.1,in.2, in.3,in.4, in.5,in.6,in.7,in.8,in.9,in.10,in.11,in.12)
outputs = list(out.1,out.2, out.3,out.4, out.5,out.6,out.7,out.8,out.9,out.10,out.11,out.12,out.13,out.14,out.15,out.16,out.17)


dash = DASHBOARD(NULL, inputs = inputs, outputs = outputs, layout = list(12))

ui <- dash$dashboard.ui()

server <- dash$dashboard.server()

shinyApp(ui, server)


### 005_sliders.R ------------------------

sliderValues = function(x1, x2, x3, x4, x5){
  # Compose data frame
  data.frame(
    Name = c("Integer", 
             "Decimal",
             "Range",
             "Custom Format",
             "Animation"),
    Value = as.character(c(x1, x2, paste(x3, collapse=' '), x4, x5)), 
    stringsAsFactors=FALSE)
}


inputs  <<- list(list(ID    = "integer"   , label = "Integer"      , type  = "SliderInput"  , min = 0, max = 1000 , value = 500                    ),      # 1
                 list(ID    = "decimal"   , label = "Decimal"      , type  = "SliderInput"  , min = 0, max = 1    , value = 0.5        , step = 0.1),      # 2
                 list(ID    = "range"     , label = "Range"        , type  = "SliderInput"  , min = 1, max = 1000 , value = c(200,500)             ),      # 3
                 list(ID    = "format"    , label = "Custom Format", type  = "SliderInput"  , min = 0, max = 10000, value = 0          , step = 2500, animate = T),      # 4
                 list(ID    = "animation" , label = "Looping Animation", type  = "SliderInput"  , min = 1, max = 2000, value = 1       , step = 10  , animate = animationOptions(interval = 300, loop = TRUE)),# 5
                 list(ID    = "mainDash", type  = "SidebarLayout", title = 'Sliders' , layout.side = - c(1:5), layout.main = c(1)))                         # 6

service = "sliderValues(input$integer, input$decimal, input$range, input$format, 'This is NIRAVIS !!!!!!')"

outputs  <<- list(list(ID    = "view"   , type  = "tableOutput", srv.func = service))  # Output 1

dash = DASHBOARD(obj = NULL, inputs = inputs, outputs = outputs, layout = list(6))

ui <- dash$dashboard.ui()

server <- dash$dashboard.server()

shinyApp(ui, server)

### slider.app.R ------------------------

inputs  <<- list(list(ID    = "integer" , type  = "sliderInput"  , min = 0, max = 1000, srv.func = NA),      # 1
                 list(ID    = "decimal" , type  = "sliderInput"  , min = 0, max = 1   , srv.func = NA),      # 2
                 list(ID    = "range"   , type  = "sliderInput"  , min = 1, max = 1000, srv.func = NA),      # 3
                 list(ID    = "format"  , type  = "sliderInput"  , min = 0, max = 1000, srv.func = NA),      # 4
                 list(ID    = "decimal" , type  = "sliderInput"  , min = 0, max = 1000, srv.func = NA),      # 5
                 list(ID    = "mainDash", type  = "SidebarLayout", title = 'Sliders' , layout.side = - c(1:5), layout.main = c(1)))      # 6
)

outputs  <<- list(list(ID    = "view"   , type  = "TableOutput"))

output.srv.func.1 = "objects[[1]]$ggplot.out()"
output.srv.func.2 = "nearPoints(objects[[1]]$data, input$plot1_click, addDist = TRUE)"
output.srv.func.3 = "brushedPoints(objects[[1]]$data, input$plot1_brush)"




dash$title = 'Sliders'


###### Folder: tmvis ===============================

### dash.R -------------------

# Think about using these packages: GLMnet, text2vec


clusters = c(Corpus = 0)
val      = reactiveValues()

val$triggerPC = T
val$triggerWC = T

WC.Cloth    = list(type = 'box', title = "Word Cloud", status = "primary", solidHeader = T, collapsible = T, weight = 12)
PC.Cloth    = list(type = 'box', title = "MDS Plot", status = "primary", solidHeader = T, collapsible = T, weight = 12)

I = list()

I$main      = list(type = 'dashboardPage', title = 'NIRA Text Miner', layout.head = c() ,layout.body = 'page', layout.side = c('getNC', 'refClust'))
I$page      = list(type = 'fluidPage', layout = list(list('WCBox', 'PCBox')))

I$WCBox     = list(type = 'fluidPage', layout  = list(list('WCWeight', 'WCCluster'), 'WC'), cloth = WC.Cloth)
I$PCBox     = list(type = 'fluidPage', layout  = list(list('PCWeight', 'PCMetric'), 'PC'), cloth = PC.Cloth)
I$PCMetric  = list(type = "radioButtons", title =  "Metric"     , choices = valid.metrics, inline = T, weight = 9, selected = 'spherical')
I$PCWeight  = list(type = "radioButtons", title =  "Weighting"  , choices = valid.weightings, weight = 3, selected = 'freq')
# I$WC        = list(type = "plotOutput" , height = '300px')
I$WC        = list(type = "wordcloud2Output")
I$PC        = list(type = "plotOutput")
I$WCWeight  = I$PCWeight
I$getNC     = list(type = "numericInput", title =  "Number of Clusters:" , value = 1, min = 1, max = 20)
I$refClust  = list(type = 'actionButton', title = "Refresh Clustering", offset = 1, width = '80%')
I$WCCluster = list(type = "selectInput" , title = "Cluster:"    , choices = clusters, inline = T, selected = '0')

I$WC$service = 
  "
if (is.null(val$triggerWC)){val$triggerWC = T}
if (val$triggerWC) {val$triggerWC = F}
if (input$WCCluster == '0'){x$plot.wordCloud(weighting = input$WCWeight, package = 'wordcloud2')} else {x$plot.wordCloud(weighting = input$WCWeight, cn = as.integer(input$WCCluster), package = 'wordcloud2')}
"

I$PC$service = "
if (is.null(val$triggerPC)){val$triggerPC = T}
if (val$triggerPC) {val$triggerPC = F}
x$plot.2D(input$PCWeight, input$PCMetric)
"

I$refClust$service = paste(
  "x$clust(as.integer(input$getNC))", 
  "clusters        = c(0, unique(x$data$CLS))",
  "names(clusters) = c('Corpus', paste('Cluster', unique(x$data$CLS)))",
  "updateSelectInput(session, 'WCCluster', choices = clusters, selected = '0')",
  "val$triggerPC = T"
  , sep = "\n")


dash = new('DASHBOARD', items = I, king.layout = list('main'), name = "TEXMIN")

###### Packages: text2vec ======================================
# ext2vec package provides the movie_review dataset. 
# It consists of 5000 movie reviews, each of which is marked as positive or negative. 
# We will also use the data.table package for data wrangling.

# First of all let's split out dataset into two parts - train and test. 
# We will show how to perform data manipulations on train set and then apply exactly the same manipulations on the test set:

library(text2vec)
library(data.table)
data("movie_review")
setDT(movie_review)
setkey(movie_review, id)
set.seed(2016L)
all_ids = movie_review$id
train_ids = sample(all_ids, 4000)
test_ids = setdiff(all_ids, train_ids)
train = movie_review[J(train_ids)]
test = movie_review[J(test_ids)]

# Vectorization:
# To represent documents in vector space, we first have to create mappings from terms to term IDS. 
# We call them terms instead of words because they can be arbitrary n-grams not just single words. 
# We represent a set of documents as a sparse matrix, where each row corresponds to a document and each column corresponds to a term. 
# This can be done in 2 ways: using the vocabulary itself or by feature hashing.

# Vocabulary-based vectorization
# Let's first create a vocabulary-based DTM. 
# Here we collect unique terms from all documents and mark each of them with a unique ID using the create_vocabulary() function. 
# We use an iterator to create the vocabulary.


# define preprocessing function and tokenization function
prep_fun = tolower
tok_fun = word_tokenizer

it_train = itoken(train$review, 
                  preprocessor = prep_fun, 
                  tokenizer = tok_fun, 
                  ids = train$id, 
                  progressbar = FALSE)

vocab = create_vocabulary(it_train)

# What was done here?

# We created an iterator over tokens with the itoken() function. 
# All functions prefixed with create_ work with these iterators. 
# R users might find this idiom unusual, but the iterator abstraction allows us to hide 
# most of details about input and to process data in memory-friendly chunks.
# We built the vocabulary with the create_vocabulary() function.


# Alternatively, we could create list of tokens and reuse it in further steps. 
# Each element of the list should represent a document, and each element should be a character vector of tokens:

train_tokens = train$review %>% prep_fun %>%  tok_fun # This is a list
it_train = itoken(train_tokens, ids = train$id, progressbar = FALSE)

vocab = create_vocabulary(it_train, stopwords)

# ote that text2vec provides a few tokenizer functions (see ?tokenizers). 
# These are just simple wrappers for the base::gsub() function and are not very fast or flexible. 
# If you need something smarter or faster you can use the tokenizers package which will cover most use cases, 
# or write your own tokenizer using the stringi package.

#Now that we have a vocabulary, we can construct a document-term matrix:

vectorizer = vocab_vectorizer(vocab)

t1 = Sys.time()
dtm_train = create_dtm(it_train, vectorizer)
print(difftime(Sys.time(), t1, units = 'sec'))

# http://text2vec.org/vectorization.html



# TF-IDF:
# define tfidf model
tfidf = TfIdf$new()
# fit model to train data and transform train data with fitted model
dtm_train_tfidf = fit_transform(dtm_train, tfidf)
# tfidf modified by fit_transform() call!
# apply pre-trained tf-idf transformation to test data
dtm_test_tfidf  = create_dtm(it_test, vectorizer) %>% 
  transform(tfidf)


# Note that here we first time touched model object in text2vec. 
# At this moment the user should remember several important things about text2vec models:
#   
# Models can be fitted on a given data (train) and applied to unseen data (test)
# Models are mutable - once you will pass model to fit() or fit_transform() function, model will be modifed by it.
# After model is fitted, it can be applied to a new data with fitted_model$transform(new_data) 
# method or equivalent S3 method: transform(new_data, fitted_model).
# You can find more detailed overview of models and models API in a separate vignette.


x = TEXT.MINER(movie_review, text_col = 'review')
D = x$get.dtm()
x$plot.2D()






###### Package: bupar ==============================
### pmap.examples.R ---------------------
library(magrittr)
library(dplyr)
library(niragen)

# library(niravis)
# library(niraprom)

# process Map Examples:

patients %>% process_map(type_nodes = performance('absolute'), type_edges = performance('absolute'))


D = read.csv('C:/Nima/RCode/projects/cba.hlp.simulation/data/full_discharges_mohammad_Sep_Dec 2016.csv')
D$APPT_I %<>% as.character
D$STUS_C %<>% as.character
D$STRT_S %<>% as.character %>% as.time(target_class = 'POSIXlt') %>% as.POSIXct  

D = D[D$Type == 'PADC',]

x = bupaR::isimple_eventlog(eventlog = D)
x %>% processmapR::process_map

# Translation:

obj = Process() %>% feedEventLog(D, caseID_col = 'APPT_I', skillID_col = 'STUS_C', time_col = 'STRT_S')

# obj = obj %>% addTaskHistory %>% addGraphTables %>% addDiagrammeRGraph

obj %<>% addTaskHistory %>% addGraphTables
obj %>% plot.process(plotter = 'diagramer', direction = 'left.right', node_colors = 'navy')


library(eventdataR)
library(processmapR)
library(edeaR)


obj$bupaobj %>% idle_time("resource", units = "hours")
obj$bupaobj %>% processing_time("activity") %>% head


### eda.examples.R ----------------------
library(bupaR)
library(eventdataR)
library(processmapR)
library(edeaR)
library(magrittr)
library(dplyr)
library(niragen)

patients %>%
  idle_time("resource", units = "days")


patients %>% 
  processing_time("activity") %>% plot

patients %>% 
  processing_time("resource") %>% plot




###### Package: flexdashboard ===================================
### galayout.R ------------------
---
  title: "Google Analytics & Highcharter"
runtime: shiny
output: 
  flexdashboard::flex_dashboard:
  favicon: https://www.iconexperience.com/_img/o_collection_png/office/24x24/plain/chart_line.png
css: styles.css
orientation: rows
vertical_layout: fill
social: menu
source_code: embed
theme: lumen
---
  
  ```{r setup, include=FALSE}
# rm(list = ls())
knitr::opts_chunk$set(echo = FALSE)
library("flexdashboard")
library("RGA")
library("htmltools")
library("dplyr")
library("tidyr")
library("purrr")
library("stringr")
library("lubridate")
library("scales")
library("highcharter")
library("DT")
library("viridis")
```

Sidebar {.sidebar}
-----------------------------------------------------------------------
  ```{r}
```

Row
-----------------------------------------------------------------------
  
  ### Sessions  {.value-box}
  ```{r}
```

### Users {.value-box}
```{r}
```

### Page Views {.value-box}
```{r}
```


### Pages per Session {.value-box}
```{r}
```

### Avg Duration of Sessions {.value-box}
```{r}
```

### Bounce Rate {.value-box}
```{r}
```

### Percent New Sessions {.value-box}
```{r}
```


Row {data-height=200}
-----------------------------------------------------------------------
  ### Detailed View 
  ```{r}
```

Row {.tabset .tabset-fade data-height=350}
-----------------------------------------------------------------------
  ### Referral Path
  ```{r}
```

### Referral Source
```{r}
```

### dayOfWeek vs hour
```{r}
```



### Pages
```{r}
```


### Channels
```{r}
```

### Input (Internal)
```{r}
```


###### Package fmsb =========================

### radarchart.R ------------------
# Library
library(fmsb)


# Data must be given as the data frame, where the first cases show maximum.
maxmin <- data.frame(
  total=c(5, 1),
  phys=c(15, 3),
  psycho=c(3, 0),
  social=c(5, 1),
  env=c(5, 1))
# data for radarchart function version 1 series, minimum value must be omitted from above.
RNGkind("Mersenne-Twister")
set.seed(123)
dat <- data.frame(
  total=runif(3, 1, 5),
  phys=rnorm(3, 10, 2),
  psycho=c(0.5, NA, 3),
  social=runif(3, 1, 5),
  env=c(5, 2.5, 4))
dat <- rbind(maxmin,dat)
op <- par(mar=c(1, 2, 2, 1),mfrow=c(2, 2))
radarchart(dat, axistype=1, seg=5, plty=1, vlabels=c("Total\nQOL", "Physical\naspects", 
                                                     "Phychological\naspects", "Social\naspects", "Environmental\naspects"), 
           title="(axis=1, 5 segments, with specified vlabels)", vlcex=0.5)
radarchart(dat, axistype=2, pcol=topo.colors(3), plty=1, pdensity=c(5, 10, 30), 
           pangle=c(10, 45, 120), pfcol=topo.colors(3), 
           title="(topo.colors, fill, axis=2)")
radarchart(dat, axistype=3, pty=32, plty=1, axislabcol="grey", na.itp=FALSE,
           title="(no points, axis=3, na.itp=FALSE)")
radarchart(dat, axistype=1, plwd=1:5, pcol=1, centerzero=TRUE, 
           seg=4, caxislabels=c("worst", "", "", "", "best"),
           title="(use lty and lwd but b/w, axis=1,\n centerzero=TRUE, with centerlabels)")
par(op)




# Library
library(fmsb)

# Create data: note in High school for several students
set.seed(99)
data=as.data.frame(matrix( sample( 0:20 , 15 , replace=F) , ncol=5))
colnames(data)=c("math" , "english" , "biology" , "music" , "R-coding" )
rownames(data)=paste("mister" , letters[1:3] , sep="-")

# To use the fmsb package, I have to add 2 lines to the dataframe: the max and min of each topic to show on the plot!
data=rbind(rep(20,5) , rep(0,5) , data)





#==================
# Plot 1: Default radar chart proposed by the library:
radarchart(data)


#==================
# Plot 2: Same plot with custom features
colors_border=c( rgb(0.2,0.5,0.5,0.9), rgb(0.8,0.2,0.5,0.9) , rgb(0.7,0.5,0.1,0.9) )
colors_in=c( rgb(0.2,0.5,0.5,0.4), rgb(0.8,0.2,0.5,0.4) , rgb(0.7,0.5,0.1,0.4) )
radarchart( data  , axistype=1 , 
            #custom polygon
            pcol=colors_border , pfcol=colors_in , plwd=4 , plty=1,
            #custom the grid
            cglcol="grey", cglty=1, axislabcol="grey", caxislabels=seq(0,20,5), cglwd=0.8,
            #custom labels
            vlcex=0.8 
)
legend(x=0.7, y=1, legend = rownames(data[-c(1,2),]), bty = "n", pch=20 , col=colors_in , text.col = "grey", cex=1.2, pt.cex=3)

# Plot3: If you remove the 2 first lines, the function compute the max and min of each variable with the available data:
colors_border=c( rgb(0.2,0.5,0.5,0.9), rgb(0.8,0.2,0.5,0.9) , rgb(0.7,0.5,0.1,0.9) )
colors_in=c( rgb(0.2,0.5,0.5,0.4), rgb(0.8,0.2,0.5,0.4) , rgb(0.7,0.5,0.1,0.4) )
radarchart( data[-c(1,2),]  , axistype=0 , maxmin=F,
            #custom polygon
            pcol=colors_border , pfcol=colors_in , plwd=4 , plty=1,
            #custom the grid
            cglcol="grey", cglty=1, axislabcol="black", cglwd=0.8, 
            #custom labels
            vlcex=0.8 
)
legend(x=0.7, y=1, legend = rownames(data[-c(1,2),]), bty = "n", pch=20 , col=colors_in , text.col = "grey", cex=1.2, pt.cex=3)

###### Pa

###### Folder Docker ==================
### Dockerfile -----------------
FROM docker.artifactory.ai.cba/aiaa/r-essential:3.4.2r1-mran

MAINTAINER Nima Ramezani "nima.ramezani@cba.com.au"
################################################################################

COPY shiny-server-1.5.4.869-amd64.deb /tmp/
  COPY niragen_2.4.3.tar.gz /packages/
  COPY myShinyApp/* /projects/
  
  RUN R -e "install.packages('packages/niragen_2.4.3.tar.gz', repos = NULL, type = 'source')" && \
R -e "install.packages(c('devtools', 'roxygen2', 'shiny', 'highcharter'), repos = 'http://cran.dev.cba/')"

EXPOSE 8080



### shiny-server.conf -----------------

# Define the user we should use when spawning R Shiny processes
run_as shiny;

# Define a top-level server which will listen on a port
server {
  # Instruct this server to listen on port 80. The app at dokku-alt need expose PORT 80, or 500 e etc. See the docs
  listen 80;
  
  # Define the location available at the base URL
  location / {
    
    # Run this location in 'site_dir' mode, which hosts the entire directory
    # tree at '/srv/shiny-server'
    site_dir /srv/shiny-server;
    
    # Define where we should put the log files for this location
    log_dir /var/log/shiny-server;
    
    # Should we list the contents of a (non-Shiny-App) directory when the user 
    # visits the corresponding URL?
    directory_index on;
  }
}

### shint-server.sh -----------------
#!/bin/sh

# Make sure the directory for individual app logs exists
mkdir -p /var/log/shiny-server
chown shiny.shiny /var/log/shiny-server

exec shiny-server >> /var/log/shiny-server.log 2>&1


########## testidea.R =======================
library(dplyr)

Di = data.frame(Xi = c(1.0, 3.0, 2.0, -1.0, 2.0), Yi = c(1,1,1,0,0)) %>% mutate(i = 1:length(Xi))
Dj = Di %>% select(Xj = Xi, Yj = Yi, j = i)


func = function(r){cbind(t(r), Dj)}
lstm = apply(Di, 1, func)
D    = data.frame()
for (e in lstm) {D = rbind(D, e)}

tbd = D[, c('i','j')] %>% apply(1, sort) %>% t %>% duplicated
D = D[!tbd, ]
D %<>% mutate(ID = ) %>% filter(i != j, Yi == Yj)
####
m = 3
for (p in 1:(m-1)){
  D %<>% mutate(newcol = 2*(Xi^(p + 1) - Xj^(p + 1))*(Xi - Xj))
  names(D)[which(colnames(D) == 'newcol')] <- paste('H', p, sep = '.')
  for(q in 1:(m-1)){
    D %<>% mutate(newcol = 2*(Xi^(p + 1) - Xj^(p + 1))*(Xi^(q + 1) - Xj^(q + 1)))
    names(D)[which(colnames(D) == 'newcol')] <- paste('S', p,q, sep = '.')
  }
}

build.S = function(D){
  d   = colSums(D)
  arr = c()
  for (p in 1:(m-1)){
    for(q in 1:(m-1)){
      colname = paste('S', p,q, sep = '.')
      arr = c(arr, d[colname])
    }
  }
  matrix(arr, m-1, m-1)
}

build.H = function(D){
  d   = colSums(D)
  arr = c()
  for (p in 1:(m-1)){
    colname = paste('H', p, sep = '.')
    arr = c(arr, d[colname])
  }
  arr
}

S = build.S(D)
H = build.H(D)

sum(H * solve(S,H))
