# Folder: dashboard_v2
# global.R:

source('~/R/projects/metro_analysis/Nima/tools.R')
source('~/R/packages/gener-master/R/io.R')
visinit()


plot_process_map = function(obj, measure = c('freq', 'time'), time_unit = c('second', 'minute', 'hour', 'day', 'week', 'year'), plotter = c('grviz', 'visNetwork'), config = NULL, ...){
  plotter   = match.arg(plotter)
  measure   = match.arg(measure)
  time_unit = match.arg(time_unit)
  nontime   = 'freq'
  k         = chif(measure %in% nontime, as.integer(1), 1.0/timeUnitCoeff[time_unit])
  plotname  = 'process.map' %>% paste(measure, plotter, sep = '.')
  if(measure != 'freq'){plotname %<>% paste(time_unit, sep = '.')}
  
  if(!is.null(obj$plots[[plotname]])){return(obj$plots[[plotname]])}
  
  nodes = obj$get.nodes()
  links = obj$get.links()
  
  if(is.null(config)){config = list()}
  
  cfg = list(link.width.max = 12, link.width.min = 2, link.smooth = list(enabled = T, type = 'curvedCCW'),
             node.label.size = 40, link.label.size = 25, node.physics.enabled = T, layout = 'hierarchical', direction = 'up.down',
             node.size.min = 2, node.size.max = 4, node.size = 3, node.size.ratio = 0.6) %<==>% config
  
  nodes %<>%
    dplyr::mutate(shape = ifelse(status %in% c('START', 'END'), 'circle', ifelse(status %in% c('ENTER', 'EXIT'), 'diamond', 'rectangle')))
  
  if(measure == 'freq'){
    
    nodes$totalEntryFreq[nodes$status == 'START'] <- nodes$totalEntryFreq[nodes$status == 'END'] %>% sum(na.rm = T)
    
    nodes %<>%
      dplyr::mutate(label = status %>% paste0('\n', '(', totalEntryFreq, ')')) %>%
      dplyr::mutate(id = status, size = totalEntryFreq, color = totalEntryFreq)
    
    links %<>%
      dplyr::mutate(linkLabel = ' ' %++% totalFreq, linkTooltip = status %>% paste(nextStatus, sep = '-')) %>%
      dplyr::mutate(source = status, target = nextStatus, linkColor = totalFreq, linkWidth = totalFreq)
    
    list(nodes = nodes, links = links) %>%
      viserPlot(key = 'id', shape = 'shape', label = 'label', color = 'color', source = 'status', target = 'nextStatus', linkColor = 'linkColor', linkWidth = 'linkWidth', linkLabel = 'linkLabel', linkTooltip = 'linkTooltip', config = cfg, plotter = plotter, type = 'graph', ...) -> obj$plots[[plotname]]
  } else {
    cfg$palette$color = c('white', 'red')
    
    nodes %<>%
      dplyr::mutate(meanDuration = k*meanDuration) %>%
      dplyr::mutate(label = status %>% paste0('\n', '(', meanDuration %>% round(digits = 2), ' ', time_unit %>% substr(1,1), ')'))
    
    links %<>%
      dplyr::mutate(meanTime = k*meanTime) %>%
      dplyr::mutate(label = ' ' %++% (meanTime %>% round(digits = 2) %>% paste(time_unit %>% substr(1,1))), tooltip = status %>% paste(nextStatus, sep = '-'))
    
    list(nodes = nodes, links = links) %>%
      viserPlot(key = 'status', shape = 'shape', label = 'label', color = list(color = 'totalDuration'), source = 'status', target = 'nextStatus', linkColor = list(color = 'totalTime'), linkWidth = 'totalTime', linkLabel = 'label', linkTooltip = 'tooltip', config = cfg, plotter = plotter, type = 'graph', ...) -> obj$plots[[plotname]]
    
  }
  return(obj$plots[[plotname]])
}


# source('C:/Users/nima/Documents/R/projects/metro_analysis/Nima/dashboard_v1/dash_v1.R')


# Folder: dashboard_v2
# report.Rmd:
---
title: "MT Incident Analysis"
author: "Nicolas Berta"
date: "6/26/2019"
output: html_document
---

```{r setup, include=FALSE}
source('global.R')
x = readRDS('object.rds')
```
This analysis is based on actual departure and arrival events for group: ..., line: ..., direction: Down
for February 2019.

## Process Map for frequency

```{r , echo=FALSE}
x$filter.reset()
x %>% plot_process_map(config = list(direction = 'left.right'), width = '600%')
```

## Process Map with durations

```{r , echo=FALSE}
x$filter.reset()
x %>% plot_process_map(measure = 'time', time_unit = 'minute', config = list(direction = 'left.right'), width = '600%')
```

## Including Plots

Transit and Dwelling durations:

```{r , echo=FALSE}
x %>% plot.statuses.box(width = '800%') 
```

# Folder dashboard_v1:
# dash_v1.R:
prescript  = "if(is.null(sync$trigger)){sync$trigger = 0}"
showObjFiltersScript = paste(
  "  chs = x$get.statuses()",
  "  mlp = x$get.case.path() %>% pull('loops') %>% max %>% as.integer",
  "  updateDateRangeInput(session, 'getdates', start = x$modelStart %>% setTZ('GMT') %>% as.Date, end = x$modelEnd %>% setTZ('GMT') %>% as.Date)", 
  "  updateSliderInput(session, 'freqthr', value   = chif(is.null(x$settings$filter$freqThreshold), 1.0, x$settings$filter$freqThreshold))",
  "  updateSelectInput(session, 'stsdmn', selected = chif(is.null(x$settings$filter$statusDomain), 'All', x$settings$filter$statusDomain), choices = chs)", 
  "  updateSelectInput(session, 'strsta', selected = chif(is.null(x$settings$filter$startStatus), 'All', x$settings$filter$startStatus), choices = chs)", 
  "  updateSelectInput(session, 'endsta', selected = chif(is.null(x$settings$filter$endStatus), 'All', x$settings$filter$endStatus), choices = chs)", 
  "  sync$message  = x %>% summary",
  sep = '\n')

