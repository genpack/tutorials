

####### Folder presentations/brokers/script: ================================
### brokers_v3.R: -----------------------
---
  title: "Broker Segmentation (Version 3)"
author: "Nicolas Berta"
date: "13 June 2017"
output: html_document
runtime: shiny
---
  
  ```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
library(magrittr)
library(ggplot2)
library(plotly)
source('C:/Nicolas/RCode/projects/libraries/developing_packages/gener.R')
source('C:/Nicolas/RCode/projects/libraries/developing_packages/visgen.R')
source('C:/Nicolas/RCode/projects/libraries/developing_packages/plotly.R')
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
author: "Nicolas Berta (Data Scientist in A&I)"
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
library(gener)
source('C:/Nicolas/RCode/projects/libraries/developing_packages/gener.R')
source('C:/Nicolas/RCode/projects/libraries/developing_packages/visgen.R')
source('C:/Nicolas/RCode/projects/libraries/developing_packages/plotly.R')
source('C:/Nicolas/RCode/projects/libraries/developing_packages/DT.R')

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

library(gener)
source('C:/Nicolas/RCode/packages/master/viser-master/R/visgen.R')
source('C:/Nicolas/RCode/packages/master/viser-master/R/dashboard.R')

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









###### Package: rjson ========================
### convert.R -----------------------------
dataset <- read.csv("C:/Nicolas/RCode/projects/tutorials/rjson/data/Data_DISCHARGES_Exceptions_Working_File.csv")

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
library(gener)


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





# Translation to viser:
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

# Translation to viser:

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


# Translation to viser:

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
# get table bs modal example with viser:


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


# todo: viser translation:

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
library(gener)

source('../../../packages/master/viser-master/R/visgen.R')
source('../../../packages/master/viser-master/R/dashboard.R')


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



# viser translation:
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


# viser translation:
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



# viser translation:
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

# viser translation:
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
                

### test.gener.optim.bubblesCoord.R -------------------
                
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



### test.gener.scalarQP.R -------------------
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

source('C:/Nicolas/R/projects/libraries/developing_packages/gener.R')
source('C:/Nicolas/R/projects/libraries/developing_packages/optim.R')

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

###### Folder test.viser: ==========================

### 201_shinydashboard_boxes.R ------------------------
library(shiny)
library(shinydashboard)
source('C:/Nicolas/R/packages/viser/R/tools.R')
source('C:/Nicolas/R/packages/gener/R/gener.R')
source('C:/Nicolas/R/packages/viser/R/dashboard.R')


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

source('C:/Nicolas/R/packages/viser/R/tools.R')
source('C:/Nicolas/R/packages/gener/R/gener.R')
source('C:/Nicolas/R/packages/viser/R/dashboard.R')

inputs  = list()
outputs = list()

# containers:
inputs[[1]]  = list(ID = 'main'  , type = 'NavbarPage'   , title = "viser:NAVBAR!", layout = c(-2, -3, -6)) 
inputs[[2]]  = list(ID = 'tab.1' , type = 'TabPanel'     , title = 'Plot'           , layout = -7)
inputs[[3]]  = list(ID = 'tab.2' , type = 'TabPanel'     , title = 'Summary'        , layout = 2)
inputs[[4]]  = list(ID = 'tab.3' , type = 'TabPanel'     , title = 'Table'          , layout = 3)
inputs[[5]]  = list(ID = 'tab.4' , type = 'TabPanel'     , title = 'About'          , layout = -8)
inputs[[6]]  = list(ID = 'menu.1', type = 'NavbarMenu'   , title = 'More'           , layout = c(-4, -5))
# inputs[[7]]  = list(ID = 'page.1', type = 'SidebarLayout', title = 'Plot of Cars'   , layout.side = -9, layout.main = 1)
inputs[[7]]  = list(ID = 'page.1', type = 'DashboardPage', title = 'Plot of Cars'   , layout.side = -9, layout.body = 1)
inputs[[8]]  = list(ID = 'page.2', type = 'FluidRCPanel' , title = 'About viser'  , layout = list(list(4, c(5,6))))

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
             "ANicolastion"),
    Value = as.character(c(x1, x2, paste(x3, collapse=' '), x4, x5)), 
    stringsAsFactors=FALSE)
}


inputs  <<- list(list(ID    = "integer"   , label = "Integer"      , type  = "SliderInput"  , min = 0, max = 1000 , value = 500                    ),      # 1
                 list(ID    = "decimal"   , label = "Decimal"      , type  = "SliderInput"  , min = 0, max = 1    , value = 0.5        , step = 0.1),      # 2
                 list(ID    = "range"     , label = "Range"        , type  = "SliderInput"  , min = 1, max = 1000 , value = c(200,500)             ),      # 3
                 list(ID    = "format"    , label = "Custom Format", type  = "SliderInput"  , min = 0, max = 10000, value = 0          , step = 2500, aNicolaste = T),      # 4
                 list(ID    = "aNicolastion" , label = "Looping ANicolastion", type  = "SliderInput"  , min = 1, max = 2000, value = 1       , step = 10  , aNicolaste = aNicolastionOptions(interval = 300, loop = TRUE)),# 5
                 list(ID    = "mainDash", type  = "SidebarLayout", title = 'Sliders' , layout.side = - c(1:5), layout.main = c(1)))                         # 6

service = "sliderValues(input$integer, input$decimal, input$range, input$format, 'This is viser !!!!!!')"

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
library(gener)

# library(viser)
# library(niraprom)

# process Map Examples:

patients %>% process_map(type_nodes = performance('absolute'), type_edges = performance('absolute'))


D = read.csv('C:/Nicolas/RCode/projects/cba.hlp.simulation/data/full_discharges_mohammad_Sep_Dec 2016.csv')
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
library(gener)

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

MAINTAINER Nicolas Berta "Nicolas.Berta@cba.com.au"
################################################################################

COPY shiny-server-1.5.4.869-amd64.deb /tmp/
  COPY gener_2.4.3.tar.gz /packages/
  COPY myShinyApp/* /projects/
  
  RUN R -e "install.packages('packages/gener_2.4.3.tar.gz', repos = NULL, type = 'source')" && \
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
