# Hello, world!
#
# This is an example function named 'hello'
# which prints 'Hello, world!'.
#
# You can learn more about package authoring with RStudio at:
#
#   http://r-pkgs.had.co.nz/
#
# Some useful keyboard shortcuts for package authoring:
#
#   Build and Reload Package:  'Ctrl + Shift + B'
#   Check Package:             'Ctrl + Shift + E'
#   Test Package:              'Ctrl + Shift + T'

hello <- function() {
  print("Hello, world!")
}

####### Folder banwest ========================

### promtools2ba.R ------------------


eventlogIntervalQuery = function(tableName, from, until, time_col){
  t1  = from  %>% as.time
  t2  = until %>% as.time
  flt = list(list(type = 'time', min = t1, max = t2))
  names(flt) <- time_col
  
  sqlScript(tableName = tableName, fields = NULL, filter = flt)
}

completeEventlogQuery = function(tableName, from, until, caseID_col, time_col){
  t1  = from  %>% as.time
  t2  = until %>% as.time
  flt = list(list(type = 'time', min = t1, max = t2))
  names(flt) <- time_col
  
  caseFilterQuery = sqlScript(tableName = tableName, fields = caseID_col, filter = flt)
  flt = list(list(query = caseFilterQuery))
  names(flt) <- caseID_col
  
  sqlScript(tableName = tableName, filter = flt)
}

runSQL = function(query, dsn, ...){
  channel    = odbcConnect(dsn = dsn, ...)
  data       = sqlQuery(channel = channel, query = query, ...)
  close(channel)
  return(data)
}


### test_bupar.R ------------------

library(bupaR)
library(edeaR)
library(processmapR)


t1 = as.time('2018-03-01 08:00:00')
t2 = as.time('2018-03-01 18:00:00')

# Read eventlog:
EL = readODBC(tableName = 'BMO_POC_PROCESS_MINING_BW', filter = list(DATE_TIME = list(type = 'time', min = '2017-07-01', max = '2017-08-01')))

EL$DATE_TIME %<>% as.time

# Concatenate caseID and order number to get a unique task ID:
EL$TASK_ORDER_NUM <- EL$CASE_ID %++% '-' %++% EL$TASK_ORDER_NUM

# create a process model and feed eventlog:

x = new('PROCESS')
x$feedEventLog(EL, caseID_col = 'CASE_ID', taskID_col = 'TASK_ORDER_NUM', time_col = 'DATE_TIME', skill_col = 'TASK_TYPE', agent_col = 'USER_NAME', eventType_col = 'EVENT_STATUS',
               arrivalTag = 'Awake', startTag = 'Start', suspendTag = c('DIARISE', 'Suspend'), completeTag = 'Complete', 
               caseStartTag = 'Case Start', caseEndTag = 'Case Complete', correct = T)

y = eventlog(eventlog = x$eventlog,
             case_id  = 'caseID',
             activity_id = 'skill',
             activity_instance_id = 'taskID',
             timestamp = 'time',
             lifecycle_id = 'type',
             resource_id = 'agent')

y %>% process_map()

y %>% filter_activity_frequency(percentile = 0.75) %>% process_map

# Exploratory and Descriptive Event Process Analysis:
y %>% 
  processing_time("activity") %>%
  plot

y %>%
  throughput_time("log") %>%
  plot()

rs = y %>% resource_specialisation("resource")
rs = rs[!rs$agent == "Auto User " & !is.na(rs$agent), ]
rs[order(rs$absolute, decreasing = T)[1:20],] %>% niraPlot(x = 'absolute', y = 'agent', plotter = 'plotly', type = 'bar')


y %>% resource_involvement("resource") %>% head(n = 20) %>% na.omit %>% filter(agent != "Auto User ") %>% 
  niraPlot(x = 'relative', y = 'agent', plotter = 'plotly', type = 'bar')


### test_v1.R ------------------

### test_v2.R ------------------
library(magrittr)
library(dplyr)
library(RODBC)

source('../../packages/master/niragen-master/R/niragen.R')
source('../../packages/master/niragen-master/R/io.R')
source('../../packages/master/niragen-master/R/linalg.R')

source('../../packages/master/niraprom-master/R/tstools.R')
source('../../packages/master/niraprom-master/R/promtools.R')
source('../../packages/master/niraprom-master/R/transys.R')
source('../../packages/master/niraprom-master/R/prom.R')

source('../../packages/master/nirats-master/R/tsdaily.R')

source('../../packages/master/niravis-master/R/visgen.R')
source('../../packages/master/niravis-master/R/plotly.R')
source('../../packages/master/niravis-master/R/bpexploder.R')
source('../../packages/master/niravis-master/R/diagramer.R')
source('../../packages/master/niravis-master/R/visNetwork.R')
source('../../packages/master/niravis-master/R/niraPlot.R')

t1 = as.time('2017-02-01 00:00:00')
t2 = as.time('2017-03-02 00:00:00')

# This program, runs a que simulation on actual task arrivals:

# Read eventlog:
# EL = completeEventlogQuery(tableName = 'BMO_POC_PROCESS_MINING_BW', from = t1, until = t2, caseID_col = 'CASE_ID', time_col = 'DATE_TIME') %>% 
#   runSQL(dsn = 'Teradata_Prod')

# EL = eventlogIntervalQuery(tableName = 'BMO_POC_PROCESS_MINING_BW', from = t1, until = t2, time_col = 'DATE_TIME') %>% 
#   runSQL(dsn = 'Teradata_Prod')

EL$DATE_TIME %<>% as.time

# Concatenate caseID and order number to get a unique task ID:
EL$TASK_ORDER_NUM <- EL$CASE_ID %++% '-' %++% EL$TASK_ORDER_NUM

# create a process model and feed eventlog:

x = new('PROCESS')
x$feedEventLog(EL, caseID_col = 'CASE_ID', taskID_col = 'TASK_ORDER_NUM', time_col = 'DATE_TIME', skill_col = 'TASK_TYPE', agent_col = 'USER_NAME', eventType_col = 'EVENT_STATUS',
               arrivalTag = 'Awake', startTag = 'Start', suspendTag = c('DIARISE', 'Suspend'), completeTag = 'Complete', 
               caseStartTag = 'Case Start', caseEndTag = 'Case Complete', correct = T, silent = F)

x$eventlog %>% write.csv('bwel.csv')

##### Summary of activity processing time:
x$get.summary.skill.procTime()
x$get.summary.agent.skill.procTime()
x$get.summary.agent.procTime()
x$get.summary.agent.idleTime()

####### Box plots:

x$plot.summary.agent.procTime()
x$plot.summary.skill.procTime()

####### time series:
volin  = x$get.skill.volumeIn()
volout = x$get.skill.volumeOut()






## Build map links:
x$eventlog %>% select(caseID, taskID, time, activity, type) %>% 
  dplyr::filter(type %in% c('arrived', 'completed')) %>% 
  dplyr::arrange(caseID, time) %>% 
  dplyr::mutate(nextActivity = activity, nextType = type, nextTaskID = taskID, nextTime = time) %>% 
  dplyr::group_by(caseID) %>% 
  do(elim_next(.)) %>% ungroup %>% select(taskID, nextActivity, nextTaskID)

x$eventlog %>% select(caseID, taskID, time, activity, type) %>% 
  dplyr::filter(type %in% c('arrived', 'completed')) %>% 
  dplyr::arrange(caseID, time) %>% 
  dplyr::mutate(prevActivity = activity, prevType = type, prevTaskID = taskID) %>% 
  dplyr::group_by(caseID) %>% 
  do(elim_prev(.)) %>% ungroup %>% select(taskID, prevActivity, prevTaskID)

# convert a tasklist to eventlog
eventlog = x$tasklist %>% 
  dplyr::select(taskID, caseID, activity, agent, started = startTime, arrived = arrTime, completed = compTime) %>% 
  reshape2::melt(
    id.vars = c('caseID', 'taskID', 'activity', 'agent'), 
    measure.vars = c('started', 'completed', 'arrived'), 
    value.name = 'time', variable.name = 'type') %>% 
  mutate(time = as.POSIXct(time, origin = '1970-01-01'))

# Get isolated task flow map tables (nodes and edges):
tl = x$tasklist %>% attachPrevNext(x$eventlog)

# tst stands for team activity table
tst = EL %>% dplyr::group_by(TASK_GROUP_NAME, TASK_TYPE) %>% dplyr::summarise(count = length(unique(CASE_ID))) %>% ungroup
names(tst) <- c('team', 'activity', 'ncase')

team_activities = list()
teams = unique(tst$team)
for(team in teams){team_activities[[team]] <- as.character(tst %>% filter(team == team) %>% pull(activity))}
x$get.activities()
# add a visualisation of team and task

# for a particular activity group (let's call it team) and a particular given date (date):
team = teams[2]; date = as.Date(t1) + 5
tl %>% filter(activity %in% team_activities[[team]]) %>% group_by()



### test_v3.R ------------------
library(magrittr)
library(dplyr)
library(RODBC)
library(niragen)
library(niraprom)
library(niravis)
library(nirats)

source('C:/Nima/RCode/projects/cba.hlp.simulation/script/banwest/promtools2ba.R')

source('../../packages/master/nirats-master/R/tsdaily.R')

t1 = as.time('2017-02-01 00:00:00')
t2 = as.time('2017-02-05 00:00:00')

# Read eventlog:
# EL = completeEventlogQuery(tableName = 'BMO_POC_PROCESS_MINING_BW', from = t1, until = t2, caseID_col = 'CASE_ID', time_col = 'DATE_TIME') %>% 
#   runSQL(dsn = 'Teradata_Prod')

EL = eventlogIntervalQuery(tableName = 'BMO_POC_PROCESS_MINING_BW', from = t1, until = t2, time_col = 'DATE_TIME') %>% 
  runSQL(dsn = 'Teradata_Prod')

EL$DATE_TIME %<>% as.time

# Concatenate caseID and order number to get a unique task ID:
EL$TASK_ORDER_NUM <- EL$CASE_ID %++% '-' %++% EL$TASK_ORDER_NUM

# create a process model and feed eventlog:


x = new('PROCESS')
x$feedEventLog(EL, caseID_col = 'CASE_ID', taskID_col = 'TASK_ORDER_NUM', actGroup_col = 'TASK_GROUP_NAME', time_col = 'DATE_TIME', activity_col = 'TASK_TYPE', agent_col = 'USER_NAME', eventType_col = 'EVENT_STATUS',
               arrivalTag = 'Awake', startTag = 'Start', suspendTag = c('DIARISE', 'Suspend'), completeTag = 'Complete', 
               caseStartTag = 'Case Start', caseEndTag = 'Case Complete', correct = F, silent = T)

# x = new('PROCESS')
# x$eventlog %>% saveRDS('xel.rds')
# x$eventlog <-  readRDS('xel.rds')
# x = new('PROCESS')
# x$feedEventLog(read.csv('bwel.csv', as.is = T), caseID_col = 'caseID', taskID_col = 'taskID', actGroup_col = 'actGroup', time_col = 'time', 
#                activity_col = 'activity', agent_col = 'agent', eventType_col = 'type',
#                arrivalTag = 'arrived', startTag = 'started', suspendTag = 'suspended', completeTag = 'completed', 
#                caseStartTag = 'caseStart', caseEndTag = 'caseComplete', correct = F, silent = T) 

##### Summary of activity processing time:
x$get.activity.summary.procTime(time_unit = 'hour') %>% 
  niraPlot(x = 'Total', y = 'activity', plotter = 'highcharter', type = 'bar', config = list(legend.enabled = F, yAxis.label = 'Total Processing Time (hours)'))

x$get.agent.summary.activityProcTime(time_unit = 'hour')
x$get.agent.summary.procTime()

x$get.agent.summary.idleTime(time_unit = 'hour') %>% 
  niraPlot(x = 'Total', y = 'agent', plotter = 'highcharter', type = 'bar')

####### Box plots:

x$plot.agent.summary.procTime()
x$plot.activity.summary.procTime()

####### time series:
volin   = x$get.activity.volumeIn()
volout  = x$get.activity.volumeOut()
backlog = x$get.activity.backlog()
####### activity transition system:
at = x$get.activity.transys()
at$plot.processMap()
######### activity transition system: Process map and Filtering:
at$filter.case(freqThreshold = 0.98)
at$plot.processMap()
at$plot.processMap(plotter = 'visNetwork')
at$get.adjacency()

####### actGroup transition system:
gt   = x$get.actGroup.transys()
gvin = gt$get.volumeIn(as_timeseries = T)
gvin$plot.history()
gt$filter.case(freqThreshold = 0.99)
gt$plot.processMap()


x$tasklist %>% 
  mutate(actGroup = map.activity.actGroup[activity], prevActGroup = map.activity.actGroup[prevActivity]) %>% 
  dplyr::group_by(arrDate, actGroup, prevActGroup) %>% 
  dplyr::summarise(Count = length(taskID))



####### Folder discharges ========================

### report.R --------------------------
library(magrittr)
library(dplyr)

# library(niragen)
source('../../packages/master/niragen-master/R/linalg.R')
source('../../packages/master/niragen-master/R/io.R')
source('../../packages/master/niragen-master/R/niragen.R')

# library(niravis)
source('../../packages/master/niravis-master/R/visgen.R')
source('../../packages/master/niravis-master/R/visNetwork.R')
source('../../packages/master/niravis-master/R/billboarder.R')
source('../../packages/master/niravis-master/R/highcharter.R')
source('../../packages/master/niravis-master/R/diagramer.R')
source('../../packages/master/niravis-master/R/networkD3.R')
source('../../packages/master/niravis-master/R/niraPlot.R')
source('../../packages/master/nirats-master/R/time.series.R')
source('../../packages/master/nirats-master/R/tsdaily.R')


# library(niraprom)
source('../../packages/master/niraprom/R/transys.R')
source('../../packages/master/niraprom/R/prom.R')

D = read.csv('script/discharges/full_discharges_mohammad_Sep_Dec 2016.csv', as.is = T)
D = D[D$Type == 'PADC',]

D$APPT_I %<>% as.character
D$STUS_C %<>% as.character
D$STRT_S %<>% as.character %>% as.time(target_class = 'POSIXlt') %>% as.POSIXct  

s = new('TRANSITION.SYSTEM')
s$feedStatusHistory(dataset = D, caseID_col = 'APPT_I', status_col = 'STUS_C', startTime_col = 'STRT_S', sort_startTime = T, add_start = T)

s$plot.processMap()

FA = s$get.adjacency()
TA = s$get.adjacency(measure = 'time', aggrFuncName = 'mean')

s$plot.processMap(plotter = 'visNetwork')

s$filter.case(freqThreshold = 0.98)

s$plot.processMap(plotter = 'visNetwork')



########### Case level
app = s$getCase('CSEHM59021807')
app$getDegree()
app$getStatusProfile()
app$getGraph() %>% plot
app$getNetwork()











# Old Stuff:

i        = 0
rank     = integer()
st       = 'START'
rank[st] = i

while(st != 'END'){
  i = i + 1
  st = s$statusDomain[order(res$adjacency[st, ], decreasing = T)[1]]
  rank[st] = i
}

net %>% visHierarchicalLayout(sortMethod = 'directed') %>% visNodes(physics = F)
net %>% visHierarchicalLayout(sortMethod = 'directed', edgeMinimization = F) %>% visNodes(physics = F)
net %>% visHierarchicalLayout(sortMethod = 'directed', levelSeparation = 200, edgeMinimization = T, blockShifting = T, parentCentralization = T, direction = 'UD') %>% visNodes(physics = F) %>% visEdges(smooth = T)


net %>% visNodes(physics = F)


ADJC = s$data$adjacency %>% apply(1, vect.normalise) %>% t
ADJC[ADJC < 0.1] = 0
banned = character()
for(i in rownames(ADJC)){
  for(j in colnames(ADJC)){
    if(ADJC[i,j] == 0){banned = c(banned, i %++% '-' %++% j)}
  }
}

s$history$path = s$history$status %++% '-' %++% s$history$nextStatus
s$history$selected = !(s$history$path %in% banned)

dim(s$history)
sum(s$history$selected)


ADJC = (ADJC*100) %>% round
netc = adjacency2visNetwork(ADJC) %>% visHierarchicalLayout(sortMethod = 'directed', edgeMinimization = T, blockShifting = T, parentCentralization = T, direction = 'LR') %>% visNodes(physics = F)




## Using evenminr.analytics:
library(tibble)
library(data.table)
D_fuzzy <- create_fuzzy_data(D %>% as.tibble,
                             node_cutoff_vec = 1,
                             case_label = "APPT_I",
                             event_label = "STUS_C",
                             timestamp_label = "STRT_S")

create_fuzzy_map(D_fuzzy)


####### Folder dna_app ========================

### dash.R ---------------------
# Header
# Filename:       dash.R
# Description:    This file creates shiny UI for the process DNA dashboard. 
# Author:         Nima Ramezani Taghiabadi
# Email:          nima.ramezani@cba.com.au
# Start Date:     18 September 2018
# Last Revision:  06 November 2018
# Version:        0.1.0

# Version History:

# Version   Date                  Action
# ___________________________________________
# 0.0.1     18 September 2018     Initial Issue
# 0.0.7     05 October 2018       Items added: Sankey, Sunburst, traces, Volume trend, next & previous status distribution
# 0.0.8     12 October 2018       Item added: status overview
# 0.1.0     06 November 2018      Complete status names added in selectInputs


prescript  = "if(is.null(sync$trigger)){sync$trigger = 0}"
showObjFiltersScript = paste(
  "  chs = getStatusesWithName(x, stmap, include_all = T, full = T)",
  "  mlp = x$get.cases.path() %>% pull('loops') %>% max %>% as.integer",
  "  updateDateRangeInput(session, 'getdates', start = x$modelStart %>% setTZ('GMT') %>% as.Date, end = x$modelEnd %>% setTZ('GMT') %>% as.Date)", 
  "  updateSelectInput(session, 'comp'  , selected = chif(is.null(x$settings$filter$complete), 'all', chif(x$settings$filter$complete, 'Complete', 'Incomplete')))", 
  "  updateSliderInput(session, 'lpsrang', value   = c(chif(is.null(x$settings$filter$minLoop), 0, x$settings$filter$minLoop), chif(is.null(x$settings$filter$maxLoop), mlp, x$settings$filter$maxLoop)), max = mlp)",
  "  # cat('I am here --> ', summary(x))",
  "  updateSliderInput(session, 'freqthr', value   = chif(is.null(x$settings$filter$freqThreshold), 1.0, x$settings$filter$freqThreshold))",
  "  updateSelectInput(session, 'stsdmn', selected = chif(is.null(x$settings$filter$statusDomain), 'all', x$settings$filter$statusDomain), choices = chs)", 
  "  updateSelectInput(session, 'strsta', selected = chif(is.null(x$settings$filter$startStatus), 'all', x$settings$filter$startStatus), choices = chs)", 
  "  updateSelectInput(session, 'endsta', selected = chif(is.null(x$settings$filter$endStatus), 'all', x$settings$filter$endStatus), choices = chs)", 
  "  sync$message  = x %>% summary",
  sep = '\n')

I          = list()

######### Clothes: #########

notecloth   = list(type = 'box' , icon = 'comment-o', offset = 0.5, weight = 12, status = 'success', solidHeader = T)
metricloth  = list(type = 'valueBox', icon = 'file' , weight = 2, fill = T, color = 'blue')
# valcloth    = list(type = 'infoBox' , value = 'Fil', subtitle = 'Assess Documents', weight = 2, fill = T, color = 'green')
colcloth    = list(type = 'column', weight = 6, align = 'center')

######### Main items: #########

I$main       = list(type = 'dashboardPage', layout.head = c(), layout.side = c('getprocess', 'getdates', 'load', 'line', 'getthr', 'saveobj', 'readobj'), sidebar.width = 300, layout.body = c('shinyjs', 'menu'))
I$main       = list(type = 'dashboardPage', title = 'CBA Homeloan Process View', skin = 'black', layout.head = c() ,layout.body = c('shinyjs', 'procpage'), sidebar.width = 300,
                    layout.side = c('getprocess', 'getdates', 'load', 'line', 'filters', 'line', 'comp', 'lpsrang', 'freqthr', 'stsdmn', 'strsta', 'endsta', 'apply','reset', 'line', 'saveobj', 'readobj'), header.title = 'CBA Homeloan Process View v 0.0.1', header.title.width = 300, header.title.font = 'tahoma', header.title.font.weight = 'bold', header.title.font.size = 26)

######### SIDEBAR ###########
I$getprocess = list(type = 'selectInput', title = 'Select Process', choices = proctypes, selected = 'HL')
I$getdates   = list(type = 'dateRangeInput', title = 'Select Date Range', start = Sys.Date() - 31, end = Sys.Date(), min = Sys.Date() - 2*365, max = Sys.Date() + 7)
I$load       = list(type = 'actionButton', title = 'Load Data', width = '270px')
# Filters
I$filters    = list(type = 'static', object = h3('  Filters:'))
I$comp       = list(type = 'selectInput', title = 'Completion', selected = 'all', choices = c('all', 'Complete', 'Incomplete'))
I$lpsrang    = list(type = 'sliderInput', title = 'Loops Range', min = as.integer(0), max = as.integer(100), value = c(0, 100) %>% as.integer)
# I$lpsrang    = list(type = 'checkboxInput', title = 'No repeated transitions', value = F, inline = T)
# I$durrang    = list(type = 'sliderInput', title = 'Duration Range (days)', min = 0.0, max = 30.0, value = c(0, 30), step = 0.01*(30))
I$freqthr    = list(type = 'sliderInput', title = 'Frequency Threshold', min = 0.00, max = 1.00, value = 0.98, step = 0.01)
I$apply      = list(type = 'actionButton', title = 'Apply Filter', width = '90%')
I$reset      = list(type = 'actionButton', title = 'Reset Filter', width = '90%')
I$saveobj    = list(type = 'actionButton', title = 'Save Object' , width = '135px', inline = T, vertical_align = 'top', float = 'left')
I$readobj    = list(type = 'actionButton', title = 'Read Object' , width = '135px', inline = F, vertical_align = 'top', float = 'left')

I$stsdmn       = list(type = 'selectInput', title = 'Include Statuses' , selected = 'all', multiple = T, choices = 'all')
I$strsta       = list(type = 'selectInput', title = 'Starting Statuses', selected = 'all', multiple = F, choices = 'all')
I$endsta       = list(type = 'selectInput', title = 'Ending Statuses'  , selected = 'all', multiple = F, choices = 'all')

x <- try(x_object, silent = T)
if(!inherits(x, 'TRANSYS')){x <- try(readRDS('object.rds'), silent = T)}

if (inherits(x, 'TRANSYS')){
  x_object = x
  
  chs = getStatusesWithName(x_object, stmap, include_all = T, full = T)
  
  I$getdates$start   <- x$modelStart %>% setTZ('GMT') %>% as.Date
  I$getdates$end     <- x$modelEnd %>% setTZ('GMT') %>% as.Date
  I$comp$selected    <- chif(is.null(x$settings$filter$complete), 'all', chif(x$settings$filter$complete, 'Complete', 'Incomplete'))
  I$lpsrang$max      <- x_object$get.cases.path() %>% pull('loops') %>% max %>% as.integer
  I$lpsrang$value[1] <- chif(is.null(x$settings$filter$minLoop), 0, x$settings$filter$minLoop)
  I$lpsrang$value[2] <- chif(is.null(x$settings$filter$maxLoop), I$lpsrang$max, x$settings$filter$maxLoop)
  I$freqthr$value    <- chif(is.null(x$settings$filter$freqThreshold), 1.0, x$settings$filter$freqThreshold)
  I$stsdmn$selected  <- chif(is.null(x$settings$filter$statusDomain), 'all', x$settings$filter$statusDomain)
  I$stsdmn$choices   <- chs
  I$strsta$selected  <- chif(is.null(x$settings$filter$startStatus), 'all', x$settings$filter$startStatus)
  I$strsta$choices   <- chs
  I$endsta$selected  <- chif(is.null(x$settings$filter$endStatus), 'all', x$settings$filter$endStatus)
  I$endsta$choices   <- chs
} else {
  x = try(getProcessModel(I$getprocess$selected, I$getdates$start, I$getdates$end), silent = T)
  if(inherits(x, 'TRANSYS')){
    x_object = x
    I$lpsrang$max      = x_object$get.cases.path() %>% pull('loops') %>% max %>% as.integer
    I$lpsrang$value[2] = I$lpsrang$max
    x_object$filter.cases(complete = chif(I$comp$selected == 'all', NULL, I$comp$selected == 'Complete'), minLoops = I$lpsrang$value[1], maxLoops = I$lpsrang$value[2], freqThreshold = I$freqthr$value)
  } else {x_object = new('TRANSYS')}
}



######### Page 1:  Process Overview ###########
I$procpage = list(type = 'fluidPage' , layout = list('metrics', 'msg', list('procmenu', list(weight = 4, 'line', 'getst', 'stcard','line', list('getper', 'getcum'), 'volumes'))))
I$getst    = list(type = 'selectInput', title = 'Selected Status', value = 1, choices = getStatusesWithName(x_object, stmap), width = '100%')
I$stcard   = list(type = 'wellPanel', layout = c('prvpie', 'nxtpie'))
I$metrics  = list(type = 'column'  , layout = c('cocinfo', 'cmpinfo', 'cotinfo', 'durinfo', 'trninfo', 'lpsinfo'))
I$procmenu = list(type = 'tabsetPanel', weight = 8, layout = c('maptab', 'santab', 'suntab', 'tratab', 'statab', 'covtab'))
I$maptab   = list(type = 'tabPanel' , title = 'Process Map', layout = 'mappage')
I$mappage  = list(type = 'fluidPage' , layout = list('caret', list('mapmea', 'mapuni'), 'map'))
I$santab   = list(type = 'tabPanel' , title = 'Process Flow', layout = 'sanpage')
I$sanpage  = list(type = 'fluidPage' , layout = c('caret', 'san'))
I$suntab   = list(type = 'tabPanel' , title = 'Process DNA', layout = 'sunpage')
I$sunpage  = list(type = 'fluidPage' , layout = c('caret', 'sun'))
I$tratab   = list(type = 'tabPanel' , title = 'Trace Bar', layout = 'trapage')
I$trapage  = list(type = 'fluidPage' , layout = list('caret', list('tramea', 'trauni'), 'tra'))
I$statab   = list(type = 'tabPanel' , title = 'Status Bar', layout = 'stapage')
# I$stapage  = list(type = 'fluidPage' , layout = list('caret', 'sta'))
I$stapage  = list(type = 'fluidPage' , layout = list('caret', 'stabar', 'stauni', 'stabox'))
I$covtab   = list(type = 'tabPanel' , title = 'Case Overview', layout = 'covpage')
I$covpage  = list(type = 'fluidPage' , layout = list('caret','covuni', 'cov'))
# I$describe   = list(type = 'static', object = 'Please choose Process Type from the list below. Process types are unique instances of EVNT_ACTV_TYPE_M1' %>% paste(br()))
# I$map        = notecloth %<==>% list(layout = c('mapget', 'mapmap'))
# I$sta        = notecloth %<==>% list(layout = c('stabar', 'stauni', 'stabox'), solidHeader = F)

I$mapmea     = list(type = 'radioButtons', title = 'Measure', choices = c(time = 'time', frequency = 'freq'), selected = 'freq', inline = T, weight = 6)
I$mapuni     = list(type = 'radioButtons', title = 'Time Unit', choices = c('second', 'minute', 'hour', 'day', 'week', 'year'), selected = 'hour', inline = T, weight = 6)
I$map        = list(type = 'grvizOutput', height = '70vh', height = '850px', cloth = notecloth)

I$san        = list(type = 'sankeyNetworkOutput', width = '100%', height = '850px', cloth = notecloth)
I$sun        = list(type = 'sunburstOutput', width = '100%', height = '850px', cloth = notecloth)

# I$tre        = list(type = 'sankeytreeOutput', width = '100%', height = '850px', cloth = notecloth)

I$tramea     = I$mapmea
I$trauni     = I$mapuni
I$covuni     = I$mapuni %>% list.edit(list(weight = 12))
I$stauni     = I$covuni

I$tra        = list(type = 'plotlyOutput', width = '100%', height = '850px', cloth = notecloth)
I$sta        = list(type = 'box', icon = 'comment-o', offset = 0.5, weight = 12, status = 'success', solidHeader = T, layout = c('stabar', 'stabox'))
I$stabar     = list(type = 'plotlyOutput', width = '100%', height = '425px', cloth = notecloth)
I$stabox     = list(type = 'plotlyOutput', width = '100%', height = '425px', cloth = notecloth)

#I$sunmin     = list(type = 'sliderInput', title = 'Exclude traces with frequencies less than', value = 5, min = 1, max = x_object$get.traces() %>% pull('freq') %>% max, step = 1)

I$cov        = list(type = 'dataTableOutput', title = 'Table of Cases', width = '100%', height = '850px', cloth = notecloth)

I$nxtpie     = list(type = 'billboarderOutput', title = 'Next Status Distribution', height = '350px', cloth = colcloth)
I$prvpie     = list(type = 'billboarderOutput', title = 'Previous Status Distribution', height = '350px', cloth = colcloth)
I$getper     = list(type = 'radioButtons', title = '', choices = c('Daily', 'Hourly'), selected = 'Daily', inline = T)
I$getcum     = list(type = 'checkboxInput', title = 'Cumulative', value = T, inline = T)
I$volumes    = list(type = 'dygraphOutput', title = 'Volume Trend')
I$shinyjs    = list(type = 'static', object = useShinyjs())
I$msg        = list(type = 'uiOutput', cloth = notecloth, service = "sync$message")
I$line       = list(type = 'static', object = hr(id = 'line'))
I$caret      = list(type = 'static', object = br())
I$cocinfo    = list(type = 'uiOutput', title = 'Filtered Cases '   , cloth = metricloth %>% list.edit(icon = 'filter'), weight = 3)
I$cmpinfo    = list(type = 'uiOutput', title = 'Completed Cases '  , cloth = metricloth, weight = 3)
I$cotinfo    = list(type = 'uiOutput', title = 'Process Variations '  , cloth = metricloth  %>% list.edit(icon = 'project-diagram'), weight = 3)
I$durinfo    = list(type = 'uiOutput', title = 'Average Process Time ', cloth = metricloth %>% list.edit(icon = 'clock'), weight = 3)
I$lpsinfo    = list(type = 'uiOutput', title = 'Average Loops ', cloth = metricloth %>% list.edit(icon = 'undo'), weight = 3)
I$trninfo    = list(type = 'uiOutput', title = 'Average Transitions ', cloth = metricloth %>% list.edit(icon = 'arrows-alt-h'), weight = 3)

# I$lrg   = list(type = 'c3Output', service = "plot.status.gauge(statusID = input$getst)")
# I$crg   = list(type = 'c3Output', service = "plot.status.gauge(statusID = input$getst)")
I$getpmtype = list(type = 'selectInput', choices = c("absolute", "relative", "relative_antecedent", "relative_consequent"), selected = 1)

## Charts:

# B = "if(!is.null(input$selst)){updateSelectInput(session, 'getst', selected = input$selst)}"
# B = "if(!is.null(input$selst)){cat(input$selst)} else {cat('I am NULL!')}"
B <- paste(prescript, "isolate({updateSelectInput(session, 'getst', choices = getStatusesWithName(session$userData$pm, stmap), selected = chif(input$getst %in% session$userData$pm$get.statuses(), input$getst, session$userData$pm$get.statuses() %>% first))})", sep = ";")


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
I$map$service = "plot.process.map(measure = input$mapmea, time_unit = input$mapuni, config = list(shinyInput.click = 'selst'))"
I$san$service = "plot.process.sankey()"
I$tra$service = "plot.traces.bar(measure = input$tramea, time_unit = input$trauni, aggregator = 'mean')"
I$stabar$service = "plot.statuses.bar()"
I$stabox$service = "plot.statuses.box(time_unit = input$stauni)"
I$cov$service = "plot.cases.table(time_unit = input$covuni)"
# I$tre$service = "plot.process.tree()"

I$mapmea$service = "if(input$mapmea == 'freq'){dash$disableItems('mapuni')} else {dash$enableItems('mapuni')}"
I$tramea$service = "if(input$tramea == 'freq'){dash$disableItems('trauni')} else {dash$enableItems('trauni')}"