I          = list()

######### Clothes: #########

chartcloth   = list(type = 'box' , icon = 'comment-o', offset = 0.5, weight = 12, status = 'success', solidHeader = T, style = "overflow-x:scroll;")
notecloth    = list(type = 'box' , icon = 'comment-o', offset = 0.5, weight = 12, status = 'success', solidHeader = T)
metricloth   = list(type = 'valueBox', icon = 'file' , weight = 3, fill = T, color = 'blue')
# valcloth    = list(type = 'infoBox' , value = 'Fil', subtitle = 'Assess Documents', weight = 2, fill = T, color = 'green')
colcloth    = list(type = 'column', weight = 6, align = 'center')

######### Main items: #########

I$main       = list(type = 'dashboardPage', title = 'EL Metro Train - Process View v 0.0.1', skin = 'black', layout.head = c() ,layout.body = c('shinyjs', 'procpage'), sidebar.width = 300,
                    layout.side = c('getprocess', 'getline','getdir', 'getdates', 'eventtype', 'load', 'line', 'filters', 'line', 'freqthr', 'stsdmn', 'strsta', 'endsta', 'apply','reset', 'line', 'saveobj', 'readobj'), header.title = 'EL Melbourne Metro Train - Process View v 0.0.1', header.title.width = 300, header.title.font = 'tahoma', header.title.font.weight = 'bold', header.title.font.size = 26)

######### SIDEBAR ###########
I$getprocess = list(type = 'selectInput', title = 'Select Group', choices = all_groups(atcon), selected = 'DNG', service = "lines = all_lines(atcon, group = input$getprocess); updateSelectInput(session, 'getline', choices = lines, selected = lines[1])")
lines        = all_lines(atcon, group = I$getprocess$selected)
I$getline    = list(type = 'selectInput', title = 'Select Line', choices = lines, selected = lines[1], multiple = T)
I$getdir     = list(type = 'selectInput', title = 'Select Direction', choices = c('Up', 'Down'), selected = 'Down', multiple = T)
I$getdates   = list(type = 'dateRangeInput', title = 'Select Date Range', start = maxdate - 1, end = maxdate, min = mindate, max = maxdate)
I$load       = list(type = 'actionButton', title = 'Load Data', width = '270px')

# Filters
I$filters    = list(type = 'static', object = h3('  Filters:'))
I$eventtype  = list(type = 'selectInput',  title = 'Event Type', selected = 'Arr', choices = c('Arr', 'Dep'), multiple = T)

I$freqthr    = list(type = 'sliderInput',  title = 'Frequency Threshold', min = 0.00, max = 1.00, value = 1.0, step = 0.01)
I$apply      = list(type = 'actionButton', title = 'Apply Filter', width = '90%')
I$reset      = list(type = 'actionButton', title = 'Reset Filter', width = '90%')
I$saveobj    = list(type = 'actionButton', title = 'Save Object' , width = '135px', inline = T, vertical_align = 'top', float = 'left')
I$readobj    = list(type = 'actionButton', title = 'Read Object' , width = '135px', inline = F, vertical_align = 'top', float = 'left')

I$stsdmn     = list(type = 'selectInput', title = 'Include Statuses' , selected = 'All', multiple = T, choices = 'All')
I$strsta     = list(type = 'selectInput', title = 'Starting Statuses', selected = 'All', multiple = F, choices = 'All')
I$endsta     = list(type = 'selectInput', title = 'Ending Statuses'  , selected = 'All', multiple = F, choices = 'All')

#x <- try(x_object, silent = T)
#if(!inherits(x, 'TRANSYS')){x <- try(readRDS('object.rds'), silent = T)}

# if (inherits(x, 'TRANSYS')){
#   x_object = x
#   
#   chs = x_object$get.statuses()
#   
#   I$getdates$start   <- x$modelStart %>% setTZ('GMT') %>% as.Date; if(is.empty(I$getdates$start)) I$getdates$start <- maxdate - 31
#   I$getdates$end     <- x$modelEnd %>% setTZ('GMT') %>% as.Date;   if(is.empty(I$getdates$end)) I$getdates$end <- maxdate
# 
#   I$freqthr$value    <- chif(is.null(x$settings$filter$freqThreshold), 1.0, x$settings$filter$freqThreshold)
#   I$stsdmn$selected  <- chif(is.null(x$settings$filter$statusDomain), 'All', x$settings$filter$statusDomain)
#   I$stsdmn$choices   <- chs
#   I$strsta$selected  <- chif(is.null(x$settings$filter$startStatus), 'All', x$settings$filter$startStatus)
#   I$strsta$choices   <- chs
#   I$endsta$selected  <- chif(is.null(x$settings$filter$endStatus), 'All', x$settings$filter$endStatus)
#   I$endsta$choices   <- chs
# } else {
#   x = try(getProcessModel(con = atcon, group = I$getprocess$selected, lines = I$getlines$selected, directions = I$getdir$selected, fromDate = I$getdates$start, untilDate = I$getdates$end), eventtypes = input$eventtype, silent = T)
#   if(inherits(x, 'TRANSYS')){
#     x_object = x
#     x_object$filter.case(freqThreshold = I$freqthr$value)
#   } else {x_object = new('TRANSYS')}
# }

x = try(getTransportModel(con = atcon, groups = I$getprocess$selected, lines = I$getline$selected, directions = I$getdir$selected, from_date = I$getdates$start, to_date = I$getdates$end), silent = T)
if(inherits(x, 'TRANSYS')){
  x_object = x
  x_object$filter.case(freqThreshold = I$freqthr$value)
} else {x_object = new('TRANSYS')}



######### Page 1:  Process Overview ###########
# list('procmenu', list(weight = 4, 'line', 'getst', 'stcard','line', list('getper', 'getcum'), 'volumes'))
I$procpage = list(type = 'fluidPage' , layout = list('metrics', 'msg', 'procmenu'))
I$getst    = list(type = 'selectInput', title = 'Selected Station', value = 1, choices = x_object$get.statuses(), width = '100%')
I$stcard   = list(type = 'wellPanel', layout = c('prvpie', 'nxtpie'))
I$metrics  = list(type = 'column'  , layout = c('cocinfo', 'cotinfo', 'durinfo', 'trninfo'))
I$procmenu = list(type = 'tabsetPanel', weight = 8, layout = c('maptab', 'santab', 'suntab', 'tratab', 'statab','boxtab', 'covtab'))
I$maptab   = list(type = 'tabPanel' , title = 'Process Map', layout = 'mappage')
I$mappage  = list(type = 'fluidPage' , layout = list('caret', list('mapmea', 'mapuni', 'mapsize'), 'mapc'))

I$santab   = list(type = 'tabPanel' , title = 'Process Flow', layout = 'sanpage')
I$sanpage  = list(type = 'fluidPage' , layout = c('caret', 'san'))
I$suntab   = list(type = 'tabPanel' , title = 'Process DNA', layout = 'sunpage')
I$sunpage  = list(type = 'fluidPage' , layout = c('caret', 'sun'))
I$tratab   = list(type = 'tabPanel' , title = 'Trace Bar', layout = 'trapage')
I$trapage  = list(type = 'fluidPage' , layout = list('caret', list('tramea', 'trauni'), 'tra'))
I$statab   = list(type = 'tabPanel' , title = 'Status Bar', layout = 'stapage')
I$boxtab   = list(type = 'tabPanel' , title = 'Status Box Plot', layout = 'boxpage')
I$stapage  = list(type = 'fluidPage' , layout = list('caret', 'stabar'))
I$boxpage  = list(type = 'fluidPage' , layout = list('caret', 'stauni', 'stabox'))
I$covtab   = list(type = 'tabPanel' , title = 'Case Overview', layout = 'covpage')
I$covpage  = list(type = 'fluidPage' , layout = list('caret','covuni', 'cov'))

I$mapmea     = list(type = 'radioButtons', title = 'Measure', choices = c(time = 'time', frequency = 'freq'), selected = 'freq', inline = T, weight = 4)
I$mapuni     = list(type = 'radioButtons', title = 'Time Unit', choices = c('second', 'minute', 'hour', 'day', 'week', 'year'), selected = 'hour', inline = T, weight = 4)
I$mapsize    = list(type = 'sliderInput', title = 'Zoom', min = 0, max = 100, value = 0, step = 1, inline = T, weight = 4)
I$map        = list(type = 'grvizOutput')
I$mapc       = list(type = 'dynamicInput', cloth = chartcloth, service = "grvizOutput('map', height = 'auto', width = paste0(100 + 10*input$mapsize, '%'))")

I$san        = list(type = 'sankeyNetworkOutput', width = '100%', height = '750px', cloth = chartcloth)
I$sun        = list(type = 'sunburstOutput', width = '100%', height = '750px', cloth = chartcloth)

# I$tre        = list(type = 'sankeytreeOutput', width = '100%', height = '750px', cloth = chartcloth)

I$tramea     = I$mapmea
I$trauni     = I$mapuni
I$covuni     = I$mapuni %>% list.edit(list(weight = 12))
I$stauni     = I$covuni

I$tra        = list(type = 'plotlyOutput', width = '100%', height = '750px', cloth = chartcloth)
I$sta        = list(type = 'box', icon = 'comment-o', offset = 0.5, weight = 12, status = 'success', solidHeader = T, layout = c('stabar', 'stabox'))
I$stabar     = list(type = 'plotlyOutput', width = '100%', height = '750px', cloth = chartcloth)
I$stabox     = list(type = 'plotlyOutput', width = '100%', height = '750px', cloth = chartcloth)

#I$sunmin     = list(type = 'sliderInput', title = 'Exclude traces with frequencies less than', value = 5, min = 1, max = x_object$get.traces() %>% pull('freq') %>% max, step = 1)

I$cov        = list(type = 'dataTableOutput', title = 'Table of Cases', width = '100%', height = '750px', cloth = chartcloth)

I$nxtpie     = list(type = 'billboarderOutput', title = 'Next Status Distribution', height = '350px', cloth = colcloth)
I$prvpie     = list(type = 'billboarderOutput', title = 'Previous Status Distribution', height = '350px', cloth = colcloth)
I$getper     = list(type = 'radioButtons', title = '', choices = c('Daily', 'Hourly'), selected = 'Daily', inline = T)
I$getcum     = list(type = 'checkboxInput', title = 'Cumulative', value = T, inline = T)
I$volumes    = list(type = 'dygraphOutput', title = 'Volume Trend')
I$shinyjs    = list(type = 'static', object = useShinyjs())
I$msg        = list(type = 'uiOutput', cloth = notecloth, service = "sync$message")
I$line       = list(type = 'static', object = hr(id = 'line'))
I$caret      = list(type = 'static', object = br())
I$cocinfo    = list(type = 'uiOutput', title = 'Filtered Cases '   , cloth = metricloth %>% list.edit(icon = 'filter'), weight = 4)
I$cotinfo    = list(type = 'uiOutput', title = 'Process Variations '  , cloth = metricloth  %>% list.edit(icon = 'project-diagram'), weight = 4)
I$durinfo    = list(type = 'uiOutput', title = 'Average Process Time ', cloth = metricloth %>% list.edit(icon = 'clock'), weight = 4)
I$trninfo    = list(type = 'uiOutput', title = 'Average Transitions ', cloth = metricloth %>% list.edit(icon = 'arrows-alt-h'), weight = 4)

# I$lrg   = list(type = 'c3Output', service = "plot.status.gauge(statusID = input$getst)")
# I$crg   = list(type = 'c3Output', service = "plot.status.gauge(statusID = input$getst)")
I$getpmtype = list(type = 'selectInput', choices = c("absolute", "relative", "relative_antecedent", "relative_consequent"), selected = 1)

## Charts:

# B = "if(!is.null(input$selst)){updateSelectInput(session, 'getst', selected = input$selst)}"
# B = "if(!is.null(input$selst)){cat(input$selst)} else {cat('I am NULL!')}"
B <- paste(prescript, "isolate({updateSelectInput(session, 'getst', choices = session$userData$pm$get.statuses(), selected = chif(input$getst %in% session$userData$pm$get.statuses(), input$getst, session$userData$pm$get.statuses() %>% first))})", sep = ";")