I$load$service    = paste("sync$message  = ''",
                          "dash$disableItems('load', 'saveObj', 'readObj')",
                          "session$userData$pm = try(getProcessModel(input$getprocess, input$getdates[1], input$getdates[2]), silent = T)",
                          "if(inherits(session$userData$pm, 'TRANSYS')){",
                          "   x <- session$userData$pm", showObjFiltersScript,
                          "   sync$trigger = sync$trigger + 1}",
                          "else {sync$message = session$userData$pm %>% as.character}",
                          "dash$enableItems('load', 'saveObj', 'readObj')",
                          , sep = "\n")

I$apply$service   = paste("sync$message  = ''",
                          "if(inherits(session$userData$pm, 'TRANSYS')){",
                          "  session$userData$pm$filter.cases(complete = chif(input$comp == 'all', NULL, input$comp == 'Complete'), minLoops = input$lpsrang[1], maxLoops = input$lpsrang[2], statusDomain = chif(input$stsdmn == 'all', NULL, input$stsdmn), startStatuses = chif(input$strsta == 'all', NULL, input$strsta), endStatuses = chif(input$endsta == 'all', NULL, input$endsta), freqThreshold = input$freqthr)",
                          "  sync$trigger = sync$trigger + 1",
                          "  sync$message  = session$userData$pm %>% summary",  
                          "}", sep = "\n")

I$reset$service   = paste("if(inherits(session$userData$pm, 'TRANSYS')){",
                          "  session$userData$pm$filter.reset()", 
                          "  x <- session$userData$pm", showObjFiltersScript,
                          "  sync$trigger = sync$trigger + 1",
                          "}", sep = "\n")

I$cocinfo$service = "get.metric('freq')"
I$cmpinfo$service = "get.metric('totComp') %>% paste0(' (', 100*session$userData$pm$get.metric('avgComp'), '%)')"
I$cotinfo$service = "get.cases.path() %>% pull(path) %>% unique %>% length"
I$durinfo$service = "get.metric(measure = 'avgTT', time_unit = 'day') %>% paste('(days)')"
I$lpsinfo$service = "get.metric(measure = 'avgLoops')"
I$trninfo$service = "get.metric(measure = 'avgTrans')"

I$nxtpie$service  = "plot.status.next.pie(statusID = input$getst, trim = 0.01, plotter = 'billboarder')"
I$prvpie$service  = "plot.status.prev.pie(statusID = input$getst, trim = 0.01, plotter = 'billboarder')"

I$volumes$service = "get.status.volumes(status = input$getst, period = tolower(input$getper))$plot.history(figures = chif(input$getcum, c('Total Entry' = 'volumeInCum', 'Total Exit' = 'volumeOutCum'), c('Entry' = 'volumeIn', 'Exit' = 'volumeOut')), plotter = 'dygraphs', config = list(title = 'Volume Trend'))"

# I$stcard$service = "plot.cases.status.pie(trim = 0.01)"
for(i in c('sun', 'map', 'san', 'tra', 'stabar','stabox', 'cov', 'cocinfo', 'cmpinfo', 'cotinfo', 'durinfo', 'lpsinfo', 'trninfo', 'stcard', 'nxtpie', 'prvpie', 'volumes')){
  actstr = chif(i %in% c('cocinfo', 'cmpinfo', 'cotinfo', 'durinfo', 'lpsinfo', 'trninfo', 'volumes'), "$", " %>% ")
  I[[i]]$service = paste0("if(!is.null(session$userData$pm)){cat('Redrawing ", chif(is.null(I[[i]]$title), i, I[[i]]$title), " ... \n'); session$userData$pm", actstr, I[[i]]$service, "}")
  I[[i]]$service = paste(prescript, I[[i]]$service, sep = "\n")
}




######### Build Dashboard: #########
dash   <- new('DASHBOARD', items = I, king.layout = list('main'), observers = B, objects = list(pm = x_object), values = list(trigger = 0, message = x_object %>% summary))
ui     <- dash$dashboard.ui()
server <- dash$dashboard.server()
app    <- shinyApp(ui, server)

######### Run: #########

# runApp(app)
# runApp(app, host = "0.0.0.0", port = 80)

# Get clicked node as shiny input in sankey chart by networkD3:
# https://stackoverflow.com/questions/48454297/return-node-name-in-a-networkd3-sankey-chart-r-shiny





### global.R ---------------------

library(magrittr)
library(dplyr)
library(shiny)
library(shinydashboard)
library(shinythemes)
library(shinyjs)

library(niragen)
library(niraprom)
library(nirats)
library(niravis)

mode = 'ODBC'

if (mode == 'JDBC') {
  source('script/dna_app/iotools_JDBC.R')
} else if (mode == 'SODEV') {
  source('script/dna_app/iotools_SODEV.R')
} else {
  source('script/dna_app/iotools.R')
}

proctypes = getAllProcessTypes()
stmap     = getAllStatuses()

source('script/dna_app/dash.R')

# timeUnitCoeff = c(hour = 3600, second = 1, minute = 60, day = 24*3600, week = 7*24*3600, year = 24*3600*365)
# proctypes = getAllProcessTypes(uid = 'SUOPSANA01', pwd = 'Service#15Connect')

# x %>% saveRDS('object.rds')

# Regenerate x:
# y = readRDS('object.rds')
# x = new('TRANSYS', start = y$modelStart, end = y$modelEnd)
# x$feedStatusHistory(y$history, caseStartFlag_col = 'caseStart', caseEndFlag_col = 'caseEnd', add_start = F)

# todos:

# - tab process Overview -> left side --> Status frequency(bar chart) Done!
# - tab case overview -> table of cases (DT) Done!
# - tab process Overview -> left side --> Status time(box chart) Done!
# - let user select between time/frequency in process map/trace bar Done!
# - include exit-nulled  transitions to the data base (remove filter END_S is not null) Done!
# - apply date range filter to both entry and exit time with OR combination/add date range to the TRANSYS and limit all volume time series to that Done! test required
# - run query to get backlog at the start time
# - case start/case end circles are too big in the process map
# - icons of the metricbox
# - frequency/time on the edges of the process map + tooltips for nodes
# - pier or other plotters for pre/next or plotly without legend
# - DT table settings: entries in page change from 10 to match the height/ time -unit/ add path
# - manage message text
# - Full name of statuses and processes
# - add statuses volume area to the menu (Bottlenecks)
# - tab process Overview -> status card -> status to case ratio (Gauge)
# - let user select between zoomable/regular sunburst in process dna
# - tab process overview -> trace bar (stack bar)
# - bar tooltips 
# - tab case overview -> ... -> timeline view (timevis) shows all activity instances in a time line (y axis can be team or employee)
# - metric box -> relative_antecedent (heatmap) switch to: relative_consequent, frequency, 





# cbacran = 'https://artifactory.ai.cba/artifactory/cran-cba/2018-01-05/'
# noncbacran = 'https://artifactory.ai.cba/artifactory/mran-remote/2018-01-12/'
# 
# install.packages("RJDBC", repos = noncbacran)
# install.packages("rJava", repos = noncbacran)
# install.packages("progress", repos = noncbacran)
# install.packages("getPass", repos = noncbacran)
# 
# install.packages("teradata.cba", repos = cbacran)
# install.packages("dbplyr", repos = noncbacran)
# install.packages("dplyr", repos = noncbacran)
# 
# library(dplyr)
# library(dbplyr)
# library(teradata.cba)
# # https://confluence.prod.cba/display/ADS/Dplyr+and+teradata.cba

# Connecting via teradata.cba:
# library(dplyr)
# library(dbplyr)
# library(teradata.cba)
# 
# con = gdw_connect(uid = 'SUOPSANA01', pwd = 'Service#15Connect', local = T)
# his = tbl(con, "APPT_STUS_HIST")
# 
# his %>% group_by()



# To publish via rs connect:
# url_connect_server <- 'https://connect.aiaa.ai.cba'
# addConnectServer(url_connect_server, 'aiaa-rstudio-connect')
# connectUser(server='aiaa-rstudio-connect')


### iotools.R ---------------------
# Queries in this module all require access to PVDATA.APPT_STUS_HIST

# query.0 = "drop table UDRBSCMS.TMPA;"
# runSQL(query.0, dsn = 'TERADATA_PROD')
# query.1 = "create table UDRBSCMS.TMPA as (SELECT APPT_I, min(STRT_S) as CASE_START_S , max(END_S) as CASE_END_S from PVDATA.APPT_STUS_HIST group by APPT_I) with DATA;"
# # query.2 Read from APPT_STUS_HIST and join case start and case end time-stamps :
# runSQL(query.1, dsn = 'TERADATA_PROD')
# query.2 = "SELECT PVDATA.APPT_STUS_HIST.APPT_I, STUS_C, STRT_S, CASE_START_S, CASE_END_S, APPT_QLFY_C from PVDATA.APPT_STUS_HIST left join UDRBSCMS.TMPA on PVDATA.APPT_STUS_HIST.APPT_I = UDRBSCMS.TMPA.APPT_I left join PVDATA.APPT on PVDATA.APPT_STUS_HIST.APPT_I = PVDATA.APPT.APPT_I WHERE STRT_S > '2017-02-01 00:00:00' AND STRT_S < '2017-02-05 00:00:00' AND CASE_END_S is not null AND APPT_QLFY_C = 'HL'"
# t1 = Sys.time()
# D = runSQL(query.2, dsn = 'TERADATA_PROD')
# t2 = Sys.time()

library(RODBC)

# STD = runSQL("select * from pvdata.TYPE_STUS_CURR", dsn = 'Teradata_Prod')
# STD %>% dplyr::select(STUS_C, STUS_X) %>% write.csv('statusDecode.csv')


# Get all process types:
getAllProcessTypes = function(dsn = 'Teradata_Prod', ...){
  qry = "select APPT_QLFY_C as processType from PVDATA.APPT group by APPT_QLFY_C order by APPT_QLFY_C"
  channel    = odbcConnect(dsn = dsn, ...)
  D = sqlQuery(channel = channel, query = qry)
  close(channel)
  return(D$processType %>% na.omit %>% as.character) 
}

getAllStatuses = function(dsn = 'Teradata_Prod', ...){
  # Get and save status decode table:
  qry     = "select * from pvdata.TYPE_STUS_CURR"
  channel = odbcConnect(dsn = dsn, ...)
  STD = sqlQuery(channel = channel, query = qry)
  close(channel)
  
  if(inherits(STD, 'data.frame')){
    STD %<>% distinct(STUS_C, .keep_all = T)
    sts = STD$STUS_X %>% as.character
    names(sts) <- STD$STUS_C
    return(sts)
  } else {return(STD %>% as.character)}
} 
getEventLog = function(processType, fromDate, untilDate, dsn = 'Teradata_Prod', ...){
  cat('\n', 'Loading data from GDW ...')
  flt = list(APPT_QLFY_C = list(domain = processType %>% verify('character', lengths = 1, null_allowed = F)),
             STRT_S      = list(min = fromDate, max = untilDate, type = 'time'))
  
  # query.0 = "drop table UDRBSCMS.TMPA;"
  # runSQL(query.0, dsn = 'TERADATA_PROD')
  # query.1 = "create table UDRBSCMS.TMPA as (SELECT APPT_I, min(STRT_S) as CASE_START_S , max(END_S) as CASE_END_S from PVDATA.APPT_STUS_HIST group by APPT_I) with DATA;"
  # query.2 Read from APPT_STUS_HIST and join case start and case end time-stamps :
  # runSQL(query.1, dsn = 'TERADATA_PROD')
  query.2 = "SELECT PVDATA.APPT_STUS_HIST.APPT_I as caseID, STUS_C as status, STRT_S as startTime, CASE_START_S as caseStartTime, CASE_END_S as caseEndTime, APPT_QLFY_C as processType from PVDATA.APPT_STUS_HIST left join UDRBSCMS.TMPA on PVDATA.APPT_STUS_HIST.APPT_I = UDRBSCMS.TMPA.APPT_I left join PVDATA.APPT on PVDATA.APPT_STUS_HIST.APPT_I = PVDATA.APPT.APPT_I"
  
  scr = character()
  for(i in names(flt)){scr = c(scr, sqlFilter(i, flt[[i]]))} 
  scr %<>% paste(collapse = ' AND ')
  
  query.2 <- query.2 %++% ' WHERE ' %++% scr %++% ' AND CASE_END_S is not null'
  
  runSQL(query.2, dsn = 'TERADATA_PROD', ...)
}

getProcessModel = function(processType, fromDate, untilDate){
  t1 = as.time(fromDate)
  t2 = as.time(untilDate)
  EL = getEventLog(processType, fromDate  = t1, untilDate = t2) %>% arrange(caseID, status, startTime)
  
  EL$caseStartFlag = EL$caseStartTime >= t1
  EL$caseEndFlag   = EL$caseEndTime   <= t2
  
  cat('\n', 'Preparing event log for the model ...')
  
  x = new('TRANSYS')
  if(is.empty(EL)){cat('Warning from getProcessModel(): Empty eventlog passed, empty model issued!', '\n')} else {
    x$feedStatusHistory(EL, caseID_col = 'caseID', status_col = 'status', startTime_col = 'startTime', caseStartFlag_col = 'caseStartFlag', caseEndFlag_col = 'caseEndFlag')
    x$filter.cases(freqThreshold = 0.99)
  }
  
  cat('Done!', '\n')
  return(x)
}

getStatusesWithName = function(obj, stmap, include_all = F, full = F){
  sts = obj$get.statuses(full = full) %^% names(stmap)
  if(include_all){
    sts = c('all', sts)
    stmap['all'] <- 'All Statuses'
  }
  if(is.empty(sts)){return(sts)}
  names(sts) = sts %>% paste0(" (", stmap[sts], ")")
  return(sts)
}

### iotools_JDBC.R ---------------------
# Queries in this module all require access to PVDATA.APPT_STUS_HIST

# STD = runSQL_JDBC("select * from pvdata.TYPE_STUS_CURR")
# STD %>% dplyr::select(STUS_C, STUS_X) %>% write.csv('statusDecode.csv')

runSQL_JDBC <- function(query, uid = 'SUOPSANA01', pwd = 'Service#15Connect', local = T){
  channel    = teradata.cba::gdw_connect(uid = uid, pwd = pwd, local = local)
  D          = teradata.cba::run_sql_query(channel, query = query, lower_colnames = FALSE)
  teradata.cba::gdw_disconnect(channel)
  return(D)
}

# Get all process types:
getAllProcessTypes = function(uid = 'SUOPSANA01', pwd = 'Service#15Connect', local = T){
  channel  = teradata.cba::gdw_connect(uid = uid, pwd = pwd, local = local)
  qry      = "sel APPT_QLFY_C as processType from PVDATA.APPT group by APPT_QLFY_C order by APPT_QLFY_C"
  D        = teradata.cba::run_sql_query(channel, qry, lower_colnames = FALSE)
  return(D$processType %>% na.omit %>% as.character) 
}

getAllStatuses = function(uid = 'SUOPSANA01', pwd = 'Service#15Connect', local = T){
  # Get and save status decode table:
  STD = runSQL_JDBC("select * from pvdata.TYPE_STUS_CURR", uid = uid, pwd = pwd)
  if(inherits(STD, 'data.frame')){
    STD %<>% distinct(STUS_C, .keep_all = T)
    sts = STD$STUS_X %>% as.character
    names(sts) <- STD$STUS_C
    return(sts)
  } else {return(STD %>% as.character)}
} 

# getAllStatuses = function(uid = 'SUOPSANA01', pwd = 'Service#15Connect', local = T){
#   channel  = teradata.cba::gdw_connect(uid = uid, pwd = pwd, local = local)
#   qry      = "select * from pvdata.TYPE_STUS_CURR"
#   D        = teradata.cba::run_sql_query(channel, qry, lower_colnames = FALSE) %>% na.omit
#   stmap    = D$STUS_X
#   names(stmap) <- D$STUS_C
#   
#   return(stmap) 
# }


getStatusesWithName = function(obj, stmap, include_all = F, full = F){
  sts = obj$get.statuses(full = full) %^% names(stmap)
  if(include_all){
    sts = c('all', sts)
    stmap['all'] <- 'All Statuses'
  }
  if(is.empty(sts)){return(sts)}
  names(sts) = sts %>% paste0(" (", stmap[sts], ")")
  return(sts)
}

getEventLog = function(processType, fromDate, untilDate, dsn = 'Teradata_Prod', ...){
  cat('\n', 'Loading data from GDW ...')
  flt = list(APPT_QLFY_C = list(domain = processType %>% verify('character', lengths = 1, null_allowed = F)),
             STRT_S      = list(min = fromDate, max = untilDate, type = 'time'),
             END_S       = list(min = fromDate, max = untilDate, type = 'time'))
  
  # query.0 = "drop table UDRBSCMS.TMPA;"
  # runSQL(query.0, dsn = 'TERADATA_PROD')
  # query.1 = "create table UDRBSCMS.TMPA as (SELECT APPT_I, min(STRT_S) as CASE_START_S , max(END_S) as CASE_END_S from PVDATA.APPT_STUS_HIST group by APPT_I) with DATA;"
  # query.2 Read from APPT_STUS_HIST and join case start and case end time-stamps :
  # runSQL(query.1, dsn = 'TERADATA_PROD')
  query.2 = "SELECT PVDATA.APPT_STUS_HIST.APPT_I as caseID, STUS_C as status, STRT_S as startTime, CASE_START_S as caseStartTime, CASE_END_S as caseEndTime, APPT_QLFY_C as processType from PVDATA.APPT_STUS_HIST left join UDRBSCMS.TMPA on PVDATA.APPT_STUS_HIST.APPT_I = UDRBSCMS.TMPA.APPT_I left join PVDATA.APPT on PVDATA.APPT_STUS_HIST.APPT_I = PVDATA.APPT.APPT_I"
  
  scr = sqlFilter('APPT_QLFY_C', flt[['APPT_QLFY_C']]) %++% ' AND ((' %++% 
    sqlFilter('STRT_S', flt[['STRT_S']]) %++% ') OR (' %++% sqlFilter('END_S', flt[['END_S']]) %++% '))'
  
  # scr = character()
  # for(i in names(flt)){scr = c(scr, sqlFilter(i, flt[[i]]))} 
  # scr %<>% paste(collapse = ' AND ')
  
  query.2 <- query.2 %++% ' WHERE ' %++% scr
  
  runSQL_JDBC(query.2, ...)
}

getProcessModel = function(processType, fromDate, untilDate, ...){
  t1 = as.time(fromDate)
  t2 = as.time(untilDate)
  EL = getEventLog(processType, fromDate  = t1, untilDate = t2, ...) %>% arrange(caseID, status, startTime)
  
  EL$caseStartFlag = EL$caseStartTime  >= t1
  EL$caseStartFlag[is.na(EL$caseStartFlag)] <- F
  EL$caseEndFlag   = EL$caseEndTime    <= t2
  EL$caseEndFlag[is.na(EL$caseEndFlag)] <- F
  
  EL$status[which(is.na(EL$status))]   <- 'UNKWN'
  
  # EL[EL$status %in% names(stmap), 'status'] <- stmap[EL[EL$status %in% names(stmap), 'status']]
  
  cat('\n', 'Preparing event log for the model ...')
  
  x = new('TRANSYS', start = t1, end = t2)
  if(is.empty(EL)){cat('Warning from getProcessModel(): Empty eventlog passed, empty model issued!', '\n')} else {
    x$feedStatusHistory(EL, caseID_col = 'caseID', status_col = 'status', startTime_col = 'startTime', caseStartFlag_col = 'caseStartFlag', caseEndFlag_col = 'caseEndFlag')
    x$filter.cases(freqThreshold = 0.99)
  }
  
  cat('Done!', '\n')
  return(x)
}

applyFilter = function(obj, complete = NULL, ...){
  obj$filter.case(complete = chif(complete == 'All', NULL, complete == 'Complete'), ...)
}


### iotools_SODEV.R ---------------------
# Queries in this module all require access to staging.APPT_STUS_HIST


# Get and save status decode table:


getChannel = function(uid = 'rshinyuser', pwd = 'smart1Optimiser2'){
  server     <- 's029npcw9515.s4.chp.cba'
  database   <- 'SODEV'
  odbcDriver <- '{ODBC Driver 13 for SQL Server}'
  
  connString <- paste0('Driver=',odbcDriver,'; Trusted_Connection=No; SERVER=', server, '; DATABASE=', database, '; UID=', uid, '; PWD=', pwd)
  odbcDriverConnect(connString)
}

# "select top 100 * from staging.appt_stus_hist"
runSQL_SODEV <- function(query, uid = 'rshinyuser', pwd = 'smart1Optimiser2'){
  channel    = getChannel(uid = uid, pwd = pwd)
  D          = sqlQuery(channel, query)
  odbcClose(channel)
  return(D)
}

# runSQL_SODEV("select top 100 * from staging.appt_stus_hist where APPT_I like 'CSEHL%'")
getAllProcessTypes = function(uid = 'rshinyuser', pwd = 'smart1Optimiser2'){
  qry = "select processType from staging.APPT_STUS_HIST group by processType order by processType"
  D   = runSQL_SODEV(qry, uid = uid, pwd = pwd)
  if(inherits(D, 'data.frame')){return(D$processType %>% na.omit %>% as.character)} else {return(D %>% as.character)}
}

getAllStatuses = function(){
  # Get and save status decode table:
  STD = read.csv('statusDecode.csv', as.is = T)
  if(inherits(STD, 'data.frame')){
    STD %<>% distinct(STUS_C, .keep_all = T)
    sts = STD$STUS_X %>% as.character
    names(sts) <- STD$STUS_C
    return(sts)
  } else {return(STD %>% as.character)}
} 

getEventLog = function(processType, fromDate, untilDate, dsn = 'Teradata_Prod', ...){
  cat('\n', 'Loading data from GDW ...')
  flt = list(processType = list(domain = processType %>% verify('character', lengths = 1, null_allowed = F)),
             startTime   = list(min = fromDate, max = untilDate, type = 'time'),
             endTime     = list(min = fromDate, max = untilDate, type = 'time'))
  
  query = "SELECT * from staging.APPT_STUS_HIST"
  
  scr = sqlFilter('processType', flt[['processType']]) %++% ' AND ((' %++% 
    sqlFilter('startTime', flt[['startTime']]) %++% ') OR (' %++% sqlFilter('endTime', flt[['endTime']]) %++% '))'
  
  query <- query %++% ' WHERE ' %++% scr
  
  D = runSQL_SODEV(query, ...)
  if(inherits(D, 'data.frame')){return(D)} else {return(D %>% as.character %>% paste(collapse = ' '))}
}

getProcessModel = function(processType, fromDate, untilDate, ...){
  t1 = as.time(fromDate)
  t2 = as.time(untilDate)
  EL = getEventLog(processType, fromDate  = t1, untilDate = t2, ...)
  
  assert(inherits(EL, c('data.frame', 'tibble', 'data.table')), as.character(EL))
  
  EL %<>% arrange(caseID, status, startTime)
  
  for(col in c('caseID', 'status', 'processType')){EL[, col] %<>% as.character}
  
  EL$caseStartFlag = EL$caseStartTime  >= t1
  EL$caseStartFlag[is.na(EL$caseStartFlag)] <- F
  EL$caseEndFlag   = EL$caseEndTime    <= t2
  EL$caseEndFlag[is.na(EL$caseEndFlag)] <- F
  
  EL$status[which(is.na(EL$status))]   <- 'UNKWN'
  
  # EL[EL$status %in% names(stmap), 'status'] <- stmap[EL[EL$status %in% names(stmap), 'status']]
  
  cat('\n', 'Preparing event log for the model ...')
  
  x = new('TRANSYS', start = t1, end = t2)
  if(is.empty(EL)){cat('Warning from getProcessModel(): Empty eventlog passed, empty model issued!', '\n')} else {
    x$feedStatusHistory(EL, caseID_col = 'caseID', status_col = 'status', startTime_col = 'startTime', caseStartFlag_col = 'caseStartFlag', caseEndFlag_col = 'caseEndFlag')
    x$filter.cases(freqThreshold = 0.99)
  }
  
  cat('Done!', '\n')
  return(x)
}

getStatusesWithName = function(obj, stmap, include_all = F, full = F){
  sts = obj$get.statuses(full = full) %^% names(stmap)
  if(include_all){
    sts = c('all', sts)
    stmap['all'] <- 'All Statuses'
  }
  if(is.empty(sts)){return(sts)}
  names(sts) = sts %>% paste0(" (", stmap[sts], ")")
  return(sts)
}



####### Folder gowims_app ========================

### dash.R ----------------
# Header
# Filename:       dash.R
# Description:    This file creates shiny UI for the Smart Process Optimiser project. 
# Author:         Nima Ramezani Taghiabadi
# Email:          nima.ramezani@cba.com.au
# Start Date:     30 May 2018
# Last Revision:  18 July 2018
# Version:        1.0.2

# Version History:

# Version   Date              Action
# ___________________________________________
# 1.0.0     30 May 2018       Initial Issue
# 1.0.2     18 July 2018      activity frequency charts and precedence matrix charts added

prescript    = "if(is.null(sync$trigger)){sync$trigger = 0}"

I = list()
O = list()

######### Clothes: #########

noteCloth  = list(type = 'box' , icon = 'comment-o', offset = 0.5, weight = 12, status = 'success', solidHeader = T)


######### Main items: #########

I$main       = list(type = 'dashboardPage', layout.head = c(), layout.side = c('getprocess', 'getteams', 'getskills', 'getdates', 'load', 'line', 'getthr', 'saveobj', 'readobj'), sidebar.width = 300, layout.body = c('shinyjs', 'nvp'))

# div(HTML('<img src=\"can.png\" height=\"40\" > &nbsp;'), 'CBA Smart Process Optimiser v 1.0.0')
I$nvp        = list(type = 'navbarPage', title = 'CBA Smart Process Optimiser v 1.0.0', 
                    theme  = shinytheme("flatly"), 
                    layout = c('MPTAB', 'SPTAB', 'APTAB'))

I$MPTAB   = list(type = 'tabPanel' , title = 'Process Map', layout = 'MPPage')
I$APTAB   = list(type = 'tabPanel' , title = 'Employees', layout = 'APPage')
I$SPTAB   = list(type = 'tabPanel' , title = 'Activities', layout = 'SPPage')

I$MPPage   = list(type = 'fluidPage', layout = c('msg', 'map'))
I$APPage   = list(type = 'fluidPage', layout = c())
I$SPPage   = list(type = 'fluidPage', layout = list(list('freqbar', list('precmat', 'getpmtype'))))

# I$describe   = list(type = 'static', object = 'Please choose Process Type from the list below. Process types are unique instances of EVNT_ACTV_TYPE_M1' %>% paste(br()))
I$getprocess = list(type = 'selectInput', title = 'Select Process', choices = proctypes)
I$getteams   = list(type = 'selectInput', title = 'Select Teams', choices = c('All teams'), multiple = T)
I$getskills  = list(type = 'selectInput', title = 'Select Activity Types', choices = c('All activity types'), multiple = T)
I$getdates   = list(type = 'dateRangeInput', title = 'Select Date Range')
I$getthr     = list(type = 'sliderInput', title = 'Frequency Threshold', min = 0, max = 1.0, value = 1.0, step = 0.1, service = "if(!inherits(session$userData$pm, 'try-error') & !is.null(session$userData$pm)){session$userData$pm %<>% filter_activity_frequency(percentage = input$getthr);sync$trigger = sync$trigger + 1}")
I$saveobj    = list(type = 'actionButton', title = 'Save Object', service = "if(inherits(session$userData$pm, 'eventlog')){session$userData$pm %>% saveRDS('object.rds')}")
I$readobj    = list(type = 'actionButton', title = 'Read Object', service = "session$userData$pm <- readRDS('object.rds'); sync$trigger = sync$trigger + 1")

I$load       = list(type = 'actionButton', title = 'Load Data', service = "session$userData$pm = try(getProcessModel(input$getprocess, input$getteams, input$getskills, input$getdates[1], input$getdates[2]), silent = T); if(!inherits(session$userData$pm, 'try-error') & !is.null(session$userData$pm)){sync$trigger = sync$trigger + 1} else {sync$message = session$userData$pm %>% as.character}")
I$map        = list(type = 'DiagrammeROutput', height = '80vh', service = paste(prescript, "if(!is.null(session$userData$pm)){session$userData$pm %>% process_map()}", sep = "\n"))
I$shinyjs    = list(type = 'static', object = useShinyjs())
I$msg        = list(type = 'uiOutput', cloth = noteCloth, service = "sync$message")
I$line       = list(type = 'static', object = hr(id = 'line'))

I$getpmtype  = list(type = 'selectInput', choices = c("absolute", "relative", "relative_antecedent", "relative_consequent"), selected = 1)

## Charts:
I$freqbar = list(type = 'plotOutput', service = paste(prescript, "if(inherits(session$userData$pm, 'eventlog')){session$userData$pm %>% resource_frequency(level = 'activity') %>% plot}", sep = "\n"))
I$precmat = list(type = 'plotOutput', service = paste(prescript, "if(inherits(session$userData$pm, 'eventlog')){session$userData$pm %>% precedence_matrix(type = input$getpmtype) %>% plot}", sep = "\n"))

I$getprocess$service = "
updateSelectInput(session, 'getteams' , choices = c('All teams', getAllTeams(input$getprocess)))
updateSelectInput(session, 'getskills', choices = c('All activity types', getActivityTypes(input$getprocess, input$getteams)))
"

I$getteam$service = "
updateSelectInput(session, 'getskills', choices = c('All activity types', getActivityTypes(input$getprocess, input$getteams)))
"


# I$map$service = "obj %>% plot.process(plotter = 'DiagrammeR')"

B = "cat(is.null(input$nima), input$nima, '\n')"
######### Build Dashboard: #########
dash   <- new('DASHBOARD', items = I, king.layout = list('main'), observers = B, objects = list(pm = readRDS('object.rds')), values = list(trigger = 0))
ui     <- dash$dashboard.ui()
server <- dash$dashboard.server()
shinyApp(ui, server)

######### Run: #########

# runApp(app)
# runApp(app, host = "0.0.0.0", port = 8080)

# Get clicked node as shiny input in sankey chart by networkD3:
# https://stackoverflow.com/questions/48454297/return-node-name-in-a-networkd3-sankey-chart-r-shiny

### global.R ----------------
library(RODBC)
library(magrittr)
library(dplyr)
library(shiny)
library(shinythemes)
library(shinyjs)
library(bupaR)
library(edeaR)


library(magrittr)
library(dplyr)
library(RODBC)
library(shiny)
library(shinyjs)
library(shinythemes)
library(niragen)
library(niraprom)
library(niravis)

source('script/gowims_app/pmAppTools.R')

proctypes = getAllProcessTypes()

source('script/gowims_app/dash.R')


# 
# x = getProcessModel("HL Application Process", teams = NULL, skills = NULL, fromDate = '2018-11-01', untilDate = '2018-11-07')
# x %>% 



# todos:

# - main: add Navbar Tabs: Process map, case overview, task overview, employee overview, team overview, trace overview
# - tab process map: add process map metric box on top of map and message (modal?)
# - tab process map: add activity card for selected activity right side of the map (modal)
# - tab process map -> activity card -> Activity to case ratio (Gauge)
# - tab process map -> metric box --> Activity frequency(bar chart)
# - tab process map -> add transition card right side of the map (modal) 
# - tab case overview -> table of cases (DT) buttom row of the page
# - tab task overview -> table of tasks (DT) layout?
# - tab case overview -> case map (?) middle row of the page
# - tab process map -> activity card -> next activity distribution (pie or donut)
# - tab process map -> metric box -> relative_antecedent (heatmap) switch to: relative_consequent, frequency, 
# - tab trace explorer -> ... -> trace sunburst
# - tab case overview -> ... -> timeline view (timevis) shows all activity instances in a time line (y axis can be team or employee)
# - tab trace overview -> .. -> trace bar (stack bar, rbokeh mandeliof or a graph/network)
# - 

### pmAppTools.R ----------------
# Queries in this module all require access to UDRBSCMS.GO_WIMS. For PVDATA, we will write another module