######### SERVICE FUNCTIONS: ######
#  I$metrics$service = paste(prescript, "if(!is.null(session$userData$pm)){cat('Redrawing trace-bar freq plot ... \n'); session$userData$pm %>% plot.traces.bar()}", sep = "\n")
#  I$stcards$service = paste(prescript, "if(!is.null(session$userData$pm)){cat('Redrawing trace-bar time plot ... \n'); session$userData$pm %>% plot.traces.bar(measure = 'time')}", sep = "\n")

I$saveobj$service = "if(inherits(session$userData$pm, 'TRANSYS')){session$userData$pm %>% saveRDS('object.rds');sync$message <- 'Working session saved on the server!'}"
I$readobj$service = paste(
  "x <- try(readRDS('object.rds'), silent = T)",
  "if(inherits(x, 'TRANSYS')){", showObjFiltersScript,
  "  session$userData$pm <- x",
  "} else {",
  "  sync$msg = x %>% as.character",
  "}",
  "sync$trigger = sync$trigger + 1", sep = "\n") 

I$sun$service = "plot.traces.sunburst(min_freq = 5)"
I$map$service = "plot.process.map(measure = input$mapmea, time_unit = input$mapuni, config = list(shinyInput.click = 'selst', direction = 'left.right'))"
I$san$service = "plot.process.sankey()"
I$tra$service = "plot.traces.bar(measure = input$tramea, time_unit = input$trauni, aggregator = 'mean')"
I$stabar$service = "plot.statuses.bar()"
I$stabox$service = "plot.statuses.box(time_unit = input$stauni)"
I$cov$service = "plot.cases.table(time_unit = input$covuni)"
# I$tre$service = "plot.process.tree()"

I$mapmea$service = "if(input$mapmea == 'freq'){dash$disableItems('mapuni')} else {dash$enableItems('mapuni')}"
I$tramea$service = "if(input$tramea == 'freq'){dash$disableItems('trauni')} else {dash$enableItems('trauni')}"

I$load$service    = paste("sync$message  = ''",
                          "dash$disableItems('load', 'saveobj', 'readobj')",
                          "session$userData$pm = try(getTransportModel(con = atcon, groups = input$getprocess, lines = input$getline, directions = input$getdir, from_date = input$getdates[1], to_date = input$getdates[2]), silent = T)",
                          "# debug(check); check(object = session$userData$pm, gp = input$getprocess, gd = input$getdates)",
                          "if(inherits(session$userData$pm, 'TRANSYS')){",
                          "   x <- session$userData$pm", showObjFiltersScript,
                          "   sync$trigger = sync$trigger + 1}",
                          "else {sync$message = session$userData$pm %>% as.character}",
                          "dash$enableItems('load', 'saveobj', 'readobj')",
                          sep = "\n")

I$apply$service   = paste("sync$message  = ''",
                          "if(inherits(session$userData$pm, 'TRANSYS')){",
                          "  session$userData$pm$filter.case(statusDomain = chif(input$stsdmn == 'All', NULL, input$stsdmn), startStatuses = chif(input$strsta == 'All', NULL, input$strsta), endStatuses = chif(input$endsta == 'All', NULL, input$endsta), freqThreshold = input$freqthr)",
                          "  sync$trigger = sync$trigger + 1",
                          "  sync$message  = session$userData$pm %>% summary",  
                          "}", sep = "\n")

I$reset$service   = paste("if(inherits(session$userData$pm, 'TRANSYS')){",
                          "  session$userData$pm$filter.reset()", 
                          "  x <- session$userData$pm", showObjFiltersScript,
                          "  sync$trigger = sync$trigger + 1",
                          "}", sep = "\n")

I$cocinfo$service = "get.metric('freq')"
I$cotinfo$service = "get.case.path() %>% pull(path) %>% unique %>% length"
I$durinfo$service = "get.metric(measure = 'avgTT', time_unit = 'minute') %>% paste('(minutes)')"
I$trninfo$service = "get.metric(measure = 'avgTrans')"

#I$nxtpie$service  = "plot.status.next.pie(statusID = input$getst, trim = 0.01, plotter = 'billboarder')"
#I$prvpie$service  = "plot.status.prev.pie(statusID = input$getst, trim = 0.01, plotter = 'billboarder')"

#I$volumes$service = "get.status.volumes(status = input$getst, period = tolower(input$getper))$plot.history(figures = chif(input$getcum, c('Total Entry' = 'volumeInCum', 'Total Exit' = 'volumeOutCum'), c('Entry' = 'volumeIn', 'Exit' = 'volumeOut')), plotter = 'dygraphs', config = list(title = 'Volume Trend'))"

# I$stcard$service = "plot.cases.status.pie(trim = 0.01)"
for(i in c('sun', 'map', 'san', 'tra', 'stabar','stabox', 'cov', 'cocinfo', 'cotinfo', 'durinfo', 'trninfo')){
  actstr = chif(i %in% c('cocinfo','cotinfo', 'durinfo', 'trninfo', 'volumes'), "$", " %>% ")
  I[[i]]$service = paste0("if(!is.null(session$userData$pm)){cat('Redrawing ", chif(is.null(I[[i]]$title), i, I[[i]]$title), " ... \n'); session$userData$pm", actstr, I[[i]]$service, "}")
  I[[i]]$service = paste(prescript, I[[i]]$service, sep = "\n")
}

######### Build Dashboard: #########
dash   <- new('DASHBOARD', items = I, king.layout = list('main'), observers = B, objects = list(pm = x_object), values = list(trigger = 0, message = x_object %>% summary))
ui     <- dash$dashboard.ui()
server <- dash$dashboard.server()
app    <- shinyApp(ui, server)


runApp(app, host = "0.0.0.0", port = 3225)

# Folder dashboard_v1:
# global.R:
source('tools.R')

init_source()
atcon = athena.buildConnection(bucket = 's3://aws-athena-query-results-541550247181-ap-southeast-2/')

# initial values:
maxdate   = athena.read_s3(con = atcon, query = "select(MAX(event_time)) from table.Actual") %>% {.[1,1]} %>% as.Date
mindate   = athena.read_s3(con = atcon, query = "select(MIN(event_time)) from table.Actual") %>% {.[1,1]} %>% as.Date

X_object = new('TRANSYS')

all_lines  = function(con, group = NULL){
  flt = chif(is.null(group), "", paste0(" WHERE \"GROUP\" = '", group, "'"))
  qry = "SELECT DISTINCT Line FROM table.Actual" %>% paste0(flt)
  athena.read_s3(con = con, query = qry) %>% {.[,1]}
}

all_groups = function(con){
  qry = "SELECT DISTINCT \"GROUP\" FROM table.Actual"
  athena.read_s3(con = con, query = qry) %>% {.[,1]}
}

# Folder: Modelling
# modelling.R
ctime = as.time('2019-05-20')


average_durations    = obj$history %>% filter(endTime < ctime) %>% 
  group_by(status, nextStatus, TDN) %>% summarise(avgdur = mean(duration, na.rm = T))

ad_base_1 = obj$history %>% filter(endTime < ctime) %>% 
  group_by(status, nextStatus) %>% summarise(avgdur = mean(duration, na.rm = T))

ad_base_0 = obj$history %>% filter(endTime < ctime) %>% 
  mutate(transit = 0) %>% {.$transit[.$status %>% grep(pattern = 'Dep.')] <- 1;.$transit[.$status == 'START'] <- 2;.$transit[.$nextStatus == 'END']<-3;.} %>% 
  group_by(transit) %>% summarise(avgdur = mean(duration, na.rm = T))

mldata <- TRANSPORT.get.transitions(obj) %>% 
  {.$transit[.$status %>% grep(pattern = 'Dep.')] <- 1;.$transit[.$status == 'START'] <- 2;.$transit[.$nextStatus == 'END']<-3;.} %>% 
  mutate(wch = as.numeric((inctype == 'WHC') & (inc_elapsed > 0) & (st_from == station | st_to == station) & (transit == 0))) %>% 
  left_join(obj$get.tdn_map(), by = 'caseID') %>% 
  left_join(average_durations, by = c('status', 'nextStatus', 'TDN'))

mldata$avgdur[which(is.na(mldata$avgdur))] <- mldata %>% filter(is.na(avgdur)) %>% select(status, nextStatus) %>% 
  left_join(ad_base_1, by = c('status', 'nextStatus')) %>% pull(avgdur)

mldata$avgdur[which(is.na(mldata$avgdur))] <- mldata %>% filter(is.na(avgdur)) %>% select(transit) %>% 
  left_join(ad_base_0, by = c('transit')) %>% pull(avgdur)

mldata %<>%
  mutate(hod = format(startTime, '%H'), dof = fday(startTime)) %>% 
  mutate(st_match = (st_from == station) | (st_to == station) | (st_from == nextStation) | (st_to == nextStation), incexist = (inc_elapsed > 0)) %>% 
  mutate(st_inc = incexist & st_match, st_tr = transit & st_match, st_dw = !transit & st_match) %>% 
  mutate(delay2 = duration - avgdur) %>% logical2integer
################################################
clean <- mldata %>% select(startTime, dist, avgdur, transit, incexist, hod, st_match, st_inc, st_tr, st_dw, inctype, wch, delay2) %>% 
  filter(transit < 2)

clean.nit = clean %>% filter(is.na(incexist)) %>% filter(transit == 1)
clean.nid = clean %>% filter(is.na(incexist)) %>% filter(transit == 0)
clean.int = clean %>% filter(!is.na(incexist)) %>% filter(transit == 1)
clean.ind = clean %>% filter(!is.na(incexist)) %>% filter(transit == 0)




X_train = clean.int %>% filter(startTime < ctime) %>% select(-startTime, -delay2, -transit) %>% integer2numeric()
y_train = clean.int %>% filter(startTime < ctime) %>% pull(delay2)
X_test  = clean.int %>% filter(startTime > ctime) %>% select(-startTime, -delay2, -transit) %>% integer2numeric()
y_test  = clean.int %>% filter(startTime > ctime) %>% pull(delay2)

X_trn = X_train %>% string2factor %>% factor2integer
X_tst = X_test  %>% string2factor %>% factor2integer

c_train = y_train > 0
c_test  = y_test > 0

gr = GROUPER()
dm = DUMMIFIER()
cls.01 = CLS.SCIKIT.LR(transformers = list(gr, dm), penalty = 'l1')
cls.01$fit(X_train, c_train)
cls.01$performance(X_test, c_test, metric = 'gini')


mdl.01 = REG.LM(name = 'mdl.01', sfs.enabled = T, metric = mae)
mdl.01$fit(X_trn, y_train)
mdl.01$performance(X_tst, y_test, metric = 'mae')


mdl.02 = REG.LM(rfe.enabled = T, transformers = DUMMIFIER())
mdl.02$fit(X_train, y_train)
mdl.02$performance(X_test, y_test, metric = 'mae')


mdl.03 = REG.SCIKIT.XGB(name = 'prd')
mdl.03$fit(X_trn, y_train)
mdl.03$performance(X_tst, y_test, metric = 'mae')
mdl.03$objects$features %>% filter(importance>0) %>% arrange(desc(importance))

mdl.04 = REG.SCIKIT.XGB(name = 'prd')
mdl.04$fit(X_train, y_train)
mdl.04$performance(X_test, y_test, metric = 'mae')
mdl.04$objects$features %>% filter(importance>0) %>% arrange(desc(importance))

# Folder Optimisation:
# loopt_v4.R

# loop optimization:
source('tools.R')
init_source()

library(doParallel)
library(foreach)

atcon = athena.buildConnection(bucket = 'bucket_name')