# Get all process types:
getAllProcessTypes = function(dsn = 'Teradata_Prod', ...){
  qry = "sel evnt_actv_type_m1 as processType from UDRBSCMS.GO_WIMS group by evnt_actv_type_m1 order by evnt_actv_type_m1"
  channel    = odbcConnect(dsn = dsn, ...)
  D = sqlQuery(channel = channel, query = qry)
  close(channel)
  return(D$processType %>% na.omit %>% as.character) 
}

getAllTeams = function(processType, dsn = 'Teradata_Prod', ...){
  flt = list(evnt_actv_type_m1 = list(domain = processType %>% verify('character', lengths = 1, null_allowed = F)))
  fld = c(team = 'DEPT_LEAF_NODE_M')
  qry = sqlScript(tableName = 'GO_WIMS', fields = fld, filter = flt) %>% paste('group by DEPT_LEAF_NODE_M')
  channel = odbcConnect(dsn = dsn)
  TBL = sqlQuery(channel, query = qry)
  close(channel)
  return(TBL[,'team'] %>% as.character %>% na.omit)
}

getActivityTypes = function(processType, teams = NULL, dsn = 'Teradata_Prod', ...){
  if(is.null(teams)){teams = 'All teams'}
  flt = list(evnt_actv_type_m1 = list(domain = processType %>% verify('character', lengths = 1, null_allowed = F)))
  if(!('All teams' %in% teams)){
    teams = gsub("'", "''", teams %>% verify('character', null_allowed = F))
    flt$DEPT_LEAF_NODE_M = list(domain = teams)}
  fld = c(activityType = 'EVNT_ACTV_TYPE_M')
  qry = sqlScript(tableName = 'GO_WIMS', fields = fld, filter = flt) %>% paste('group by EVNT_ACTV_TYPE_M')
  channel = odbcConnect(dsn = dsn, ...)
  TBL = sqlQuery(channel, query = qry)
  close(channel)
  if(inherits(TBL, 'data.frame')){return(TBL[,'activityType'] %>% as.character %>% na.omit)} else
  {return(TBL %>% as.character)}
}


getTeams = function(processType, fromDate, untilDate, dsn = 'Teradata_Prod', ...){
  flt = list(evnt_actv_type_m1 = list(domain = processType %>% verify('character', lengths = 1, null_allowed = F)),
             Evnt_Start_DT     = list(min = fromDate, max = untilDate, type = 'time'))
  fld = c(team = 'DEPT_LEAF_NODE_M')
  qry = sqlScript(tableName = 'GO_WIMS', fields = fld, filter = flt) %>% paste('group by DEPT_LEAF_NODE_M')
  channel = odbcConnect(dsn = dsn, ...)
  TBL = sqlQuery(channel, query = qry)
  close(channel)
  return(TBL[,'team'] %>% as.character %>% na.omit)
}

getEventLog = function(processType, fromDate, untilDate, teams = NULL, skills = NULL, dsn = 'Teradata_Prod', ...){
  cat('\n', 'Loading data from GDW ...')
  if(is.null(teams)){teams = 'All teams'}
  if(is.null(skills)){skills = 'All activity types'}
  flt = list(evnt_actv_type_m1 = list(domain = processType %>% verify('character', lengths = 1, null_allowed = F)),
             Evnt_Start_DT     = list(min = fromDate, max = untilDate, type = 'time'),
             STUS_REAS_TYPE_C  = list(domain = 'COMT'))
  
  if(!('All teams' %in% teams)){
    teams = gsub("'", "''", teams %>% verify('character'))
    flt$DEPT_LEAF_NODE_M  = list(domain = teams)}
  if(!('All activity types' %in% skills)){
    skills = gsub("'", "''", skills %>% verify('character'))
    flt$EVNT_ACTV_TYPE_M  = list(domain = skills)}
  
  fld = c(caseID = 'EVNT_GRUP_I', taskType = 'EVNT_ACTV_TYPE_M', startTime = 'INIT_DT', compTime = 'Completed_DT', agent = 'EMPL_M', status = 'STUS_REAS_TYPE_C', team = 'DEPT_LEAF_NODE_M')
  qry = sqlScript(tableName = 'GO_WIMS', fields = fld, filter = flt)
  channel = odbcConnect(dsn = dsn, ...)
  TBL = sqlQuery(channel, query = qry)
  close(channel)
  assert(inherits(TBL, 'data.frame'), 'getEventLog Query ran with error!')
  cat('Done!', ' Loaded ', nrow(TBL), ' rows of data from GDW!', '\n')
  return(TBL)
}


getProcessModel = function(processType, teams = NULL, skills = NULL, fromDate, untilDate){
  EL = getEventLog(processType, teams = teams, skills = skills, fromDate  = fromDate, untilDate = untilDate) %>% 
    arrange(caseID, taskType, compTime)
  
  cat('\n', 'Preparing event log for the model ...')
  if(is.empty(EL)){cat('Warning from getProcessModel(): Empty eventlog passed, empty model issued!', '\n');return(NULL)}
  EL$taskID <- EL %>% nrow %>% sequence
  EL %<>% rename(complete = compTime, start = startTime) %>% tidyr::gather(status, timeStamp, start, complete)
  
  cat('Done!', '\n')
  cat('\n', 'Generating process map ...')
  support('bupaR')
  pr = bupaR::eventlog(eventlog = EL,
                       case_id = 'caseID',
                       activity_id = 'taskType',
                       activity_instance_id = 'taskID',
                       timestamp = 'timeStamp',
                       lifecycle_id = 'status',
                       resource_id = 'agent')
  cat('Done!', '\n')
  return(pr)
}



####### Folder PEGA ========================

### PEGATools.R ----------------------------
######## ---------------- #########
## This file contains the functions to process pega data
########### FUNCTIONS #############

## process data from raw excel dataset provided by PEGA team

readData = function(filename, type = 'excel'){
  if(identical(type, 'excel')){
    ## read everything from the file
    xlFile <- read_excel(path = filename)
    tbl <- data.frame(xlFile)  
  } else if(identical(type, 'csv')){
    tbl = read.csv(filename, as.is = T)
  } else {
    stop('type unknown')
  }
  return(tbl)
}

# Gets a VOC History file and returns a processed table which can be later converted to a standard event log
# Table contains important columns: 
# WORK_ID : task ID
# DATETIME: event time-stamp
# MESSAGE: refers to lifetime transition status
# PYPERFORMTASKTIME: task duration from which start time can be calculated
# PYPERFORMER: resource name
processRawPEGAData = function (raw_data)
{
  options(warn = -1)
  raw_data <- raw_data %>%
    tidyr::separate(PYMESSAGEKEY, c("PYMESSAGEKEY", "MESSAGE"), "]") %>% 
    tidyr::separate(PXHISTORYFORREFERENCE, c("PXHISTORYFORREFERENCE", "WORK_ID"), " ") %>% 
    tidyr::separate(PZINSKEY, c("PZINSKEY", "DATETIME"), "!") %>% 
    tidyr::separate(DATETIME, c("DATETIME", "TZ"), " ")  
  options(warn = 1)
  
  ## Select the columns that are required
  ## Split PYMESSAGEKEY by ], PXHISTORYFORREFERENCE by space and PZINSKEY by ! and space  -- MESSAGE , WORK_ID , DATETIME
  pega.data <- select(raw_data, taskID = WORK_ID, DATETIME, arrivalTime = PXTIMECREATED, completeTime = PXCOMMITDATETIME, status = MESSAGE, procTime = PYPERFORMTASKTIME, agent = PYPERFORMER)
  
  ## convert the dates from string to DateTime
  #pega.data$DATETIME <- parsedate::parse_iso_8601(pega.data$DATETIME) 
  #pega.data$DATETIME <- as.POSIXct(as.numeric(pega.data$DATETIME), origin='1970-01-01', tz="Australia/Sydney")
  
  #pega.data$completeTime %<>% parsedate::parse_iso_8601()
  #pega.data$completeTime <- as.POSIXct(as.numeric(pega.data$completeTime), origin='1970-01-01', tz="Australia/Sydney")
  
  ## filter takes 1 min but which takes 1 sec to do the same task
  ## filter data containing particular messages
  data <- pega.data[which(pega.data$status == "AssignmentCompleted		Close" 
                          | pega.data$status == "AssignmentCompleted		DetermineAction" 
                          | pega.data$status == "AssignmentRouted	VOC"
  ), ]
  return(data)
}


# This function extracts processing time for each task from the PEGA raw data. A shorter version of processRawPEGAData():
extractProcessTime = function (raw_data)
{
  options(warn = -1)
  raw_data <- raw_data %>%
    tidyr::separate(PYMESSAGEKEY, c("PYMESSAGEKEY", "MESSAGE"), "]") %>% 
    tidyr::separate(PXHISTORYFORREFERENCE, c("PXHISTORYFORREFERENCE", "WORK_ID"), " ") %>% 
    tidyr::separate(PZINSKEY, c("PZINSKEY", "DATETIME"), "!") %>% 
    tidyr::separate(DATETIME, c("DATETIME", "TZ"), " ")  
  options(warn = 1)
  
  pega.data <- select(raw_data, taskID = WORK_ID, status = MESSAGE, procTime = PYPERFORMTASKTIME, agent = PYPERFORMER)
  
  data <- pega.data[which(pega.data$status == "AssignmentCompleted		Close" 
                          | pega.data$status == "AssignmentCompleted		DetermineAction" 
                          | pega.data$status == "AssignmentRouted	VOC"
  ), ]
  return(data %>% select(taskID, agent, procTime))
}



## Get pega data between two specific dates

getDataByDate = function(data, fromDate, toDate)
{
  df<- data
  df <- filter(df, df$DATETIME >= fromDate & df$DATETIME <= toDate)
  
  return(df)
}

## Get processing time by aggreegation for each workid and employee

getProcessTime = function(df = data)
{
  df <- df[which(df$status == "AssignmentCompleted		Close" 
                 | df$status == "AssignmentCompleted		DetermineAction" 
  ), ]
  
  # Create a new column containing the sum of time taken to process the task in seconds
  ## aggreegation by work id and employee
  groupColumns = c("taskID","agent")
  dataColumns = c("procTime")
  df %<>% ddply(groupColumns, function(x) colSums(x[dataColumns]))
  
  return(df)
}


## Get data from GDW - not used currently

getPEGAHistoryData = function (fromDate, toDate)
{
  dsn = 'Teradata.user'
  channel  = odbcConnect(dsn = dsn)
  
  query <- sqlScript(tableName = 'BMO_PEGA_ESCALATIONS_K', filter = list(Is_VOC_Team = list(domain = 'Yes'), 
                                                                         CREATION_DATE_TIME = list(min = fromDate, max = toDate, type = 'time')))
  data <- sqlQuery(channel = channel, query = query)
  close(channel)
  
  write.csv(data, "historyData.csv")
  return(data)
}




## Get weekly data from GDW that is saved in excel every week for 3 weeks: does not contain process time or getnext call time

getPEGAWeeklyData = function()
{
  filename = "data/PEGA_VOC_HISTORY_29JAN.xlsx"
  ## read everything from the file
  xlFile <- read_excel(path = filename)
  weeklyData1 <- data.frame(xlFile)
  
  filename = "data/PEGA_VOC_HISTORY_9FEB.xlsx"
  xlFile <- read_excel(path = filename)
  weeklyData2 <- data.frame(xlFile)
  
  weeklyData.all <- rbind(weeklyData1, weeklyData2)
  
  filename = "data/PEGA_VOC_HISTORY_19FEB.xlsx"
  xlFile <- read_excel(path = filename)
  weeklyData3 <- data.frame(xlFile)
  
  weeklyData.all <- rbind(weeklyData.all, weeklyData3)
  
  #filename = "data/PEGA_VOC_HISTORY_26FEB.xlsx"
  #xlFile <- read_excel(path = filename)
  #weeklyData4 <- data.frame(xlFile)
  
  #weeklyData.all <- rbind(weeklyData.all, weeklyData4)
  #write.csv(weeklyData.all, "weeklyDate.csv")
  #test <- weeklyData.all$WORK_ID
  #duplicated(test)
  #test[duplicated(test)]
  
  weeklyData.all <-  select(weeklyData.all, WORK_ID, Urgency, DAY_CREATE_DATE_TIME, CREATE_DateTime, COMMIT_DateTime, 
                            CommitmentDateTime, EscalatedTo, IsVOCTeam, IsEscalation, AutoAssignedTeam, AutoTaggedSkill,
                            WORK_status, CaseTypeSkill, UPDATE_OPERATOR_NAME)
  
  weeklyData.all <- unique(weeklyData.all)
  return(weeklyData.all)
}


### processPEGAData.R ----------------------------
###################          
## This R code is used to process raw pega data and convert it to standard input for process modelling.
################### 

library(readxl)
library(RODBC)
library(reshape2)
library(dplyr)
library(tidyr)
library(plyr)
library(parsedate)
library(lubridate)
library(magrittr)
library(niragen)

source("script/PEGA/PEGATools.R")

# To process PEGA data, two main files are required:  raw history which contains all events and a work(task) data. 
# The task data contains taskIDs, resource names, arrival and completion times

# Location of PEGA Raw data (VOC History)
rawfile = 'script/PEGA/data/HISTORY_VOC.csv'

# Location of PEGA Raw data (VOC History)
taskfile = 'script/PEGA/data/Work_Final.csv'

# Read task data:
taskData = read.csv(taskfile, as.is = T)

# Extract required columns and change column names:
taskData %<>% 
  select(caseID = REFERENCEID, taskID = PXINSNAME, priority = PXURGENCYWORK, arrivalTime = PXCREATEDATETIME, completeTime = PXCOMMITDATETIME, 
         dueTime = COMMITMENTDATETIME, skill = CASETYPESKILL, agent = PXUPDATEOPNAME) %>% 
  filter(taskID != "", arrivalTime != "" & completeTime != "" & dueTime != "" & skill != "" & agent != "") %>% 
  mutate(arrivalTime = as.time(arrivalTime), completeTime = as.time(completeTime), dueTime = as.time(dueTime)) %>% 
  mutate(arrivalDate = as.Date(arrivalTime))

# head(taskDate)

# Read raw data (We read this file only to get task durations in order to find startTime):
raw      = readData(rawfile, type = 'csv') # Read Raw data

prt = extractProcessTime(raw)

# In table prt, we have duplicated rows for each taskID. aggregate by adding process times:
prt %<>% dplyr::group_by(taskID, agent) %>% dplyr::summarise(duration = sum(procTime))


# In table prt, we have still duplicated rows for each taskID, because one taskID has been touched by multiple agents. we inner join with task data. This removes agents which are not common in the two tables:
eventlog = taskData %>% dplyr::inner_join(prt, by = c('taskID', 'agent'))


# subtract duration from completion time to get to start time:
eventlog$startTime = eventlog$completeTime - eventlog$duration


# Make sure start time is not less than arrival time:
w = which(eventlog$startTime < eventlog$arrivalTime)
if (length(w) > 0){
  cat('Some tasks started before arrival!')
  eventlog$startTime[w] <- eventlog$arrivalTime[w] + 1
  eventlog$duration[w]  <- eventlog$completeTime[w] - eventlog$startTime[w]
}

# This is the file we can use for process modelling. Case IDs are still missing!
eventlog %>% write.csv('script/PEGA/data/PEGA_eventlog.csv', row.names = F)


### simcut.R ----------------------------
library(magrittr)
library(dplyr)

source('../../packages/master/niragen-master/R/niragen.R')

source('../../packages/master/niraprom-master/R/promtools.R')
source('../../packages/master/niraprom-master/R/prom.R')
source('../../packages/master/niraprom-master/R/prosim.R')


source('../../packages/master/niravis-master/R/visgen.R')
source('../../packages/master/niravis-master/R/jscripts.R')

source('../../packages/master/niravis-master/R/dygraphs.R')
source('../../packages/master/niravis-master/R/plotly.R')
source('../../packages/master/niravis-master/R/visNetwork.R')
source('../../packages/master/niravis-master/R/niraPlot.R')

t0 = as.time('2018-03-01 00:00:00')
t1 = as.time('2018-03-01 08:00:00')
t2 = as.time('2018-03-07 18:00:00')

# This program, runs a que simulation on actual task arrivals:

# Read eventlog:
eventlog = read.csv('script/PEGA/data/PEGA_eventlog.csv', as.is = T)

# Filter for positive durations!!!!:
eventlog %<>% filter(duration > 0)

agentSkill = eventlog %>% dplyr::group_by(agent, skill) %>% summarise(AUT = mean(duration, na.rm = T), Count = length(taskID))

# Filter for Count > 10:
agentSkill %<>% filter(Count > 10) %>% arrange(desc(Count))

# Pick top NAG agents
NAG = 10
agents = agentSkill$agent %>% unique %>% head(NAG)
# Pick all skills they have:
skills = agentSkill$skill[agentSkill$agent %in% agents] %>% unique

EL = eventlog %>% filter(skill %in% skills)
AS = agentSkill %>% filter(agent %in% agents, skill %in% skills)

EL$dueTime %<>% as.time 
EL$startTime %<>% as.time 
EL$arrivalTime %<>% as.time 
EL$completeTime %<>% as.time 


# 

tasklist <- EL %>% select(taskID, skill, agent, arrTime = arrivalTime, startTime, compTime = completeTime, dueTime) %>% arrange(arrTime) %>% column2Rownames('taskID', remove = F)
w = which(tasklist$startTime > t0)
tasklist$startTime[w]  <- NA
tasklist$compTime[w]   <- NA
tasklist$agent[w]      <- NA
tasklist$queue         <- NA

# Mean of rest time just after arrival(min) before the first getNext call: 
# How many minutes each agent spend after the first scheduled arrival time until calling the first getNext?
initWrapTime = rep(120, NAG)
names(initWrapTime) <- agents
initWrapRate = 1.0/initWrapTime

wrapTime = initWrapTime %>% rep(length(skills)) %>% unname %>% matrix(length(agents), length(skills), dimnames = list(agents, skills))
procTime = AS %>% reshape2::dcast(agent ~ skill, value.var = 'AUT') %>% column2Rownames('agent')

wrapRate = 1.0/wrapTime
procRate = 1.0/procTime

# Generate initial agent getNext call events:
calls = data.frame(callID = paste(agents, 1, sep = '.'), agent = agents, callTime = t1 + rexp(length(agents), rate = initWrapRate[agents]), compTime = NA, taskID = NA, skill = NA, stringsAsFactors = F) %>% column2Rownames('callID', remove = F)  


# settings$agentSkillAPT and settings$agentSkillAWT must be in minutes
settings = list(
  taskEventLog = list(taskID_col = 'taskID', skill_col = 'skill', agent_col = 'agent', priority_col = 'priority', arrivalTime_col = 'arrTime', startTime_col = 'startTime', completedTime_col = 'compTime'),
  callEvenLog  = list(callID_col = 'callID', agent_col = 'agent', taskID_col = 'taskID', skill_col = 'skill', callTime_col = 'callTime', startTime_col = 'startTime', completedTime_col = 'compTime'),
  agentSkillAPT = procTime/60,
  agentSkillAWT = wrapTime/60,
  minAPT        = 2,
  minAWT        = 2
)

tasklist$priority = (t1 - tasklist$dueTime) %>% as.numeric

asis.res = list(taskEventLog = tasklist, callEventLog = calls)

sq = seq(from = t1 %>% setTZ('GMT') %>% as.Date, to = t2 %>% setTZ('GMT') %>% as.Date, by = 1)
for(i in sequence(length(sq))){
  day = sq[i]
  cat('Today is: ', day %>% as.character, ': \n')
  time.begin = day %>% as.character %>% paste('08:00:00') %>% as.time
  time.end   = day %>% as.character %>% paste('18:00:00') %>% as.time
  cat('Running simulation from ', time.begin %>% as.character, ' until ', time.end %>% as.character, '\n')
  asis.res = simQueue(asis.res$taskEventLog, asis.res$callEventLog, from = time.begin, until = time.end, agents = agents, settings = settings)
}


vin.actual = EL %>% mutate(arrDate = arrivalTime %>% setTZ('GMT') %>% as.Date) %>% 
  group_by(arrDate) %>% dplyr::summarise(actual = length(taskID))

vin.sim = asis.res$taskEventLog %>% mutate(arrDate = arrTime %>% setTZ('GMT') %>% as.Date) %>% 
  group_by(arrDate) %>% dplyr::summarise(simulation = length(taskID))

vin = vin.actual %>% inner_join(vin.sim, by = 'arrDate')
#### Volume Out
vout.actual = EL %>% filter(agent %in% agents) %>% mutate(compDate = completeTime %>% setTZ('GMT') %>% as.Date) %>% 
  group_by(compDate) %>% dplyr::summarise(actual = length(taskID))

vout.sim = asis.res$taskEventLog %>%  filter(agent %in% agents) %>% mutate(compDate = compTime %>% setTZ('GMT') %>% as.Date) %>% 
  group_by(compDate) %>% dplyr::summarise(simulation = length(taskID))

vout = vout.actual %>% inner_join(vout.sim, by = 'compDate')

######## Using Smart Optimiser:
sq = seq(from = t1 %>% setTZ('GMT') %>% as.Date, to = t2 %>% setTZ('GMT') %>% as.Date, by = 1)
calls = data.frame(callID = character(), agent = character(), callTime = logical() %>% as.POSIXct, compTime = logical() %>% as.POSIXct, taskID = character(), skill = character(), stringsAsFactors = F)
for(i in sequence(length(sq))){
  day = sq[i]
  cat('Today is: ', day %>% as.character, ': \n')
  time.begin = day %>% as.character %>% paste('08:00:00') %>% as.time
  time.end   = day %>% as.character %>% paste('18:00:00') %>% as.time
  cat('Running simulation from ', time.begin %>% as.character, ' until ', time.end %>% as.character, '\n')
  # asis.res = simQueue(asis.res$taskEventLog, asis.res$callEventLog, from = time.begin, until = time.end, agents = agents, settings = settings)
  
  # # Allocate jobs from 8:00 am to 10:00 am:
  AA = data.frame(agent = agents, scheduled = 120)
  xb = OptimalTaskAllocator() %>% feedAgents(agents) %>% feedSkills(skills) %>% 
    feedAgentSchedule(AA, agentID_col = 'agent', scheduled_col = 'scheduled')
  xb$TAT[agents, skills] = settings$agentSkillAPT[agents, skills]
  xb$SP$score = 1
  
  current = time.begin
  while(current <  time.end) {
    cat('Allocation round from ', as.character(current), '\n')
    tasklist$priority = current - tasklist$arrTime
    tasks2ba  = tasklist[which(tasklist$arrTime < current & is.na(tasklist$compTime)),]
    tasks2ba$agent = tasks2ba$queue
    
    x <- xb %>% feedTasks(tasks2ba, skillID_col = 'skill', priority_col = 'priority', agentID_col = 'agent', extra_col = c('arrTime', 'startTime', 'compTime')) %>% 
      distributeTasks(fill_gap_time = FALSE)
    # generate task queues for each agent
    # Simulate single Queue:
    # Mark queue name for allocated tasks:
    allocated = x$TSK[!is.na(x$TSK$agent),]
    tasklist[rownames(allocated), 'queue'] = allocated$agent
    # Generate initial agent getNext call events:
    
    for (e in agents){
      cat('Simulating for agent: ', e, '...')
      st = settings
      st$agentSkillAPT = st$agentSkillAPT[e, , drop = F]
      st$agentSkillWPT = st$agentSkillAWT[e, , drop = F]
      
      res  = simQueue(tasklist[which(tasklist$queue == e),], calls[calls$agent == e, ], from = current, until = current + 3600*2, agents = e, settings = st, show_progress = F)
      cols = names(tasklist) %^% names(res$taskEventLog)
      
      completed = !is.na(res$taskEventLog$agent)
      tasklist[res$taskEventLog$taskID[completed], cols] = res$taskEventLog[completed, cols]
      
      calls %<>% rbind(res$callEventLog) %>% distinct(callID, .keep_all = T)
      
      # calls %<>% left_join(res$callEventLog, by = 'callID')
      cat('Done! ', '\n')
    }
    
    current = current + 3600*2
  }
  
  
}

vout.sim.so = tasklist %>%  filter(agent %in% agents) %>% mutate(compDate = compTime %>% setTZ('GMT') %>% as.Date) %>% 
  group_by(compDate) %>% dplyr::summarise(simso = length(taskID))
vout = vout.sim %>% inner_join(vout.sim.so, by = 'compDate')

### simulation.R ----------------------------
library(magrittr)
library(dplyr)

source('../../packages/master/niragen-master/R/niragen.R')

source('../../packages/master/niraprom-master/R/promtools.R')
source('../../packages/master/niraprom-master/R/prom.R')
source('../../packages/master/niraprom-master/R/prosim.R')


source('../../packages/master/niravis-master/R/visgen.R')
source('../../packages/master/niravis-master/R/jscripts.R')

source('../../packages/master/niravis-master/R/dygraphs.R')
source('../../packages/master/niravis-master/R/plotly.R')
source('../../packages/master/niravis-master/R/visNetwork.R')
source('../../packages/master/niravis-master/R/niraPlot.R')

t1 = as.time('2018-03-01 08:00:00')
t2 = as.time('2018-04-01 18:00:00')

# This program, runs a que simulation on actual task arrivals:

# Read eventlog:
eventlog = read.csv('script/PEGA/data/PEGA_eventlog.csv', as.is = T)


eventlog$arrivalTime %<>% as.time
eventlog$completeTime %<>% as.time
eventlog$startTime %<>% as.time
eventlog$dueTime %<>% as.time

# create a process model and feed eventlog:
x = new('PROCESS')
x$feedTasklist(eventlog, caseID_col = 'caseID', taskID_col = 'taskID', arrTime_col = 'arrivalTime', compTime_col = 'completeTime', activity_col = 'skill', agent_col = 'agent')

x$filter.task.arrTime(until = t1)

# Read simluation parameters:
# Agent-activity AUT Matrix:
agentSkillMatrix = x$get.agent.summary.activityProcTime() %>% rename(skill = activity)
agentSkillMatrix$Average[agentSkillMatrix$Average < 120.0] <- 120.0

# Get average idle time:
agentIdleTime = x$get.agent.summary.idleTime()

skills = x$get.activity.ids()
agents = x$get.agent.ids()

tasklist <- x$tasklist %>% select(taskID, skill = activity, agent, arrTime, startTime, compTime, dueTime) %>% arrange(arrTime) %>% column2Rownames('taskID', remove = F)
w = which(tasklist$startTime > t1)
tasklist$startTime[w]  <- NA
tasklist$compTime[w]   <- NA
tasklist$agent[w]      <- NA


# Mean of rest time just after arrival(min) before the first getNext call: 
# How many minutes each agent spend after the first scheduled arrival time until calling the first getNext?
initWrapTime = agentIdleTime$Average
initWrapTime[initWrapTime < 1800] <- 1800
names(initWrapTime) <- agentIdleTime$agent
initWrapRate = 1.0/initWrapTime

wrapTime = initWrapTime %>% rep(length(skills)) %>% unname %>% matrix(length(agents), length(skills), dimnames = list(agents, skills))
procTime = agentSkillMatrix %>% reshape2::dcast(agent ~ skill, value.var = 'Average') %>% column2Rownames('agent')

wrapRate = 1.0/wrapTime
procRate = 1.0/procTime

# Generate initial agent getNext call events:
# calls = data.frame(callID = character(), agent = character, callTime = T[-1] %>% as.POSIXct, rate = numeric(), compTime = T[-1] %>% as.POSIXct, taskID = character(), skill = character, stringsAsFactors = F)

agents = x$get.agent.ids()
calls = data.frame(callID = paste(agents, 1, sep = '.'), agent = agents, callTime = t1 + rexp(length(agents), rate = initWrapRate[agents]), compTime = NA, taskID = NA, skill = NA, stringsAsFactors = F) %>% column2Rownames('callID', remove = F)  


# settings$agentSkillAPT and settings$agentSkillAWT must be in minutes
settings = list(
  taskEventLog = list(taskID_col = 'taskID', skill_col = 'skill', agent_col = 'agent', priority_col = 'priority', arrivalTime_col = 'arrTime', startTime_col = 'startTime', completedTime_col = 'compTime'),
  callEvenLog  = list(callID_col = 'callID', agent_col = 'agent', taskID_col = 'taskID', skill_col = 'skill', callTime_col = 'callTime', startTime_col = 'startTime', completedTime_col = 'compTime'),
  agentSkillAPT = procTime/60,
  agentSkillAWT = wrapTime/60,
  minAPT        = 2,
  minAWT        = 30
)


tasklist$priority = (t1 - tasklist$dueTime) %>% as.numeric

asis.res = list(taskEventLog = tasklist, callEventLog = calls)

sq = seq(from = t1 %>% setTZ('GMT') %>% as.Date, to = t2 %>% setTZ('GMT') %>% as.Date, by = 1)
for(i in sequence(length(sq))){
  day = sq[i]
  cat('Today is: ', day %>% as.character, ': \n')
  time.begin = day %>% as.character %>% paste('08:00:00') %>% as.time
  time.end   = day %>% as.character %>% paste('18:00:00') %>% as.time
  cat('Running simulation from ', time.begin %>% as.character, ' until ', time.end %>% as.character, '\n')
  asis.res = simQueue(asis.res$taskEventLog, asis.res$callEventLog, from = time.begin, until = time.end, agents = agents, settings = settings)
}


vin.actual = x$tasklist %>% mutate(arrDate = arrTime %>% setTZ('GMT') %>% as.Date) %>% 
  group_by(arrDate) %>% dplyr::summarise(actual = length(taskID))

vin.sim = asis.res$taskEventLog %>% mutate(arrDate = arrTime %>% setTZ('GMT') %>% as.Date) %>% 
  group_by(arrDate) %>% dplyr::summarise(simulation = length(taskID))

vin = vin.actual %>% inner_join(vin.sim, by = 'arrDate')
#### Volume Out
vout.actual = x$tasklist %>% mutate(compDate = compTime %>% setTZ('GMT') %>% as.Date) %>% 
  group_by(compDate) %>% dplyr::summarise(actual = length(taskID))

vout.sim = asis.res$taskEventLog %>% mutate(compDate = compTime %>% setTZ('GMT') %>% as.Date) %>% 
  group_by(compDate) %>% dplyr::summarise(simulation = length(taskID))

vout = vout.actual %>% inner_join(vout.sim, by = 'compDate')

vints = TS.DAILY(from = min(vin$arrDate), until = max(vin$arrDate))
vints$feedData(vin, 'arrDate')

cfg = list(color = list(simulation = 'blue', actual = 'red'),
           shape = list(simulation = 'bar', actual = 'line.dash'))


vin.actual

vin %>% niraPlot(x = 'arrDate', y = list('actual', 'simulation'), config = cfg, type = 'combo', plotter = 'dygraphs')




# Using Smart Optimiser:

# # Allocate jobs from 9:00 am to 11:00 am:
AA = data.frame(agent = agents, scheduled = 240)
xb = OptimalTaskAllocator() %>% feedAgents(agents) %>% feedSkills(skills) %>% 
  feedAgentSchedule(AA, agentID_col = 'agent', scheduled_col = 'scheduled')
xb$TAT[agents, skills] = settings$agentSkillAPT[agents, skills]
xb$SP$score = 1

current = as.time('2018-05-03 08:00:00')


calls = data.frame(callID = character(), agent = character(), callTime = logical() %>% as.POSIXct, compTime = logical() %>% as.POSIXct, taskID = character(), skill = character(), stringsAsFactors = F)