day_run = function(simdate, rt = 0.92, dt = 0.985){
  ss = try(readTransportModel(from_date = simdate, to_date = as.character(as.Date(simdate) + 1), path = './data/'), silent = T)
  if(inherits(ss, 'try-error')){
    ss = try(getTransportModel(con = atcon, from_date = simdate, to_date = as.character(as.Date(simdate) + 1), max_rows = 3000000,
                               actual_eventlog_table = 'table_name',
                               scheduled_eventlog_table = 'table_name',
                               incidents_table = 'incident_profile'), silent = T)
    
  }
  if(inherits(ss, 'try-error')){
    cat('\n', 'ERROR: ', ss, '\n')
    return(NULL)
  }
    
  cores = detectCores()
  
  d = makeCluster(cores[1] - 1)
  registerDoParallel(d)
  
  execute = function(obj){
    TRANSPORT.gen.random_service_alterations(obj, caseIDs = obj$get.cases()) -> rsalt
    
    rsalt %>% apply_service_alterations(obj = obj) %>% 
      predict_startTime_divine(obj) %>% 
      predict_durations_V2(obj) %>% correct_durations_PB(obj) %>% 
      run_simulation %>% apply_headway_rule(obj = obj)
  }
  
  hist = try(execute(ss), silent = T)
  if(inherits(hist, 'try-error')){
    cat('\n', 'ERROR: ', hist, '\n')
    return(NULL)
  }
  
  base    = hist[1,]
  base$id = 'error'
  
  result = foreach(i = 1:300, .combine = rbind, .packages = c('dplyr', 'tibble', 'magrittr', 'stringr', 'rprom')) %dopar% {
    source('tools.R')
    
    hist = try(execute(ss), silent = T)
    
    if(inherits(hist, 'try-error')){
      base$id = as.character(hist)
      hist = base
      # hist = NULL
    } else {
      hist$id = i
    }
    # gc()
    # hist %>% write.csv('report/simres/may19' %>% paste(i, 'csv', sep = '.'))
    hist
  } 
  
  result %>% 
    group_by(id) %>% 
    do({get_metrics(., ss$objects$timetable$history) %>% as.data.frame}) -> metrics
  
  metrics %>%
    mutate(rdev = ifelse(reliability > rt, 0, rt - reliability), ddev =  ifelse(delivery > dt, 0, dt - delivery)) %>%
    mutate(performance = 0.01*reliability*delivery + 1.0/(1.0 + 0.3*rdev + 0.7*ddev)) %>%
    arrange(desc(performance)) %>% head(100) %>% pull(id) -> bst
  
  result$sim_day  = simdate
  metrics$sim_day = simdate
  
  result  %>% filter(id %in% bst) %>% select(-TDN, -sdTime) %>% write.csv(paste0('report/simres/', simdate,'.csv'))
  metrics %>% write.csv(paste0('report/simres/metrics_', simdate,'.csv'))
  
  stopCluster(d)
}

simdates = as.character(as.Date('2019-02-18') + 0:0)

for(simdate in simdates){
  day_run(simdate)
}

# read_loopt_v1.R

# loop optimization:
source('tools.R')
init_source()

library(doParallel)
library(foreach)
cores = detectCores()
d = makeCluster(cores[1] - 1)
registerDoParallel(d)

day_read = function(simdate){
  ss    = readTransportModel(from_date = simdate, to_date = as.character(as.Date(simdate) + 1), path = './data/')
  
  metrics = read.csv(paste0('report/simres/metrics_', simdate,'.csv'), as.is = T) %>% spark.unselect('X', 'X.1')

  # bstid = metrics %>%
  #   mutate(performance = reliability*delivery) %>%
  #   arrange(desc(performance)) %>% head(1) %>% pull(id)

  bstid = metrics %>%
    mutate(rdev = ifelse(reliability > 0.92, 0, 0.92 - reliability), ddev =  ifelse(delivery > 0.985, 0, 0.985 - delivery)) %>%
    mutate(performance = 0.01*reliability*delivery + 1.0/(1.0 + 0.3*rdev + 0.7*ddev)) %>%
    arrange(desc(performance)) %>% head(1) %>% pull(id)
  
  events  = read.csv(paste0('./report/simres/', simdate,'.csv'), as.is = T) %>% spark.unselect('X', 'X.1') %>% 
    filter(id == bstid) %>% 
    mutate(startTime = as.POSIXct(startTime), endTime = as.POSIXct(endTime)) %>% 
    left_join(ss$get.tdn_map(), by = 'caseID')

  tdns  = unique(events$TDN) %>% na.omit
  valid_caseids = paste(tdns, simdate, sep = '_')
  events %<>% filter(caseID %in% valid_caseids)
  
  events %>% 
    left_join(
      extract_service_alterations.table(
        events, ss$objects$timetable$history) %>% 
        rownames2Column('caseID'), by = 'caseID')
}

simdates = as.character(as.Date('2019-03-01') + 0:30)

#Parallel:
result = foreach(simdate = simdates, .combine = rbind, .packages = c('dplyr', 'tibble', 'magrittr', 'stringr')) %dopar% {
    source('tools.R')
    init_source()

    sim = try(day_read(simdate), silent = T)

    if(inherits(sim, 'try-error')){
      sim = NULL
    }
    sim
}
stopCluster(d)



# Not Parallel:
# result = NULL
# for(simdate in simdates){
#   sim = try(day_read(simdate), silent = T)
#   cat(simdate, '\n')
#   if(inherits(sim, 'try-error')){
#     cat(sim)
#     sim = NULL
#   }
#   result = rbind(result, sim)
# }



write.csv(result, 'looptres_mar19' %>% paste0('_', Sys.Date(), '.csv'))

# 
# result = NULL
# for(simdate in simdates){
#   cat(simdate, '\n')
#   result %<>% rbind(day_read(simdate))
# } 

obj = readTransportModel(from_date = '2019-03-01', to_date = '2019-04-01', path = './data/')
get_metrics(obj$history, obj$objects$timetable$history)
get_metrics(result, obj$objects$timetable$history)

# Folder: Optimisation:
# test2.R
source('tools.R')

init_source()
atcon = athena.buildConnection(bucket = 'your_s3_bucket')

obj   = getTransportModel(con = atcon, from_date = '2019-03-01', to_date = '2019-04-01', max_rows = 3000000,
                          actual_eventlog_table = 'table',
                          scheduled_eventlog_table = 'table',
                          incidents_table = 'table')