while(current <  as.time('2018-05-03 18:00:00')) {
  cat('Allocation round from ', as.character(current), '\n')
  tasklist$priority = current - tasklist$arrTime
  tasks2ba  = tasklist[which(tasklist$arrTime < current & is.na(tasklist$compTime)),]
  tasks2ba$agent = tasks2ba$queue
  
  x <- xb %>% feedTasks(tasks2ba, skillID_col = 'skill', priority_col = 'priority', agentID_col = 'agent', extra_col = c('arrTime', 'startTime', 'compTime')) %>% 
    distributeTasks(fill_gap_time = FALSE)
  # generate task queues for each agent
  # Simulate single Queue:
  # Mark queue name for allocated tasks:
  allocated = x$TSK[!is.na(x$TSK$agent),]
  tasklist[rownames(allocated), 'queue'] = allocated$agent
  # Generate initial agent getNext call events:
  
  for (e in agents){
    cat('Simulating for agent: ', e, '...')
    st = settings
    st$agentSkillAPT = st$agentSkillAPT[e, , drop = F]
    st$agentSkillWPT = st$agentSkillAWT[e, , drop = F]
    
    res  = simQueue(tasklist[which(tasklist$queue == e),], calls[calls$agent == e, ], from = current, until = current + 3600*2, agents = e, settings = st, show_progress = F)
    cols = names(tasklist) %^% names(res$taskEventLog)
    
    completed = !is.na(res$taskEventLog$agent)
    tasklist[res$taskEventLog$taskID[completed], cols] = res$taskEventLog[completed, cols]
    
    calls %<>% rbind(res$callEventLog) %>% distinct(callID, .keep_all = T)
    
    # calls %<>% left_join(res$callEventLog, by = 'callID')
    cat('Done! ', '\n')
  }
  
  current = current + 3600*2
}

tasklist %>% dplyr::group_by(agent, skill) %>% dplyr::summarise(AUT = mean(compTime - startTime, na.rm = T)) 

# Total idle time in hours:
idl = grep('.idle.', calls$taskID)
t1 = asis.res$callEventLog[idl, 'callTime']
t2 = asis.res$callEventLog[idl, 'compTime']
as.numeric(sum(t2 - t1, na.rm = T)/3600)


# How many tasks are handled?
tasklist %>% filter(!is.na(agent)) %>% nrow
# out of:
tasklist %>% nrow

### test_niraprom.R ----------------------------

source('../../packages/master/niragen-master/R/niragen.R')

source('../../packages/master/niraprom-master/R/prom.R')


source('../../packages/master/niravis-master/R/visgen.R')
source('../../packages/master/niravis-master/R/plotly.R')
source('../../packages/master/niravis-master/R/visNetwork.R')
source('../../packages/master/niravis-master/R/niraPlot.R')


# This program, runs a que simulation on actual task arrivals:

# Read eventlog:
eventlog = read.csv('script/PEGA/data/PEGA_eventlog.csv')

# create a process model and feed eventlog:

x = PROCESS()

x$feedTasklist(eventlog, caseID_col = 'caseID', taskID_col = 'taskID', arrivalTime_col = 'arrivalTime', compTime_col = 'completeTime', skill_col = 'skill', agent_col = 'agent')

x$get.summary.skill.procTime()

x$plot.summary.skill.procTime()

p = x$plot.summary.agent.procTime()

x$get.summary.agent.idleTime()

x$get.summary.agent.skill.procTime()

x$get.transys.skill.arrival
x$get.transys.skill.start
x$get.transys.skill.complete

x$get.transys.agent.start
x$get.transys.agent.complete


y = new('TRANSITION.SYSTEM')
y$feedStatusHistory(x$eventlog, caseID_col = 'caseID', status_col = 'skill', startTime_col = 'compTime', add_start = F)

vin  = y$get.volumeIn()
vout = y$get.volumeOut()
back = y$get.backlog()


x$eventlog %>% dplyr::group_by(skill, compDate) %>% dplyr::summarise(volout = length(compDate))



### archive/runSimulation.R ---------------------

### archive/runSmartOptimiser.R ---------------------
### archive/simtest.R ---------------------
library(magrittr)
library(dplyr)
library(niragen)
library(niraprom)
library(reshape2)
library(lpSolve)

# Read PEGA history data:
# PH = read.csv('data/pegaHistory.csv') %>% column2Rownames('agent')
# PH %<>% select(taskID = 'WORK_ID', agent = 'UPDATE_OPERATOR_NAME', skill = 'CaseTypeSkill', priority = 'Urgency', 
#              arrTime = 'CREATE_DateTime', startTime = 'GETNEXTCALL', compTime = 'COMMIT_DateTime', dueTime = 'CommitmentDateTime')
# rownames(PH) <- NULL
# 
# PH %<>% arrange(skill, arrTime) %>% mutate(intrArrival = )

# Stage 1: Single queue, multiple agents (PEGA As-Is pull system):


# Read simluation parameters:
# Agent-Skill AUT Matrix:
agentSkillMatrix = read.csv('data/agentSkillMatrix.csv', row.names = 1)

# Initial Wrap time for employees:
agentProfile = read.csv('data/agentProfile.csv') %>% column2Rownames('agent')

skills = colnames(agentSkillMatrix)
agents = rownames(agentSkillMatrix) %^% rownames(agentProfile)

# Reduce data size for evaluation:
# skills = skills[1:10]
# agents = agents[1:10]

# limit to agents and skills for which full data is available:
agentProfile = agentProfile[agents, , drop = F]
agentSkillMatrix  = agentSkillMatrix[agents, skills, drop = F]

# Stage 1: Single queue, multiple agents (PEGA As-Is pull system):

## Task arrival rates (per hour) during working hours (from 9 am to 6 pm) for each skill
arrivalRate_wh = read.csv("data/arrivalRate_wh.csv")
arrivalRate.w = arrivalRate_wh$COUNT
names(arrivalRate.w) <- arrivalRate_wh$skill

## Task arrival rates (per hour) after hours for each skill
arrivalRate_ah = read.csv("data/arrivalRate_ah.csv")
arrivalRate.a = arrivalRate_ah$COUNT
names(arrivalRate.a) <- arrivalRate_ah$skill

# # How many tasks can come in the first 9 hours?
# maxTaskCount.a = (2.0*14*arrivalRate.a) %>% ceiling
# # How many tasks can come from 9 am to 6 pm? (Working hours)
# maxTaskCount.w = (2.0*10*arrivalRate.w) %>% ceiling


# Generate task list for a few days:
# Simulates task arrival with observed rates 
# from:
#time.start = as.time('2018-03-01 08:00:00')
# until:
#time.end   = as.time('2018-03-01 18:00:00')

# todo: add due time based on the observed service levels

# Generate task list for 18 hours:
# tasklist = data.frame()


tasklist = data.frame() %>%
  generateTasks(from = as.time('2018-05-01 18:00:00'), to = as.time('2018-05-02 08:00:00'), rate = arrivalRate.a) %>%
  generateTasks(from = as.time('2018-05-02 08:00:00'), to = as.time('2018-05-02 18:00:00'), rate = arrivalRate.w) %>%
  generateTasks(from = as.time('2018-05-02 18:00:00'), to = as.time('2018-05-03 08:00:00'), rate = arrivalRate.a) %>%
  generateTasks(from = as.time('2018-05-03 08:00:00'), to = as.time('2018-05-03 18:00:00'), rate = arrivalRate.w)

# for (sk in skills){
#   if(sk %in% names(maxTaskCount.a)){
#     TL.a = data.frame(intrArrival = rexp(n = maxTaskCount.a[sk], rate = arrivalRate.a[sk]/3600), taskID = sk %>% paste(1:maxTaskCount.a[sk], 'A', sep = '.'), skill = sk, dueTime = as.time('2018-03-01 18:00:00'), queue = NA, agent = NA, priority = NA, startTime = as.POSIXct(NA), compTime = as.POSIXct(NA), stringsAsFactors = F) %>% mutate(arrTime = as.time('2018-02-28 18:00:00') + cumulative(intrArrival)) %>% filter(arrTime < as.time('2018-03-01 09:00:00'))
#   } else{
#     TL.a = data.frame(intrArrival = numeric(), taskID = character(), skill = character(), dueTime = character() %>% as.time, queue = character(), agent = character(), priority = numeric(), startTime = character() %>% as.time, compTime = character() %>% as.time, stringsAsFactors = F)
#   }
#   if(sk %in% names(maxTaskCount.w)){
#     TL.w = data.frame(intrArrival = rexp(n = maxTaskCount.w[sk], rate = arrivalRate.w[sk]/3600), taskID = sk %>% paste(1:maxTaskCount.w[sk], 'W', sep = '.'), skill = sk, dueTime = as.time('2018-03-01 18:00:00'), queue = NA, agent = NA, priority = NA, startTime = as.POSIXct(NA), compTime = as.POSIXct(NA), stringsAsFactors = F) %>% mutate(arrTime = as.time('2018-03-01 09:00:00') + cumulative(intrArrival)) %>% filter(arrTime < as.time('2018-03-01 18:00:00'))
#   } else{
#     TL.W = data.frame(intrArrival = numeric(), taskID = character(), skill = character(), dueTime = character() %>% as.time, queue = character(), agent = character(), priority = numeric(), startTime = character() %>% as.time, compTime = character() %>% as.time, stringsAsFactors = F)
#   }  
#   tasklist %<>% rbind(TL.a, TL.w) %>% filter(arrTime < as.time('2018-03-01 18:00:00'))
# }

tasklist %<>% arrange(arrTime) %>% column2Rownames('taskID', remove = F)

# Mean of rest time just after arrival(min) before the first getNext call: 
# How many minutes each agent spend after the first scheduled arrival time until calling the first getNext?
initWrapTime = agentProfile$initWrapTime
names(initWrapTime) <- rownames(agentProfile)
initWrapRate = 1.0/initWrapTime

wrapTime = initWrapTime %>% rep(length(skills)) %>% unname %>% matrix(length(agents), length(skills), dimnames = list(agents, skills))
procTime = agentSkillMatrix*10 # Why???
# procTime = agent-skill matrix
wrapRate = 1.0/wrapTime
procRate = 1.0/procTime
# Generate initial agent getNext call events:
calls = data.frame(callID = paste(agents, 1, sep = '.'), agent = agents, callTime = as.time('2018-05-03 08:00:00') + rexp(length(agents), rate = initWrapRate[agents]), compTime = NA, taskID = NA, skill = NA, stringsAsFactors = F) %>% column2Rownames('callID', remove = F)  

# settings$agentSkillAPT and settings$agentSkillAWT must be in minutes
settings = list(
  taskEventLog = list(taskID_col = 'taskID', skill_col = 'skill', agent_col = 'agent', priority_col = 'priority', arrivalTime_col = 'arrTime', startTime_col = 'startTime', completedTime_col = 'compTime'),
  callEvenLog  = list(callID_col = 'callID', agent_col = 'agent', taskID_col = 'taskID', skill_col = 'skill', callTime_col = 'callTime', startTime_col = 'startTime', completedTime_col = 'compTime'),
  agentSkillAPT = procTime/60,
  agentSkillAWT = wrapTime/60,
  minAPT        = 5,
  minAWT        = 10
)

asis.res = simQueue(tasklist, calls, from = as.time('2018-05-03 08:00:00'), until = as.time('2018-05-03 18:00:00'), agents = agents, settings = settings)

# Verify to see if given AUTs are respected:
asis.res$taskEventLog %>% mutate(duration = compTime - startTime) %>% group_by(agent, skill) %>% summarise(meanDur = mean(duration))
# Save ASIS simulation results:
# saveRDS(asis.res, file = 'simResultASIS.rds')
# Read ASIS simulation results
# asis.res = readRDS(file = 'simResultASIS.rds')


# Total idle time in hours:
idl = grep('.idle.', asis.res$callEventLog$taskID)
t1 = asis.res$callEventLog[idl, 'callTime']
t2 = asis.res$callEventLog[idl, 'compTime']
as.numeric(sum(t2 - t1)/3600)

# How many tasks are handled?
asis.res$taskEventLog %>% filter(!is.na(agent)) %>% nrow
# out of:
asis.res$taskEventLog %>% nrow

# Using Smart Optimiser:

# # Allocate jobs from 9:00 am to 11:00 am:
AA = data.frame(agent = agents, scheduled = 240)
xb = OptimalTaskAllocator() %>% feedAgents(agents) %>% feedSkills(skills) %>% 
  feedAgentSchedule(AA, agentID_col = 'agent', scheduled_col = 'scheduled')
xb$TAT[agents, skills] = settings$agentSkillAPT[agents, skills]
xb$SP$score = 1

current = as.time('2018-05-03 08:00:00')


calls = data.frame(callID = character(), agent = character(), callTime = logical() %>% as.POSIXct, compTime = logical() %>% as.POSIXct, taskID = character(), skill = character(), stringsAsFactors = F)

while(current <  as.time('2018-05-03 18:00:00')) {
  cat('Allocation round from ', as.character(current), '\n')
  tasklist$priority = current - tasklist$arrTime
  tasks2ba  = tasklist[which(tasklist$arrTime < current & is.na(tasklist$compTime)),]
  tasks2ba$agent = tasks2ba$queue
  
  x <- xb %>% feedTasks(tasks2ba, skillID_col = 'skill', priority_col = 'priority', agentID_col = 'agent', extra_col = c('arrTime', 'startTime', 'compTime')) %>% 
    distributeTasks(fill_gap_time = FALSE)
  # generate task queues for each agent
  # Simulate single Queue:
  # Mark queue name for allocated tasks:
  allocated = x$TSK[!is.na(x$TSK$agent),]
  tasklist[rownames(allocated), 'queue'] = allocated$agent
  # Generate initial agent getNext call events:
  
  for (e in agents){
    cat('Simulating for agent: ', e, '...')
    st = settings
    st$agentSkillAPT = st$agentSkillAPT[e, , drop = F]
    st$agentSkillWPT = st$agentSkillAWT[e, , drop = F]
    
    res  = simQueue(tasklist[which(tasklist$queue == e),], calls[calls$agent == e, ], from = current, until = current + 3600*2, agents = e, settings = st, show_progress = F)
    cols = names(tasklist) %^% names(res$taskEventLog)
    
    completed = !is.na(res$taskEventLog$agent)
    tasklist[res$taskEventLog$taskID[completed], cols] = res$taskEventLog[completed, cols]
    
    calls %<>% rbind(res$callEventLog) %>% distinct(callID, .keep_all = T)
    
    # calls %<>% left_join(res$callEventLog, by = 'callID')
    cat('Done! ', '\n')
  }
  
  current = current + 3600*2
}

tasklist %>% dplyr::group_by(agent, skill) %>% dplyr::summarise(AUT = mean(compTime - startTime, na.rm = T)) 

# Total idle time in hours:
idl = grep('.idle.', calls$taskID)
t1 = asis.res$callEventLog[idl, 'callTime']
t2 = asis.res$callEventLog[idl, 'compTime']
as.numeric(sum(t2 - t1, na.rm = T)/3600)


# How many tasks are handled?
tasklist %>% filter(!is.na(agent)) %>% nrow
# out of:
tasklist %>% nrow

### archive/simtest2.R ---------------------
### archive/utility.R ---------------------
### archive/runSimulation.R ---------------------


###### Folder Archive ================

### dash.R ---------------------
# Header
# Filename:       dash.R
# Description:    This file creates shiny UI for the Smart Process Optimiser project. 
# Author:         Nima Ramezani Taghiabadi
# Email:          nima.ramezani@cba.com.au
# Start Date:     30 May 2018
# Last Revision:  30 May 2018
# Version:        1.0.0

# Version History:

# Version   Date              Action
# ___________________________________________
# 1.0.0     30 May 2018       Initial Issue





library(niragen)
library(shinythemes)
library(shinyjs)

source('../../packages/master/niravis-master/R/dashboard.R')
source('../../packages/master/niravis-master/R/visgen.R')
source('../../packages/master/niravis-master/R/rscripts.R')


######### Service Functions:#########
prescript    = "if(is.null(sync$trigger)){sync$trigger = 0}"

# OTS.srv        = paste(prescript, "session$userData$pm %>% niraPlot(label = SPLabels, config = list(withRowNames = T), plotter = 'DT', type = 'table')", sep = ';')
# lovrInfo.srv   = paste(prescript, "session$userData$pm %>% leftover.count(rownames(session$userData$ota$SP)[input$OTS_rows_selected])", sep = ';')
# backInfo.srv   = paste(prescript, "session$userData$pm %>% backlog.count(rownames(session$userData$ota$SP)[input$OTS_rows_selected])", sep = ';')                            
# unalInfo.srv   = paste(prescript, "session$userData$ota %>% unallocated.count(rownames(session$userData$ota$SP)[input$OTS_rows_selected])", sep = ';')
# newInfo.srv    = paste(prescript, "session$userData$ota %>% assigned.count(rownames(session$userData$ota$SP)[input$OTS_rows_selected])", sep = ';')
# nonInfo.srv    = paste(prescript, "session$userData$ota %>% nonworkable.count(rownames(session$userData$ota$SP)[input$OTS_rows_selected])", sep = ';')
# utilInfo.srv   = paste(prescript, "session$userData$ota %>% overallUtilization", sep = ";")

# APApply.srv   = paste("dash$disableItems('APUndo', 'APApply')",
#                       "sync$message = 'In progress...'", "Sys.sleep(0.5)",
#                       "ota = try(feedAgentSchedule(session$userData$ota, sync$APTable, scheduled_col = 'scheduled', utilFactor_col = 'utilFactor'), silent = T)",
#                       "if(inherits(ota, 'OptimalTaskAllocator')){session$userData$ota = ota",
#                       "sync$trigger = sync$trigger + 1",
#                       "sync$message = messages['APTableApplied']",
#                       "} else {sync$message = ota %>% as.character %>% cleanError}", 
#                       "dash$enableItems('APUndo', 'APApply')", sep = ';')


######### Load data, build reactive variables and define initial values: #########
# teamTable = readTeams(dsn = 'SOTEST', uid = 'rshinyuser', pwd = 'smart1Optimiser2') %>% column2Rownames('TEAMID')
# holidays  = readHolidays(dsn = 'SOTEST', uid = 'rshinyuser', pwd = 'smart1Optimiser2')[,'CALENDARDATE'] %>% as.Date
# teams = rownames(teamTable)
# names(teams) = teamTable[,'TEAMNAME']
# 
# val = list(ALCD = NULL, ALCT = NULL, trigger = 0)
# 
# dataset   = loadData(Sys.Date(), dsn = 'SOTEST', uid = 'rshinyuser', pwd = 'smart1Optimiser2')
# 
# logt = getLoginTable(dsn = 'SOTEST', uid = 'rshinyuser', pwd = 'smart1Optimiser2') %>% column2Rownames('USERNAME')
# names(logt) %<>% tolower
# logt$password %<>% as.character
# logt['bmoguest', 'password'] <- "$2a$12$ZcVliB8VHNdS2IFKLPFTe.W6pZk6UsQLwLI4o/rCCUCNEst5D3aum"
# 
# x = dataset %>% dataset2Obj
# 
# reactives = obj2Reactives(x)

I = list()
O = list()

######### Clothes and static objects: #########
# tableCloth  = list(type = 'box', status = "primary", solidHeader = T, collapsible = T, collapsed = T, weight = 12, title = 'List of Tasks')
# ageBoxcloth = list(type = 'box', status = "primary", solidHeader = T, collapsible = T, collapsed = T, weight = 12, title = 'Age Box Plot')
# dueAgeBoxcloth = list(type = 'box', status = "primary", solidHeader = T, collapsible = T, collapsed = T, weight = 12, title = 'Due Age Box Plot')
# sunbox         = list(type = 'box', status = "primary", solidHeader = T, collapsible = T, collapsed = F, weight = 11, title = 'Sunburst View')
# 
# centerAlign = list(type = 'column', align = 'center')
# 
# lovrCloth  = list(type = 'valueBox', icon = 'calendar-plus-o'   , subtitle = 'leftover tasks'     , weight = 2, fill = T, color = 'teal')
# backCloth  = list(type = 'valueBox', icon = 'files-o'     , subtitle = 'total backlog'      , weight = 2, fill = T, color = 'teal')
# unalCloth  = list(type = 'valueBox', icon = 'file-o'      , subtitle = 'unallocated tasks'  , weight = 2, fill = T, color = 'teal')
# utilCloth  = list(type = 'valueBox', icon = 'clock-o'     , subtitle = 'Total Utilized Time', weight = 2, fill = T, color = 'teal')
# nonCloth   = list(type = 'valueBox', icon = 'ban'         , subtitle = 'non-workable tasks' , weight = 2, fill = T, color = 'teal')
# newCloth   = list(type = 'valueBox', icon = 'file'        , subtitle = 'new allocated tasks', weight = 2, fill = T, color = 'teal')
# noteCloth  = list(type = 'box' , icon = 'comment-o', offset = 0.5, weight = 12, status = 'success', solidHeader = T)
# 
# O$line         = list(type = 'static', object = hr(id = 'line'))
# O$lhide        = list(type = 'static', object = hr(id = 'lhide'))
# O$caret        = list(type = 'static', object = br())
# 
# 
# O$shinyjs      = list(type = 'static', object = useShinyjs())

######### Main Containers: #########

I$main       = list(type = 'fluidPage', layout = c('shinyjs', 'nvp'))

# div(HTML('<img src=\"can.png\" height=\"40\" > &nbsp;'), 'CBA Smart Process Optimiser v 1.0.0')

I$nvp        = list(type = 'navbarPage', title = 'CBA Smart Process Optimiser v 1.0.0', 
                    theme  = shinytheme("flatly"), 
                    layout = c('MPTAB', 'APTAB', 'SPTAB'))

I$MPTAB   = list(type = 'tabPanel' , title = 'Process Map', layout = 'MPPage')
I$APTAB   = list(type = 'tabPanel' , title = 'Agent Profile', layout = 'APPage')
I$SPTAB   = list(type = 'tabPanel' , title = 'Skill Profile', layout = 'SPPage')

I$MPPage   = list(type = 'sidebarLayout', layout.side = c('describe', 'getprocess', 'getdates'), layout.main = 'map')
I$APPage   = list(type = 'fluidPage', layout = c())
I$SPPage   = list(type = 'fluidPage', layout = c())

I$describe   = list(type = 'static', object = 'This is your inut panel!')
I$getprocess = list(type = 'selectInput', title = 'Select Process', choices = c('Homeloan', 'Credit Card'))
I$getdates   = list(type = 'dateRangeInput', title = 'Select Date Interval')
I$map        = list(type = 'plotOutput', title = 'This is your map')
I$shinyjs    = list(type = 'static', object = useShinyjs())


######### Build Dashboard: #########

dash   <- new('DASHBOARD', items = I, king.layout = list('main'))
ui     <- dash$dashboard.ui()
server <- dash$dashboard.server()
app    <- shinyApp(ui, server)


######### Run: #########

# runApp(app)
# runApp(app, host = "0.0.0.0", port = 8080)


### dash.Rmd ---------------------
---
  title: "Status Transition System for CBA HL Application Process"
author: "NIRASOFT"
date: "3 March 2017"
output: 
  flexdashboard::flex_dashboard:
  orientation: rows
social: menu
runtime: shiny
---
  
  ```{r setup, include=T}
knitr::opts_chunk$set(echo = F)

library(flexdashboard)
library(magrittr)
library(timeDate)
library(dygraphs)
library(googleVis)

# prepare objects:

```
Dashboard
=======================================================================
  
  Row
-----------------------------------------------------------------------
  
  ### Entry Rate {.value-box}
  
  ```{r}
# Shows the average (per day) number of cases entered in this status or inter-arrival time
renderValueBox({
  valueBox(123, icon = "fa-download")
})
```

### Exit Rate {.value-box}

```{r}
# Shows the average daily exit rate (number of cases emitted from the status per day)  
renderValueBox({
  valueBox(123, icon = "fa-download")
})
```

### Average Service Time {.value-box}

```{r}
# Shows the average amount of time (per case) spent in this status
renderValueBox({
  rate <- formatC(5.2656565, digits = 1, format = "f")
  valueBox(
    value = rate,
    icon = "fa-area-chart",
    color = if (rate >= 5) "warning" else "primary"
  )
})
```

### Distribution to next destination {.value-box}

```{r}
# Shows distribution to next statuses by a pie chart 
# Emit the user count
renderValueBox({
  valueBox(value = 2.396, icon = "fa-users")
})
```

Row
-----------------------------------------------------------------------
  
  ### Status Volume Time Series {data-width=700}
  
  ```{r}
renderDygraph({V$plot.history(period = 1:V$N.int, figures = 'ASES')})
```

Row
-----------------------------------------------------------------------
  
  ### Network View
  ```{r}
renderVisNetwork({net})
```

### Sunburst View
```{r}
renderSunburst({sun})
```


### dashtemp.Rmd ---------------------
# ---
#   title: "Untitled"
# author: "NIRASOFT"
# date: "3 March 2017"
# output: html_document
# runtime: shiny
# ---
#   
#   ```{r setup, include=FALSE}
# knitr::opts_chunk$set(echo = TRUE)
# ```
# 
# This R Markdown document is made interactive using Shiny. Unlike the more traditional workflow of creating static reports, you can now create documents that allow your readers to change the assumptions underlying your analysis and see the results immediately. 
# 
# To learn more, see [Interactive Documents](http://rmarkdown.rstudio.com/authoring_shiny.html).
# 
# ## Inputs and Outputs
# 
# You can embed Shiny inputs and outputs in your document. Outputs are automatically updated whenever inputs change.  This demonstrates how a standard R plot can be made interactive by wrapping it in the Shiny `renderPlot` function. The `selectInput` and `sliderInput` functions create the input widgets used to drive the plot.
# 
# ```{r eruptions, echo=FALSE}
# inputPanel(
#   selectInput("n_breaks", label = "Number of bins:",
#               choices = c(10, 20, 35, 50), selected = 20),
#   
#   sliderInput("bw_adjust", label = "Bandwidth adjustment:",
#               min = 0.2, max = 2, value = 1, step = 0.2)
# )
# 
# renderPlot({
#   hist(faithful$eruptions, probability = TRUE, breaks = as.numeric(input$n_breaks),
#        xlab = "Duration (minutes)", main = "Geyser eruption duration")
#   
#   dens <- density(faithful$eruptions, adjust = input$bw_adjust)
#   lines(dens, col = "blue")
# })
# ```
# 
# ## Embedded Application
# 
# It's also possible to embed an entire Shiny application within an R Markdown document using the `shinyAppDir` function. This example embeds a Shiny application located in another directory:
# 
# ```{r tabsets, echo=FALSE}
# shinyAppDir(
#   system.file("examples/06_tabsets", package = "shiny"),
#   options = list(
#     width = "100%", height = 550
#   )
# )
# ```
# 
# Note the use of the `height` parameter to determine how much vertical space the embedded application should occupy.
# 
# You can also use the `shinyApp` function to define an application inline rather then in an external directory.
# 
# In all of R code chunks above the `echo = FALSE` attribute is used. This is to prevent the R code within the chunk from rendering in the document alongside the Shiny components.
# 



### denny.R ---------------------
# niragen:
library(niragen)

# nirats:
library(nirats)

# niravis:
source('C:/Nima/R/projects/libraries/developing_packages/visgen.R')
library(niravis)

D = readODBC(tableName = 'BW_CPS_OUTCOME_VOLUME') 

p = new('SIMPLE.PROCESS')
p$feedStatusHistory(D, caseID_colname = 'CASE_ID', status_colname = 'q_name', startTime_colname = 'Q_VOL_IN_DT')

p$setQuery()


res = p$getAdjacencies()

v   = adjacency2visNetwork(res$adjacency, res$timeAdjacency)
s   = adjacency2Sankey(res$adjacency, res$timeAdjacency)


A = res$adjacency

for (i in rownames(A)){
  for (j in colnames(A)){
    if (A[i,j] >= A[j,i]){A[j,i] <- 0} else {A[i,j] <- 0}
  }
}

### genTranSys.R ---------------------
library(timeDate)

library(magrittr)
# library(niragen)
source('C:/Nima/RCode/packages/niragen/R/niragen.R')
source('C:/Nima/RCode/packages/niragen/R/linalg.R')
source('C:/Nima/RCode/packages/niragen/R/io.R')

# library(niravis)
source('C:/Nima/RCode/packages/niravis-master/R/visgen.R')
source('C:/Nima/RCode/packages/niravis-master/R/visNetwork.R')
source('C:/Nima/RCode/packages/niravis-master/R/networkD3.R')

# library(niraprom)
source('C:/Nima/RCode/packages/niraprom/R/transys.R')


case.filter.query = sqlScript(tableName = 'APPT', dbName = 'PVDATA', fields = c('APPT_I'), filter = list(APPT_QLFY_C = list(domain = "HL"), APPT_CRAT_D = list(min = '2016-01-01', max = '2016-03-01', type = 'date')))
filter = list(APPT_I = list(query = case.filter.query))

D = readODBC(tableName = 'APPT_STUS_HIST', dbName = 'PVDATA', fields = c('APPT_I', 'STUS_C', 'STRT_S'), filter = filter)

s = new('TRANSITION.SYSTEM')
s$feedStatusHistory(dataset = D, caseID_colname = 'APPT_I', status_colname = 'STUS_C', startTime_colname = 'STRT_S', sort_startTime = T, add_ends = T)

res = s$getSimpleAdjacencies(sf = 0.9)

banned = getFilteredPaths(res$adjacency)

s$excludePaths(banned)



saveRDS(s, 'data/system.rds')


# Todos:

# Given the event log, compute the volume of fresh arrival: (SQL script)
# Given the event log table within a particular date range, compute the volume of each team/task-type for a given series of time intervals (R Code)
# Given the event log, compute the backlog of each team/task type for a given time stamp (SQL Script)
# (Count WIMs where start_dt is lower and end_dt is higher than the given time stamp)
# Test and verify the results with the volumes from BMO to make sure the outputs are identical for some selected teams/task-types

### gfdash2.R ---------------------

# Columns required:
# caseID:  Character or factor pr onteger
# taskID:  Character or factor or integer
# activity: character or factor
# status:   character or factor
# time:  POSIXct
# agent:   Character or factor
# 


library(shiny)
library(niravis)


# Expected Columns and their classes:




# This functions builds a niravis container for a dialog box in order to get a CSV table and issue out a table with desired column names and classes. 
# The returned container includes all service functions for reading and modifying the input table as well as error handling.
# todo: add Excel tables should be added
# the function returns a list of items that needs to be appended to any UI(dashboard) on which the dialog box is going to appear.
# name: name or ID of the container element
# classes: a named list containing acceptable classes of each column. list names should refer to the desired name of each column.
# outputvar: specifies the name of the final output variable. This can refer to a reactive or non-reactive global 
# variable which can be defined anywhere in global.R and is accessible in all service functions of the UI.
# There are two error (fail) messages. The error messages are '<name>.failmsg' and '<name>.failmsg2' will appear in list 'temp' which is an element of the 'userData' property of the session:
# For example, if the name of the dialogbox is 'my_dialog', error messages will be found at:
# session$userData$temp$failmsg & session$userData$temp$failmsg2
# failmsg is NULL if no file has been specified yet or the dialogbox is reset.
# failmsg is 'Ok' if table CSV file is read with no problem (No checking or verification on the contents yet)
# failmsg is 'One and only one file must be selected!' if more than one file is selected by the user
# failmsg is 'Please choose a CSV file.' if a file with extention other than .csv is selected.
# failmsg is 'Selected table has no column names' if the selected table has no column labels.
# failmsg is 'File read failed for some reason!' if the selected file is corrupt and cannot be read.
# failmsg2 is 'Ok' if all the columns inherit desired classes or have been successfully coerced to the first desired class.
# failmsg2 is 'Column ... cannot be coerced to ...!' if any of the columns does not inherit desired classes and cannot be coerced to the first desired class for that column.
build.getTableDialogBox = function(name, classes, outputvar = name %>% paste('out', sep = '.') , fileSelectTitle = 'Select input CSV file', loadButtonTitle = 'Load selected file'){
  colns = names(classes)
  
  items = list()
  items[[name]]        = list(type = 'fluidPage')
  items[[name %>% paste0('.get.file')]] = list(type = 'fileInput', title = fileSelectTitle, accept = c('.csv'))
  lay = list(list(name %>% paste0('.get.file'), offset = 1))
  checkstr = character()
  for(col in colns){
    itmID = paste(name, 'get', col, sep = '.')
    items[[itmID]] = list(type = 'selectInput', title = paste(col, 'Column', 'Label'))
    lay %<>% list.add(list(itmID, offset = 1))
    checkstr %<>% c(paste0("if(!fail){
                           if(!inherits(session$userData$temp$TBL$", col, " , c(", paste0("'", classes[[col]],"'") %>% paste(collapse = ','), "))){
                           fail = try({session$userData$temp$TBL$", col, " %<>% coerce('", classes[[col]][1], "')}, silent = T) %>% inherits('try-error')
                           if(fail){session$userData$temp$", name, ".failmsg2 = 'Column ", col, "  cannot be coerced to ", classes[[col]][1], "!'}}}"))
}
  checkstr %<>% paste(collapse = '\n')
  updatescr = paste0("updateSelectInput(session, '", name, ".get.", colns, "', choices = ctgrs)") %>% paste(collapse = '\n')
  updatescr = paste("\n", updatescr, "\n")
  
  lay %<>% list.add(list('loadfile', 'cancel'))
  items$loadfile       = list(type = 'actionButton', title = loadButtonTitle)
  items$cancel         = list(type = 'actionButton', title = 'Cancel')
  items[[name]]$layout = lay
  scr = paste0(
    "
    session$userData$temp = list(", name, ".failmsg = 'Ok')
    # Verifications
    # if(length(input$", name, ".get.file$datapath) != 1){session$userData$temp$", name, ".failmsg = 'One and only one file must be selected!'}
    ssp = strsplit(input$", name, ".get.file$name, '.', fixed = T)[[1]]
    nnn = length(ssp)
    if(ssp[nnn] != 'csv'){session$userData$temp$", name, ".failmsg = 'Please choose a CSV file.'}
    if(session$userData$temp$", name, ".failmsg == 'Ok'){
    session$userData$temp$ORGTBL = try(read.csv(input$", name, ".get.file$datapath, as.is = T), silent = T)
    if(inherits(session$userData$temp$ORGTBL, 'data.frame')){
    ctgrs = names(session$userData$temp$ORGTBL)
    if(!is.null(ctgrs)){", updatescr,
    "} else {session$userData$temp$", name, ".failmsg = 'Selected table has no column names'}
    } else {session$userData$temp$", name, ".failmsg = 'File read failed for some reason!'}
    }
    ")
  items[[name %>% paste0('.get.file')]]$service = scr
  
  inputcolnstr = paste0("input$", name, ".get.", colns) %>% paste(collapse = ' , ')  
  colnstr      = paste0("'", colns, "'") %>% paste(collapse = ' , ')  
  
  
  items$loadfile$service = paste0(
    "
    cat('Reading file: ', session$userData$temp$", name, ".failmsg, '\n')
    if(!is.null(session$userData$temp$", name, ".failmsg)){
    if(session$userData$temp$", name, ".failmsg == 'Ok'){
    session$userData$temp$", name, ".failmsg2 = 'Ok'
    session$userData$temp$TBL = session$userData$temp$ORGTBL[, c(", inputcolnstr, ")]
    names(session$userData$temp$TBL) <- c(", colnstr, ") 
    fail = F", "\n", checkstr, "
    cat('Coercing Classes: ', session$userData$temp$", name, ".failmsg2, '\n')
    if(!fail){
    OUT = session$userData$temp$TBL
    session$userData$temp$TBL <- NULL
    print(head(OUT))}}}")
  
  return(items)
    }

# This function will be transferred to niravis and all future editions will be done there
# 'dialog' is now the name of the dialogbox
# OUT is the reactive global variable in the system that should not change if file read fails
# dialog.failmsg is a non-reactive variable in session$userData$temp specifying fail message. If not failed, failmsg = ''


classes = list(caseID = c('character', 'factor'), activity = c('character', 'factor'), status = c('character', 'factor'), timestamp = 'POSIXct')

######### Build Dashboard: #########

dash   <- new('DASHBOARD', items = build.getTableDialogBox(name = 'my_dialog', classes = classes), king.layout = list('my_dialog'))
ui     <- dash$dashboard.ui()
server <- dash$dashboard.server()
shinyApp(ui, server)


######### Run: #########

# runApp(app)
# runApp(app, host = "0.0.0.0", port = 8080)

### global.R ---------------------
# Required Libraries
library(sunburstR)
library(magrittr)

# Run local R scripts:

# niragen:
source('C:/Nima/RCode/packages/niragen/R/niragen.R')
source('C:/Nima/RCode/packages/niragen/R/linalg.R')
source('C:/Nima/RCode/packages/niragen/R/io.R')

# time series:
source('C:/Nima/RCode/packages/nirats/R/time.series.R')

# niravis
source('C:/Nima/RCode/packages/niravis-master/R/visgen.R')
source('C:/Nima/RCode/packages/niravis-master/R/visNetwork.R')
source('C:/Nima/RCode/packages/niravis-master/R/dygraphs.R')
source('C:/Nima/RCode/packages/niravis-master/R/networkD3.R')

# niraprom:
source('C:/Nima/RCode/packages/niraprom/R/transys.R')

s = readRDS('C:/Nima/R/projects/cba/cba.hlp.simulation/data/system.rds')

res = s$getAdjacencies()
net = adjacency2visNetwork(res$adjacency, res$timeAdjacency)
snk = adjacency2Sankey(res$adjacency, res$timeAdjacency)

# View(s$history)

R = s$history[,c('caseID', 'status')] %>% group_by(caseID) %>% summarise(CNT = length(status), Path = paste(status, collapse = '-')) %>% as.data.frame()
t = table(R$Path[R$CNT < 6])
t = as.data.frame(t)
names(t) <- c('V1','V2')
t$V1 <- as.character(t$V1)
t$V1 <- t$V1 %+% '-end'
sun = sunburst(t)

V = s$getStatusVolume()



### mohammad.R ---------------------
library(magrittr)
library(dplyr)

# library(niragen)
source('../../packages/master/niragen-master/R/linalg.R')
source('../../packages/master/niragen-master/R/io.R')
source('../../packages/master/niragen-master/R/niragen.R')

# library(niravis)
source('../../packages/master/niravis-master/R/visgen.R')
source('../../packages/master/niravis-master/R/visNetwork.R')
source('../../packages/master/niravis-master/R/billboarder.R')
source('../../packages/master/niravis-master/R/highcharter.R')
source('../../packages/master/niravis-master/R/diagramer.R')
source('../../packages/master/niravis-master/R/networkD3.R')
source('../../packages/master/niravis-master/R/niraPlot.R')
source('../../packages/master/nirats-master/R/time.series.R')
source('../../packages/master/nirats-master/R/tsdaily.R')


# library(niraprom)
source('../../packages/master/niraprom/R/transys.R')
source('../../packages/master/niraprom/R/prom.R')

D = read.csv('data/full_discharges_mohammad_Sep_Dec 2016.csv', as.is = T)


# PROCESS() %>%
#   feedEventLog(D, caseID_col = "APPT_I", )

D = D[D$Type == 'PADC',]

D$APPT_I %<>% as.character
D$STUS_C %<>% as.character
D$STRT_S %<>% as.character %>% as.time(target_class = 'POSIXlt') %>% as.POSIXct  

s = new('TRANSITION.SYSTEM')
s$feedStatusHistory(dataset = D, caseID_col = 'APPT_I', status_col = 'STUS_C', startTime_col = 'STRT_S', sort_startTime = T, add_start = T)

s$plot.processMap()

FA = s$get.adjacency()
TA = s$get.adjacency(measure = 'time', aggrFuncName = 'mean')

s$plot.processMap(plotter = 'visNetwork')

s$filter.case(freqThreshold = 0.98)



########### Case level
app = s$getCase('CSEHM59021807')
app$getDegree()
app$getStatusProfile()
app$getGraph() %>% plot
app$getNetwork()











# Old Stuff:

i        = 0
rank     = integer()
st       = 'START'
rank[st] = i

while(st != 'END'){
  i = i + 1
  st = s$statusDomain[order(res$adjacency[st, ], decreasing = T)[1]]
  rank[st] = i
}

net %>% visHierarchicalLayout(sortMethod = 'directed') %>% visNodes(physics = F)
net %>% visHierarchicalLayout(sortMethod = 'directed', edgeMinimization = F) %>% visNodes(physics = F)
net %>% visHierarchicalLayout(sortMethod = 'directed', levelSeparation = 200, edgeMinimization = T, blockShifting = T, parentCentralization = T, direction = 'UD') %>% visNodes(physics = F) %>% visEdges(smooth = T)


net %>% visNodes(physics = F)


ADJC = s$data$adjacency %>% apply(1, vect.normalise) %>% t
ADJC[ADJC < 0.1] = 0
banned = character()
for(i in rownames(ADJC)){
  for(j in colnames(ADJC)){
    if(ADJC[i,j] == 0){banned = c(banned, i %++% '-' %++% j)}
  }
}

s$history$path = s$history$status %++% '-' %++% s$history$nextStatus
s$history$selected = !(s$history$path %in% banned)

dim(s$history)
sum(s$history$selected)


ADJC = (ADJC*100) %>% round
netc = adjacency2visNetwork(ADJC) %>% visHierarchicalLayout(sortMethod = 'directed', edgeMinimization = T, blockShifting = T, parentCentralization = T, direction = 'LR') %>% visNodes(physics = F)




## Using evenminr.analytics:
library(tibble)
library(data.table)
D_fuzzy <- create_fuzzy_data(D %>% as.tibble,
                             node_cutoff_vec = 1,
                             case_label = "APPT_I",
                             event_label = "STUS_C",
                             timestamp_label = "STRT_S")

create_fuzzy_map(D_fuzzy)

### petriTest.R ---------------------
library(petrinetR)

flw = read.csv('data/pnExample.csv', stringsAsFactors = F)

p = create_PN(places = c("start", "c1", "c2", "c3", "c4", "c5", "end"),
              transitions = c("a", "b", "c", "d", "e", "f", "g", "h"),
              flows = flw,
              marking = rep("start",3))

v = visNetwork_from_PN(p)

p = execute(p, 'a')

enabled(p)

### suraj.R ---------------------

### suraj_ts ---------------------

### test_status_volume_ts ---------------------

### test_transys.R ---------------------

### testbupa_v1.R ----------------------

### testbupa_v2.R ----------------------

### testbupa_v3.R ----------------------

### testbupa_v4.R ----------------------

### tstools.R ----------------------

### RYAN/ARIMA.comp.R -------------------
arima.seven.ahead <- function(my.ts)
{  
  colnames(my.ts) <- c("date", "volume")
  # convert data frame to time series 
  my.xts <- df2xts(my.ts)
  my.ts.ts <- df2ts(my.ts)
  
  ts.per <- pern(my.xts)
  
  # find monday to split on (for comparison with BMO forecast)
  
  mondays <- my.ts %>%
    mutate(date = as.Date(date)) %>%
    mutate(wday = wday(date), n = row_number()) %>%
    filter(wday == 2) %>%
    select(date)
  
  mondaySplit <- mondays$date[round(0.75*nrow(mondays))]
  
  toSplit <- my.ts %>%
    mutate(model = ifelse(date < mondaySplit, "train", "test")) %>%
    select(date, volume, model)
  
  ## Create Training and Testing Sets
  fullSplit <- toSplit %>%
    arrange(model) %>%
    split(.$model) %>% 
    map(~ select(., -model)) %>%
    map(~ df2ts(.)) %>%
    `names<-`(c("test", "train"))
  
  # split train data for parameter grid search
  split <- datasplit(fullSplit$train)
  
  #Arima Parameter Tester
  parametergrid <- expand.grid(p = c(0:5), d = 0, q = c(0:5) ,P = 1,  D = 0, Q = 1)
  pglen <- dim(parametergrid)[1]
  rmsedf<-matrix(nrow=pglen,ncol=9)
  
  rmsedf <- foreach(i = 1:pglen,.combine=rbind) %do%
    (tryCatch({
      print(i)
      
      for (meth in c("CSS-ML", "ML", "CSS")){
        print(meth)
        arimatrained <- try(Arima(split$train,
                                  order=as.numeric(as.vector(parametergrid[i,1:3])), 
                                  seasonal=as.numeric(as.vector(parametergrid[i,4:6])),
                                  method = meth), silent = T)
        if(!inherits(arimatrained, 'try-error')) break
      }
      
      trainExtend <- split$train
      arimaforecast <- data.frame()
      
      for (j in 1:length(split$test)){
        
        arimatrained <- Arima(trainExtend,
                              model = arimatrained)
        
        arimaforecast <- rbind(arimaforecast, forecast(arimatrained, h=1)$mean[1])
        
        trainExtend <- ts(c(trainExtend, split$test[j]), 
                          start = start(trainExtend),
                          frequency = frequency(trainExtend))
      }
      
      colnames(arimaforecast) <- "Forecast"
      
      ARIMAtmp <- data.frame(arimaforecast$Forecast, split$test, 1:length(split$test))
      
      colnames(ARIMAtmp) <- c("predicted","actual","x")
      print(RMSE(ARIMAtmp$actual, ARIMAtmp$predicted))
      print(AIC(arimatrained))
      data.frame(Model = i,
                 p = as.numeric(parametergrid[i,1]), 
                 d = as.numeric(parametergrid[i,2]),
                 q = as.numeric(parametergrid[i,3]),
                 P = as.numeric(parametergrid[i,4]), 
                 D = as.numeric(parametergrid[i,5]),
                 Q = as.numeric(parametergrid[i,6]),
                 RMSE = RMSE(ARIMAtmp$actual, ARIMAtmp$predicted), 
                 AIC = AIC(arimatrained))
    },
    error = function(x) NA))
  
  meanRMSE <- mean(rmsedf$RMSE %>% na.omit)
  meanAIC <- mean(rmsedf$AIC, na.rm = T)
  
  selectionCrit <- rmsedf %>% mutate(weightedRMSE = RMSE/meanRMSE, weightedAIC = AIC/meanAIC) %>% mutate(metric = (weightedAIC + weightedRMSE)/2)
  
  extractARIMA <- selectionCrit[which.min(selectionCrit$metric),]
  extractARIMA
  
  trainExtend <- fullSplit$train
  arimaforecast <- data.frame()
  
  for (meth in c("CSS-ML", "ML", "CSS")){
    print(meth)
    arimatrained <- try(Arima(fullSplit$train,
                              order= c(extractARIMA$p[1], extractARIMA$d[1], extractARIMA$q[1]), 
                              seasonal= c(extractARIMA$P[1], extractARIMA$D[1], extractARIMA$Q[1]), 
                              method = meth), silent = T)
    if(!inherits(arimatrained, 'try-error')) break
  }
  
  for (i in seq(from = 1, to = length(fullSplit$test), by = 7)){
    
    arimatrained <- Arima(trainExtend,
                          model = arimatrained)
    
    arimaforecast <- rbind(arimaforecast, sum(forecast(arimatrained, h=7)$mean))
    
    trainExtend <- ts(c(trainExtend, fullSplit$test[i:(i+6)]), 
                      start = start(trainExtend), 
                      frequency = frequency(trainExtend))
  }
  
  colnames(arimaforecast) <- "Forecast"
  
  testingDates <- data.frame("date" = my.ts[(length(fullSplit$train) + 1):length(my.ts.ts),1]) %>% as.tbl
  
  weekStarts <- testingDates %>% 
    mutate(wday = wday(date)) %>%
    filter(wday == wday(testingDates$date[1])) %>% 
    select(date)  
  
  forecastDF <- data.frame(value = as.numeric(arimaforecast$Forecast), 
                           time = weekStarts$date) %>% 
    mutate(type = "forecast") %>% 
    head(-1)
  
  weeklyActuals <- data.frame("value" = as.numeric(fullSplit$test)) %>% 
    mutate(week = (row_number()-1) %/% 7) %>%
    group_by(week) %>%
    summarise(volume = sum(value))
  
  actualDF <- data.frame(value = weeklyActuals$volume,
                         time = weekStarts$date) %>%
    mutate(type = "actual") %>% 
    head(-1)
  
  colnames(actualDF) <- c("value", "time", "type")
  colnames(forecastDF) <- c("value", "time", "type")
  
  plotDF <- rbind(forecastDF, actualDF)
  
  plot <- plotDF %>%
    ggplot(aes(x = time, y = value, color = type)) +
    geom_point(alpha = 0.5) +
    geom_line(alpha = 0.5) +
    scale_color_manual(values = cbastylr_corp()) +
    theme_tq()
  
  accuracy <- data.frame(accuracy(forecastDF$value, actualDF$value))
  rmse <- accuracy$RMSE
  mape <- accuracy$MAPE
  parameters <- extractARIMA
  model <- arimatrained
  
  list("Model" = model, 
       "Parameters" = parameters, 
       "RMSE" = rmse,
       "MAPE" = mape,
       "Time.Series" = my.ts,
       "Frequency" = ts.per,
       "Plot" = plot, 
       "Forecast" = forecastDF %>% select(time, value) %>% as.tbl,
       "Actual" = actualDF %>% select(time, value) %>% as.tbl)
}

arima.one.ahead <- function(my.ts)
{  
  colnames(my.ts) <- c("date", "volume")
  # convert data frame to time series 
  my.xts <- df2xts(my.ts)
  my.ts.ts <- df2ts(my.ts)
  
  ts.per <- pern(my.xts)
  
  # create training and tesing set
  fullSplit <- datasplit(my.ts.ts)
  
  # split train data for parameter grid search
  split <- datasplit(fullSplit$train)
  
  #Arima Parameter Tester
  parametergrid <- expand.grid(p = c(0:4), d = 0, q = c(0:4) ,P = c(0:1),  D = 0, Q = c(0:1))
  pglen <- dim(parametergrid)[1]
  rmsedf<-matrix(nrow=pglen,ncol=9)
  
  rmsedf <- foreach(i = 1:pglen,.combine=rbind) %do%
    (tryCatch({
      print(i)
      
      for (meth in c("CSS-ML", "ML", "CSS")){
        print(meth)
        arimatrained <- try(Arima(split$train,
                                  order=as.numeric(as.vector(parametergrid[i,1:3])), 
                                  seasonal=as.numeric(as.vector(parametergrid[i,4:6])),
                                  method = meth), silent = T)
        if(!inherits(arimatrained, 'try-error')) break
      }
      
      trainExtend <- split$train
      arimaforecast <- data.frame()
      
      for (j in 1:length(split$test)){
        
        arimatrained <- Arima(trainExtend,
                              model = arimatrained)
        
        arimaforecast <- rbind(arimaforecast, forecast(arimatrained, h=1)$mean[1])
        
        trainExtend <- ts(c(trainExtend, split$test[j]), 
                          start = start(trainExtend),
                          frequency = frequency(trainExtend))
      }
      
      colnames(arimaforecast) <- "Forecast"
      
      ARIMAtmp <- data.frame(arimaforecast$Forecast, split$test, 1:length(split$test))
      
      colnames(ARIMAtmp) <- c("predicted","actual","x")
      print(RMSE(ARIMAtmp$actual, ARIMAtmp$predicted))
      print(AIC(arimatrained))
      data.frame(Model = i,
                 p = as.numeric(parametergrid[i,1]), 
                 d = as.numeric(parametergrid[i,2]),
                 q = as.numeric(parametergrid[i,3]),
                 P = as.numeric(parametergrid[i,4]), 
                 D = as.numeric(parametergrid[i,5]),
                 Q = as.numeric(parametergrid[i,6]),
                 RMSE = RMSE(ARIMAtmp$actual, ARIMAtmp$predicted), 
                 AIC = AIC(arimatrained))
    },
    error = function(x) NA))
  
  meanRMSE <- mean(rmsedf$RMSE %>% na.omit)
  meanAIC <- mean(rmsedf$AIC %>% na.omit)
  
  selectionCrit <- rmsedf %>% mutate(weightedRMSE = RMSE/meanRMSE, weightedAIC = AIC/meanAIC) %>% mutate(metric = (weightedAIC + weightedRMSE)/2)
  
  extractARIMA <- selectionCrit[which.min(selectionCrit$metric),]
  extractARIMA
  
  trainExtend <- fullSplit$train
  arimaforecast <- data.frame()
  
  for (meth in c("CSS-ML", "ML", "CSS")){
    print(meth)
    arimatrained <- try(Arima(fullSplit$train,
                              order= c(extractARIMA$p[1], extractARIMA$d[1], extractARIMA$q[1]), 
                              seasonal= c(extractARIMA$P[1], extractARIMA$D[1], extractARIMA$Q[1]), 
                              method = meth), silent = T)
    if(!inherits(arimatrained, 'try-error')) break
  }
  
  for (i in 1:length(fullSplit$test)){
    
    arimatrained <- Arima(trainExtend,
                          model = arimatrained)
    
    arimaforecast <- rbind(arimaforecast, sum(forecast(arimatrained, h=1)$mean))
    
    trainExtend <- ts(c(trainExtend, fullSplit$test[i]), 
                      start = start(trainExtend), 
                      frequency = frequency(trainExtend))
  }
  
  colnames(arimaforecast) <- "Forecast"
  
  forecastDF <- data.frame(value = as.numeric(arimaforecast$Forecast), 
                           time = my.ts[(length(fullSplit$train) + 1):length(my.ts.ts),1]) %>% 
    mutate(type = "forecast")  %>% 
    head(-1)
  
  actualDF <- data.frame(value = as.numeric(fullSplit$test),
                         time = my.ts[(length(fullSplit$train) + 1):length(my.ts.ts),1]) %>% 
    mutate(type = "actual") %>% 
    head(-1)
  
  colnames(actualDF) <- c("value", "time", "type")
  colnames(forecastDF) <- c("value", "time", "type")
  
  plotDF <- rbind(forecastDF, actualDF)
  
  plot <- plotDF %>%
    ggplot(aes(x = time, y = value, color = type)) +
    geom_point(alpha = 0.5) +
    geom_line(alpha = 0.5) +
    scale_color_manual(values = cbastylr_corp()) +
    theme_tq()
  
  accuracy <- data.frame(accuracy(forecastDF$value, actualDF$value))
  rmse <- accuracy$RMSE
  mape <- accuracy$MAPE
  parameters <- extractARIMA
  model <- arimatrained
  
  list("Model" = model, 
       "Parameters" = parameters, 
       "RMSE" = rmse,
       "MAPE" = mape,
       "Time.Series" = my.ts,
       "Frequency" = ts.per,
       "Plot" = plot, 
       "Forecast" = forecastDF %>% select(time, value) %>% as.tbl,
       "Actual" = actualDF %>% select(time, value) %>% as.tbl)
}


### RYAN/ARIMA.final.R -------------------
arima.daily.final <- function(my.ts, model, horizon, weekly.data){ # weekly horizon
  
  horizon <- horizon * 7
  names(my.ts) <- c("Date", "Volume")
  names(weekly.data) <- c("Date", "Volume")
  my.ts.ts <- df2ts(my.ts)
  
  arimatrained <- Arima(my.ts.ts,
                        model = model)
  
  arimaforecast <- forecast(arimatrained, h = horizon)
  
  forecast.df <- data.frame("date" = (as.POSIXct(seq(from = tail(my.ts,1)[[1,1]], by = 'd', length.out=(horizon+1))) %>% tail(-1)),
                            "volume" = arimaforecast$mean)
  
  weekStarts <- forecast.df %>% 
    mutate(wday = wday(date)) %>%
    filter(wday == 2) %>% 
    select(date)
  
  weeklyForcast <- forecast.df %>%
    mutate(week = (row_number()-1) %/% 7) %>%
    group_by(week) %>%
    summarise(volume = sum(volume)) %>%
    mutate(date = as_datetime(weekStarts$date)) %>%
    select(date, volume) %>%
    mutate(type = "Forecast")
  
  actual.df <- data.frame(Date = as_datetime(weekly.data$Date),
                          Volume = weekly.data$Volume,
                          Type = "Actual") %>% as.tbl
  
  plot.df <- rbind(actual.df, weeklyForcast)
  
  arimaplot <- ggplot(plot.df, aes(x = Date, y = Volume, colour = Type))  +
    geom_point(alpha = 0.5) +
    geom_line(alpha = 0.5) +
    scale_color_manual(values = cbastylr_corp()) +
    theme_tq()
  
  list("Forecast" = forecast.df, "Plot" = arimaplot)
}

arima.weekly.final <- function(my.ts, model, horizon){
  
  names(my.ts) <- c("Date", "Volume")
  my.ts.ts <- df2ts(my.ts)
  
  arimatrained <- Arima(my.ts.ts,
                        model = model)
  
  arimaforecast <- forecast(arimatrained, h = horizon)
  
  
  forecast.df <- data.frame("Date" = (as_datetime(seq(from = tail(my.ts,1)[[1,1]], by = 'w', length.out=(horizon+1))) %>% tail(-1)),
                            "Volume" = arimaforecast$mean,
                            "Type" = "Forecast")
  
  actual.df <- data.frame("Date" = as_datetime(my.ts$Date),
                          "Volume" = my.ts$Volume,
                          "Type" = "Actual") %>% as.tbl
  
  plot.df <- rbind(actual.df, forecast.df)
  
  arimaplot <- ggplot(plot.df, aes(x = Date, y = Volume, colour = Type)) +
    geom_point(alpha = 0.5) +
    geom_line(alpha = 0.5) +
    scale_color_manual(values = cbastylr_corp()) +
    theme_tq()
  
  list("Forecast" = forecast.df, "Plot" = arimaplot)
}

### RYAN/GLSWestWeekly.R -------------------
#' ---
#' title: "GLS West Weekly Time Series Benchmarking"
#' author: "Ryan Snoyman"
#' date: "16/01/2018"
#' output:
#'   html_document:
#'     highlight: pygments
#'     toc: true
#'     theme: flatly
#' ---

#+ include = F
# R CMD javareconf 
# install.packages("rJava", type="source")
library(rJava)
library(tidyverse)
library(lubridate)
library(teradata.cba)
library(DBI)
library(RJDBC)
library(tidyverse)
library(caret)
library(tidyquant)
library(broom)
library(timekit)
library(timetk)
library(modelr)
library(matrixStats)
library(ggcorrplot)
library(rminer)
library(zeallot)
library(knitr)
library(zoo)
library(forecast)
library(stats)
library(foreach)
library(cbastylr)

source('~/src/snoymary/shinyBMO_1/app/functions/Utilities_for_Time_Series.R')
source('~/src/snoymary/timeseries-final/ARIMA.comp.R')
source('~/src/snoymary/timeseries-final/ARIMA.final.R')
source('~/src/snoymary/timeseries-final/rminer.comp.R')
source('~/src/snoymary/timeseries-final/rminer.final.R')

conn <- gdw_connect(uid="snoymary", pwd =  "Sem12018")

#' We will analyse the following models for each time series:
#' 
#'     1.  BMO benchmark forecast
#'     2.  ARIMA taking weekly data as an input and iteratively predicts 1 week forward
#'     3.  ARIMA taking daily data as an input and iteratively predicts 7 days forward which is aggregated to weekly data
#'     4.  Random Forest taking weekly data as an input
#'     5.  Random Forest taking daily data as an input and aggregating forecast to weekly
#'     6.  MLPE taking weekly data as an input
#'     7.  MLPE Forest taking daily data as an input and aggregating forecast to weekly
#' 
#' The ARIMA models perform a grid search to select its parameters, 
#' selecting a model based on its AIC and its performance on a validation set (using RMSE as a metric).
#' 
#' Using the rminer package, chosing the type of model to run is as easy as supplying a model argument in the function call. 
#' To improve the model, we need to supply some relevant categories to train on and select the best features as well as some highly correlated lags or auto correlations. 
#' We will elaborate on this now.  
#' 
#' Using the `tk_augment_timeseries_signature()` function, we add a number of features based on the properties of our time series signature.  
#' 
#'   * index: The index value that was decomposed
#'   * year: The year component of the index.
#'   * half: The half component of the index.
#'   * quarter: The quarter component of the index.
#'   * month: The month component of the index with base 1.
#'   * month.xts: The month component of the index with base 0, which is what xts implements.
#'   * month.lbl: The month label as an ordered factor beginning with January and ending with December.
#'   * day: The day component of the index.
#'   * wday: The day of the week with base 1. Sunday = 1 and Saturday = 7.
#'   * wday.xts: The day of the week with base 0, which is what xts implements. Sunday = 0 and Saturday = 6.
#'   * wday.lbl: The day of the week label as an ordered factor begining with Sunday and ending with Saturday.
#'   * mday: The day of the month.
#'   * qday: The day of the quarter.
#'   * yday: The day of the year.
#'   * mweek: The week of the month.
#'   * week: The week number of the year (Sunday start).
#'   * week.iso: The ISO week number of the year (Monday start).
#'   * week2: The modulus for bi-weekly frequency.
#'   * week3: The modulus for tri-weekly frequency.
#'   * week4: The modulus for quad-weekly frequency.
#'   * mday7: The integer division of day of the month by seven, which returns the first, second, third, … instance the day has appeared in the month. Values begin at 1. For example, the first Saturday in the month has mday7 = 1. The second has mday7 = 2.    
#'
#' We apply these methods to three of GLS West data sets: Home Loans Transfer, Validations and CMS
#' 

#+ include = F

#' ## Home Loans Transfer Data
#+ include = F
HLTransfer <- run_sql_query(conn, 
                            "SELECT *
                            FROM UDRBSCMS.BMO_CPS_NEW_VOLUME
                            WHERE function_name = 'Home Loans Transfer' AND sub_function_name = 'Home Loans Transfer'
                            ORDER BY calendar_date") %>% as.tbl

HLT <- HLTransfer %>% group_by(calendar_date) %>% summarise(volume = sum(vol_in_new)) 

HLTAdj <- HLT %>%
  right_join(data.frame(date = seq(from = as.Date("2016-01-04"), to = as.Date("2018-01-14"), by = 'd')), by = c("calendar_date" = "date")) %>%
  mutate(wday = wday(calendar_date)) %>%  
  mutate(week = (row_number()-1) %/% 7) 

HLTAdj[is.na(HLTAdj)] = 0

dailyHLT <- HLTAdj[,1:2]

weekHLTStarts <- HLTAdj %>% filter(wday == 2) %>% select(calendar_date)

weeklyHLT <- HLTAdj %>%
  group_by(week) %>%
  summarise(volume = sum(volume)) %>%
  mutate(date = as_datetime(weekHLTStarts$calendar_date)) %>%
  select(date, volume)

HLTF <- run_sql_query(conn, 
                      "SELECT *
                      FROM UDRBSCMS.BMO_NEW_WEEKLY_FORECASTS_W
                      WHERE function_name = 'Home Loans Transfer' AND sub_function_name = 'Home Loans Transfer'
                      ORDER BY week_start_date") %>% as.tbl

HLTForecast <- HLTF %>% filter(week_start_date >= as.Date("2017-07-09")) %>% select(week_start_date, forecast_new_vol)

benchHLTdf <- left_join(weeklyHLT %>% mutate(date = as.Date(date)), HLTForecast, by = c("date" = "week_start_date")) %>% 
  na.omit %>%
  `colnames<-`(c("date", "actual", "forecast"))


plotHLTBench <- benchHLTdf %>% 
  gather("actual", "forecast", key = "type", value = "volume") %>%
  ggplot(aes(x = date, y = volume, color = type)) +
  geom_point(alpha = 0.5) +
  geom_line(alpha = 0.5) +
  scale_color_manual(values = cbastylr_corp()) +
  theme_tq()

accuracyHLTBench <- as.data.frame(accuracy(benchHLTdf$actual, benchHLTdf$forecast))

#' ### 1. Current Benchmark
accuracyHLTBench$RMSE
accuracyHLTBench$MAPE
plotHLTBench

#' ### 2. ARIMA Weekly
#+ include = F
arimaWeekHLT <- arima.one.ahead(weeklyHLT)
#+ echo = T
arimaWeekHLT$RMSE
arimaWeekHLT$MAPE
arimaWeekHLT$Model
arimaWeekHLT$Plot

#' ### 3. ARIMA Daily
#+ include = F
arimaDayHLT <- arima.seven.ahead(dailyHLT)
#+ echo = T
arimaDayHLT$RMSE
arimaDayHLT$MAPE
arimaDayHLT$Model
arimaDayHLT$Plot

#' ### 4. Random Forest Weekly
#+ include = F
rfWeekHLT <- rminer.weekly.comp(weeklyHLT, "randomforest")
#+ echo = T
rfWeekHLT$RMSE
rfWeekHLT$MAPE
rfWeekHLT$Plot

#' ### 5. Random Forest Daily
#+ include = F
rfDayHLT <- rminer.daily.comp(dailyHLT, "randomforest")
#+ echo = T
rfDayHLT$RMSE
rfDayHLT$MAPE
rfDayHLT$Plot

#' ### 6. Artificial Neural Network - Multilayer Perceptron Ensemble Weekly
#+ include = F
nnWeekHLT <- rminer.weekly.comp(weeklyHLT, "mlpe")
#+ echo = T
nnWeekHLT$RMSE
nnWeekHLT$MAPE
nnWeekHLT$Plot

#' ### 7. Artificial Neural Network - Multilayer Perceptron Ensemble  Daily
#+ include = F
nnDayHLT <- rminer.daily.comp(dailyHLT, "mlpe")
#+ echo = T
nnDayHLT$RMSE
nnDayHLT$MAPE
nnDayHLT$Plot

#' ## Validations Data
#+ include = F
Validations <- run_sql_query(conn, 
                             "SELECT *
                             FROM UDRBSCMS.BMO_CPS_NEW_VOLUME
                             WHERE function_name = 'Validations' AND sub_function_name = 'Validations'
                             ORDER BY calendar_date") %>% as.tbl()

val <- Validations %>% group_by(calendar_date) %>% summarise(volume = sum(vol_in_new)) 

valAdj <- val %>%
  right_join(data.frame(date = seq(from = as.Date("2016-01-04"), to = as.Date("2018-01-14"), by = 'd')), by = c("calendar_date" = "date")) %>%
  mutate(wday = wday(calendar_date)) %>%  
  mutate(week = (row_number()-1) %/% 7) 

valAdj[is.na(valAdj)] = 0

dailyVal <- valAdj[,1:2]

weekValStarts <- valAdj %>% filter(wday == 2) %>% select(calendar_date)

weeklyVal <- valAdj %>%
  group_by(week) %>%
  summarise(volume = sum(volume)) %>%
  mutate(date = as_datetime(weekValStarts$calendar_date)) %>%
  select(date, volume)

valF <- run_sql_query(conn, 
                      "SELECT *
                      FROM UDRBSCMS.BMO_NEW_WEEKLY_FORECASTS_W
                      WHERE function_name = 'Validations' AND sub_function_name = 'Validations'
                      ORDER BY week_start_date") %>% as.tbl

valForecast <- valF %>% filter(week_start_date >= as.Date("2017-07-09")) %>% select(week_start_date, forecast_new_vol)

benchValdf <- left_join(weeklyVal %>% mutate(date = as.Date(date)), valForecast, by = c("date" = "week_start_date")) %>% 
  na.omit %>%
  `colnames<-`(c("date", "actual", "forecast"))


plotValBench <- benchValdf %>% 
  gather("actual", "forecast", key = "type", value = "volume") %>%
  ggplot(aes(x = date, y = volume, color = type)) +
  geom_point(alpha = 0.5) +
  geom_line(alpha = 0.5) +
  scale_color_manual(values = cbastylr_corp()) +
  theme_tq()

accuracyValBench <- as.data.frame(accuracy(benchValdf$actual, benchValdf$forecast))

#' ### 1. Current Benchmark
accuracyValBench$RMSE
accuracyValBench$MAPE
plotValBench

#' ### 2. ARIMA Weekly
#+ include = F
arimaWeekVal <- arima.one.ahead(weeklyVal)
#+ echo = T
arimaWeekVal$RMSE
arimaWeekVal$MAPE
arimaWeekVal$Model
arimaWeekVal$Plot

#' ### 3. ARIMA Daily
#+ include = F
arimaDayVal <- arima.seven.ahead(dailyVal)
#+ echo = T
arimaDayVal$RMSE
arimaDayVal$MAPE
arimaDayVal$Model
arimaDayVal$Plot

#' ### 4. Random Forest Weekly
#+ include = F
rfWeekVal <- rminer.weekly.comp(weeklyVal, "randomforest")
#+ echo = T
rfWeekVal$RMSE
rfWeekVal$MAPE
rfWeekVal$Plot

#' ### 5. Random Forest Daily
#+ include = F
rfDayVal <- rminer.daily.comp(dailyVal, "randomforest")
#+ echo = T
rfDayVal$RMSE
rfDayVal$MAPE
rfDayVal$Plot

#' ### 6. Artificial Neural Network - Multilayer Perceptron Ensemble Weekly
#+ include = F
nnWeekVal <- rminer.weekly.comp(weeklyVal, "mlpe")
#+ echo = T
nnWeekVal$RMSE
nnWeekVal$MAPE
nnWeekVal$Plot

#' ### 7. Artificial Neural Network - Multilayer Perceptron Ensemble  Daily
#+ include = F
nnDayVal <- rminer.daily.comp(dailyVal, "mlpe")
#+ echo = T
nnDayVal$RMSE
nnDayVal$MAPE
nnDayVal$Plot

#' ## CMS Data
#+ include = F

cms <- run_sql_query(conn, 
                     "SELECT *
                     FROM UDRBSCMS.BMO_CPS_NEW_VOLUME
                     WHERE function_name = 'CMS' AND sub_function_name = 'CMS'
                     ORDER BY calendar_date") %>% as.tbl

CMS <- cms %>% group_by(calendar_date) %>% summarise(volume = sum(vol_in_new)) 

CMSAdj <- CMS %>%
  right_join(data.frame(date = seq(from = as.Date("2016-09-26"), to = as.Date("2018-01-14"), by = 'd')), by = c("calendar_date" = "date")) %>%
  mutate(wday = wday(calendar_date)) %>%  
  mutate(week = (row_number()-1) %/% 7) 

CMSAdj[is.na(CMSAdj)] = 0

dailyCMS <- CMSAdj[,1:2]

weekCMSStarts <- CMSAdj %>% filter(wday == 2) %>% select(calendar_date)

weeklyCMS <- CMSAdj %>%
  group_by(week) %>%
  summarise(volume = sum(volume)) %>%
  mutate(date = as_datetime(weekCMSStarts$calendar_date)) %>%
  select(date, volume)

CMSF <- run_sql_query(conn, 
                      "SELECT *
                      FROM UDRBSCMS.BMO_NEW_WEEKLY_FORECASTS_W
                      WHERE function_name = 'CMS' AND sub_function_name = 'CMS'
                      ORDER BY week_start_date") %>% as.tbl

CMSForecast <- CMSF %>% filter(week_start_date >= as.Date("2017-10-09")) %>% select(week_start_date, forecast_new_vol)

benchCMSdf <- left_join(weeklyCMS %>% mutate(date = as.Date(date)), CMSForecast, by = c("date" = "week_start_date")) %>% 
  na.omit %>%
  `colnames<-`(c("date", "actual", "forecast"))


plotCMSBench <- benchCMSdf %>% 
  gather("actual", "forecast", key = "type", value = "volume") %>%
  ggplot(aes(x = date, y = volume, color = type)) +
  geom_point(alpha = 0.5) +
  geom_line(alpha = 0.5) +
  scale_color_manual(values = cbastylr_corp()) +
  theme_tq()

accuracyCMSBench <- as.data.frame(accuracy(benchCMSdf$actual, benchCMSdf$forecast))

#' ### 1. Current Benchmark
accuracyCMSBench$RMSE
accuracyCMSBench$MAPE
plotCMSBench

#' ### 2. ARIMA Weekly
#+ include = F
arimaWeekCMS <- arima.one.ahead(weeklyCMS)
#+ echo = T
arimaWeekCMS$RMSE
arimaWeekCMS$MAPE
arimaWeekCMS$Model
arimaWeekCMS$Plot

#' ### 3. ARIMA Daily
#+ include = F
arimaDayCMS <- arima.seven.ahead(dailyCMS)
#+ echo = T
arimaDayCMS$RMSE
arimaDayCMS$MAPE
arimaDayCMS$Model
arimaDayCMS$Plot

#' ### 4. Random Forest Weekly
#+ include = F
rfWeekCMS <- rminer.weekly.comp(weeklyCMS, "randomforest")
#+ echo = T
rfWeekCMS$RMSE
rfWeekCMS$MAPE
rfWeekCMS$Plot

#' ### 5. Random Forest Daily
#+ include = F
rfDayCMS <- rminer.daily.comp(dailyCMS, "randomforest")
#+ echo = T
rfDayCMS$RMSE
rfDayCMS$MAPE
rfDayCMS$Plot

#' ### 6. Artificial Neural Network - Multilayer Perceptron Ensemble Weekly
#+ include = F
nnWeekCMS <- rminer.weekly.comp(weeklyCMS, "mlpe")
#+ echo = T
nnWeekCMS$RMSE
nnWeekCMS$MAPE
nnWeekCMS$Plot

#' ### 7. Artificial Neural Network - Multilayer Perceptron Ensemble  Daily
#+ include = F
nnDayCMS <- rminer.daily.comp(dailyCMS, "mlpe")
#+ echo = T
nnDayCMS$RMSE
nnDayCMS$MAPE
nnDayCMS$Plot

### RYAN/markov_purrr.R -------------------
library(niragen)
support('rJava', 'tidyverse', 'lubridate', 'timetk', 'zoo', 'DBI', 'RJDBC', 
        'eventminr.analytics', 'igraph', 'xts', 'foreach', 'stats', 'forecast', 
        'caret', 'tidyquant', 'broom', 'modelr', 'matrixStats', 'ggcorrplot', 'rminer')

source('script/Utilities_for_Time_Series.R')
source('script/ARIMA.comp.R')
source('script/ARIMA.final.R')
library(RODBC)

set.seed(73)

run_sql_query = function(qry){
  channel         = odbcConnect(dsn = 'Teradata_Prod')
  x = sqlQuery(channel = channel, query = qry)
  close(channel)
  return(x)
}

# Get current backlog status data
current_backlog = run_sql_query(
  "SELECT APPT_I AS case_id, STUS_C AS status, STRT_S as start_dt 
  FROM PVDATA.APPT_STUS_HIST 
  WHERE APPT_I IN (
  SELECT APPT_I 
  FROM PVDATA.APPT 
  WHERE APPT_QLFY_C IN ('HL'))
  AND STRT_S BETWEEN '2016-06-01 00:00:00.000000' AND '2016-07-01 00:00:00.000000' 
  AND END_S >= '2016-07-01 00:00:00.000000'") %>% as.tbl() %>%  mutate(start_dt = as_datetime(start_dt)) 

current_backlog <- current_backlog %>% arrange(case_id, start_dt) %>% unique()

# get historical data to train markov chain model
historical_data <- run_sql_query(
  "SELECT APPT_I AS case_id, STUS_C AS status, STRT_S as start_dt 
  FROM PVDATA.APPT_STUS_HIST 
  WHERE APPT_I IN (
  SELECT APPT_I 
  FROM PVDATA.APPT 
  WHERE APPT_QLFY_C IN ('HL') 
  AND APPT_CRAT_D > '2016-06-01'  
  AND APPT_CRAT_D < '2016-07-01')") %>% as.tbl() %>%  mutate(start_dt = as_datetime(start_dt)) 

historical_data <- historical_data %>% arrange(case_id, start_dt) %>% unique()

# event minr function that creates edge list
historical_fuzzy <- create_fuzzy_data(historical_data,
                                      node_cutoff_vec = 1,
                                      case_label = "case_id",
                                      event_label = "status",
                                      timestamp_label = "start_dt")

# niraprom function that creates edge list:
s = new('TRANSITION.SYSTEM')
s$feedStatusHistory(dataset = historical_data %>% as.data.frame, caseID_colname = 'case_id', status_colname = 'status', startTime_colname = 'start_dt', sort_startTime = T, add_ends = T)
res = s$getAdjacencies()
# transitions.np = res$adjacency %>% rownames2Column('event') %>% melt(id.vars)

# task (node) information
events <- historical_fuzzy[[2]][[1]][[1]] 
# task transitions - edge list
transitions <- historical_fuzzy[[2]][[1]][[2]] 

# mean transition time weights edge list
mean_time_melt <- transitions %>% 
  select(status = event, next_task = next_event, mean_time = time_diff_mean) %>%
  arrange(status, next_task) %>%
  na2zero

# frequency of each transition
# relative frequency of each transition from each node
# cumulative sum of relative frequency to create brackets for uniform distribution 
brackets <- transitions %>% 
  select(status = event, next_task = next_event, n) %>%
  arrange(status, next_task) %>%
  group_by(status) %>%
  mutate(cumulative = cumsum(n)) %>%
  mutate(prob = cumulative/sum(n)) %>%
  ungroup() %>%
  select(status, next_task, prob)

# select next task type based on brackets and random uniform variable
get_next_events <- function(current_backlog, brackets, mean_time_melt) {
  task_join <- current_backlog %>%
    mutate(rand_var = runif(n())) %>%
    left_join(brackets, by = "status") %>%
    left_join(mean_time_melt, by = c("status", "next_task")) %>% na.omit
  
  next_task_and_time <- task_join %>%
    filter(rand_var < prob) %>%
    group_by(case_id, status) %>% # can be altered
    filter(prob == min(prob)) %>%
    ungroup() %>%
    mutate(rexp_time = ifelse(mean_time > 0, rexp(n(), 1/mean_time), 0)) %>%
    select(case_id, status, next_task, start_dt, rexp_time)
  
  next_task_and_time
}

# get training data to forecast fresh arrivals
fresh_arrivals_training <- run_sql_query(
  "SELECT STRT_D as start_dt, COUNT(distinct APPT_I) as fresh_arrivals
  FROM PVDATA.APPT_STUS_HIST 
  WHERE APPT_I IN (
  SELECT APPT_I 
  FROM PVDATA.APPT 
  WHERE APPT_QLFY_C IN ('HL') 
  AND APPT_CRAT_D >= '2015-06-01'  
  AND APPT_CRAT_D < '2017-06-01'
  )
  AND STRT_D >= '2015-06-01'  
  AND STRT_D < '2017-06-01'
  GROUP BY 1
  ORDER BY start_dt;") %>% 
  as.tbl() %>%
  mutate(start_dt = as_datetime(start_dt))

# convert to weekly data
fresh_arrivals_daily <- fresh_arrivals_training %>%
  right_join(data.frame(date = seq(from = as_datetime("2015-06-01"), to = as_datetime("2017-05-31"), by = 'd')), by = c("start_dt" = "date")) %>%
  mutate(wday = wday(start_dt)) %>%  
  mutate(week = (row_number()-1) %/% 7) %>%
  na2zero

weekStarts <- fresh_arrivals_daily %>% filter(wday == 2) %>% select(start_dt)

fresh_arrivals_weekly <- fresh_arrivals_daily %>%
  group_by(week) %>%
  summarise(volume = sum(fresh_arrivals)) %>%
  mutate(date = as_datetime(weekStarts$start_dt)) %>%
  select(date, volume)

ggplot(fresh_arrivals_weekly, aes(date, volume)) + geom_line()

#### find best model (using my created function - do not run. takes too long) ###
# arima_weekly <- arima.one.ahead(fresh_arrivals_weekly)
# ARIMA(1,0,2)

simulate_eventlog.old <- function(current_backlog, fresh_arrivals_training, model, brackets, mean_time_melt, start_date, target_dt) {
  # add fresh arrivals to backlog
  horizon <- difftime(target_dt, start_date, units = "week") %>% as.numeric() %>% round
  
  fresh_arrivals <- df2ts(fresh_arrivals_training) %>% 
    Arima(order = c(1,0,2)) %>% 
    forecast(h = horizon)
  
  fresh_volumes <- fresh_arrivals$mean %>% 
    as.numeric() %>% round
  
  dates <- seq(from = start_date, length.out = horizon, by = "w")
  
  fresh_dates <- foreach(i = 1:horizon, .combine = c) %do% {
    rep(dates[i], times = fresh_volumes[i])
  } 
  
  fresh_bind <- tibble(case_id = paste0("FORECAST", seq(1, sum(fresh_volumes))),
                       status = rep("Start", sum(fresh_volumes)), 
                       start_dt = fresh_dates)
  
  # simulate 
  tracking_backlog <- rbind(current_backlog, fresh_bind)
  final_events <- tibble()
  while(nrow(tracking_backlog) > 0) {
    tracking_backlog <- get_next_events(tracking_backlog, brackets, mean_time_melt)
    # extract completed events and those that wont be completed before target_dt
    final_events <- rbind(final_events, tracking_backlog)
    # remove those rows from tracking and update
    tracking_backlog <- tracking_backlog %>% 
      filter(!(next_task == "End" | (start_date + rexp_time) > target_dt)) %>%
      transmute(case_id, status = next_task, start_dt = start_dt + rexp_time)
  }
  
  final_events %>% arrange(case_id, start_dt)
}

simulate_eventlog <- function(current_backlog, fresh_arrivals_training, brackets, mean_time_melt, start_date, target_dt) {
  
  library(nirats)
  
  x = fresh_arrivals_training %>% TIME.SERIES(time_col = 'start_dt')
  x$goto(as.Date(start_date) - 1)
  x$updateForecast('fresh_arrivals')
  res = x$predictNext(difftime(target_dt, start_date, units = "day") %>% as.numeric)
  res$pred %<>% round
  
  # add fresh arrivals to backlog
  # horizon <- difftime(target_dt, start_date, units = "day") %>% as.numeric() %>% round
  
  #fresh_arrivals <- df2ts(fresh_arrivals_training) %>% 
  #  Arima(order = c(1,0,2)) %>% 
  #  forecast(h = horizon)
  
  #fresh_volumes <- fresh_arrivals$mean %>% 
  #  as.numeric() %>% round
  
  # dates <- seq(from = start_date, length.out = horizon, by = "d")
  dates = names(res$pred) %>% setTZ('GMT')
  
  fresh_dates <- foreach(i = 1:length(dates), .combine = c) %do% {
    rep(dates[i], times = res$pred[i])
  } 
  
  fresh_bind <- tibble(case_id = paste0("FORECAST", seq(1, sum(res$pred))),
                       status = rep("Start", sum(res$pred)), 
                       start_dt = fresh_dates + runif(sum(res$pred), max = 24*3600))
  
  # simulate 
  tracking_backlog <- rbind(current_backlog, fresh_bind)
  # tracking_backlog <- current_backlog
  final_events <- tibble()
  
  
  while(nrow(tracking_backlog) > 0) {
    tracking_backlog <- get_next_events(tracking_backlog, brackets, mean_time_melt) %>% 
      mutate(nxtTrTime = if_else(start_dt > start_date, start_dt, start_date) + rexp_time)
    # extract completed events and those that wont be completed before target_dt
    final_events <- rbind(final_events, tracking_backlog)
    # remove those rows from tracking and update
    tracking_backlog <- tracking_backlog %>% 
      filter(!(next_task == "End" | nxtTrTime > target_dt)) %>%
      transmute(case_id, status = next_task, start_dt = nxtTrTime)
  }
  
  final_events %>% arrange(case_id, start_dt)
}



future_eventlog <- simulate_eventlog(current_backlog, fresh_arrivals_daily, brackets, mean_time_melt, start_date = as_datetime('2016-07-01'), target_dt = as_datetime('2016-07-05'))
future_eventlog # %>% filter(str_detect(case_id, "FORECAST")) %>% mutate(rexp_days = round(rexp_time/60/60/24))


f2 = future_eventlog %>% filter(start_dt < as_datetime('2016-07-02')) %>% filter(nxtTrTime > as_datetime('2016-07-02'))

b2 <- f2 %>% 
  group_by(case_id) %>% 
  filter(start_dt == max(start_dt)) %>%
  ungroup() %>%
  group_by(status) %>%
  summarise(estimated = n())

backlog <- future_eventlog %>% 
  group_by(case_id) %>% 
  filter(start_dt == max(start_dt)) %>%
  ungroup() %>%
  group_by(status) %>%
  summarise(estimated = n())

varify_backlog <- run_sql_query( 
  "SELECT STUS_C AS status, count(distinct(APPT_I)) AS actual
  FROM PVDATA.APPT_STUS_HIST 
  WHERE APPT_I IN (
  SELECT APPT_I 
  FROM PVDATA.APPT 
  WHERE APPT_QLFY_C IN ('HL'))
  AND STRT_S BETWEEN '2016-06-01 00:00:00.000000' AND '2016-07-02 00:00:00.000000' 
  AND END_S >= '2016-07-02 00:00:00.000000'
  GROUP BY 1") %>% as.tbl() %>% arrange(status)

comparison <- left_join(varify_backlog, b2, by = "status") %>% mutate(difference = (actual - estimated)/actual)

comparison %>% gather("actual", "estimated", key = "type", value = "volume") %>% 
  ggplot() +
  geom_col(aes(x = status, y = volume, fill = type), position ="dodge")

D = run_sql_query("SELECT * 
                  FROM PVDATA.APPT 
                  WHERE APPT_QLFY_C IN ('HL') 
                  AND APPT_CRAT_D > '2016-06-01'  
                  AND APPT_CRAT_D < '2016-07-01'")

### RYAN/rminer.comp.R -------------------
rminer.daily.comp <- function(my.ts, method){
  
  my.ts.ts <- df2ts(my.ts)
  ts.split <- datasplit(my.ts.ts)
  
  names(my.ts) <- c("Date", "Volume")
  
  # find monday to split on (for comparison with BMO forecast)
  mondays <- my.ts %>%
    mutate(Date = as.Date(Date)) %>%
    mutate(wday = wday(Date)) %>%
    filter(wday == 2) %>%
    select(Date)
  
  mondaySplit <- mondays$Date[round(0.75*nrow(mondays))]
  
  toSplit <- my.ts %>%
    mutate(model = ifelse(Date < mondaySplit, "train", "test")) %>%
    select(Date, Volume, model)
  
  ## Create Training and Testing Sets
  ts.split <- toSplit %>%
    arrange(model) %>%
    split(.$model) %>% 
    map(~ select(., -model)) %>%
    map(~ df2ts(.)) %>%
    `names<-`(c("test", "train"))
  
  H <- length(ts.split$test) # number of ahead predictions
  
  full <- my.ts %>%
    mutate(Date = as_datetime(Date)) %>%
    mutate(n = 1:nrow(my.ts)) %>%
    mutate(model = ifelse(n <= length(ts.split$train) , "train", "test")) %>%
    select(Date, Volume, model) %>% 
    tk_augment_timeseries_signature() %>% 
    as.tbl %>% 
    select(-c(index.num, diff, Date))
  
  
  ## Convert Dates/Times to Factors
  clean_full <- full %>%
    mutate_at(vars(-c(1:2)), as.factor) %>%
    rename(y = Volume) %>%
    select(-c(1:2), c(1:2)) %>%
    select_if(~ is.numeric(.) || (n_distinct(.) > 1) && (n_distinct(.) < 53)) 
  
  acf <- 14
  lags <- CasesSeries(my.ts.ts, 1:acf) %>% as.tbl()
  
  clean_lags <- bind_cols(clean_full[-(1:acf),], lags[,-ncol(lags)])
  
  ## Create Training and Testing Sets
  clean_lags %>%
    arrange(model) %>%
    split(.$model) %>% 
    map(~ select(., -model)) %->% 
    c(test, train)
  
  model_ready_full <- select(clean_lags, -model)
  
  ## Get Column Names
  columnNames <- colnames(model_ready_full)
  
  ## Get Pr ANOVA Correlation Metric for each column of train
  getPR <- function(x, dat) {
    form <- paste0("y ~ ", x) %>% as.formula
    f <- aov(form, data = dat)
    summary(f)[[1]][["Pr(>F)"]][[1]]
  }
  
  # Select those column where Pr < 5%
  cols_to_keep <- columnNames %>%
    discard(~ . == 'y') %>% # Don't get PR for response variable
    keep(~ !is.null(getPR(., train)) && (getPR(., train) < 0.05))
  
  list(model_ready_full, train, test) %>%
    map(select, one_of(cols_to_keep), y) %->%
    c(pred_full, pred_train, pred_test)
  
  ## Train Model
  model <- rminer::fit(y ~., data = as.data.frame(pred_train), task="reg", model= method)
  
  ## Make Forecast
  split.df <- my.ts %>%
    mutate(Date = as.POSIXct(Date)) %>%
    mutate(n = 1:nrow(full)) %>%
    mutate(model = ifelse(n <= length(ts.split$train) , "train", "test")) %>%
    select(Date, Volume, model) %>%
    tail(-acf)
  
  test_results <- pred_test %>%
    mutate(predicted = predict(model, .)) %>%
    mutate(Date = split.df %>% dplyr::filter(model == 'test') %>% pull(Date)) %>%
    select(Date, y, predicted) %>%
    `colnames<-`(c("date", "actual", "forecast"))
  
  weekStarts <- test_results %>% 
    mutate(wday = wday(date)) %>%
    filter(wday == 2) %>% 
    select(date)
  
  weeklyForcast <- test_results %>%
    mutate(week = (row_number()-1) %/% 7) %>%
    group_by(week) %>%
    summarise(volume = sum(forecast)) %>%
    mutate(date = as_datetime(weekStarts$date)) %>%
    select(date, volume) %>%
    mutate(type = "forecast")
  
  weeklyActual <- test_results %>%
    mutate(week = (row_number()-1) %/% 7) %>%
    group_by(week) %>%
    summarise(volume = sum(actual)) %>%
    mutate(date = as_datetime(weekStarts$date)) %>%
    select(date, volume) %>%
    mutate(type = "actual")
  
  weeklyPlot <- rbind(weeklyForcast, weeklyActual) %>% 
    ggplot(aes(x = date, y = volume, color = type)) +
    geom_point(alpha = 0.5) +
    geom_line(alpha = 0.5) +
    scale_color_manual(values = cbastylr_corp()) +
    theme_tq()
  
  weeklyAccuracy <- as.data.frame(accuracy(weeklyActual$volume, weeklyForcast$volume))
  
  rmse <- weeklyAccuracy$RMSE
  mape <- weeklyAccuracy$MAPE
  
  list("Time.Series" = my.ts, "RMSE" = rmse, "MAPE" = mape, "Plot" = weeklyPlot, "Actuals" = weeklyActual, "Forecast" = weeklyForcast)
}

rminer.weekly.comp <- function(my.ts, method){
  
  my.ts.ts <- df2ts(my.ts)
  ts.split <- datasplit(my.ts.ts)
  
  H <- length(ts.split$test) # number of ahead predictions
  names(my.ts) <- c("Date", "Volume")
  
  full <- my.ts %>%
    mutate(Date = as_datetime(Date)) %>%
    mutate(n = 1:nrow(my.ts)) %>%
    mutate(model = ifelse(n <= length(ts.split$train) , "train", "test")) %>%
    select(Date, Volume, model) %>% 
    tk_augment_timeseries_signature() %>% 
    as.tbl %>% 
    select(-c(index.num, diff, Date))
  
  
  ## Convert Dates/Times to Factors
  clean_full <- full %>%
    mutate_at(vars(-c(1:2)), as.factor) %>%
    rename(y = Volume) %>%
    select(-c(1:2), c(1:2)) %>%
    select_if(~ is.numeric(.) || (n_distinct(.) > 1) && (n_distinct(.) < 53)) 
  
  acf <- 5
  lags <- CasesSeries(my.ts.ts, 1:acf) %>% as.tbl()
  
  clean_lags <- bind_cols(clean_full[-(1:acf),], lags[,-ncol(lags)])
  
  ## Create Training and Testing Sets
  clean_lags %>%
    arrange(model) %>%
    split(.$model) %>% 
    map(~ select(., -model)) %->% 
    c(test, train)
  
  model_ready_full <- select(clean_lags, -model)
  
  ## Get Column Names
  columnNames <- colnames(model_ready_full)
  
  ## Get Pr ANOVA Correlation Metric for each column of train
  getPR <- function(x, dat) {
    form <- paste0("y ~ ", x) %>% as.formula
    f <- aov(form, data = dat)
    summary(f)[[1]][["Pr(>F)"]][[1]]
  }
  
  # Select those column where Pr < 5%
  cols_to_keep <- columnNames %>%
    discard(~ . == 'y') %>% # Don't get PR for response variable
    keep(~ !is.null(getPR(., train)) && (getPR(., train) < 0.05))
  
  list(model_ready_full, train, test) %>%
    map(select, one_of(cols_to_keep), y) %->%
    c(pred_full, pred_train, pred_test)
  
  ## Train Model
  model <- rminer::fit(y ~., data = as.data.frame(pred_train), task="reg", model= method)
  
  ## Make Forecast
  split.df <- my.ts %>%
    mutate(Date = as.POSIXct(Date)) %>%
    mutate(n = 1:nrow(full)) %>%
    mutate(model = ifelse(n <= length(ts.split$train) , "train", "test")) %>%
    select(Date, Volume, model) %>%
    tail(-acf)
  
  test_results <- pred_test %>%
    mutate(predicted = predict(model, .)) %>%
    mutate(Date = split.df %>% dplyr::filter(model == 'test') %>% pull(Date))
  
  final_train <- pred_train %>%
    mutate(Date = split.df %>% dplyr::filter(model == 'train') %>% pull(Date))
  
  ## RMSE
  
  accuracy <- as.data.frame(accuracy(test_results$y, test_results$predicted))
  
  rmse <- accuracy$RMSE
  mape <- accuracy$MAPE
  
  plot.df <- data.frame(test_results$Date, test_results$y, test_results$predicted) %>%
    `colnames<-`(c("date", "actual", "forecast")) %>%
    gather("actual", "forecast", key = "type", value = "value")
  
  Plot <- plot.df %>% ggplot(aes(x = date, y = value, color = type)) +
    geom_point(alpha = 0.5) +
    geom_line(alpha = 0.5) +
    scale_color_manual(values = cbastylr_corp()) +
    theme_tq()
  
  actualDF <- select(test_results, Date, y)
  forecastDF <- select(test_results, Date, predicted)
  
  colnames(actualDF) <- c("date", "volume")
  colnames(forecastDF) <- c("date", "volume")
  
  list("Time.Series" = my.ts, "RMSE" = rmse, "MAPE" = mape, "Plot" = Plot, "Actuals" = actualDF, "Forecast" = forecastDF)
}


### RYAN/rminer.final.R -------------------
rminer.daily.final <- function(my.ts, method, horizon, weekly.data){ #weekly horizon
  
  my.ts.ts <- df2ts(my.ts)
  colnames(my.ts) <- c("Date", "Volume")
  colnames(weekly.data) <- c("Date", "Volume")
  
  full <- my.ts %>%
    mutate(Date = as_datetime(Date)) %>%
    select(Date, Volume) %>% 
    tk_augment_timeseries_signature() %>% 
    as.tbl %>% 
    select(-c(index.num, diff, Date))
  
  ## Convert Dates/Times to Factors
  clean_full <- full %>%
    mutate_at(vars(-1), as.factor) %>%
    rename(y = Volume) %>%
    select(-1, 1) %>%
    select_if(~ is.numeric(.) || (n_distinct(.) > 1) && (n_distinct(.) < 53)) 
  
  acf <- 14
  lags <- CasesSeries(my.ts.ts, 1:acf) %>% as.tbl()
  
  clean_lags <- bind_cols(clean_full[-(1:acf),], lags[,-ncol(lags)])
  
  ## Get Column Names
  columnNames <- colnames(clean_lags)
  
  ## Get Pr ANOVA Correlation Metric for each column of train
  getPR <- function(x, dat) {
    form <- paste0("y ~ ", x) %>% as.formula
    f <- aov(form, data = dat)
    summary(f)[[1]][["Pr(>F)"]][[1]]
  }
  
  # Select those column where Pr < 5%
  cols_to_keep <- columnNames %>%
    discard(~ . == 'y') %>% # Don't get PR for response variable
    keep(~ !is.null(getPR(., clean_lags)) && (getPR(., clean_lags) < 0.05))
  
  train <- as.data.frame(select(clean_lags, one_of(cols_to_keep), y))
  
  ## Train Model
  max <- 1200
  options(warn=2)
  while(TRUE){
    print(max)
    model <- try(rminer::fit(y ~., data = train, task="reg", model = "mlpe", MaxNWts = max), silent = T)
    if(!inherits(model, 'try-error')) break
    max <- max * 2
  }
  
  test_results <- train[1:(horizon*7),] %>%
    transmute(date = (as_datetime(seq(from = tail(my.ts,1)[[1,1]], by = 'd', length.out=(horizon*7+1)))) %>% tail(-1),
              forecast = predict(model, .))
  
  weekStarts <- test_results %>% 
    mutate(wday = wday(date)) %>%
    filter(wday == 2) %>% 
    select(date)
  
  weeklyForcast <- test_results %>%
    mutate(week = (row_number()-1) %/% 7) %>%
    group_by(week) %>%
    summarise(volume = sum(forecast)) %>%
    mutate(date = as_datetime(weekStarts$date)) %>%
    select(date, volume) %>%
    mutate(type = "Forecast")
  
  actual.df <- data.frame(date = as_datetime(weekly.data$Date),
                          volume = weekly.data$Volume,
                          type = "Actual") %>% as.tbl
  
  weeklyPlot <- rbind(weeklyForcast, actual.df) %>% 
    ggplot(aes(x = date, y = volume, color = type)) +
    geom_point(alpha = 0.5) +
    geom_line(alpha = 0.5) +
    scale_color_manual(values = cbastylr_corp()) +
    theme_tq()
  
  list("Plot" = weeklyPlot, "Forecast" = weeklyForcast)
}

rminer.weekly.final <- function(my.ts, method, horizon){ #weekly horizon
  
  my.ts.ts <- df2ts(my.ts)
  colnames(my.ts) <- c("Date", "Volume")
  
  full <- my.ts %>%
    mutate(Date = as_datetime(Date)) %>%
    select(Date, Volume) %>% 
    tk_augment_timeseries_signature() %>% 
    as.tbl %>% 
    select(-c(index.num, diff, Date))
  
  ## Convert Dates/Times to Factors
  clean_full <- full %>%
    mutate_at(vars(-1), as.factor) %>%
    rename(y = Volume) %>%
    select(-1, 1) %>%
    select_if(~ is.numeric(.) || (n_distinct(.) > 1) && (n_distinct(.) < 53)) 
  
  acf <- 14
  lags <- CasesSeries(my.ts.ts, 1:acf) %>% as.tbl()
  
  clean_lags <- bind_cols(clean_full[-(1:acf),], lags[,-ncol(lags)])
  
  ## Get Column Names
  columnNames <- colnames(clean_lags)
  
  ## Get Pr ANOVA Correlation Metric for each column of train
  getPR <- function(x, dat) {
    form <- paste0("y ~ ", x) %>% as.formula
    f <- aov(form, data = dat)
    summary(f)[[1]][["Pr(>F)"]][[1]]
  }
  
  # Select those column where Pr < 5%
  cols_to_keep <- columnNames %>%
    discard(~ . == 'y') %>% # Don't get PR for response variable
    keep(~ !is.null(getPR(., clean_lags)) && (getPR(., clean_lags) < 0.05))
  
  train <- as.data.frame(select(clean_lags, one_of(cols_to_keep), y))
  
  ## Train Model
  max <- 1200
  options(warn=2)
  while(TRUE){
    print(max)
    model <- try(rminer::fit(y ~., data = train, task="reg", model = "mlpe", MaxNWts = max), silent = T)
    if(!inherits(model, 'try-error')) break
    max <- max * 2
  }
  
  forecast.df <- train[1:horizon,] %>%
    transmute(date = (as_datetime(seq(from = tail(my.ts,1)[[1,1]], by = 'w', length.out=(horizon+1)))) %>% tail(-1),
              volume = predict(model, .),
              type = "Forecast")
  
  actual.df <- data.frame("date" = as_datetime(my.ts$Date),
                          "volume" = my.ts$Volume,
                          "type" = "Actual") %>% as.tbl
  
  weeklyPlot <- rbind(forecast.df, actual.df) %>% 
    ggplot(aes(x = date, y = volume, color = type)) +
    geom_point(alpha = 0.5) +
    geom_line(alpha = 0.5) +
    scale_color_manual(values = cbastylr_corp()) +
    theme_tq()
  
  list("Plot" = weeklyPlot, "Forecast" = weeklyForcast)
}

### RYAN/Utilities4ts.R -------------------
## Utilities for Time Series ##

#Load Utils

getArimaq <- function(x, max_q){ # x is a time series or vector
  a <- Acf(x)
  acf.vector <- data.frame(acf = abs(a$acf[,,1]), lag = 0:(nrow(a$acf)-1)) %>% 
    mutate(threshold = 1.96/sqrt(a$n.used)) %>%
    filter(acf >= threshold) %>%
    mutate(lag_lead = lead(lag)) %>%
    mutate(lag_diff = lag_lead - lag) %>%
    filter(lag_diff != 1 | is.na(lag_diff)) %>%
    filter(lag <= max_q & lag > 0)
  
  if(length(acf.vector$lag) == 0) {
    return(max_q)
  }
  
  return(acf.vector$lag)}

getArimap <- function(x, max_p){ # x is a time series or vector
  a <- Pacf(x)
  pacf.vector <- data.frame(acf = abs(a$acf[,,1]), lag = 0:(nrow(a$acf)-1)) %>% 
    mutate(threshold = 1.96/sqrt(a$n.used)) %>%
    filter(acf >= threshold) %>%
    mutate(lag_lead = lead(lag)) %>%
    mutate(lag_diff = lag_lead - lag) %>%
    filter(lag_diff != 1 | is.na(lag_diff)) %>%
    filter(lag <= max_p & lag > 0)
  
  if(length(pacf.vector$lag) == 0) {
    return(max_p)
  }
  
  return(pacf.vector$lag)
  
}

timeseries.subset <- function(ts, start_idx, end_idx) {
  window(ts, time(ts)[start_idx], time(ts)[end_idx])
}

timeseries.training <- function(ts, size = 0.8) {
  len <- length(time(ts))
  timeseries.subset(ts, 1, size * len)
}

timeseries.testing <- function(ts, size = 0.2, training.length) {
  len <- length(time(ts))
  timeseries.subset(ts, training.length+1, len)
}

# Periodicity to Numeric
pern <- function(ts){
  switch(periodicity(ts)$scale,
         "hourly" = 24,
         "daily" = 14,
         "weekly" = 52,
         "monthly" = 12,
         "quarterly" = 4,
         "yearly" = 1)
}

# Convert Data Frame to X Times Series
df2xts <- function(time.s){
  ZOO <- zoo(as.data.frame(time.s)[,2], 
             order.by=as.Date(as.character(as.data.frame(time.s)[,1])))
  
  timeStamp <- tk_augment_timeseries_signature(time.s %>% head(1))
  
  start.vector <- switch(periodicity(ZOO)$scale,
                         "hourly" = c(timeStamp$year, (timeStamp$yday*24 + timeStamp$hour)),
                         "daily" = 1,
                         "weekly" = c(timeStamp$year, timeStamp$week),
                         "monthly" = c(timeStamp$year, timeStamp$month),
                         "quarterly" = c(timeStamp$year, timeStamp$quarter),
                         "yearly" = timeStamp$year)
  scale.of <- pern(ZOO)
  
  xts(ZOO,
      start = start.vector,
      frequency = scale.of)
}

df2ts <- function(time.s){
  ZOO <- zoo(as.data.frame(time.s)[,2], 
             order.by=as.Date(as.character(as.data.frame(time.s)[,1])))
  
  timeStamp <- tk_augment_timeseries_signature(time.s %>% head(1))
  
  start.vector <- switch(periodicity(ZOO)$scale,
                         "hourly" = c(timeStamp$year, (timeStamp$yday*24 + timeStamp$hour)),
                         "daily" = 1,
                         "weekly" = c(timeStamp$year, timeStamp$week),
                         "monthly" = c(timeStamp$year, timeStamp$month),
                         "quarterly" = c(timeStamp$year, timeStamp$quarter),
                         "yearly" = timeStamp$year)
  scale.of <- pern(ZOO)
  
  ts(ZOO,
     start = start.vector,
     frequency = scale.of)
}


# Split Function
datasplit <- function(timeseries){
  train <- timeseries.training(timeseries)
  test <- timeseries.testing(timeseries,training.length = length(time(train)))
  
  
  A<-list(train, test)
  names(A)<-c("train", "test")
  A
}

# Standardise Date Format - ymd

# Time must be in "%Y-%m-%d" or "%Y/%m/%d" format. Year must be 4 digitd i.e. 1996/07/16
# Time Column must be first

stand.date <- function(my.ts){
  colnames(my.ts) <- c("date", "volume")
  mutate(my.ts, date = as.Date(my.ts$date))
}


###### project wim_forecast =========================
### skillVolAnal.R -------------------
rm(list=ls())
library(RODBC)
library(magrittr)
library(niragen)
library(reshape2)
library(dplyr)
library(nirats)

# source('C:/Nima/RCode/projects/libraries/developing_packages/niragen.R')

# source('C:/Nima/RCode/projects/libraries/developing_packages/time.series.R')

source('C:/Nima/RCode/projects/cba/wim_forecast/script/tools.R')

query   = "sel calendar_date,L1_cat_topupevent,sum(vol_in) as vol_in,sum(vol_out) as vol_out, sum(backlog_start ) as backlog
from udrbscms.HL_Topup_dailyVol_perEvent 
group by calendar_date,L1_cat_topupevent
"
channel = odbcConnect(dsn = 'Teradata_Prod')
Dt      = sqlQuery(channel = channel, query = query)
close(channel)

Dt %<>% arrange(calendar_date)

skills = Dt$L1_cat_topupevent %>% unique %>% as.character
target = 'Top Up After Care'

vo     = Dt %>% dcast(calendar_date ~ L1_cat_topupevent, value.var = 'vol_out', fun.aggregate = sum)
volags = vo %>% column2Rownames('calendar_date') %>% as.matrix %>% addLags(keep = F) %>% na.omit

bl     = Dt %>% dcast(calendar_date ~ L1_cat_topupevent, value.var = 'backlog', fun.aggregate = sum)    
bllags = bl %>% column2Rownames('calendar_date') %>% as.matrix %>% addLags(keep = F) %>% na.omit 

yy  = Dt[Dt$L1_cat_topupevent == target, 'vol_in'][-(1:14)]

# Without ARIMA:
sig = cbind(volags[1:300,], yy[1:300]) %>% evaluate()

v = volags %>% TIME.SERIES
v$append(yy, 'Y')

v$goto(300)
v$now()
v$updateForecast(figures = 'Y')
res = v$predictNext(v$N.int - v$ctn)
res$pred[res$pred < 0] = 0
res$pred[names(res$pred)] %<>% as.integer
v$data[names(res$pred), 'arima'] = res$pred

y = v$data$Y[1:300]
x = v$data[1:300, sig$sig.feature.names] %>% as.matrix

yt = v$data$Y[301:v$N.int]
xt = v$data[301:v$N.int, sig$sig.feature.names]

model = glm(y~x)

prd = model %>% predict_glm_fit(xt)
sqrt(sum((yt - prd[,1])^2)/nrow(prd))
sqrt(sum((v$data[rownames(prd),'Y'] - v$data[rownames(prd),'arima'])^2)/nrow(prd))

v$data[rownames(prd), 'reg'] = prd[,1]
library(niravis)
v$goto(v$N.int)
v$plot.history(figures = c('Y', 'arima', 'reg'))

w = which(abs(v$data$arima - v$data$Y) > abs(v$data$reg - v$data$Y))
v$data$best = 'arima'
v$data$best[w] = 'reg'
View(v$data[301:v$N.int, c('Y', 'arima', 'reg', 'best')])
v$data$best[301:v$N.int] %>% table

### teamVolAnal.R -------------------
rm(list=ls())
library(RODBC)
library(magrittr)
library(niragen)
library(reshape2)
library(dplyr)

source('C:/Nima/RCode/projects/libraries/developing_packages/niragen.R')

source('C:/Nima/RCode/projects/cba/wim_forecast/script/tools.R')

query   = "SELECT calendar_date , Team_name , sum(vol_in) AS vol_in, sum(vol_out) AS vol_out, sum(backlog_start) AS backlog from UDRBSCMS.HL_Topup_dailyVol1 WHERE calendar_date > '2016-01-01' GROUP BY  calendar_date , Team_name"
channel = odbcConnect(dsn = 'Teradata_Prod')
Dt      = sqlQuery(channel = channel, query = query)
close(channel)

Dt %<>% arrange(calendar_date)

teams  = Dt$Team_name %>% unique %>% as.character
target = "MORTGAGE SERVICES CUSTODY TEAM (SYD)"

vo     = Dt %>% dcast(calendar_date ~ Team_name, value.var = 'vol_out', fun.aggregate = sum)
volags = vo %>% column2Rownames('calendar_date') %>% as.matrix %>% addLags(keep = F) %>% na.omit

bl     = Dt %>% dcast(calendar_date ~ Team_name, value.var = 'backlog', fun.aggregate = sum)    
bllags = bl %>% column2Rownames('calendar_date') %>% as.matrix %>% addLags(keep = F) %>% na.omit 

y  = Dt[Dt$Team_name == target,'vol_in'][-(1:14)]


# Without ARIMA:
res = cbind(volags, y) %>% evaluate

v = volags %>% TIME.SERIES
v$append(y, 'Y')
v$goto(332)
v$now()

v$updateForecast(figures = 'Y')
res = v$predictNext(100)
v$data[names(res$pred), 'forec'] = res$pred

v$jump(100)
v$now()
v$updateForecast(figures = 'Y')
res = v$predictNext(100)
v$data[names(res$pred), 'forec'] = res$pred

v$jump(100)
v$now()

w = which(names(v) == 'Y')

v$data = v$data[, c(sequence(w - 1), w + 1, w)]
names(v$data) %>% tail

v$data %>% evaluate(start = 109)
debug(evaluate)

### script/find_predictors.R -------------------
# Header
# Filename:     find_predictors.R
# Description:  We are trying to search and select a set of predictors and their combinations 
#               in order to predict future candles with maximum adjusted r squared (target: %50)
# Author:       Nima Ramezani Taghiabadi
# Email :       N.RamezaniTaghiabadi@uws.edu.au
# Date:         26 September 2013
# Version:      3.0
# Changes from previous version:

# First all the raw data are read from csv file and then 
# all combinations of figures are 
# function evaluate is modified. It gets the raw data and a list of column numbers as input 

# File: init.R must be in the working directory

evaluate <- function (D, start = 1, history.intervals = floor((nrow(D)-start+1)*2/3), tfun = function(x){x}, tfun.inv = tfun) {
  N = dim(D)[1]
  m = dim(D)[2]
  
  X = D[start:(history.intervals + start - 1), 1:(m - 1)]
  y = D[start:(history.intervals + start - 1), m] %>% tfun
  
  Xt = D[(history.intervals + start):N, 1:(m - 1)]
  yt = D[(history.intervals + start):N, m ] %>% tfun
  
  # X = scale(X, center = FALSE)
  # sorting the predictors based on R squared in a linear regression with single regressor
  # Number of predictors: m-1
  
  ter = c()
  bstmdl = NULL
  
  CC  = cor(x = X, y = y, method = "pearson") %>% na2zero
  index = order(CC, decreasing=TRUE)
  CC = CC[index]
  index = index[CC > 0.1]
  if(is.empty(index)){return(NULL)}
  
  X   = X[,index]
  Xt  = Xt[,index]
  
  # Construct the initial model using the best predictor
  A  = X[,1]
  At = Xt[,1, drop = F]
  
  fig.index = index[1]
  # Set zero as the initial value of r adjusted
  
  # reg = glm.fit(x = A, y = y)
  reg = glm(y ~ A)
  rss = sum(reg$residuals^2)
  dfr = length(reg$coefficients)
  # prediction accuracy with test data:
  prd = reg %>% predict_glm_fit(At, addintercept = !(ncol(At) %>% equals(reg$coefficients %>% length)))
  pss = sum(((prd[,1] %>% tfun.inv) - (yt %>% tfun.inv))^2)
  
  for (i in sequence(index %>% length) %-% 1){
    # Add predictor to the model
    A_new  = cbind(A, X[,i])
    At_new = cbind(At, Xt[,i, drop = F])
    colnames(At_new)  <- c(colnames(At), colnames(X)[i])
    colnames(A_new) <- colnames(At_new)
    # Run the regression
    # reg     = try(glm.fit(y = y, x = A_new), silent = T)
    reg     = try(glm(y ~ A_new), silent = T)
    
    if(!inherits(reg, 'try-error')){
      prd_new = reg %>% predict_glm_fit(At_new)
      pss_new = sum(((prd_new[,1] %>% tfun.inv) - (yt %>% tfun.inv))^2)
      # If successful, replace it with the new model
      permit = pss_new < pss
      if(is.na(permit)){permit = F}
      
      if(permit){
        sum.reg = summary(reg)
        dftest  = nrow(At_new) - dfr
        ft      = dftest*(pss - pss_new)/pss_new
        pvlt    = pf(ft, 1, dftest, lower.tail = F)
        ter_new = sqrt(pss_new/length(yt))
        rss_new = sum(reg$residuals^2)
        fstats  = ((rss - rss_new)*reg$df.residual)/(rss_new)
        pvl     = pf(fstats, 1, reg$df.residual, lower.tail = F)
        pvls    = sum.reg$coefficients[-1, "Pr(>|t|)"]
        det     = det(t(A_new) %*% A_new)
        permit  = !equals(det, 0) & (sum(pvls > 0.05, na.rm = T) %>% equals(0)) & (pvl < 0.05) & (pvlt < 0.05)
        
        if(is.na(permit)){permit = F}
      }
      
      if (permit){
        cat("Det            = ", det, "\n")
        cat("Test Error     = ", ter_new, "\n")
        cat("F Statistics   = ", fstats, "\n")
        cat("P-Value        = ", pvl, "\n \n")
        A   = A_new
        At  = At_new
        rss = rss_new
        pss = pss_new
        fig.index = c(fig.index, index[i])
        bstmdl  = reg
        names(bstmdl$coefficients)[-1] = colnames(A)
        fig.names = colnames(A)
        ter = c(ter, ter_new)
      }
    }
  }
  
  output = list(sig.feature.values = A, sig.feature.indexes = fig.index, sig.feature.names = fig.names,test.error = ter, model = bstmdl)
  return(output)
}



#gold.fig = rbind(fig[result$significant.predictor.indexes,], fig[n.fig,])




### script/genTables.R -------------------
library(RODBC)
library(niragen)
library(reshape2)
library(dplyr)

D = readODBC(tableName = 'HL_Topup_dailyVol1', 
             fields = c('calendar_date', 'team_name', 'wim_actv_type_m', 'vol_in', 'vol_out', 'backlog_start'),
             dbName = 'UDRBSCMS', 
             dsn  = 'Teradata_Prod')

A = D %>% dcast(calendar_date ~ WIM_ACTV_TYPE_M, value.var = 'vol_in', fun.aggregate = sum) 

addLags = function(A, lags, columns, date_col){
  for(lag in lags){
    A %>% column.shift.up()
  }
}



A %>% column.shift.up(col = 'Top Up Applications Follow Up', k = 1, keep)

A %>% column.shift.down(col = 1:2, k = 1)

A[,'A'] %>% vect.shift.down(k = 3, keep.rows=TRUE)

### script/nextGenRegModels.R -------------------
rm(list=ls())
library(RODBC)
library(niragen)
library(reshape2)
library(dplyr)
source('C:/Nima/RCode/projects/cba/wim_forecast/script/tools.R')

D = readODBC(tableName = 'HL_Topup_dailyVol1', 
             fields = c('calendar_date', 'Team_name', 'WIM_ACTV_TYPE_M', 'vol_in', 'vol_out', 'backlog_start'),
             filter = list(calendar_date = list(type = 'date', min = '2016-06-01')),
             dbName = 'UDRBSCMS', 
             dsn  = 'Teradata_Prod')


D.team = D %>% arrange(calendar_date) %>% group_by(calendar_date, Team_name) %>% summarise(vol_in = sum(vol_in), vol_out = sum(vol_out), backlog = sum(backlog_start))



# D = readODBC(tableName = 'HL_Topup_dailyVol_in1', 
#              fields = c('calendar_date', 'Team_name', 'topup_event', 'vol_in'),
#              dbName = 'UDRBSCMS', 
#              dsn  = 'Teradata_Prod')

# write.csv(D, 'volumes.csv')
# D = read.csv('volumes.csv')
# HL_Topup_dailyVol1 <-  read.csv("/home/guany/nextgen/afteraggregation.csv", header = TRUE)
D$TACT = paste(D$Team_name, D$WIM_ACTV_TYPE_M, sep = '.')
A.team = D %>% dcast(calendar_date ~ Team_name, value.var = 'backlog_start', fun.aggregate = sum) 

A.actv = D %>% dcast(calendar_date ~ WIM_ACTV_TYPE_M, value.var = 'backlog_start', fun.aggregate = sum)
A.totl = D %>% dcast(calendar_date ~ TACT, value.var = 'backlog_start', fun.aggregate = sum)

rownames(A.team) <- A.team$calendar_date %>% as.character
A.team = A.team[, -1] %>% as.matrix
A.team.red = A.team[, (colMeans(A.team) > 5) & (sum(colSums(A.team > 0) > 400))] 

rownames(A.actv) <- A.actv$calendar_date %>% as.character
A.actv = A.actv[, -1] %>% as.matrix
A.actv.red = A.actv[, (colMeans(A.actv) > 5) & (sum(colSums(A.actv > 0) > 400))] 

rownames(A.totl) <- A.totl$calendar_date %>% as.character
A.totl = A.totl[, -1] %>% as.matrix
A.totl.red = A.totl[, (colMeans(A.totl) > 5) & (sum(colSums(A.totl > 0) > 400))] 

lags = cbind(A.team.red,A.actv.red, A.totl.red) %>% addLags(keep = F) %>% na.omit 


y    = A.actv[-(1:14),"Top Up After Care"]

CC   = cor(x = lags, y = y, method = "pearson")

CC = CC[order(CC[,1] %>% abs, decreasing = T)[sequence(nrow(lags)/2)],, drop = F]
CC = CC[abs(CC[,1]) > 0.5,, drop = F]

CC = CC[!duplicated(CC[,1]),, drop = F]
# lags[, rownames(CC)] %>% cbind(A[-(1:14), 'Top Up After Care'])
fit = glm.fit(x = lags[, rownames(CC)], y = y)

## R-square
rsqrd = sum(fit$fitted.values^2)/ sum(y^2)

## R 0.9632901
rr = sqrt(rsqrd)

## AIC 1165.011
fit$aic

## Training: row 15-70
trainingModel = glm.fit(x = lags[1:400, rownames(CC)], y = y[1:400])
trainingAcutal=  y[1:400]

trainingRsqrd = sum(trainingModel$fitted.values^2)/ sum(y[1:400]^2)

## test error
test = lags[401:469, rownames(CC)]  %*% trainingModel$coefficients 
test[test < 0] <- 0

testAcutal =  y[401:469]

compare = cbind(test, testAcutal)

testSD = sd(testAcutal - test[,1])

testingerror = testSD/mean(testAcutal, na.rm = T)












#sqrt(sum(fit$fitted.values^2)/ sum(A[-(1:14),"Top Up After Care"]^2))
#sum(fit$fitted.values^2)    +  sum(fit$residuals^2)    - sum(A[-(1:14),"Top Up After Care"]^2)



### script/tools.R -------------------
addLags = function(A, lags = 1:14, columns = seq(ncol(A)), keep = T){
  if(keep){R = A} else {R = NULL}
  for(lag in lags){
    B <- A %>% column.shift.down(col = columns, k = lag, keep.rows = T)
    B <- B[, columns]
    colnames(B) <- paste0(colnames(A)[columns], "_L", lag)
    R <-cbind(R,B)
  }
  return(R)
}



predict_glm_fit <- function(glmfit, newmatrix, addintercept=TRUE){
  newmatrix %<>% as.matrix
  if (addintercept)
    newmatrix <- cbind(1,newmatrix)
  eta <- newmatrix %*% glmfit$coef
  glmfit$family$linkinv(eta)
}


###### project timeseries comparison ======================

### run_app.R ------------------
library(shiny)
library(shinythemes)

runApp('app', launch.browser = TRUE)

### app/dash.R ------------------


I = list()

I$tabs       = list(type = 'navbarPage', title = div(HTML("<img src=\"can.png\" height=\"130\" alt=\"This is alternate text\"> &nbsp;"), "Time Series Forecasting"),
                    theme = shinytheme("flatly"),
                    windowTitle = "Time Series Forecasting", layout = c('ETS', 'TP', 'FC', 'ADJ'))
I$ETS        = list(type = 'sidebarLayout', 
                    layout.side = c('text1', 'mytsfile', 'header', 'horizon', 'text2', 'max_p', 'max_d', 'max_q', 'max_P', 'max_D', 'max_Q', 'forecastButton'),
                    layout.main = 'timeseriesTabs')
# Incomplete
### app/server.R ------------------
# Load Libraries
library(dplyr)
library(xts)
library(zoo)
library(fpp)
library(caret)
library(ModelMetrics)
library(forecast)
library(foreach)
# library(doMC)
library(stats)
library(ggplot2)
library(lubridate)
library(shiny)
library(rminer)
library(shinythemes)
library(tidyverse)
library(tidyquant)
library(broom)
# library(timekit)
library(timetk)
library(modelr)
library(matrixStats)
library(ggcorrplot)
library(zeallot)
# library(cbastylr)

# setwd(dir = "/Users/snoymary/src/snoymary/shinyBMO_2/app")

for (i in dir("functions")) {
  source(paste0("functions/", i))
}

server <- shinyServer(function(input, output, session) {
  #Pre Processing Tab
  get.ts.csv <- reactive({
    inFile <- input$mytsfile
    if(is.null(inFile)) {
      return(NULL)
    }
    read.raw <- lapply(inFile$datapath, function(x) read.csv(x, header = input$header, sep = ","))
    date.raw <- lapply(read.raw, stand.date)
    date.raw
  })
  
  output$timeseriesTabs = renderUI({
    target <- get.ts.csv()
    nTabs = length(target)
    if(nTabs > 0) {
      myTabs = lapply(1:nTabs, function(i) {tabPanel(paste("Time Series", i), 
                                                     textOutput(paste0("title", i)), 
                                                     plotOutput(paste0("tsPlot", i)), 
                                                     dataTableOutput(paste0("tsData", i)))})
      do.call(tabsetPanel, myTabs)
    }
  })
  
  observeEvent(get.ts.csv(), {
    target <- get.ts.csv()
    nTabs <- length(target)
    lapply(1:nTabs, function(i) {
      output[[paste0("tsPlot", i)]] <- renderPlot({
        if (is.null(target)){
          ggplot()
        }
        if (!is.null(target)){
          ggplot(data = target[[i]], mapping = aes(date, volume)) +
            geom_point(alpha = 0.5) +
            geom_line(alpha = 0.5) +
            scale_color_manual(values = cbastylr_corp()) +
            theme_tq()
        }
      })
      
      output[[paste0("tsData", i)]] <- renderDataTable({
        if (!is.null(target)){
          target[[i]]
        }
      })
    }
    )
  })
  
  output$testingTabs = renderUI({
    target <- get.ts.csv()
    nTabs = length(target)
    if(nTabs > 0) {
      myTabs = lapply(1:nTabs, function(i) {tabPanel(paste("Time Series", i), 
                                                     tableOutput(paste0("parameters", i)),
                                                     tableOutput(paste0("accuracy", i)),
                                                     plotOutput(paste0("testPlot", i))
      )})
      do.call(tabsetPanel, myTabs)
    }
  })
  
  output$forecastTabs = renderUI({
    target <- get.ts.csv()
    nTabs = length(target)
    if(nTabs > 0) {
      myTabs = lapply(1:nTabs, function(i) {tabPanel(paste("Time Series", i), 
                                                     value = i,
                                                     plotOutput(paste0("forecastPlot", i))
      )})
      myTabs$id = "forecastTabs"
      do.call(tabsetPanel, myTabs)
    }
  })
  
  output$adjustTabs = renderUI({
    target <- get.ts.csv()
    nTabs = length(target)
    if(nTabs > 0) {
      myTabs = lapply(1:nTabs, function(i) {tabPanel(paste("Time Series", i), 
                                                     value = i,
                                                     sidebarLayout(
                                                       sidebarPanel(
                                                         uiOutput(paste0("adjustForecast", i)),
                                                         actionButton(paste0("adjustButton", i), "Adjust"),
                                                         textInput("adjName", label = "Enter File Name (excluding .csv extension)", "forecast") , 
                                                         htmlOutput(paste0("downloadAdjButton", i))
                                                       ),
                                                       mainPanel(
                                                         plotOutput(paste0("adjPlot", i)),
                                                         dataTableOutput(paste0("adjPred", i)))
                                                     )
                                                     
                                                     
      )})
      myTabs$id = "adjTabs"
      do.call(tabsetPanel, myTabs)
    }
  })
  
  getTests <- reactive({
    target <- get.ts.csv()
    lapply(target, function(x) {
      incProgress(1/length(target))
      if (input$horizon < 3) {
        arima.comp(x, max_p = input$max_p, max_q = input$max_q, max_d = input$max_d, max_P = input$max_P, max_Q = input$max_Q, max_D = input$max_D)
      } else {
        random.forrest.comp(x, input$horizon)
      }
    })
  })
  
  getFinals <- reactive({
    target <- get.ts.csv()
    nTabs <- length(target)
    tests <- getTests()
    lapply(1:nTabs, function(i) {
      if (input$horizon < 3) {
        arima.final(target[[i]], tests[[i]][["Model"]], input$horizon)
      } else {
        random.forrest.final(target[[i]], input$horizon)
      }
    })
  })
  
  
  observeEvent(input$forecastButton, {
    target <- get.ts.csv()
    if (!is.null(target)){
      nTabs <- length(target)
      tests <- withProgress(getTests(), message = "Running Forecasts")
      finals <- getFinals()
      # Download Forecast
      output$downloadButton <- renderUI({
        downloadButton("downloadData", "Download Forecast Data")
      })
      
      output$downloadData <- downloadHandler(
        filename = function() {paste0(input$filename, ".csv")},
        content = function(file) {
          write.csv(finals[[as.numeric(input$forecastTabs)]][["Forecast"]], file, row.names = FALSE)
        }
      )
      
      lapply(1:nTabs, function(i) {
        output[[paste0("parameters", i)]] <- renderTable({
          if (!is.null(tests)){
            tests[[i]][["Parameters"]]
          }
        })
        output[[paste0("accuracy", i)]] <- renderTable({
          if (!is.null(tests)){
            tests[[i]][["Accuracy"]]
          }
        })
        output[[paste0("testPlot", i)]] <- renderPlot({
          if (is.null(tests)){
            ggplot()
          }
          if (!is.null(tests)){
            tests[[i]][["Plot"]]
          }
        })
        
        output[[paste0("forecastPlot", i)]] <- renderPlot({
          if (is.null(finals)){
            ggplot()
          }
          if (!is.null(finals)){
            finals[[i]][["Plot"]]
          }
        })
        
        output[[paste0("adjustForecast", i)]] <- renderUI({
          lapply(1:input$horizon, function(x) {
            numericInput(inputId = paste("mult", i, x, sep = "_"), label = paste(finals[[i]][["Forecast"]][["Date"]][x]), value = 1, min = 0, step = 0.05)
          })
        })
      }
      )
    }
  })
  
  observeEvent(input[[paste0("adjustButton", input$adjTabs)]], {
    target <- get.ts.csv()
    nTabs <- length(target)
    tests <- getTests()
    finals <- getFinals()
    
    adjusted <- finals[[as.numeric(input$adjTabs)]][["Full"]]
    
    members <- input$horizon
    start <- nrow(adjusted) - members
    
    for (x in 1:members){
      adjusted$Volume[start + x] <- (adjusted$Volume[start + x]) * (input[[paste("mult", input$adjTabs, x, sep = "_")]])
    }
    
    adjustPlot <- ggplot(adjusted, aes(x = Date, y = Volume, colour = Type)) + 
      geom_point(alpha = 0.5) +
      geom_line(alpha = 0.5) +
      scale_color_manual(values = cbastylr_corp()) +
      theme_tq()
    
    
    output[[paste0("adjPlot", input$adjTabs)]] <- renderPlot(
      if(!is.null(adjusted)){
        adjustPlot
      })
    
    output[[paste0("adjPred", input$adjTabs)]] <- renderDataTable(
      if(!is.null(adjusted)){
        adjusted %>% select(Date, Volume) %>% mutate(Date = as.Date(Date))
      })
    
    # Download Forecast
    output[[paste0("downloadAdjButton", input$adjTabs)]] <- renderUI({
      downloadButton("downloadAdj", "Download Forecast Data")
    })
    
    output$downloadAdj <- downloadHandler(
      filename = function() {paste0(input$adjName, ".csv")},
      content = function(file) {
        write.csv(adjusted %>% select(Date, Volume) %>% mutate(Date = as.Date(Date)), file, row.names = FALSE)
      }
    )
  })
  
})


### app/ui.R ------------------
library(shiny)
library(plotly)
library(shinythemes)

ui <- fluidPage(
  
  navbarPage(title = div(HTML("<img src=\"can.png\" height=\"40\" alt=\"This is alternate text\"> &nbsp;"), "Time Series Forecasting"),
             id = "tabs", 
             theme = shinytheme("flatly"),
             windowTitle = "Time Series Forecasting",
             
             tabPanel(title = "Enter Time Series",
                      sidebarLayout(
                        sidebarPanel(
                          includeText("text1"),
                          fileInput("mytsfile", "Choose Time Series CSV", multiple = T,
                                    accept = c(
                                      "text/csv",
                                      "text/comma-separated-values,text/plain",
                                      ".csv")
                          ),
                          
                          checkboxInput("header", "Use First Row as Headers", TRUE),
                          numericInput("horizon", "Forecast Horizon (same time unit as input time series)", min = 1, value = 12),
                          includeText("text2"),
                          numericInput("max_p", "Max p for ARIMA Grid Search", min = 1, value = 4),
                          numericInput("max_d", "Max d for ARIMA Grid Search", min = 0, value = 0),
                          numericInput("max_q", "Max q for ARIMA Grid Search", min = 1, value = 4),
                          numericInput("max_P", "Max P for ARIMA Grid Search", min = 0, value = 1),
                          numericInput("max_D", "Max D for ARIMA Grid Search", min = 0, value = 0),
                          numericInput("max_Q", "Max Q for ARIMA Grid Search", min = 0, value = 1),
                          
                          actionButton("forecastButton", "Forecast")
                        ),
                        
                        mainPanel(uiOutput('timeseriesTabs'))
                      )
             ),
             
             tabPanel(title = "Testing Performance",
                      mainPanel(uiOutput('testingTabs'))
             ),  
             
             tabPanel(title = "Forecast",
                      sidebarLayout(
                        sidebarPanel(textInput("filename", label = "Enter File Name (excluding .csv extension)", "forecast") , 
                                     htmlOutput("downloadButton"),
                                     textOutput("text")),
                        mainPanel(uiOutput('forecastTabs'))
                      )
             ),
             
             tabPanel(title = "Adjust Forecast",
                      uiOutput("adjustTabs")
             )
  )
)      
### app/functions/ARIMA.comp.R ------------------
arima.comp <- function(my.ts, max_p = 4, max_q = 4, max_d = 0, max_P = 1, max_Q = 1, max_D = 0)
{  
  colnames(my.ts) <- c("date", "volume")
  
  weekStarts <- my.ts %>% 
    mutate(wday = wday(date)) %>%
    filter(wday == 2) %>% 
    select(date)
  
  my.ts <- my.ts %>%
    mutate(week = (row_number()-1) %/% 7) %>%
    group_by(week) %>%
    summarise(volume = sum(volume)) %>%
    mutate(date = as_datetime(weekStarts$date)) %>%
    select(date, volume)
  
  # convert data frame to time series 
  my.xts <- df2xts(my.ts)
  my.ts.ts <- df2ts(my.ts)
  
  ts.per <- pern(my.xts)
  
  # create training and tesing set
  fullSplit <- datasplit(my.ts.ts)
  
  # split train data for parameter grid search
  split <- datasplit(fullSplit$train)
  
  # p_vec <- getArimap(fullSplit$train, max_p) 
  # q_vec <- getArimaq(fullSplit$train, max_q)
  
  #Arima Parameter Tester
  parametergrid <- expand.grid(p = c(0:max_p), d = c(0:max_d), q = c(0:max_q) ,P = c(0:max_P),  D = c(0:max_D), Q = c(0:max_Q))
  pglen <- dim(parametergrid)[1]
  rmsedf<-matrix(nrow=pglen,ncol=9)
  
  rmsedf <- foreach(i = 1:pglen,.combine=rbind) %do%
    (tryCatch({
      print(i)
      
      for (meth in c("CSS-ML", "ML", "CSS")){
        print(meth)
        arimatrained <- try(Arima(split$train,
                                  order=as.numeric(as.vector(parametergrid[i,1:3])), 
                                  seasonal=as.numeric(as.vector(parametergrid[i,4:6])),
                                  method = meth), silent = T)
        if(!inherits(arimatrained, 'try-error')) break
      }
      
      trainExtend <- split$train
      arimaforecast <- data.frame()
      
      for (j in 1:length(split$test)){
        
        arimatrained <- Arima(trainExtend,
                              model = arimatrained)
        
        arimaforecast <- rbind(arimaforecast, forecast(arimatrained, h=1)$mean[1])
        
        trainExtend <- ts(c(trainExtend, split$test[j]), 
                          start = start(trainExtend),
                          frequency = stats::frequency(trainExtend))
      }
      
      colnames(arimaforecast) <- "Forecast"
      
      ARIMAtmp <- data.frame(arimaforecast$Forecast, split$test, 1:length(split$test))
      
      colnames(ARIMAtmp) <- c("predicted","actual","x")
      print(RMSE(ARIMAtmp$actual, ARIMAtmp$predicted))
      print(AIC(arimatrained))
      data.frame(Model = i,
                 p = as.numeric(parametergrid[i,1]), 
                 d = as.numeric(parametergrid[i,2]),
                 q = as.numeric(parametergrid[i,3]),
                 P = as.numeric(parametergrid[i,4]), 
                 D = as.numeric(parametergrid[i,5]),
                 Q = as.numeric(parametergrid[i,6]),
                 RMSE = RMSE(ARIMAtmp$predicted, ARIMAtmp$actual), 
                 AIC = AIC(arimatrained))
    },
    error = function(x) NA))
  
  meanRMSE <- mean(rmsedf$RMSE %>% na.omit)
  meanAIC <- mean(rmsedf$AIC %>% na.omit)
  
  selectionCrit <- rmsedf %>% mutate(weightedRMSE = RMSE/meanRMSE, weightedAIC = AIC/meanAIC) %>% mutate(metric = (weightedAIC + weightedRMSE)/2)
  
  extractARIMA <- selectionCrit[which.min(selectionCrit$metric),]
  extractARIMA
  
  trainExtend <- fullSplit$train
  arimaforecast <- data.frame()
  
  for (meth in c("CSS-ML", "ML", "CSS")){
    print(meth)
    arimatrained <- try(Arima(fullSplit$train,
                              order= c(extractARIMA$p[1], extractARIMA$d[1], extractARIMA$q[1]), 
                              seasonal= c(extractARIMA$P[1], extractARIMA$D[1], extractARIMA$Q[1]), 
                              method = meth), silent = T)
    if(!inherits(arimatrained, 'try-error')) break
  }
  
  for (i in 1:length(fullSplit$test)){
    
    arimatrained <- Arima(trainExtend,
                          model = arimatrained)
    
    arimaforecast <- rbind(arimaforecast, sum(forecast(arimatrained, h=1)$mean))
    
    trainExtend <- ts(c(trainExtend, fullSplit$test[i]), 
                      start = start(trainExtend), 
                      frequency = stats::frequency(trainExtend))
  }
  
  colnames(arimaforecast) <- "Forecast"
  
  forecastDF <- data.frame(value = as.numeric(arimaforecast$Forecast) %>% round, 
                           time = my.ts[(length(fullSplit$train) + 1):length(my.ts.ts),1]) %>% 
    mutate(type = "forecast")  %>% 
    head(-1)
  
  actualDF <- data.frame(value = as.numeric(fullSplit$test),
                         time = my.ts[(length(fullSplit$train) + 1):length(my.ts.ts),1]) %>% 
    mutate(type = "actual") %>% 
    head(-1)
  
  colnames(actualDF) <- c("value", "time", "type")
  colnames(forecastDF) <- c("value", "time", "type")
  
  plotDF <- rbind(forecastDF, actualDF)
  
  plot <- plotDF %>%
    ggplot(aes(x = time, y = value, color = type)) +
    geom_point(alpha = 0.5) +
    geom_line(alpha = 0.5) +
    scale_color_manual(values = cbastylr_corp()) +
    theme_tq()
  
  accuracy <- data.frame(accuracy(forecastDF$value, actualDF$value))
  accuracy.df <- data.frame("RMSE" = accuracy$RMSE, "MAPE" = accuracy$MAPE, "AIC" = extractARIMA$AIC)
  parameters <- extractARIMA %>% select(p,d,q,P,D,Q)
  model <- arimatrained
  
  list("Model" = model, 
       "Parameters" = parameters, 
       "Accuracy" = accuracy.df,
       "Time.Series" = my.ts,
       "Frequency" = ts.per,
       "Plot" = plot, 
       "Forecast" = forecastDF %>% select(time, value) %>% as.tbl,
       "Actual" = actualDF %>% select(time, value) %>% as.tbl)
}


### app/functions/ARIMA.final.R ------------------
arima.final <- function(my.ts, model, horizon){
  
  colnames(my.ts) <- c("date", "volume")
  
  weekStarts <- my.ts %>% 
    mutate(wday = wday(date)) %>%
    filter(wday == 2) %>% 
    select(date)
  
  my.ts <- my.ts %>%
    mutate(week = (row_number()-1) %/% 7) %>%
    group_by(week) %>%
    summarise(volume = sum(volume)) %>%
    mutate(date = as_datetime(weekStarts$date)) %>%
    select(date, volume)
  
  my.ts.ts <- df2ts(my.ts)
  my.xts <- df2xts(my.ts)
  
  arimatrained <- Arima(my.ts.ts,
                        model = model)
  
  arimaforecast <- forecast(arimatrained, h = horizon)
  
  forecast.df <- data.frame("Date" = (as_datetime(seq(from = tail(my.ts,1)[[1,1]], by = 'w', length.out=(horizon+1)))),
                            "Volume" = c(my.ts.ts %>% tail(1), arimaforecast$mean),
                            "Type" = "Forecast") %>% as.tbl
  
  actual.df <- data.frame("Date" = as_datetime(my.ts$date),
                          "Volume" = my.ts$volume,
                          "Type" = "Actual") %>% as.tbl
  
  plot.df <- rbind(actual.df, forecast.df)
  
  forecast.df <- forecast.df %>% select(Date, Volume) %>% mutate(Date = as.Date(Date)) %>% tail(-1)
  
  arimaplot <- ggplot(plot.df, aes(x = Date, y = Volume, colour = Type)) +
    geom_point(alpha = 0.5) +
    geom_line(alpha = 0.5) +
    scale_color_manual(values = cbastylr_corp()) +
    theme_tq()
  
  list("Forecast" = forecast.df, "Full" = plot.df, "Plot" = arimaplot)
}

### app/functions/pre.process.R ------------------
pre.process <- function(my.times){ 
  
  my.ts <- my.times[[1]] %>% select(1:2)
  colnames(my.ts) <- c("Time", "Value")
  dateTime <- my.ts %>% mutate(Time = as_datetime(Time), Value = as.numeric(Value)) %>% as.tbl
  plot.data.df <- mutate(dateTime, Type = "Data")
  
  list("Full" = dateTime, "Data" = plot.data.df)
}
### app/functions/random.forrest.comp.R ------------------
random.forrest.comp <- function(daily_volumes, horizon){
  
  ## Daily Data
  names(daily_volumes) <- c("Date", "Volume")
  
  public_holidays <- read_csv("public_holidays.csv", col_names = F) %>%
    `colnames<-`(c("date", "holiday")) %>%
    mutate(date = as.Date(date))
  
  holiday_bools <- left_join(select(daily_volumes, Date), public_holidays, by = c("Date" = "date")) %>%
    mutate(holiday = ifelse(is.na(holiday), 0, 1)) %>%
    mutate(week = (row_number()-1) %/% 7) %>%
    group_by(week) %>%
    mutate(holiday_week = ifelse(any(holiday == 1),1,0)) %>%
    filter(Date == min(Date)) %>%
    ungroup() %>%
    transmute(holiday_week = as.factor(holiday_week))
  
  weekStarts <- daily_volumes %>% 
    mutate(wday = wday(Date)) %>%
    filter(wday == 2) %>% 
    select(Date)
  
  weekly_volumes <- daily_volumes %>%
    mutate(week = (row_number()-1) %/% 7) %>%
    group_by(week) %>%
    summarise(volume = sum(Volume)) %>%
    mutate(date = as_datetime(weekStarts$Date)) %>%
    select(date, volume)
  
  names(weekly_volumes) <- c("Date", "Volume")
  names(daily_volumes) <- c("Date", "Volume")
  
  weekly.ts <- ts(weekly_volumes$Volume, start = 1, frequency = 52)
  
  full <- weekly_volumes %>%
    mutate(Date = as_datetime(Date)) %>%
    mutate(model = ifelse(row_number() <= (nrow(.) - horizon) , "train", "test")) %>%
    tk_augment_timeseries_signature() %>% 
    as.tbl %>% 
    select(-c(index.num, diff))
  
  ## Convert Dates/Times to Factors
  clean_full <- full %>%
    cbind(holiday_bools) %>%
    mutate_at(vars(-c(1:3)), as.factor) %>%
    rename(y = Volume) %>%
    select(-c(1:3), c(1:3)) %>%
    select(-c(year.iso, month.xts, mday, qday, yday, week.iso, mday7, day, month.lbl)) %>%
    select_if(~ is.numeric(.) || (n_distinct(.) > 1) && (n_distinct(.) < 53)) %>% 
    as.tbl 
  
  ## Add Lags
  nlags <- horizon
  lags <- CasesSeries(weekly.ts, 1:nlags) %>% as.tbl()
  
  clean_lags <- bind_cols(clean_full[-(1:nlags),], lags[,-ncol(lags)])
  
  ## Create Training and Testing Sets
  test_train <- clean_lags %>%
    arrange(model) %>%
    split(.$model) %>% 
    map(~ select(., -model))
  
  test <- test_train$test
  train <- test_train$train
  
  model_ready_full <- select(clean_lags, -model)
  
  ## Get Column Names
  columnNames <- colnames(model_ready_full)
  
  ## Get Pr ANOVA Correlation Metric for each column of train
  getPR <- function(x, dat) {
    form <- paste0("y ~ ", x) %>% as.formula
    f <- aov(form, data = dat)
    summary(f)[[1]][["Pr(>F)"]][[1]]
  }
  
  # Select those column where Pr < 5%
  cols_to_keep <- columnNames %>%
    discard(~ . == 'y') %>% # Don't get PR for response variable
    keep(~ !is.null(getPR(., train)) && (getPR(., train) < 0.05) | (. == "holiday_week") | (grepl("lag", .))) 
  
  pred <- list(model_ready_full, train, test) %>%
    map(select, y, one_of(cols_to_keep))
  
  pred_full <- pred[[1]]
  pred_train <- pred[[2]]
  pred_test <- pred[[3]]
  
  predictions <- lapply((1:nlags), function(i) {
    training <- pred_train %>% select(1:(ncol(.) - i+1))
    model <- rminer::fit(y ~., data = as.data.frame(training), task="reg", model = "randomforest")
    testing <- pred_test %>% select(1:(ncol(.) - i+1))
    predict(model, testing[i,]) %>% round
  }) %>% unlist
  
  ## Make Forecast
  split.df <- weekly_volumes %>% 
    mutate(Date = as.POSIXct(Date)) %>%
    mutate(model = ifelse(row_number() <= (nrow(.) - horizon) , "train", "test")) %>%
    select(Date, Volume, model) %>%
    tail(-nlags)
  
  weekly_raw <- data.frame(split.df %>% filter(model == "test") %>% pull(Date), pred_test$y, predictions) %>% #pred_test$y,
    `colnames<-`(c("date", "actual", "forecast")) %>%
    head(-1) 
  
  ## Public Holiday Adjustments
  daily <- daily_volumes %>%
    mutate(Day = wday(Date))
  
  dailyAM <- daily %>%
    group_by(Day) %>%
    summarise(AM = mean(Volume)) %>%
    mutate(proportion = AM/sum(AM))
  
  daily_from <- weekly_raw$date[1]
  daily_to <- weekly_raw$date[nrow(weekly_raw)] + 6*24*3600
  
  full_dates <- data.frame(date = seq(from = daily_from, to = daily_to, by = "d"))
  full_forecast <- data.frame(forecast = rep(weekly_raw$forecast, each = 7))
  
  holiday_impact <- right_join(daily_volumes, public_holidays, by = c("Date" = "date")) %>%
    mutate(Day = wday(Date)) %>%
    mutate(type = ifelse((Date < as.Date("2017/07/01")), "train" ,"test")) %>%
    right_join(dailyAM, by = "Day") %>%
    na.omit() %>%
    filter(Day != 1 & Day != 7) %>%
    mutate(multiplier = Volume/AM) %>%
    arrange(Date) %>%
    group_by(holiday, type) %>%
    summarise(multiplier = min(multiplier)) %>%
    filter(type == "train")
  
  weekly_to_daily <- bind_cols(full_dates, full_forecast) %>%
    as.tibble() %>%
    mutate(Day = wday(date)) %>%
    right_join(dailyAM, by = "Day") %>%
    mutate(date = as.Date(date)) %>%
    arrange(date) %>%
    mutate(adjusted = forecast * proportion) %>%
    left_join(public_holidays, by = "date") %>%
    left_join(holiday_impact %>% select(-type), by = "holiday") %>% 
    mutate(multiplier = ifelse(is.na(holiday) | is.na(multiplier), 1, multiplier)) %>%
    mutate(impact = adjusted * multiplier) %>%
    mutate(week = (row_number()-1) %/% 7) %>%
    group_by(week) %>%
    summarise(forecast = sum(impact))
  
  weekly_adjusted <- cbind(weekly_raw, weekly_to_daily$forecast) %>%
    `colnames<-`(c("date", "actual", "forecast", "adjusted"))
  
  accuracy <- as.data.frame(accuracy(weekly_adjusted$actual, weekly_adjusted$adjusted))
  
  rmse <- accuracy$RMSE
  mape <- accuracy$MAPE
  
  # error_df <- weekly_raw %>% mutate(error = abs(actual - forecast)) %>% arrange(desc(error))
  
  plot.df <- weekly_adjusted %>%
    gather("actual", "adjusted", key = "type", value = "value")
  
  Plot <- plot.df %>% ggplot(aes(x = date, y = value, color = type)) +
    geom_point(alpha = 0.5) +
    geom_line(alpha = 0.5) +
    scale_color_manual(values = cbastylr_corp()) +
    theme_tq()
  
  actualDF <- select(weekly_adjusted, date, actual)
  forecastDF <- select(weekly_adjusted, date, adjusted)
  
  colnames(actualDF) <- c("date", "volume")
  colnames(forecastDF) <- c("date", "volume")
  
  list("Time.Series" = daily_volumes, "RMSE" = rmse, "MAPE" = mape, "Plot" = Plot, "Actuals" = actualDF, "Forecast" = forecastDF, "Accuracy" = accuracy)
}

### app/functions/random.forrest.final.R ------------------
random.forrest.final <- function(daily_volumes, horizon){ #weekly horizon
  daily_volumes <- dailyVal
  ## Daily Data
  names(daily_volumes) <- c("Date", "Volume")
  
  forecast_dates <- data.frame(Date = seq(from = daily_volumes$Date[nrow(daily_volumes)], length.out = (horizon*7 + 1), by = 'd') %>% tail(-1),
                               Volume = 1)
  
  full_daily <- rbind(daily_volumes, forecast_dates)  
  
  public_holidays <- read_csv("/Users/snoymary/src/snoymary/TimeSeries/public_holidays.csv", col_names = F) %>%
    `colnames<-`(c("date", "holiday")) %>%
    mutate(date = as.Date(date))
  
  holiday_bools <- left_join(select(full_daily, Date), public_holidays, by = c("Date" = "date")) %>%
    mutate(holiday = ifelse(is.na(holiday), 0, 1)) %>%
    mutate(week = (row_number()-1) %/% 7) %>%
    group_by(week) %>%
    mutate(holiday_week = ifelse(any(holiday == 1),1,0)) %>%
    filter(Date == min(Date)) %>%
    ungroup() %>%
    transmute(holiday_week = as.factor(holiday_week))
  
  weekStarts <- full_daily %>% 
    mutate(wday = wday(Date)) %>%
    filter(wday == 2) %>% 
    select(Date)
  
  weekly_volumes <- full_daily %>%
    mutate(week = (row_number()-1) %/% 7) %>%
    group_by(week) %>%
    summarise(volume = sum(Volume)) %>%
    mutate(date = as_datetime(weekStarts$Date)) %>%
    select(date, volume)
  
  names(weekly_volumes) <- c("Date", "Volume")
  names(full_daily) <- c("Date", "Volume")
  
  weekly.ts <- ts(weekly_volumes$Volume, start = 1, frequency = 52)
  
  full <- weekly_volumes %>%
    mutate(Date = as_datetime(Date)) %>%
    mutate(model = ifelse(row_number() <= (nrow(.) - horizon) , "train", "forecast")) %>%
    tk_augment_timeseries_signature() %>% 
    as.tbl %>% 
    select(-c(index.num, diff))
  
  ## Convert Dates/Times to Factors
  clean_full <- full %>%
    cbind(holiday_bools) %>%
    mutate_at(vars(-c(1:3)), as.factor) %>%
    rename(y = Volume) %>%
    select(-c(1:3), c(1:3)) %>%
    select(-c(year.iso, month.xts, mday, qday, yday, week.iso, mday7, day, month.lbl)) %>%
    select_if(~ is.numeric(.) || (n_distinct(.) > 1) && (n_distinct(.) < 53)) %>% 
    as.tbl 
  
  ## Add Lags
  nlags <- horizon
  lags <- CasesSeries(weekly.ts, 1:nlags) %>% as.tbl()
  
  clean_lags <- bind_cols(clean_full[-(1:nlags),], lags[,-ncol(lags)])
  
  train_forecast <- clean_lags %>%
    arrange(model) %>%
    split(.$model) %>% 
    map(~ select(., -model))
  
  train <- train_forecast$train
  forecast <- train_forecast$forecast
  
  model_ready_full <- select(clean_lags, -model)
  
  ## Get Column Names
  columnNames <- colnames(clean_lags)
  
  ## Get Pr ANOVA Correlation Metric for each column of train
  getPR <- function(x, dat) {
    form <- paste0("y ~ ", x) %>% as.formula
    f <- aov(form, data = dat)
    summary(f)[[1]][["Pr(>F)"]][[1]]
  }
  
  # Select those column where Pr < 5%
  cols_to_keep <- columnNames %>%
    keep(~ (. %in% c("y", "holiday_week", "week", "mweek", "month")) | (grepl("lag", .))) 
  
  pred <- list(model_ready_full, train, forecast) %>%
    map(select, one_of(cols_to_keep))
  
  pred_full <- pred[[1]]
  pred_train <- pred[[2]]
  pred_forecast <- pred[[3]]
  
  predictions <- lapply((1:nlags), function(i) {
    training <- pred_train %>% select(1:(ncol(.) - i+1))
    model <- rminer::fit(y ~., data = as.data.frame(training), task="reg", model = "randomforest")
    testing <- pred_forecast %>% select(1:(ncol(.) - i+1))
    predict(model, testing[i,]) %>% round
  }) %>% unlist
  
  ## Make Forecast
  split.df <- weekly_volumes %>% 
    mutate(Date = as.POSIXct(Date)) %>%
    mutate(model = ifelse(row_number() <= (nrow(.) - horizon) , "train", "test")) %>%
    select(Date, Volume, model) %>%
    tail(-nlags)
  
  weekly_raw <- data.frame(split.df %>% filter(model == "test") %>% pull(Date), predictions) %>% #pred_forecast$y,
    `colnames<-`(c("date", "forecast")) %>%
    head(-1) 
  
  ## Public Holiday Adjustments
  daily <- daily_volumes %>%
    mutate(Day = wday(Date))
  
  dailyAM <- daily %>%
    group_by(Day) %>%
    summarise(AM = mean(Volume)) %>%
    mutate(proportion = AM/sum(AM))
  
  daily_from <- weekly_raw$date[1]
  daily_to <- weekly_raw$date[nrow(weekly_raw)] + 6*24*3600
  
  full_dates <- data.frame(date = seq(from = daily_from, to = daily_to, by = "d"))
  full_forecast <- data.frame(forecast = rep(weekly_raw$forecast, each = 7))
  
  holiday_impact <- right_join(daily_volumes, public_holidays, by = c("Date" = "date")) %>%
    mutate(Day = wday(Date)) %>%
    mutate(type = ifelse((Date < as.Date("2017/07/01")), "train" ,"test")) %>%
    right_join(dailyAM, by = "Day") %>%
    na.omit() %>%
    filter(Day != 1 & Day != 7) %>%
    mutate(multiplier = Volume/AM) %>%
    arrange(Date) %>%
    group_by(holiday, type) %>%
    summarise(multiplier = min(multiplier)) %>%
    filter(type == "train")
  
  weekly_to_daily <- bind_cols(full_dates, full_forecast) %>%
    as.tibble() %>%
    mutate(Day = wday(date)) %>%
    right_join(dailyAM, by = "Day") %>%
    mutate(date = as.Date(date)) %>%
    arrange(date) %>%
    mutate(adjusted = forecast * proportion) %>%
    left_join(public_holidays, by = "date") %>%
    left_join(holiday_impact %>% select(-type), by = "holiday") %>% 
    mutate(multiplier = ifelse(is.na(holiday) | is.na(multiplier), 1, multiplier)) %>%
    mutate(impact = adjusted * multiplier) %>%
    mutate(week = (row_number()-1) %/% 7) %>%
    group_by(week) %>%
    summarise(forecast = sum(impact))
  
  weekly_adjusted <- cbind(data.frame(date = weekly_raw$date), weekly_to_daily$forecast) %>%
    `colnames<-`(c("Date", "Volume")) %>%
    as.data.frame()
  
  weekly_actuals <- weekly_volumes %>% 
    head(-horizon) %>%
    mutate(Type = "actual")
  
  weekly_forecast <- rbind(weekly_actuals[nrow(weekly_actuals),1:2], weekly_adjusted) %>% mutate(Type = "forecast")
  
  plot.df <- rbind(weekly_actuals, weekly_forecast) %>%
    `colnames<-`(c("Date", "Volume", "Type"))
  
  Plot <- plot.df %>% 
    ggplot(aes(x = Date, y = Volume, colour = Type)) +
    geom_point(alpha = 0.5) +
    geom_line(alpha = 0.5) +
    scale_color_manual(values = cbastylr_corp()) +
    theme_tq()
  
  list("Plot" = Plot, "Forecast" = weekly_forecast, "Full" = plot.df)
}

### app/functions/scalDF.R ------------------
#scaledPrediction <- ausbeer

#colnames(scaledPrediction) <- c("Time", "Value")
#scaledPrediction$Time <- as.POSIXct(scaledPrediction$Time)

#starttime <- as.POSIXct("2000-1-12")
#endDate <- as.POSIXct("2008-1-12")
#multiplier <- 0

scaledP <- function(scaledPrediction, startDate, endDate, multiplier){
  
  colnames(scaledPrediction) <- c("Time", "Value", "Type")
  
  startDate <- year(startDate) + as.numeric(strftime(startDate, format = "%j"))/365
  endDate <- year(endDate) + as.numeric(strftime(endDate, format = "%j"))/365
  
  for (i in 1:nrow(scaledPrediction)){
    if (scaledPrediction$Time[i] >= startDate & scaledPrediction$Time[i] <= endDate) {
      scaledPrediction$Value[i] = scaledPrediction$Value[i] * multiplier
    }
  }
  
  scaledPlot <- ggplot(scaledPrediction, aes(x = Time, y = Value, colour = Type)) + geom_line()
  
  list("data" = scaledPrediction, "plot" = scaledPlot)
  
}


### app/functions/utilities_for_time_series.R ------------------

## Utilities for Time Series ##

#Load Utils

getArimaq <- function(x, max_q){ # x is a time series or vector
  a <- Acf(x)
  acf.vector <- data.frame(acf = abs(a$acf[,,1]), lag = 0:(nrow(a$acf)-1)) %>% 
    mutate(threshold = 1.96/sqrt(a$n.used)) %>%
    filter(acf >= threshold) %>%
    mutate(lag_lead = lead(lag)) %>%
    mutate(lag_diff = lag_lead - lag) %>%
    filter(lag_diff != 1 | is.na(lag_diff)) %>%
    filter(lag <= max_q & lag > 0)
  
  if(length(acf.vector$lag) == 0) {
    return(max_q)
  }
  
  return(acf.vector$lag)}

getArimap <- function(x, max_p){ # x is a time series or vector
  a <- Pacf(x)
  pacf.vector <- data.frame(acf = abs(a$acf[,,1]), lag = 0:(nrow(a$acf)-1)) %>% 
    mutate(threshold = 1.96/sqrt(a$n.used)) %>%
    filter(acf >= threshold) %>%
    mutate(lag_lead = lead(lag)) %>%
    mutate(lag_diff = lag_lead - lag) %>%
    filter(lag_diff != 1 | is.na(lag_diff)) %>%
    filter(lag <= max_p & lag > 0)
  
  if(length(pacf.vector$lag) == 0) {
    return(max_p)
  }
  
  return(pacf.vector$lag)
  
}

timeseries.subset <- function(ts, start_idx, end_idx) {
  window(ts, time(ts)[start_idx], time(ts)[end_idx])
}

timeseries.training <- function(ts, size = 0.8) {
  len <- length(time(ts))
  timeseries.subset(ts, 1, size * len)
}

timeseries.testing <- function(ts, size = 0.2, training.length) {
  len <- length(time(ts))
  timeseries.subset(ts, training.length+1, len)
}

# Periodicity to Numeric
pern <- function(ts){
  switch(periodicity(ts)$scale,
         "hourly" = 24,
         "daily" = 14,
         "weekly" = 52,
         "monthly" = 12,
         "quarterly" = 4,
         "yearly" = 1)
}

# Convert Data Frame to X Times Series
df2xts <- function(time.s){
  ZOO <- zoo(as.data.frame(time.s)[,2], 
             order.by=as.Date(as.character(as.data.frame(time.s)[,1])))
  
  timeStamp <- tk_augment_timeseries_signature(time.s %>% head(1))
  
  start.vector <- switch(periodicity(ZOO)$scale,
                         "hourly" = c(timeStamp$year, (timeStamp$yday*24 + timeStamp$hour)),
                         "daily" = 1,
                         "weekly" = c(timeStamp$year, timeStamp$week),
                         "monthly" = c(timeStamp$year, timeStamp$month),
                         "quarterly" = c(timeStamp$year, timeStamp$quarter),
                         "yearly" = timeStamp$year)
  scale.of <- pern(ZOO)
  
  xts(ZOO,
      start = start.vector,
      frequency = scale.of)
}

df2ts <- function(time.s){
  ZOO <- zoo(as.data.frame(time.s)[,2], 
             order.by=as.Date(as.character(as.data.frame(time.s)[,1])))
  
  timeStamp <- tk_augment_timeseries_signature(time.s %>% head(1))
  
  start.vector <- switch(periodicity(ZOO)$scale,
                         "hourly" = c(timeStamp$year, (timeStamp$yday*24 + timeStamp$hour)),
                         "daily" = 1,
                         "weekly" = c(timeStamp$year, timeStamp$week),
                         "monthly" = c(timeStamp$year, timeStamp$month),
                         "quarterly" = c(timeStamp$year, timeStamp$quarter),
                         "yearly" = timeStamp$year)
  scale.of <- pern(ZOO)
  
  ts(ZOO,
     start = start.vector,
     frequency = scale.of)
}


# Split Function
datasplit <- function(timeseries){
  train <- timeseries.training(timeseries)
  test <- timeseries.testing(timeseries,training.length = length(time(train)))
  
  
  A<-list(train, test)
  names(A)<-c("train", "test")
  A
}

# Standardise Date Format - ymd

# Time must be in "%Y-%m-%d" or "%Y/%m/%d" format. Year must be 4 digitd i.e. 1996/07/16
# Time Column must be first

stand.date <- function(my.ts){
  colnames(my.ts) <- c("date", "volume")
  mutate(my.ts, date = as.Date(my.ts$date))
}