# obj   = readTransportModel(from_date = '2019-05-01', to_date = '2019-06-01', path = './data/')

obj$history %>% predict_durations_V2(obj = obj) -> prd.0
prd.0 %>% correct_durations_PB(obj = obj) -> prd.b
prd.b %>% run_simulation -> sim.b

sim.b %>% apply_headway_rule(obj) -> sim.bh

prd.b  %>% mutate(dur_error = duration - duration_prd) %>% mutate(dur_abser = abs(dur_error)) %>% pull(dur_abser) %>% mean
sim.bh %>% mutate(dur_error = duration - duration_prd) %>% mutate(dur_abser = abs(dur_error)) %>% pull(dur_abser) %>% mean

sim.b  %>% mutate(dur_error = duration - duration_org) %>% mutate(dur_abser = abs(dur_error)) %>% pull(dur_abser) %>% mean

sim.b %>% filter(nextStatus == 'END') %>% mutate(delay = difftime(startTime, startTime_org, units = 'secs') %>% as.numeric) %>% 
  mutate(absdelay = abs(delay)) %>% pull(absdelay) %>% mean

sim.bh %>% filter(nextStatus == 'END') %>% mutate(delay = difftime(startTime, startTime_org, units = 'secs') %>% as.numeric) %>% 
  mutate(absdelay = abs(delay)) %>% pull(absdelay) %>% mean


################
# simulation on exact actual service alterations (startTime as actual):
obj$history %>% 
  predict_durations_V2(obj) %>% correct_durations_PB(obj) %>% 
  run_simulation %>% apply_headway_rule(obj = obj) -> hsim

# simulation on exact actual service alterations (startTime as scheduled):
obj$history %>% 
  predict_startTime_scheduled(obj) %>% 
  predict_durations_V2(obj) %>% correct_durations_PB(obj) %>% 
  run_simulation %>% apply_headway_rule(obj = obj) -> gsim

# simulation on scheduled (without any service alterations) (startTime as scheduled)
obj$objects$timetable$history %>% 
  predict_durations_V2(obj) %>% correct_durations_PB(obj) %>% 
  run_simulation %>% apply_headway_rule(obj = obj) -> ssim

# simulation on scheduled (without any service alterations) (startTime as actual)
obj$objects$timetable$history %>% predict_startTime_divine(obj) %>% 
  predict_durations_V2(obj) %>% correct_durations_PB(obj) %>% 
  run_simulation %>% apply_headway_rule(obj = obj) -> bsim

# simulation on scheduled (without any service alterations) using actual durations (startTime as scheduled)
obj$objects$timetable$history %>% 
  predict_durations_divine(obj) %>% 
  run_simulation -> dsim

# simulation on actual service alterations applied to scheduled: (startTime as scheduled)
obj$tables$profile.case %>% select(caseID) %>% 
  left_join(obj$tables$jp_full %>% 
              select(caseID, primary_flag, secondary_flag, sd_flag, sa_flag, bl_flag, c_flag, altst), by = 'caseID') -> asalt
asalt %>% apply_service_alterations(obj = obj) %>% 
  predict_durations_V2(obj) %>% correct_durations_PB(obj) %>% 
  run_simulation %>% apply_headway_rule(obj = obj) -> asim

# simulation on actual service alterations applied to scheduled: (startTime as actual)
obj$tables$profile.case %>% select(caseID) %>% 
  left_join(obj$tables$jp_full %>% 
              select(caseID, primary_flag, secondary_flag, sd_flag, sa_flag, bl_flag, c_flag, altst), by = 'caseID') -> asalt
asalt %>% apply_service_alterations(obj = obj) %>% 
  predict_startTime_divine(obj) %>% 
  predict_durations_V2(obj) %>% correct_durations_PB(obj) %>% 
  run_simulation %>% apply_headway_rule(obj = obj) -> gsim

# simulation on randomly generated service alterations applied to scheduled: (startTime as scheduled)
TRANSPORT.gen.random_service_alterations(obj, caseIDs = obj$get.cases()) -> rsalt
rsalt %>% apply_service_alterations(obj = obj) %>% 
  predict_durations_V2(obj) %>% correct_durations_PB(obj) %>% 
  run_simulation %>% apply_headway_rule(obj = obj) -> rsim

# simulation on randomly generated service alterations applied to scheduled: (startTime as scheduled)
rsalt %>% apply_service_alterations(obj = obj) %>% 
  predict_startTime_divine(obj) %>% 
  predict_durations_V2(obj) %>% correct_durations_PB(obj) %>% 
  run_simulation %>% apply_headway_rule(obj = obj) -> osim

get_metrics(obj$history, obj$objects$timetable$history)
get_metrics(hsim, obj$objects$timetable$history)
get_metrics(asim, obj$objects$timetable$history)
get_metrics(gsim, obj$objects$timetable$history)
get_metrics(rsim, obj$objects$timetable$history)
get_metrics(osim, obj$objects$timetable$history)
get_metrics(ssim, obj$objects$timetable$history)
get_metrics(bsim, obj$objects$timetable$history)
get_metrics(dsim, obj$objects$timetable$history)


# Folder: Reinforcement_Learning:
# test_agent_v2:
source('tools.R')
init_source()
obj = readTransportModel(from_date = '2019-03-11', to_date = '2019-03-12', path = './data/')
##################################################

obj$goto("2019-03-11 07:57:43")

while (nrow(obj$queue) > 0){
  action = obj$valid_actions() %>% sample(1)
  obj$take_action(action)
  cat(as.character(obj$ctime), ' ', obj$ctdn, ' ', action, '\n')
}

library(keras)

# keras.models      = reticulate::import('keras.models')
# keras.layers.core = reticulate::import('keras.layers.core')
# mod <- keras.models$Sequential()

ninput = obj$rstate %>% as.numeric %>% length

model <- keras_model_sequential() %>% 
  layer_dense(name = 'first_layer', units = ninput, input_shape = ninput) %>% 
  layer_activation_parametric_relu() %>% 
  layer_dense(name = 'second_layer', units = ninput) %>% 
  layer_activation_parametric_relu() %>% 
  layer_dense(units = 6) %>% 
  compile(optimizer = 'adam', loss = 'mse')


experience = EXPERIENCE(keras_model = model, max_memory = 10000)

jump(obj, experience, 100, show_progress = T)
obj$now()
teach(obj, experience, model, n_train_data = 1000)

qtrain(model, obj, parameters = list(n_epoch = 15)) -> tmdl

obj$goto("2019-03-03 06:13:43")

# Folder: Simulation:
# act_salt.R:

source('tools.R')
init_source()


obj = readTransportModel(from_date = '2019-05-01', to_date = '2019-06-01', path = './data/')

obj$history %>% 
  left_join(
    extract_service_alterations.table(
      obj$history, obj$objects$timetable$history) %>% 
      rownames2Column('caseID'), by = 'caseID') -> hisalt


hisalt %>% write.csv('act_evntlg_wth_salt_may19.csv')

# Folder: Simulation:
# violations.R
source('tools.R')
init_source()
library(doParallel)
library(foreach)

cores = detectCores()

d = makeCluster(cores[1] - 1)
registerDoParallel(d)


simdates = as.character(as.Date('2019-02-01') + 0:119)

violations = foreach(simdate = simdates, .combine = rbind, .packages = c('dplyr', 'tibble', 'magrittr', 'stringr')) %dopar% {
  source('tools.R')
  init_source()
  
  obj = readTransportModel(from_date = simdate, to_date = as.character(as.Date(simdate) + 1), path = './data/')
  obj %>% headway_violations
}
stopCluster(d)
# 
# 
# violations = NULL
# for (simdate in simdates){
#   obj = readTransportModel(from_date = simdate, to_date = as.character(as.Date(simdate) + 1), path = './data/')
#   obj %>% headway_violations %>% rbind(violations)
# }

violations %>% write.csv('violations_feb_may19.csv')

# Folder: Simulation:
# sim_trend_v3.R
source('tools.R')

init_source()

###########
obj   = readTransportModel(from_date = '2019-02-01', to_date = '2019-03-01', path = './data/')

obj$history %>% filter(startTime > obj$ctime) %>% predict_durations_V2(obj = obj) %>% correct_durations_PB(obj = obj) %>% 
  run_simulation %>% apply_headway_rule(obj = obj) -> feb19_hr120_pb

feb19_hr120_pb %>% write.csv('report/feb19_hr120_pb_20190919.csv')

###########
obj   = readTransportModel(from_date = '2019-03-01', to_date = '2019-04-01', path = './data/')

obj$history %>% filter(startTime > obj$ctime) %>% predict_durations_V2(obj = obj) %>% correct_durations_PB(obj = obj) %>% 
  run_simulation %>% apply_headway_rule(obj = obj) -> mar19_hr120_pb

mar19_hr120_pb %>% write.csv('report/mar19_hr120_pb_20190919.csv')

###########
obj = readTransportModel(from_date = '2019-04-01', to_date = '2019-05-01', path = './data/')

obj$history %>% filter(startTime > obj$ctime) %>% predict_durations_V2(obj = obj) %>% correct_durations_PB(obj = obj) %>% 
  run_simulation %>% apply_headway_rule(obj = obj) -> apr19_hr120_pb

apr19_hr120_pb %>% write.csv('report/apr19_hr120_pb_20190919.csv')

###########
obj   = readTransportModel(from_date = '2019-05-01', to_date = '2019-06-01', path = './data/')

obj$history %>% filter(startTime > obj$ctime) %>% predict_durations_V2(obj = obj) %>% correct_durations_PB(obj = obj) %>% 
  run_simulation %>% apply_headway_rule(obj = obj) -> may19_hr120_pb

may19_hr120_pb %>% write.csv('report/may19_hr120_pb_20190919.csv')

#################

feb19_hr120_pb = read.csv('report/feb19_hr120_pb_20190919.csv')
mar19_hr120_pb = read.csv('report/mar19_hr120_pb_20190919.csv')
apr19_hr120_pb = read.csv('report/apr19_hr120_pb_20190919.csv')
may19_hr120_pb = read.csv('report/may19_hr120_pb_20190919.csv')


feb19_hr120_pb %>% filter(nextStatus == 'END') %>% mutate(delay = difftime(startTime, startTime_org, units = 'secs') %>% as.numeric) %>% 
  mutate(absdelay = abs(delay)) %>% pull(absdelay) %>% mean

mar19_hr120_pb %>% filter(nextStatus == 'END') %>% mutate(delay = difftime(startTime, startTime_org, units = 'secs') %>% as.numeric) %>% 
  mutate(absdelay = abs(delay)) %>% pull(absdelay) %>% mean

apr19_hr120_pb %>% filter(nextStatus == 'END') %>% mutate(delay = difftime(startTime, startTime_org, units = 'secs') %>% as.numeric) %>% 
  mutate(absdelay = abs(delay)) %>% pull(absdelay) %>% mean

may19_hr120_pb %>% filter(nextStatus == 'END') %>% mutate(delay = difftime(startTime, startTime_org, units = 'secs') %>% as.numeric) %>% 
  mutate(absdelay = abs(delay)) %>% pull(absdelay) %>% mean

rbind(feb19_hr120_pb, mar19_hr120_pb, apr19_hr120_pb, may19_hr120_pb) -> res
res %>% 
  # left_join(obj$objects$timetable$history %>% select(caseID, station, nextStation, schTime = startTime, schDur = duration), by = c('caseID', 'station', 'nextStation')) %>% 
  rename(actTime = startTime_org, actDur = duration_org, simTime = startTime, simDur = duration) %>% 
  mutate(time_error = difftime(simTime, actTime, units = 'secs') %>% as.numeric, dur_error = simDur - actDur) %>% 
  mutate(time_abser = abs(time_error), dur_abser = abs(dur_error)) %>% 
  select(-location, -sdTime, -eventAge, -path, -selected) -> res2

res2 %>% write.csv('simres_feb_may19_v3.csv')
