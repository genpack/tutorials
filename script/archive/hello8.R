### global.R ----------------------
# Header
# Filename:       global.R
# Description:    This module reads or generates the the ATM group, updates it and and makes it ready for being visualized in a dashboard
# Author:         Nima Ramezani Taghiabadi
# Email:          nima.ramezani@cba.com.au
# Start Date:     18 May 2016
# Last Revision:  25 January 2017
# Version:        2.1
# 
# 

# Requirements:
library(timeDate)
library(shiny)
library(shinydashboard)
library(googleVis)
library(dygraphs)
library(leaflet)
library(rAmCharts)

library(niragen)
library(nirats)
library(nira.storeman)
library(nira.atmopt)
library(niravis)

figs = c(ATM.ID     = 'ATM ID'      , ATM.Name  = 'ATM Name'     , N.Days   = 'Ndays', 
         Order.Date = 'Order Date'  , Date      = 'Delivery Date',
         TD100      = 'TDemand $100', TD50      = 'TDemand $50'  , TD20 = 'TDemand $20', TD     = 'TDemand Total',
         Roster     = 'Roster Date' , Order.Fee = 'Order Fee'    , 
         O100       = 'Order $100'  , O50       = 'Order $50'    , O20  = 'Order $20'  , Order  = 'Order Total',
         flag       = 'SNO',
         R100       = 'Rebank $100' , R50       = 'Rebank $50'   , R20  = 'Rebank $20' , Rebank = 'Rebank Total',
         Submitted  = 'Submitted')

# Local variables
valid.figures <- c('Usage' = 'Demand', 'Usage Forecast' = 'forec', 'Balance' = 'Balance', 'Order' = 'Order', 'Rebank' = 'Rebank', 'Holding Cost' = 'Hold.Cost', 'Order Cost' = 'Order.Cost', 'Total Cost' = 'Total.Cost',
                   'Usage.20' = 'D20', 'Usage.50' = 'D50', 'Usage.100' = 'D100',
                   'Balance.20' = 'B20', 'Balance.50' = 'B50', 'Balance.100' = 'B100',
                   'Order.20' = 'O20', 'Order.50' = 'O50', 'Order.100' = 'O100'
)

yoyxaxis = c(Daily = 'doy', Weekly = 'woy', Monthly = 'moy')
# report.figures <- c('ATM.ID', 'Date', 'Demand', 'D100', 'D50', 'D20', 'Roster', 'Order.Fee', 'Order.Date', 'Order', 'O100', 'O50', 'O20', 'Rebank', 'R100', 'R50', 'R20')

timeBreak = function(x){
  # x should ne inherited from class TIME.SERIES 
  verify(x, c('TIME.SERIES', 'STORE.GROUP'))
  if (inherits(x, 'TIME.SERIES')){
    x$append.interval.start()
    x$append.interval.start(interval = "month", field_name = 'Month.Start')
    x$append.interval.start(interval = "year" , field_name = 'Year.Start')
  } else if (inherits(x, 'STORE.GROUP')){
    for (i in names(x$stores)){
      x$stores[[i]] = x$stores[[i]] %>>% timeBreak()
    }    
  }
  return(x)
}


path      = '\\\\flsy04/G_TS_SY$/CDO_MTK_SMT/Business Performance Reporting/Tableau Dashboards/VCC/PS/Cash and ATM/Off Premise ATM Cash Rebanks/Opportunity Sizing Presentation/National/Optimization Model/Adelaide/'
data.path = '\\\\flsy04/G_TS_SY$/CDO_MTK_SMT/Business Performance Reporting/Tableau Dashboards/VCC/PS/Cash and ATM/Off Premise ATM Cash Rebanks/Opportunity Sizing Presentation/National/Optimization Model/Adelaide/auxdata/'

sg = readRDS(data.path %+% 'dataset.rds')

curUsage.den = function(vs){
  paste0("WD100: $", vs$current('D100'), "<br>\n", "WD50 : $ ", vs$current('D50'), "\n", "WD20 : $ ", vs$current('D20'), "\n \n", "Total: $ ", vs$current('demand'))
}

curBalance.den = function(vs){
  paste0("BAL100: $", vs$current('B100'), "\n", "BAL50 : $ ", vs$current('B50'), "\n", "BAL20 : $ ", vs$current('B20'), "\n \n", "Total : $ ", vs$current('balance'))
}

# cat(curBalance.den(sg[1]))

tableOptions = list(header = list('background-color' = '#6D929B', 'color' = 'navy'),
                    filter = list(position = 'top', clear = FALSE))

# variable of type Table.Link
fgn = figs[c('ATM.ID', 'Date', 'O100', 'O50', 'O20')]
names(fgn) <- NULL

link.col.1 = list(class.name = 'go-map', column.name = 'Select', href = "", inputs = c('id' = fgn[1], 'date' = fgn[2], 'ord100' = fgn[3], 'ord50' = fgn[4], 'ord20' = fgn[5]), icon = 'fa fa-crosshairs', text = '')
tableLinks = list(link.col.1)

getTordsRowNumber = function(TBL, day, id){
  which((TBL[, figs['ATM.ID']] == id) & (TBL[, figs['Date']] == day))[1]
}


#vs = sg[1]
#vs$goto(vs$etn)
#vs$reset()
#debug(vs$jump.active)
#vs$now()
#vs$jump.active(until = '2016-07-30')

lg = h3("BI&A", span("Off Premise ATM Replenishment Optimization", style = "font-weight: 100"),
        style = "font-family: 'Source Sans Pro'; size: 10;
        color: 'red'; text-align: center; 
        background-image: url('C:/Nima/R/projects/cba/ATM.opt.dashboard/images/GO_Logo.png');
        padding: 12px")

source('script/atm.dash.R')

### ui.R ----------------------
ui     <- dash$dashboard.ui()

### server.R ----------------------
server <- dash$dashboard.server()

###### Folder scipt ========================

### atm.dash.R --------------------
# Header
# Filename:       atm.dash.R
# Description:    This file creates the first shiny dashboard for visualizing a group of ATMs. 
#                 More dashboards may be generated in the future 
# Author:         Nima Ramezani Taghiabadi
# Email:          nima.ramezani@cba.com.au
# Start Date:     18 May 2016
# Last Revision:  02 February 2016
# Version:        3.2.2

# Version History:

# Version   Date              Action
# ----------------------------------
# 3.1.1     25 August 2016    Estimated usage until next service is now dynamic
# 3.1.2     25 August 2016    Estimated Rebank in the next service is now dynamic
# 3.1.3     25 August 2016    icons selection finished and some colors changed
# 3.2.0     07 September 2016 History plot modified: Only one figure can be selected and different years can overlay
# 3.2.1     30 September 2016 By changing an order, the 'Order.Date' will be set to today rather than specified by ctn which refers to yesterday
# 3.2.2     02 February 2016  Modifications in dygraphs plot, added header.

# Changes from version 3.0:

# 1- Column filters added to the table
# 2- reactive parameters sls, day removed 

tdy = Sys.Date()

ydy = tdy - 1
tmr = tdy + 1

val = reactiveValues()

I = list()

val      = reactiveValues()
val$ord     = 0
val$tableTrigger  = T
val$nxtSrvTrigger = T
val$mapsel  = names(sg$stores)
val$tabsel  = names(sg$stores)
val$tabday  = unique(sg$TORDS[, figs['Date']])

val.ord100  = sg$TORDS[getTordsRowNumber(sg$TORDS, day = tmr, id = sg$selected), figs['O100']]
val.ord50   = sg$TORDS[getTordsRowNumber(sg$TORDS, day = tmr, id = sg$selected), figs['O50']]
val.ord20   = sg$TORDS[getTordsRowNumber(sg$TORDS, day = tmr, id = sg$selected), figs['O20']]

# Containers:

I = list()
O = list()

# Clothes:

boxCloth       = list(type = 'box', status = "primary", solidHeader = F, collapsible = F, weight = 12, background = 'light-blue', title = 'Change Order')
metricsFrame   = list(type = 'wellPanel')
cloth.latbal   = list(type = 'infoBox', icon = 'money' , subtitle = 'On ' %+% prettyDate(ydy), weight = 12, fill = T, color = 'yellow')
cloth.latuse   = list(type = 'infoBox', icon = 'credit-card'   , subtitle = 'On ' %+% prettyDate(ydy), weight = 12, fill = T, color = 'yellow')
cloth.dysnxt   = list(type = 'valueBox', icon = 'calendar-o', subtitle = 'On ' %+% prettyDate(ydy), weight = 12, fill = T, color = 'yellow')
cloth.usenxt   = list(type = 'valueBox', icon = 'credit-card', subtitle = 'On ' %+% prettyDate(ydy), weight = 12, fill = T, color = 'yellow')
colCloth       = list(type = 'column', weight = 3, offset = 0, align = 'center')
mapFrame       = list(type = 'wellPanel')

# Main Boxes:

I$main      = list(type = 'dashboardPage', title = 'BI&A ATM Optimization Toolbox', layout.head = c() ,layout.body = 'page', layout.side = c(), header.title = 'Cash Manager')
I$page      = list(type = 'fluidPage', 
                   layout = list('jsheader', list('CPLeft', 'metricBox'), list('mapBox',  'histBox'), 'tabBox'))

I$metricBox = list(type = 'fluidPage'    , layout = list(list('curUse', 'curBal', 'lstSrv', 'nxtSrv'), list('nDaysUNS', 'usageUNS', 'nextReb', 'available'), 'line', list('address', 'capacity', 'delStat')), weight = 8)
I$histBox   = list(type = 'box'          , title = 'History Plot', layout = 'histPanel', collapsible = T, collapsed = T, solidHeader = T, status = 'primary')
I$histPanel = list(type = 'fluidPage'    , title = '', layout = list(list('histYear', 'histPer', 'histFig'), 'histPlot'))
I$histFig   = list(type = 'selectInput'  , title = 'Plot Figure', choices = valid.figures            , selected = 'Demand'  , multiple = F)
I$histYear  = list(type = 'checkboxGroupInput', title = 'Year'  , choices = as.character(2013:2016)  , selected = '2016'    , inline = T)
I$histPer   = list(type = 'radioButton', title = 'Period'  , choices = c('Daily', 'Weekly', 'Monthly')  , selected = 'Weekly', inline = T)

#I$seasBox   = list(type = 'box'          , title = 'Seasonality', layout = 'seasPanel', collapsible = T, collapsed = T, solidHeader = T, status = 'primary')
#I$seasPanel = list(type = 'fluidPage'    , title = '', layout = list(list('seasYear', 'seasFigs', 'seasType'), 'seasPlot'))
#I$seasYear  = list(type = 'radioButton'  , title = 'Year'  , choices = c(as.character(2013:2016),'All History', 'Future'), selected = '2016', inline = T)
#I$seasFigs  = list(type = 'selectInput'  , title = 'Figures', choices = valid.figures,  selected = 'Demand', multiple = T)
#I$seasType  = list(type = 'radioButton'  , title = 'Seasonality', choices = c("Day of Week" = "dow", "Month of Year" = "moy"),  selected = 'dow', inline = T)

I$mapBox   = list(type = 'box'            , title = 'Map', layout = 'mapPanel', collapsible = T, collapsed = T, solidHeader = T, status = 'primary')
I$mapPanel = list(type = 'fluidPage'      , title = '', layout = list(list('reset.atms', 'zoom'), 'map'))
I$reset.atms = list(type = 'actionButton' , title = 'Show All ATMs', srv.func = "val$mapsel = names(sg$stores)")
I$zoom      = list(type = 'actionButton'  , title = 'Zoom on Selected ATM', srv.func = "val$mapsel = input$atmid")

I$tabBox   = list(type = 'box'          , title = 'Orders Overview', layout = 'tabPanel', collapsible = T, collapsed = F, solidHeader = T, status = 'primary')
I$tabPanel = list(type = 'fluidPage'    , title = '', layout = list(list('filter.atm', 'filter.day', 'all.atms', 'all.days', 'saveOrder', 'saveModel'), 'line', 'profile'))

#I$calBox    = list(type = 'box'          , title = 'Calendar', layout = 'calPanel', collapsible = T, collapsed = T, solidHeader = T, status = 'primary')
#I$calPanel  = list(type = 'fluidPage'    , title = '', layout = list(list('calYear', 'calFig'), 'calPlot'))
#I$calYear   = list(type = 'radioButton'  , title = 'Year'  , choices = c(as.character(2013:2016),'All History', 'Future'), selected = '2016', inline = T)
#I$calFig    = list(type = 'selectInput'  , title = 'Figure', choices = valid.figures,  selected = 'Order', multiple = F)

I$CPLeft    = list(type = 'fluidPage'    , title = '', layout = list(list('atmid', 'ordate'), list('ord100', 'ord50', 'ord20'), 'line', list('curTotal', 'submit', 'clear')), weight = 4, cloth = boxCloth)

# Sidebar Inputs
# I$date       = list(type = 'dateInput'    , title = 'Date:', min = min(all.dates), max = max(all.dates))
# I$reset.days = list(type = 'actionButton' , title = 'All days', cloth = colCloth)

# Outputs:

I$ord20  = list(type = 'numericInput', title = h3('Order $20:') , min = 0 , max = 60000, step = 20, value = val.ord20, width = '100%', weight = 4)
I$ord50  = list(type = 'numericInput', title = h3('Order $50:') , min = 0 , max = 300000, step = 50, value = val.ord50, width = '100%', weight = 4)
I$ord100 = list(type = 'numericInput', title = h3('Order $100:'), min = 0 , max = 200000, step = 100, value = val.ord100, width = '100%', weight = 4)

I$ordate = list(type = 'dateInput', value = tdy + 1, min = tdy, max = tdy + 30, title = h3('Order Delivery Date:'), weight = 8)
I$atmid  = list(type = 'selectInput', title = h3('ATM ID:'), choices = rownames(sg$spec), selected = sg$selected, weight = 4)

O$curTotal    = list(type = 'htmlOutput', title = "Total Order")

O$line        = list(type = 'static', object = hr())
# O$line        = list(type = 'static', object = img(src='C:/Nima/R/projects/cba/ATM.opt.dashboard/images/GO_Line.png', align = "right"))
# O$logo        = list(type = 'static', object = img(src='C:/Nima/R/projects/cba/ATM.opt.dashboard/images/GO_Logo.png', align = "left"))
O$logo        = list(type = 'static', object = lg)

I$all.atms    = list(type = 'actionButton' , title = h4('Include All ATMs'), width = '100%', icon = icon('bullseye', 'fa-2x'), srv.func = "val$tabsel = names(sg$stores)")
I$all.days    = list(type = 'actionButton' , title = h4('Include All Days'), width = '100%', icon = icon('calendar', 'fa-2x'), srv.func = "val$tabday = unique(sg$TORDS[, figs['Date']])")
I$filter.atm  = list(type = 'actionButton' , title = h4('Filter Selected ATM'), width = '100%', icon = icon('filter', 'fa-2x'), srv.func = "val$tabsel = input$atmid")
I$filter.day  = list(type = 'actionButton' , title = h4('Filter Selected Date'), width = '100%', icon = icon('calendar-check-o', 'fa-2x'), srv.func = "val$tabday = input$ordate")
#I$submitSel = list(type = 'actionButton' , title = h4('Submit Selected Orders'), width = '100%', icon = icon('trash-o', 'fa-2x'))
#I$clearSel  = list(type = 'actionButton' , title = h4('Clear  Selected Orders'), width = '100%', icon = icon('send', 'fa-2x'))
I$submit    = list(type = 'actionButton' , title = h4('Submit Order'), width = '100%')
I$clear     = list(type = 'actionButton' , title = h4('Clear Order'), width = '100%')
I$saveModel = list(type = 'actionButton' , title = h4('Save Model'), width = '100%', icon = icon('save', 'fa-2x'))
I$saveOrder = list(type = 'actionButton' , title = h4('Save Orders'), width = '100%', icon = icon('save', 'fa-2x'))


O$map       = list(type = 'leafletOutput'  , title = '', cloth = mapFrame)
O$profile   = list(type = 'dataTableOutput', title = 'ATM Profile')
O$jsheader  = list(type = 'static')
O$histPlot  = list(type = 'dygraphOutput')
#O$seasPlot  = list(type = 'gglVisChartOutput', title = 'Seasonality')
#O$calPlot   = list(type = 'gglVisChartOutput', title = 'Calendar', width = "auto")

O$curUse    = list(type = 'uiOutput', title = "Latest Usage"  , cloth = cloth.latuse)
O$curBal    = list(type = 'uiOutput', title = "Latest Balance", cloth = cloth.latbal)
O$lstSrv    = list(type = 'infoBoxOutput')
O$nxtSrv    = list(type = 'infoBoxOutput')
O$address   = list(type = 'valueBoxOutput', weight = 6)
O$capacity  = list(type = 'valueBoxOutput', weight = 3)
O$delStat   = list(type = 'valueBoxOutput', weight = 3)
# O$nxtSrv    = list(type = 'uiOutput', title = "Next Service Forecasted", cloth = infoCloth)

O$available = list(type = 'valueBoxOutput')
O$nDaysUNS  = list(type = 'uiOutput', title = "Days until the Next Service", cloth = cloth.dysnxt)
O$usageUNS  = list(type = 'uiOutput', title = "Estimated Usage until the Next Service", cloth = cloth.usenxt)
O$nextReb   = list(type = 'valueBoxOutput')

# Input Service Functions:

I[['submit']]$srv.func <- paste(
  "sg$goto(ydy)",
  "sg[input$atmid]$change.order(date = input$ordate, order_date = tdy, ord20 = input$ord20, ord50 = input$ord50, ord100 = input$ord100)",
  "sg[input$atmid]$jumptoLastSubmittedOrder()",
  "sg[input$atmid]$jump.optimal(until = tdy + 40, forecast_demand = F, fixed_roster = T, show = F)",
  "sg[input$atmid]$goto(ydy)",
  "sg$tords.update(atmids = input$atmid, start = tdy,  end = tdy + 30, figures = figs)",
  "val$tableTrigger  = T",
  "val$nxtSrvTrigger = T",
  sep = "\n")

I[['clear']]$srv.func <- paste(
  "sg$goto(ydy)",
  "sg[input$atmid]$change.order(date = input$ordate, ord20 = 0, ord50 = 0, ord100 = 0, submit = F)",
  "sg[input$atmid]$jumptoLastSubmittedOrder()",
  "sg[input$atmid]$jump.optimal(until = tdy + 40, forecast_demand = F, fixed_roster = T, show = F)",
  "sg[input$atmid]$goto(ydy)",
  "sg$tords.update(atmids = input$atmid, start = tdy,  end = tdy + 30, figures = figs)",
  "val$tableTrigger  = T",
  "val$nxtSrvTrigger = T",
  sep = "\n")

I[['saveOrder']]$srv.func <- "write.csv(sg$TORDS, path %+% as.character(tdy) %+% '.csv')"
I[['saveModel']]$srv.func <- "saveRDS(sg, data.path %+% 'dataset.rds')"

# I[['atmid']]$srv.func <- paste(
#   "val$tabsel = input$atmid",
#   "val$tabday = unique(sg$TORDS[,figs['Date']])",
#   sep = "\n")
# 
# I[['ordate']]$srv.func <- paste(
#   "val$tabsel = val$tabsel = names(sg$stores)",
#   "val$tabday = val$tabday = input$ordate",
#   sep = "\n")

# Output Service Functions:

O[['map']]$srv.func       = "leaflet.map.plot(sg, tiles = T)"
O[['profile']]$srv.func   = paste(
  "if (is.null(val$tableTrigger)){val$tableTrigger = T}",
  "if (is.null(val$tabsel)){val$tabsel <- names(sg$stores)}",
  "if (is.null(val$tabday)){val$tabday <- tdy + 1}",
  "if (val$tableTrigger){val$tableTrigger = F}",
  "w = (sg$TORDS[,figs['Order']] > 0) & (sg$TORDS[, figs['Date']] %in% val$tabday) & (sg$TORDS[,figs['ATM.ID']] %in% val$tabsel)",
  "DT.Table.plot(sg$TORDS[w,], links = tableLinks, session = session, options = tableOptions, rownames = T) %>%", 
  "DT::formatStyle('Submitted', target = 'row', fontWeight = DT::styleEqual(c(0, 1), c('normal', 'bold')), color = DT::styleEqual(c(0, 1), c('gray', 'black')))", 
  sep = "\n")

O[['jsheader']]$object    = tags$head(includeCSS('script/styles.css'), includeScript('script/gomap.js'))

O[['histPlot']]$srv.func  = "sg$stores[[input$atmid]]$plot.timeBreak.yoy(years = input$histYear, x.axis = yoyxaxis[input$histPer],figure = input$histFig, main = paste0('ATM No. ', input$atmid, ' (', input$histFig, ')'))"

# vs$plot.history(peri = getPeriod(vs, input$histYear), figures = input$histFig, main = paste0('ATM No. ', input$atmid, ' (', input$histFig, ')'))", sep = "\n")
# O[['seasPlot']]$srv.func      = "sg[input$atmid]$plot.seasonality(peri = getPeriod(sg$stores[[input$atmid]], input$seasYear), figures = input$seasFigs, seasonality = input$seasType)"
# O[['calPlot']]$srv.func       = "sg[input$atmid]$plot.calendar(peri = getPeriod(sg$stores[[input$atmid]], input$calYear), figure = input$calFig)"
O[['curTotal']]$srv.func      = "h3('Total Order: $' %+% prettyNum(val$ord, scientific = F, big.mark = ','))"

O[['curUse']]$srv.func = "'$ ' %+% prettyNum(sg[input$atmid]$current('Demand'), scientific = F, big.mark = ',')"
O[['curBal']]$srv.func = "'$ ' %+% prettyNum(sg[input$atmid]$current('Balance'), scientific = F, big.mark = ',')"
O[['lstSrv']]$srv.func = paste(
  "tn = sg[input$atmid]$last.order(global = F, submitted_only = T)",
  "ov = '$ ' %+% prettyNum(sg[input$atmid]$data$Order[tn], scientific = F, big.mark = ',')",
  "od = 'On ' %+% prettyDate(sg[input$atmid]$time[tn])",
  "infoBox('Last Service', value = ov, icon = icon('truck'), subtitle = od)",
  sep = "\n")

O[['nxtSrv']]$srv.func = paste(
  "if (is.null(val$nxtSrvTrigger)){val$nxtSrvTrigger = T}",
  "if (val$nxtSrvTrigger){val$nxtSrvTrigger = F}",
  "tn = sg[input$atmid]$next.order(submitted_only = F)",
  "ov = '$ ' %+% prettyNum(sg[input$atmid]$data$Order[tn], scientific = F, big.mark = ',')",
  "od = 'On ' %+% prettyDate(sg[input$atmid]$time[tn])",
  "infoBox('Next Service', value = ov, icon = icon('truck'), subtitle = od)",
  sep = "\n")

O[['available']]$srv.func = "valueBox(subtitle = 'Availability on ' %+% prettyDate(sg[input$atmid]$now()), value = format(100*sg[input$atmid]$current('Availability'), digits = 3) %+% ' %', icon = icon('hand-grab-o'))"
O[['nDaysUNS']]$srv.func  = "sg[input$atmid]$next.order(submitted_only = F) - sg[input$atmid]$ctn"

# O[['usageUNS']]$srv.func = "paste('$', prettyNum(sg$TORDS[(sg$TORDS[, figs['Date']] == tdy) & (sg$TORDS[, figs['ATM.ID']] == input$atmid), figs['TD']], scientific = F, big.mark = ','))"
O[['usageUNS']]$srv.func = paste(
  "tn = sg[input$atmid]$next.order(submitted_only = F)",
  "rv = sg[input$atmid]$current('Balance') - sg[input$atmid]$data$Rebank[tn]",
  "paste('$', prettyNum(rv , scientific = F, big.mark = ','))",
  sep = "\n")

O[['nextReb']]$srv.func = paste(
  "if (is.null(val$nxtSrvTrigger)){val$nxtSrvTrigger = T}",
  "if (val$nxtSrvTrigger){val$nxtSrvTrigger = F}",
  "tn = sg[input$atmid]$next.order(submitted_only = F)",
  "rv = '$ ' %+% prettyNum(sg[input$atmid]$data$Rebank[tn], scientific = F, big.mark = ',')",
  "od = 'On ' %+% prettyDate(sg[input$atmid]$time[tn])",
  "valueBox(value = rv, icon = icon('rotate-left'), subtitle = 'Estimated Rebank in the Next Service')",
  sep = "\n")


O[['address']]$srv.func  = "valueBox(value = sg$spec[input$atmid, 'Name'], icon = icon('map-marker'), subtitle = 'Address: ' %+% sg$spec[input$atmid, 'Address.1'], color = 'olive')"
O[['capacity']]$srv.func = "valueBox(subtitle = 'Capacity', value = prettyNum(sg$spec[input$atmid, 'Capacity'], scientific = F, big.mark = ','), icon = icon('battery-full'), color = 'olive')"
O[['delStat']]$srv.func  = "valueBox(subtitle = 'Roster Delivery Dates', value = sg$spec[input$atmid, 'DeliveryDays'], icon = icon('calendar', lib = 'glyphicon'), color = 'olive')"


# Observers:

OB = character()

OB[1] <- "updateSelectInput(session, 'atmid', selected = input$map_marker_click$id)"
OB[2] <- paste("if (is.null(val$mapsel)){val$mapsel <- rownames(sg$spec)}",
               "isolate({leafletProxy('map') %>% leaflet.map.Zoom(lat = sg$spec[val$mapsel, 'Latitude'], long = sg$spec[val$mapsel, 'Longitude'])})",
               sep = "\n")

OB[3] <- paste(
  "a = is.null(input$goto)",
  "updateNumericInput(session, 'ord100', value = sg$TORDS[getTordsRowNumber(sg$TORDS, day = input$ordate, id = input$atmid), figs['O100']])",
  "updateNumericInput(session, 'ord50' , value = sg$TORDS[getTordsRowNumber(sg$TORDS, day = input$ordate, id = input$atmid), figs['O50']])",
  "updateNumericInput(session, 'ord20' , value = sg$TORDS[getTordsRowNumber(sg$TORDS, day = input$ordate, id = input$atmid), figs['O20']])",
  
  sep = "\n")

# map.zoom('map', lat = sg$spec[input$goto$id, 'Latitude'], long = sg$spec[input$goto$id, 'Longitude'], dist = 0.01)

OB[4] <- paste(
  "if (is.null(input$goto)) {return()}",
  "updateSelectInput(session, 'atmid', selected = input$goto$id)",
  "updateDateInput(session, 'ordate', value = input$goto$date)",
  sep = "\n")

OB[5] <- "val$ord = input$ord100 + input$ord50 + input$ord20"


dash = new('DASHBOARD', items = c(I, O), king.layout = list('main'), observers = OB)

#ui     <- dash$dashboard.ui()
#server <- dash$dashboard.server()

#shinyApp(ui, server)

# Todo Now:
# 1- tooltip for the table: https://rstudio.github.io/DT/options.html (Section 4.4: Column Rendering)
# 2- calendar and seasplot size
# 3- $ sign for currencies: http://127.0.0.1:25115/library/DT/html/formatCurrency.html or https://rstudio.github.io/DT/options.html (section 4.5: row rendering) 

# Todo later:
# 1- reactive values defined inside the object
# 2- reactive functions added
# 3- renderui added as a new type of output
# HOUzz

# 1 - show 90 days ahead
# 2 - icons (Done)
# 3 - apply version 2 table columns (Done)
# 4 - order date show as string (Done)
# 5 - remove balances from the table (Done)
# 6 - swap filter.sel.date & include all.atms (Done)
# 7 - Total order written bigger (Done)
# 8 - set order should be exactly the same amount (Done)
# 9 - Different color for submitted orders (Done) Took one whole day! (Done)
# 10- Table filtered by selecting day and ATM from change order box and map, but not selection from the table (Not Possible)
# 11- Run the optimization when new orders are submitted or orders change (Done)
# 12- Remove rownames from the table (Not Possible!)
# 13- Infoboxes functionality (Done)
# 14- close to 340 k round to 340K ! (Done)
# 15- Functionality for buttons 'submit selected orders' and 'clear selected orders'

# Next Steps:
# 11- Add Calender & seasonality views
# 12- Amend history plot ()
# 13- Amend map (line below the buttons)
# 14- map (remove popups)
# 15- map: apply tooltip
# 16- add table filter
# 17- add table column selection

### cba.tools.R --------------------
# Header
# Filename:      cba.tools.R
# Description:   This library, can be used to read the ATM data with the special format provided by CBA
#                Everything you need to convert the ATM data into a set of instances of class VIRTUAL.STORE from package nira.storeman
# Author:        Nima Ramezani Taghiabadi
# Email :        nima.ramezani@cba.com.au
# Start Date:    14 January 2016
# Last Revision: 24 February 2017
# Version:       2.2.0

# Version History:

# Version   Date            Action
# ----------------------------------
# 1.8.0     29 July 2016      Availability data is read from data-mart. Functions readATMData(), prepare4ATMGroup() and as.ATMGroup() modified.
# 1.8.1     24 August 2016    Function read.atm.data.raw() renamed to readATMData().
# 1.8.2     24 August 2016    Function readATMData() modified: Arguments 'startDate', 'endDate' added,  
# 1.8.3     24 August 2016    Arguments 'start' and 'end' in all functions renamed to 'startDate' and 'endDate'
# 1.8.4     24 August 2016    Arguments 'start_date' and 'end_date' in all functions renamed to 'startDate' and 'endDate'
# 1.8.5     24 August 2016    Function read.atm.profile() renamed to readATMProfile().
# 1.8.6     24 August 2016    Function prepare4ATMGroup() renamed to prepare4ATMGroup().
# 1.8.7     24 August 2016    Function to.atm.group() eliminated.
# 1.8.8     24 August 2016    Argument 'rawData' renamed to 'rawData' in all functions.
# 1.8.8     24 August 2016    Argument 'dsn' added to function readATMData()
# 1.8.9     24 August 2016    Argument 'query' eliminated for function readATMProfile()
# 1.9.0     24 August 2016    Function to.virtual.atm() renamed to as.VirtualATM().
# 2.0.0     07 September 2016 Function updateATMGroup() modified. Updates Availability and Demand.Adj as well.
# 2.1.0     09 September 2016 Function readATMData() modified: Argument 'settings_fn' reads the specific atm settings 
#                             from a file and adds as additional columns to the 'spec' table.
# 2.1.1     14 September 2016 Argument 'forecast_err_fn' renamed to 'forerror'
# 2.1.2     27 October 2016   Function decodeDD() added. Decodes Delivery Days from ATM profile table
# 2.1.3     06 December 2016  Function readATMProfile() deleted. Function readATMData() modified: calls readODBC() from niraIO.R in niragen
# 2.1.4     23 January 2017   Function calls readODBC() in readATMData() causes problem: Column ATMID is read as integers. Problem fixed by converting to charachter. 
# 2.1.5     24 January 2017   Function calls readODBC() in readATMData() causes problem: strings are converted to factors. Problem fixed by setting argument 'stringsAsFactors' to FALSE. 
# 2.1.6     06 February 2017  Function updateDemandForecast() eliminated. 
# 2.1.7     06 February 2017  Module removed from package nira.atmopt. All #export roxygen tags removed.
# 2.1.8     06 February 2017  ATM table names changed.
# 2.2.0     24 February 2017  Method prepare4ATMGroup() modified: Relocates the re-banks to their correct places


atm.spec.columns  = list(id = "ATMID", capacity = 'MaximumCapacity', address.1 = 'Address1', address.2 = 'Address2',
                         city = "City", state = "State", postcode = "Postcode", longitude = "Longitude", lattitude = "Lattitude",
                         type = "MachineType", class = "Cannisters", depot = "VaultCarrier", group = "GroupName", 
                         initial.balance = "IB", standard.order.cost = "Standrad", emergency.order.cost = "Emergency")

###### READ DIRECTLY FROM DATAMART ###### 


readATMData = function(atmids = NULL, ratecard_fn = NULL, settings_fn = NULL, forecast_fn = NULL, forerror_fn = NULL, frost_fn = NULL, ipo_fn = NULL, startDate = NULL, endDate = NULL, dsn = "Teradata_Prod"){
  assert(require(RODBC), "Package 'RODBC' is not installed!", err_src = match.call()[[1]])
  assert(require(data.table), "Package 'data.table' is not installed!", err_src = match.call()[[1]])
  
  cat('Reading profiles ... ')
  filter = list(ATMID = list(domain = atmids), loaddate = list(query = "(select max(loaddate) as ld from  UDRBSCMS.tblATMProfile_base)"))
  spc    = readODBC(tableName = 'tblATMProfile_base', dbName = 'UDRBSCMS', filter = filter, stringsAsFactors = F)
  spc$ATMID = as.character(spc$ATMID)
  cat('Done ! \n')
  
  cat('Removing inactive ATMs ... ')
  atms = spc$ATMID[!is.na(spc$Active) & as.logical(spc$Active)]
  if (is.null(atmids)){atmids = unique(spc$ATMID)}
  atms = intersect(atmids, atms)
  spc = spc[spc$ATMID %in% atms, ,drop = F]
  # todo: remove duplicated rows if there are any
  rownames(spc) <- spc$ATMID
  cat('Done ! \n')
  
  if (!is.null(ratecard_fn)){
    cat('Reading order cost rate card ... ')
    crc = read.csv(ratecard_fn, row.names = 1, as.is = T)
    verify(crc, 'data.frame', names_include = c('Standard', 'Emergency'), varname = 'The Rate-card file: ' %+% ratecard_fn)
    verify(crc$Standard, 'numeric', varname = 'crc$Standard')
    verify(crc$Emergency, 'numeric', varname = 'crc$Standard')
    # crc$ATM.ID <- as.character(crc$ATM.ID)
    
    if (sum(!rownames(spc) %in% rownames(crc)) > 0){
      cat('Some ATMs are missing in the ratecard: \n', rownames(spc)[which(!rownames(spc) %in% rownames(crc))], '\n')
      atms = intersect(atms, rownames(crc))
      spc = spc[atms, , drop = F]      
    }
    crc = crc[atms,]
    cat('Done ! \n')
  } else {crc = NULL}  
  
  if (!is.null(settings_fn)){
    cat('Reading settings file ... ')
    sts = read.csv(settings_fn, row.names = 1, as.is = T)
    verify(sts, 'data.frame', names_include = c('SEG', 'Base'), varname = 'The settings file: ' %+% settings_fn)
    verify(sts$SEG,  c('numeric', 'integer'), domain = c(0,1), varname = 'sts$SEG')
    verify(sts$Base, c('numeric', 'integer'), varname = 'crc$Base')
    
    # No need to filter out ATMs missing in the settings table    
    
    #     if (sum(!rownames(spc) %in% rownames(srs)) > 0){
    #       cat('Some ATMs are missing in the settings: \n', rownames(spc)[which(!rownames(spc) %in% rownames(sts))], '\n')
    #       # atms = intersect(atms, rownames(sts)) 
    #       spc = spc[atms, , drop = F]      
    #     }
    
    sts = sts[atms %^% rownames(sts),]
    cat('Done ! \n')
  } else {sts = NULL}  
  
  if ((!is.null(forecast_fn)) & (!is.null(forerror_fn))){
    cat('Reading forecasts ... ')
    frc = read.csv(forecast_fn, as.is = T, row.names = 1, check.names = F)
    fer = read.csv(forerror_fn, as.is = T, row.names = 1, check.names = F)
    frc = frc[, intersect(atmids,names(frc)), drop = F]
    fer = fer[, intersect(atmids,names(fer)), drop = F]
    cat('Done ! \n')
  } else {
    frc = NULL
    fer = NULL
  }
  
  if (!is.null(frost_fn)){
    cat('Reading feasible roster days ... ')
    frst = read.csv(frost_fn, as.is = T, row.names = 1)
    frst = frst[atmids, , drop = F]
    cat('Done ! \n')
    # frst[(frst == 0) | (frst == 'NA')] <- NA
  } else {
    frst = NULL
  }
  
  if (length(atmids) > length(atms)){cat("\n Some ATMs from the given list are removed as inactive. \n")}
  channel <- odbcConnect(dsn = dsn)
  atm_list = paste(atms, collapse = "','")
  query.1  = "sel * from UDRBSCMS.ATM_Trans_HIST where ATMID IN ('" %+% atm_list  %+% "')"  
  query.2  = "sel * from UDRBSCMS.ATM_Rebank_HIST where ATM_ID IN ('" %+% atm_list  %+% "')"  
  query.3  = "sel * from UDRBSCMS.tblATM_ATMDtls where ATM_ID IN ('" %+% atm_list  %+% "')"  
  query.4  = "sel * from UDRBSCMS.ATM_AVAIL_HIST where ATMID IN ('" %+% atm_list  %+% "')"  
  
  startDate = verify(startDate, valid.time.classes, varname = "startDate")
  endDate   = verify(endDate  , valid.time.classes, varname = "endDate")
  
  if (!is.null(startDate)){
    startChar   = paste0("'", as.character(as.Date(startDate)), " 00:00:00.000000'")
    query.1     = paste0(query.1, "AND TransDate >=", startChar)
    query.2     = paste0(query.2, "AND delivery_date >=", startChar)
    query.4     = paste0(query.4, "AND YYMMDD >=", as.character(as.Date(startDate), format = "%y%m%d"))
  }
  
  if (!is.null(endDate)){
    endChar     = paste0("'", as.character(as.Date(endDate)), " 00:00:00.000000'")
    query.1     = paste0(query.1, "AND TransDate <=", endChar)
    query.2     = paste0(query.2, "AND delivery_date <=", endChar)
    query.4     = paste0(query.4, "AND YYMMDD <=", as.character(as.Date(endDate), format = "%y%m%d"))
  }
  
  cat('Reading demands and balances ... ')
  D <- sqlQuery(channel = channel, query = query.1)
  cat('Done ! \n')
  
  cat('Reading orders and rebanks ... ')
  O <- sqlQuery(channel = channel, query = query.2)
  cat('Done ! \n')
  
  cat('Preparations ... ')
  names(D)[3]  <- 'Date'
  names(O)[3]  <- 'Date'
  
  names(O)[2] <- 'ATMID'
  
  D$Date <- as.Date(D$Date, tz = "NZ")
  O$Date <- as.Date(O$Date, tz = "NZ")
  
  D = D[order(D$Date),, drop = F]
  O = O[order(O$Date),, drop = F]
  
  DO = merge(D, O, by = c('Date','ATMID'), all = T)
  
  DO$ATMID = as.factor(DO$ATMID)  
  DO = DO[, c('Date', 'ATMID', 'WD100', 'WD50', 'WD20', 'Bal100', 'BAL50', 'BAL20', 'Order100', 'Order50', 'Order20', 'Rebank100', 'Rebank50', 'Rebank20')]
  
  DO[is.null(DO)] <- 0
  DO[is.na(DO)]   <- 0
  
  names(DO) <- c("Date", "ATMID", "WD100", "WD50", "WD20", "BAL100", "BAL50", "BAL20", "ORD100", "ORD50", "ORD20", "REB100", "REB50", "REB20")
  
  cat('Done ! \n')
  
  cat('Reading spacial data and adding to profiles ... ')
  spacial <- sqlQuery(channel = channel, query = query.3)
  spacial$ATM_ID <- as.character(spacial$ATM_ID)
  spacial = spacial[!duplicated(spacial$ATM_ID),]
  rownames(spacial) <- spacial$ATM_ID
  
  atms.sp = intersect(atms, spacial$ATM_ID)
  
  # Fix errors
  errors <- spacial$Longitude < 0
  keep   <- spacial$Longitude[errors]
  spacial$Longitude[errors] <- spacial$Latitude[errors]
  spacial$Latitude[errors]  <- keep
  
  spc[atms.sp, 'Longitude'] = spacial[atms.sp, 'Longitude']
  spc[atms.sp, 'Latitude']  = spacial[atms.sp, 'Latitude']
  
  cat('Done ! \n')
  
  DO$ATMID <- as.character(DO$ATMID)
  
  if (!is.null(ipo_fn)){
    IPO = read.csv(ipo_fn, as.is = T)
    IPO = IPO[IPO$ATMID %in% atmids, ]
    k = nrow(IPO)
    N = nrow(DO)
    
    DO[N + sequence(k), 'Date'] <- as.POSIXct(char.to.time(IPO$ServiceDate))
    DO[N + sequence(k), c('ATMID', 'ORD100', 'ORD50', 'ORD20')] <- IPO[c('ATMID', 'X.100', 'X.50', 'X.20')]
  }  
  
  cat('Reading availability ... ')
  # Soon I will add some code here
  A <- sqlQuery(channel = channel, query = query.4)
  A$Date = as.Date(as.character(A$YYMMDD), format = '%y%m%d')
  A = A[order(A$YYMMDD),]
  A$Availability = A$OPEN1/1440
  A = A[,c('Date', 'ATMID', 'Availability')]
  cat('Done ! \n')
  
  close(channel)
  
  out = list(profile = spc, transactions = DO, ratecard = crc, settings = sts, forecasts = frc, forecast_errors = fer, froster = frst, availability = A)
  return(out)
}

# Note: The rawData that is given to this function as input, must have ratecard data
prepare4ATMGroup = function(rawData){
  SPC     = rawData$profile
  
  atms    = as.factor(unique(rawData$transaction$ATMID))
  time    = sort(unique(rawData$transaction$Date))
  DEM.20  = data.frame()
  DEM.50  = DEM.20
  DEM.100 = DEM.20
  BAL.20  = DEM.20
  BAL.50  = DEM.20
  BAL.100 = DEM.20
  ORD.20  = DEM.20
  ORD.50  = DEM.20
  ORD.100 = DEM.20
  REB.20  = DEM.20
  REB.50  = DEM.20
  REB.100 = DEM.20
  AVA     = DEM.20
  
  for (k in atms){
    Ak                  <- rawData$availability[rawData$availability$ATMID == k,]
    Dk                  <- rawData$transactions[rawData$transactions$ATMID == k,]
    dates.k             <- as.character(Dk$Date)
    dates.A             <- as.character(Ak$Date)
    Dk                  <- Dk[!duplicated(dates.k),]
    Ak                  <- Ak[!duplicated(dates.A),]
    dates.k             <- unique(dates.k)
    dates.A             <- unique(dates.A)
    rownames(Ak)        <- dates.A
    
    # DEM.20            <- merge(DEM.20, Dk[, c('Date', 'WD20')], by = 'Date', all = T) # another solution
    DEM.20[dates.k, k]  <- Dk[, 'WD20']
    DEM.50[dates.k, k]  <- Dk[, 'WD50']
    DEM.100[dates.k, k] <- Dk[, 'WD100']
    
    BAL.20[dates.k, k]  <- Dk[, 'BAL20']
    BAL.50[dates.k, k]  <- Dk[, 'BAL50']
    BAL.100[dates.k, k] <- Dk[, 'BAL100']
    
    ORD.20[dates.k, k]  <- Dk[, 'ORD20']
    ORD.50[dates.k, k]  <- Dk[, 'ORD50']
    ORD.100[dates.k, k] <- Dk[, 'ORD100']
    
    w = which((Dk[, 'ORD20'] > 0) | (Dk[, 'ORD50'] > 0) | (Dk[, 'ORD100'] > 0))
    
    N = length(w)
    Dk[w[N], 'REB20']  <- NA
    Dk[w[N], 'REB50']  <- NA
    Dk[w[N], 'REB100'] <- NA
    
    Dk[w[-N], 'REB20']  <- Dk[w[-1], 'REB20']
    Dk[w[-N], 'REB50']  <- Dk[w[-1], 'REB50']
    Dk[w[-N], 'REB100'] <- Dk[w[-1], 'REB100']
    
    REB.20[dates.k, k]  <- Dk[, 'REB20']
    REB.50[dates.k, k]  <- Dk[, 'REB50']
    REB.100[dates.k, k] <- Dk[, 'REB100']
    
    AVA[dates.k, k] <- Ak[dates.k, 'Availability']
    
  }
  
  timechar = as.character(time)
  DEM.20   = DEM.20[timechar,, drop = F]
  DEM.50   = DEM.50[timechar,, drop = F]
  DEM.100  = DEM.100[timechar,, drop = F]
  BAL.20   = BAL.20[timechar,, drop = F]
  BAL.50   = BAL.50[timechar,, drop = F]
  BAL.100  = BAL.100[timechar,, drop = F]
  ORD.20   = ORD.20[timechar,, drop = F]
  ORD.50   = ORD.50[timechar,, drop = F]
  ORD.100  = ORD.100[timechar,, drop = F]
  REB.20   = REB.20[timechar,, drop = F]
  REB.50   = REB.50[timechar,, drop = F]
  REB.100  = REB.100[timechar,, drop = F]
  AVA      = AVA[timechar,, drop = F]
  
  DEM = DEM.20 + DEM.50 + DEM.100
  BAL = BAL.20 + BAL.50 + BAL.100
  ORD = ORD.20 + ORD.50 + ORD.100
  REB = REB.20 + REB.50 + REB.100
  
  ff   = apply(as.matrix(ORD), 2, first.feasible)
  ff   = ff[!is.na(ff)]
  atms = names(ff)
  
  SPC[atms, 'IB.Date.Num'] <- ff + 1 # IB here refers to the opening balance of the day
  for (k in atms){SPC[k, 'IB'] <- BAL[ff[k], k]}
  SPC[rownames(rawData$ratecard), 'Standard']  <- rawData$ratecard$Standard
  SPC[rownames(rawData$ratecard), 'Emergency'] <- rawData$ratecard$Emergency
  
  if (!is.null(rawData$settings)){
    SPC[rownames(rawData$settings), 'SEG']       <- rawData$settings$SEG
    SPC[rownames(rawData$settings), 'Base']      <- rawData$settings$Base
  }
  
  if (length(atms) < nrow(SPC) ){
    SPC = SPC[atms, ]
    DEM.20  = DEM.20[, atms]
    DEM.50  = DEM.50[, atms]
    DEM.100 = DEM.100[, atms]
    DEM     = DEM[, atms]
    
    BAL.20  = BAL.20[, atms]
    BAL.50  = BAL.50[, atms]
    BAL.100 = BAL.100[, atms]
    BAL     = BAL[, atms]
    
    ORD.20  = ORD.20[, atms]
    ORD.50  = ORD.50[, atms]
    ORD.100 = ORD.100[, atms]
    ORD     = ORD[, atms]
    
    REB.20  = REB.20[, atms]
    REB.50  = REB.50[, atms]
    REB.100 = REB.100[, atms]
    REB     = REB[, atms]
  }
  
  out = list(dem.20 = DEM.20, dem.50 = DEM.50, dem.100 = DEM.100, dem = DEM,
             bal.20 = BAL.20, bal.50 = BAL.50, bal.100 = BAL.100, bal = BAL,
             ord.20 = ORD.20, ord.50 = ORD.50, ord.100 = ORD.100, ord = ORD,
             reb.20 = REB.20, reb.50 = REB.50, reb.100 = REB.100, reb = REB,
             avail = AVA, spc = SPC, time = time)
  return(out)
}

as.VirtualATM = function(rawData, atm.id, ...){
  atms   = as.character(unique(rawData$profile$ATMID))
  atm.id =  as.character(atm.id)
  verify(atm.id, c('character', 'factor'), domain = atms)
  index = rawData$transactions$ATMID == atm.id
  R     = rawData$transactions[index, ]
  
  all.days = as.character(R$Date)
  nf       = !duplicated(all.days)
  
  #   R$WD20   = R$WD20[nf, ]
  #   R$WD50   = R$WD50[nf, ]
  #   R$WD100  = R$WD100[nf, ]
  #   R$BAL20  = R$BAL20[nf, ]
  #   R$BAL50  = R$BAL50[nf, ]
  #   R$BAL100 = R$BAL100[nf, ]
  #   R$ORD20  = R$ORD20[nf, ]
  #   R$ORD50  = R$ORD50[nf, ]
  #   R$ORD100 = R$ORD100[nf, ]
  #   R$REB20  = R$REB20[nf, ]
  #   R$REB50  = R$REB50[nf, ]
  #   R$REB100 = R$REB100[nf, ]
  R        = R[nf,]  
  all.days = all.days[nf]
  
  DEM   = R$WD20 + R$WD50 + R$WD100
  BAL   = R$BAL20 + R$BAL50 + R$BAL100
  ORD   = R$ORD20 + R$ORD50 + R$ORD100
  REB   = R$REB20 + R$REB50 + R$REB100
  
  ff    = first.feasible(ORD)
  if (is.na(ff)) {return(NA)}
  peri  = ff:length(R$Date)
  
  all.days = all.days[peri]
  
  if (ORD[ff] == 0){ib = BAL[ff] + DEM[ff]} else {ib = REB[ff] + DEM[ff] + BAL[ff] - ORD[ff]}
  d  = DEM[peri]
  o  = ORD[peri]
  b  = BAL[peri]
  
  bp    = c(Inf, b[-length(b)])
  nf    = which((b > bp) & (o < 1))
  o[nf] = b[nf] + d[nf]*0.5
  
  if (length(nf) > 0){
    days = paste(all.days[nf], collapse = " and ")
    cat( "Warning: On " %+% days %+% ", order is missing while balance increased for ATM ID " %+% atm.id %+% 
           "! Order and rebank estimated based on ARD ratio of 0.5 \n")
  }
  
  ar = (o-b)/d
  nf = (ar < 0) | (ar > 1) | is.na(ar)
  ar[nf] <- mean(ar[!nf])
  
  nf = which((o < 1) & (bp - b != d))
  if (length(nf) > 0){
    days = paste(all.days[nf], collapse = " and ")
    cat( "Warning: On " %+% days %+% ", usage and balance are inconsistent for ATM ID " %+% atm.id %+% "!\n")
  }
  
  VIRTUAL.STORE(timeset = R$Date[peri], demandset = d, orderset = o, initial_balance = ib, name = atm.id, center = "Sydney", ard_ratio = ar, ...)
}


as.ATMGroup = function(rawData, atm.ids = rawData$profile$ATMID, ...){
  atm.spec.columns  = list(ID = "ATMID", Name = "ATM_Name", Capacity = 'MaximumCapacity', Address.1 = 'Address1', Address.2 = 'Address2',
                           City = "City", State = "State", Postcode = "PostCode", 
                           Depot = "VaultCarrier", Initial.Balance = "IB", 
                           Order.Fee.InRoster = "Standard", Order.Fee.OffRoster = "Emergency",
                           Longitude = 'Longitude', Latitude = 'Latitude')
  
  res   = prepare4ATMGroup(rawData)
  ds    = list(D20 = res$dem.20, D50 = res$dem.50, D100 = res$dem.100,
               B20 = res$bal.20, B50 = res$bal.50, B100 = res$bal.100,
               O20 = res$ord.20, O50 = res$ord.50, O100 = res$ord.100,
               R20 = res$reb.20, R50 = res$reb.50, R100 = res$reb.100)
  
  #atms  = as.factor(unique(rawData$profile$ATMID))
  res$spc$MaximumCapacity <- res$spc$MaximumCapacity
  new('ATM.GROUP', dataset = ds, specset = res$spc, spec_columns = atm.spec.columns, 
      predset = rawData$forecasts, errorset = rawData$forecast_errors, availability = rawData$availability, ...)
}


# Once a year, the roster plan should be updated. This function, reads the data for a given depot from teradata and 
# based on the average usage and fortnightly seasonality, returns an optimum roster plan. 
# For doing this, a feasibility roster is required which specifies which days in a fortnight are forbidden for each atm
# The feasibility roster file is table n X 14 where n is the number of ATMs.
# Rownames are ATM IDs and columns refer to Monday the first week until Sunday the second week
# Inputs: depot A string specifying the depot
#         frost_fn path and filename containing the feasibility roster file
#         ratecard_fn is the path-filename of the ratecard table. Rownames must be ATM IDs and ATM depot should be specified by column 'Depot'   # Specify the date in which we want to run optimal roster planner:
#         date: Specifies the date in which we want to run optimal roster planner as character or timeDate
#         inflation_gain: A gain multiplied by the average usage values to accommodate inflation rate 
#         (For example, if it is estimated that average usages will be 10% higher the next year, the inflation_gain is 1.1)
#' @export
genCalRstr = function(depot, startDate, endDate, holidays = character(), inflation_gain = 1.0, frost_fn, ratecard_fn, output_fn, update = F){
  # What are the ATM IDs in this depot? Let's read ATM profiles.
  RC           = read.csv(ratecard_fn, as.is = T, row.names = 1, check.names = F)
  atms         = rownames(RC)[RC$Depot == depot]
  
  # Read raw data from datamart for the selected ATM IDs:
  raw = readATMData(atms, ratecard_fn = ratecard_fn, frost_fn = frost_fn)
  
  
  # And construct an ATM group object:
  sg  = as.ATMGroup(raw, time_zone = "Sydney")
  sg$name = depot
  
  #a = unique(raw$profile$ATMID)
  #a1 = sum(a %in% rownames(sg$spec))
  #a2 = sum(rownames(sg$spec) %in% a)
  #a3 = length(a)
  #a4 = sg$N.store
  
  #if((a1 != a2) | (a1 != a3) | (a1 != a4)){
  #  cat(depot, as.character(a), rownames(sg$spec))
  #  assert(F)
  #}
  
  strtn = sg$demand$time.number(startDate)
  
  # Let's obtain the optimum roster based on feasible roster days we read from frost_fn:
  R = sg$optimal.fortnight.roster(hist = sequence(strtn - 1), srv_cap = 200, gain = inflation_gain, feasible_roster = raw$froster)
  R = R[rownames(sg$spec),, drop = F]
  # Change the roster for 'Just in Time' ATMs:
  jits = which(sg$spec$DeliveryDays %in% c('JUST IN TIME', 'JIT'))
  R[jits,][!is.na(R[jits,])] <- 1
  
  endDate = as.time(endDate)
  
  if (endDate > sg$demand$time[sg$demand$N.int]){
    sg$extend(until = endDate, forecast_demand = F, period = 'DSTday')}
  
  endtn = sg$demand$time.number(endDate)
  # Roll the optimum roster to the whole calender of the time series:
  sg$settings$apply.roster.fortnightly(time = sg$demand$time, start = strtn, end = endtn, f_rost = R, in_roster_fee = sg$spec$Order.Fee.InRoster, off_roster_fee = sg$spec$Order.Fee.OffRoster, off_roster_weight = 5000.0, in_roster_weight = sg$spec$Order.Fee.InRoster)
  
  holidays = intersect(holidays, rownames(sg$settings$roster))
  sg$settings$roster[holidays, ] <- NA
  
  # And save the calroster:
  sg$settings$write.roster(output_fn, period = strtn:endtn, update = update)
}

#' @export
num.cans = function(cannisters){
  cannisters = as.character(cannisters)
  switch(cannisters,
         '4 Canister (1-$20 & 3-$50)' = {nc = c(1,3,0)},
         '4 Canister (2-$20 & 2-$50)' = {nc = c(2,2,0)},
         '3 Canister (1-$20 & 2-$50)' = {nc = c(1,2,0)},
         '2 Canister (1-$20 & 1-$50)' = {nc = c(1,1,0)},
         '4 Canister (3-$50 & 1-$100)'= {nc = c(0,3,1)},
         '4 Canister (3-$20 & 1-$50)' = {nc = c(3,1,0)})
  return(as.integer(nc))
}

# This method, pulls data from datamart for the atms of an ATM group object
# Remember, this function does not update time series properties of the store group object: demand, balance, rebank, data, order.cost, hold.cost and total.cost
# Only the virtual store objects in the list of stores will be updated!
# todo: should update these properties as well!
#' @export
updateATMGroup = function(atmg, atms = NULL, startDate = NULL, endDate = NULL, dsn = "Teradata_Prod"){
  # Todo: should update demand, balance, order and rebank time series as well
  # Verifications:
  verify(atmg, "ATM.GROUP")
  
  atms  = verify(atms, 'character', domain = rownames(atmg$spec), varname = "atms", default = rownames(atmg$spec))
  startDate = verify(startDate, valid.time.classes, varname = "startDate", default = yesterday())
  end   = verify(endDate  , valid.time.classes, varname = "endDate"  , default = yesterday())
  
  
  startChar = paste0("'", as.character(as.Date(startDate)), " 00:00:00.000000'")
  endChar   = paste0("'", as.character(as.Date(endDate))  , " 00:00:00.000000'")
  atmsChar  = paste(atms, collapse = "','")
  # Build SQL query:
  query.D   = paste("sel * from UDRBSCMS.ATM_Trans_HIST where ATMID IN ('" %+% atmsChar %+% "')",
                    "AND TransDate >=", startChar, "AND TransDate <=", endChar)
  query.O   = paste("sel * from UDRBSCMS.ATM_Rebank_HIST where ATM_ID IN ('" %+% atmsChar %+% "')",
                    "AND delivery_date >=", startChar, "AND delivery_date <=", endChar)
  
  query.A   = paste("sel * from UDRBSCMS.ATM_AVAIL_HIST where ATMID IN ('" %+% atmsChar %+% "')",
                    "AND YYMMDD >=", as.character(as.Date(startDate), format = "%y%m%d"), 
                    "AND YYMMDD <=", as.character(as.Date(endDate), format = "%y%m%d")) 
  
  assert(require('RODBC', character.only = T), "Package 'RODBC' must be installed before running this function!", err_src = match.call()[[1]])
  channel   <- odbcConnect(dsn = dsn)
  D         <- sqlQuery(channel = channel, query = query.D)
  O         <- sqlQuery(channel = channel, query = query.O)
  A         <- sqlQuery(channel = channel, query = query.A)
  close(channel)
  
  for (i in atms){
    cat(i, '\n')
    Di = D[D$ATMID == i,]
    Di = Di[!duplicated(Di$TransDate),]
    dateChar.D     <- time2Char(Di$TransDate)
    rownames(Di) <- dateChar.D
    Di           <- Di[c("WD100", "WD50", "WD20", "Bal100", "BAL50", "BAL20")]
    colnames(Di) <- c("D100", "D50", "D20", "B100", "B50", "B20")
    Di$Balance   <- Di$B20 + Di$B50 + Di$B100
    Di$Demand    <- Di$D20 + Di$D50 + Di$D100
    
    Oi = O[O$ATM_ID == i,]
    Oi = Oi[!duplicated(Oi$delivery_date),]
    dateChar.O     <- time2Char(Oi$delivery_date)
    rownames(Oi) <- dateChar.O
    Oi           <- Oi[c("Order100", "Order50", "Order20")]
    colnames(Oi) <- c("O100", "O50", "O20")
    Oi$Order     <- Oi$O20 + Oi$O50 + Oi$O100
    
    Ai = A[A$ATMID == i,]
    Ai = Ai[!duplicated(Ai$YYMMDD),]
    Ai$Date = as.Date(as.character(Ai$YYMMDD), format = '%y%m%d')
    Ai = Ai[order(Ai$YYMMDD),]
    Ai$Availability = Ai$OPEN1/1440
    Ai = Ai[,c('Date', 'Availability')]
    dateChar.A   <- time2Char(Ai$Date)
    rownames(Ai) <- dateChar.A
    Ai           <- Ai[,'Availability', drop = F]
    
    atmg$stores[[i]]$feed(Di)
    atmg$stores[[i]]$feed(Oi)
    atmg$stores[[i]]$feed(Ai)
    atmg$stores[[i]]$adjust.demand()
    
    strtn = atmg$stores[[i]]$time.number(startDate)
    endtn = atmg$stores[[i]]$time.number(endDate)
    atmg$stores[[i]]$data$Submitted[strtn:endtn] = TRUE
  }
  return(atmg)
}


#' @export
clearFutureForecasts = function(atmg){
  for (i in names(atmg$stores)){atmg$stores[[i]]$clearFutureForecasts()}
  return(atmg)
}


decodeDD = function(scr = c(), s){
  weekDay = wdlabel
  nwd     = c('M', 'T', 'W', 'H', 'F', 'S', 'U')
  names(weekDay) = nwd
  a = strsplit(s, 12)[[1]]
  if(length(a) > 1){
    assert(a[2] == '34')
    b = strsplit(a[1], NULL)[[1]]
    out = c((weekDay[b] %+% '.' %+% 1),(weekDay[b] %+% '.' %+% 2))
    return (c(scr, out))
  } else {
    a = strsplit(s, 13)[[1]]
    if(length(a) > 1){
      b = strsplit(a[1], NULL)[[1]]
      scr = c(scr, weekDay[b] %+% '.2')
      return(decodeDD(scr, a[2]))
    } else {
      if (2 %in% strsplit(a, NULL)[[1]]){
        a = strsplit(s, 24)[[1]]
        b = strsplit(a[1], NULL)[[1]]
        scr = c(scr, weekDay[b] %+% '.1')
        return(scr)
      } else {
        b = strsplit(a[1], NULL)[[1]]
        return(c(scr, weekDay[b] %+% '.2'))
      }
    }  
  } 
}

# Extract Usage Variances
# raw$transactions$Year = year(raw$transactions$Date)
# raw$transactions$WD   = raw$transactions$WD20 + raw$transactions$WD50 + raw$transactions$WD100
# M = aggregate(cbind(WD20, WD50, WD100, WD) ~ ATMID + Year, data = raw$transactions, FUN = high.pass.mean)
# S = aggregate(cbind(WD20, WD50, WD100, WD) ~ ATMID + Year, data = raw$transactions, FUN = high.pass.sd)
# MS = cbind(M, S)
# MSF = MS[MS$ATMID %in% atmids,]
# write.csv(MSF, 'variances_pilot2.csv')

### consolidate_results.R --------------------
rosters   = c('Current', 'Optimal')
bases     = c('0K','1K', '2K', '3K', '5K','10K','15K','20K')
segs      = c('20', '25','30','35', '40', '45', '50', '55', '60', '65', '75', '80', '85', '90', '95', '100')
versions  = c('V1', 'V2')
periods   = c('NEW')

# For test
r = rosters[1]
b = bases[1]
s = segs[1]
v = versions[1]
p = periods[1]

data.path = '\\\\flsy04/G_TS_SY$/CDO_MTK_SMT/Business Performance Reporting/Nima Ramezani/SIM_Results_NEW/'

R = data.frame()

for (p in periods){
  for (v in versions){
    for (r in rosters){
      for (b in bases){
        for (s in segs){
          filename = paste0(r, '_Base', b, '_SEG', s, '_', v, '_', p, '/.report.csv')
          RPT      = try(read.csv(data.path %+% filename), silent = T)
          if (inherits(RPT, 'data.frame')){
            R[filename, 'Roster']       <- r
            R[filename, 'Base']         <- b
            R[filename, 'SEG']          <- s
            R[filename, 'Version']      <- v
            R[filename, 'Hold.Cost']    <- '$ ' %+% prettyNum(floor(sum(RPT$HOLD.COST, na.rm = T)), big.mark = ',')
            R[filename, 'Serv.Cost']    <- '$ ' %+% prettyNum(floor(sum(RPT$SRV.COST, na.rm = T)) , big.mark = ',')
            R[filename, 'Tot.Cost']     <- '$ ' %+% prettyNum(floor(sum(RPT$TOT.COST, na.rm = T)) , big.mark = ',')
            R[filename, 'OOC.Zero']     <- as.integer(sum(1.0 - RPT$FILL.RATE.ZERO, na.rm = T)*365)
            R[filename, 'OOC.Base']     <- as.integer(sum(1.0 - RPT$FILL.RATE.BASE, na.rm = T)*365)
          }
        }
      }
    }    
  }  
}

RPT      = try(read.csv(data.path %+% 'ACTUAL_NEW/.report.csv'), silent = T)
if (inherits(RPT, 'data.frame')){
  R['Actual', 'Hold.Cost']    <- '$ ' %+% prettyNum(sum(RPT$HOLD.COST, na.rm = T), big.mark = ',')
  R['Actual', 'Serv.Cost']    <- '$ ' %+% prettyNum(sum(RPT$SRV.COST, na.rm = T) , big.mark = ',')
  R['Actual', 'Tot.Cost']     <- '$ ' %+% prettyNum(sum(RPT$TOT.COST, na.rm = T) , big.mark = ',')
  R['Actual', 'OOC.Zero']     <- as.integer(sum(1.0 - RPT$FILL.RATE.ZERO, na.rm = T)*365)
}


write.csv(R, file = 'overall_report.csv')

### evaluate.R --------------------
# niragen:
source('../../libraries/developing_packages/niragen.R')
source('../../libraries/developing_packages/linalg.R')
# nira.timser:
source('../../libraries/developing_packages/deviset.R')
source('../../libraries/developing_packages/time.series.R')
# nira.storeman:
source('../../libraries/developing_packages/inv.tools.R')
source('../../libraries/developing_packages/opt.rost.plan.R')
source('../../libraries/developing_packages/virtual.store.R')
source('../../libraries/developing_packages/store.group.R')
# nira.atmopt:
source('../../libraries/developing_packages/atm.tools.R')
source('../../libraries/developing_packages/virtual.atm.R')
source('../../libraries/developing_packages/atm.group.R')
source('../../libraries/developing_packages/cba.tools.R')

library(pipeR)
path      = '\\\\flsy04/G_TS_SY$/CDO_MTK_SMT/Business Performance Reporting/Tableau Dashboards/VCC/PS/Cash and ATM/Off Premise ATM Cash Rebanks/Opportunity Sizing Presentation/National/Optimization Model/Adelaide/'
data.path = '\\\\flsy04/G_TS_SY$/CDO_MTK_SMT/Business Performance Reporting/Tableau Dashboards/VCC/PS/Cash and ATM/Off Premise ATM Cash Rebanks/Opportunity Sizing Presentation/National/Optimization Model/Adelaide/auxdata/'

calroster_fn = data.path %+% 'calrostersCurrent.csv'
# calroster_fn = data.path %+% 'calrostersOptimal.csv'

# Test for parallel run for 20 ATMs in Adelaide:
atmids = c('500090', '500093', '500491', '501198'  , '511299', '512295', 
           '512296', '513794', '513797', '514596'  , '514898', '515095', 
           '515098', '515695', '515791', '516794'  , '517598', '519098', 
           '550298', '550599')

# raw  = readATMData(atmids, ratecard_fn = 'data/ratecard.csv', forecast_fn = 'data/SAS.pred.csv', forecast_err_fn = 'data/SAS.error.csv')
raw  = readATMData(atmids, ratecard_fn = data.path %+% 'ratecard.csv', settings_fn = data.path %+% 'pilotSettingsCurrent_2015.csv')
# raw  = readATMData(atmids, ratecard_fn = data.path %+% 'ratecard.csv')

sg   = as.ATMGroup(raw, time_zone = "Sydney")


start = '2015-06-30'
end   = '2016-06-30'

strtn = sg$demand$time.number(start)
endtn = sg$demand$time.number(end)

sg$settings$read.roster(filename = calroster_fn, in_roster_fee = sg$spec$Order.Fee.InRoster, off_roster_fee = sg$spec$Order.Fee.OffRoster, off_roster_weight = 10*sg$spec$Order.Fee.OffRoster, in_roster_weight = sg$spec$Order.Fee.InRoster)

a   = apply(sg$demand$data, 2, first.feasible)
tbd = names(a)[which((a > sg$demand$time.number(start)) | (is.na(a)))]
if (length(tbd) > 0){
  sg$remove.stores(tbd)
  cat('Some ATMs are deleted because they had not enough History data: \n', tbd, '\n')  
}

tbd = names(which(colSums(sg$settings$roster[strtn:endtn,], na.rm = T) < (endtn - strtn)/14 - 10))
if (length(tbd) > 0){
  sg$remove.stores(tbd)
  cat('Some ATMs are deleted becasue they had not enough replenishments in their roster: \n', tbd, '\n')  
}

sg$settings$base.stock = 10000
sg$settings$hc.rate    = 0.0176/365
sg$settings$es.penalty = 20000
sg$settings$top.up     = 0
sg$settings$lead.time  = as.integer(2)
sg$settings$serr.gain  = 0.3

sg$settings$nDaysAhead  = as.integer(120)

sg$read.forecasts(forecast_fn = data.path %+% 'pilotForecasts_2016.csv', forerror_fn = data.path %+% 'pilotErrors_2016.csv', to_stores = T)

sg$fill.atms()

sg$run.optimal(atms = atmids, start = start, end = end, show = F, forecast_demand = F, update_forecast = F, flexorder = F)
sg$gen.report()
RPT    = sg$report
atmids = rownames(RPT)

a.1 = atmids[RPT$FILL.RATE.BASE == 1]
a.2 = atmids %-% a.1
sg$tune.atms(atms = a.2, seg = 1.0, base = 15000)
sg$run.optimal(atms = a.2, start = start, end = end, show = F, forecast_demand = F, update_forecast = F, flexorder = F)
sg$gen.report(base = 10000)
RPT = sg$report
atmids = rownames(RPT)

sg$save.report(path = 'report')
sg$save.atms(path = 'report')

# for (i in names(sg$stores)){
#   a = sg[i]$data[, 'forec', drop = F]
#   e = sg[i]$data[, 'fserr', drop = F]/sg$settings$serr.gain
#   names(a) <- i
#   names(e) <- i
#   sg$pred$feed(a)
#   sg$error$feed(e)
# }
# 
# saveRDS(sg$pred, 'preds_2015.rds')
# saveRDS(sg$error, 'errors_2015.rds')

sg$save.settings('data/settings_current_2016.csv')

sum(RPT$TOT.COST)
365*(20.0 - sum(RPT$FILL.RATE.ZERO))
# =IF(AND(H2="NA",K2>0),"***","")

'Optimal_Base0K_SEG80_V1_NEW'
### evaluate_national.R --------------------
# niragen:
# niragen:
library(niragen)
# nira.timser:
library(nira.timser)
# nira.storeman:
library(nira.storeman)
# nira.atmopt:
library(nira.atmopt)


library(pipeR)
path      = '\\\\flsy04/G_TS_SY$/CDO_MTK_SMT/Business Performance Reporting/Tableau Dashboards/VCC/PS/Cash and ATM/Off Premise ATM Cash Rebanks/Opportunity Sizing Presentation/National/Optimization Model/Adelaide/'
data.path = '\\\\flsy04/G_TS_SY$/CDO_MTK_SMT/Business Performance Reporting/Tableau Dashboards/VCC/PS/Cash and ATM/Off Premise ATM Cash Rebanks/Opportunity Sizing Presentation/National/Optimization Model/Adelaide/auxdata/'

calroster_fn = data.path %+% 'calrostersCurrent.csv'

D = read.csv(calroster_fn, as.is = T, row.names = 1, check.names = F)

all.atms = names(D)

exclude = c('200005', '211184', '218134', '225997', '231734', '276299', '312590', '324534', '340898', '354898', '362291',
            '362292', '362295', '376534', '377734', '389495', '400002', '400006', '400007', '400101', '400102', '400106', 
            '412901', '412902', '414501', '417094', '447434', '600159', '600397', '601359', '601734', '601956', '601957', 
            '601958', '601959', '610054', '610056', '610057', '610058', '610756', '610758', '610759', '611535', '611551', 
            '611859', '612159', '612434', '612459', '612534', '612835', '613035', '613036', '613255', '613256', '613434', 
            '613435', '613459', '615335', '615357', '615358', '615658', '615754', '615756', '615835', '615858', '615934', 
            '616235', '616255', '616334', '616534', '616535', '616556', '616557', '616559', '616658', '617334', '617859', 
            '620234', '650037', '650835', '651234', '651256', '651257', '653434')

all.atms = all.atms %-% exclude

# raw  = readATMData(all.atms', ' ratecard_fn = 'data/ratecard.csv')
# saveRDS(raw, 'raw_' %+% today())
# raw = readRDS('raw_' %+% today()) 

# sg   = as.ATMGroup(raw, time_zone = "Sydney")
# saveRDS(sg, 'data/national_dataset.rds')
# sg = readRDS('data/national_dataset.rds')


start = '2014-12-01'
end   = '2015-11-30'

start = '2015-06-30'
end   = '2016-06-30'

strtn = sg$demand$time.number(start)
endtn = sg$demand$time.number(end)

sg$settings$read.roster(filename = calroster_fn, in_roster_fee = sg$spec$Order.Fee.InRoster, off_roster_fee = sg$spec$Order.Fee.OffRoster, off_roster_weight = 10*sg$spec$Order.Fee.OffRoster, in_roster_weight = sg$spec$Order.Fee.InRoster)

first.feasible.custom <- function(x){first.feasible(x, excludes = 0)}
a   = apply(sg$demand$data, 2, first.feasible.custom)
tbd = names(a)[which((a > sg$demand$time.number(start)) | (is.na(a)))]
if (length(tbd) > 0){
  sg$remove.stores(tbd)
  cat('Some ATMs are deleted because they had not enough History data: \n', tbd, '\n')  
}

tbd = names(which(colSums(sg$settings$roster[strtn:endtn,], na.rm = T) < (endtn - strtn)/14 - 10))
if (length(tbd) > 0){
  sg$remove.stores(tbd)
  cat('Some ATMs are deleted becasue they had not enough replenishments in their roster: \n', tbd, '\n')  
}

sg$settings$base.stock = 10000
sg$settings$hc.rate    = 0.0176/365
sg$settings$es.penalty = 20000
sg$settings$top.up     = 0
sg$settings$lead.time  = as.integer(2)
sg$settings$serr.gain  = 0.5

sg$settings$nDaysAhead  = as.integer(120)

sg$pred  = readRDS('preds_new.rds')
sg$error = readRDS('errors_new.rds')

sg$fill.atms()

sg$run.optimal(start = start, end = end, show = F, forecast_demand = F, update_forecast = T)
sg$gen.report()

RPT = sg$report

sg$save.report(path = 'report')
sg$save.atms(path = 'report')

# for (i in names(sg$stores)){
#   a = sg[i]$data[, 'forec', drop = F]
#   e = sg[i]$data[, 'fserr', drop = F]/sg$settings$serr.gain
#   names(a) <- i
#   names(e) <- i
#   sg$pred$feed(a)
#   sg$error$feed(e)
# }
# 
# saveRDS(sg$pred, 'preds_new.rds')
# saveRDS(sg$error, 'errors_new.rds')


sum(RPT$TOT.COST)
365*(20.0 - sum(RPT$FILL.RATE.ZERO))
# =IF(AND(H2="NA",K2>0),"***","")

'Optimal_Base0K_SEG80_V1_NEW'
### evaluate_pilot2.R --------------------
# niragen:
source('../../libraries/developing_packages/niragen.R')
source('../../libraries/developing_packages/linalg.R')
# nira.timser:
source('../../libraries/developing_packages/deviset.R')
source('../../libraries/developing_packages/time.series.R')
# nira.storeman:
source('../../libraries/developing_packages/inv.tools.R')
source('../../libraries/developing_packages/opt.rost.plan.R')
source('../../libraries/developing_packages/virtual.store.R')
source('../../libraries/developing_packages/store.group.R')
# nira.atmopt:
source('../../libraries/developing_packages/atm.tools.R')
source('../../libraries/developing_packages/virtual.atm.R')
source('../../libraries/developing_packages/atm.group.R')
source('../../libraries/developing_packages/cba.tools.R')

library(pipeR)
path      = '\\\\flsy04/G_TS_SY$/CDO_MTK_SMT/Business Performance Reporting/Tableau Dashboards/VCC/PS/Cash and ATM/Off Premise ATM Cash Rebanks/Opportunity Sizing Presentation/National/Optimization Model/Adelaide/'
data.path = '\\\\flsy04/G_TS_SY$/CDO_MTK_SMT/Business Performance Reporting/Tableau Dashboards/VCC/PS/Cash and ATM/Off Premise ATM Cash Rebanks/Opportunity Sizing Presentation/National/Optimization Model/Adelaide/auxdata/'

# calroster_fn = data.path %+% 'calrostersOptimal.csv'
calroster_fn = data.path %+% 'calrostersCurrent.csv'

# Test for parallel run for 20 ATMs in Adelaide:
atmids = c('500090', '500093', '500491', '501198'  , '511299', '512295', 
           '512296', '513794', '513797', '514596'  , '514898', '515095', 
           '515098', '515695', '515791', '516794'  , '517598', '519098', 
           '550599')

raw  = readATMData(atmids, ratecard_fn = data.path %+% 'ratecard.csv', forecast_fn = data.path %+% 'forecasts.csv', forerror_fn = data.path %+% 'errors.csv', settings_fn = data.path %+% 'pilotSettingsCurrent_2015.csv')
# raw  = readATMData(atmids, ratecard_fn = data.path %+% 'ratecard.csv', forecast_fn = data.path %+% 'forecasts.csv', forerror_fn = data.path %+% 'errors.csv')

sg   = as.ATMGroup(raw, time_zone = "Sydney")


#start = '2014-06-30'
#end   = '2015-06-30'

start = '2015-06-30'
end   = '2016-06-30'

strtn = sg$demand$time.number(start)
endtn = sg$demand$time.number(end)

sg$settings$read.roster(filename = calroster_fn, in_roster_fee = sg$spec$Order.Fee.InRoster, off_roster_fee = sg$spec$Order.Fee.OffRoster, off_roster_weight = 10*sg$spec$Order.Fee.OffRoster, in_roster_weight = sg$spec$Order.Fee.InRoster)

sg$settings$base.stock = 2000
sg$settings$hc.rate    = 0.0176/365
sg$settings$es.penalty = 20000
sg$settings$top.up     = 0
sg$settings$lead.time  = as.integer(2)
sg$settings$serr.gain  = 0.2

sg$settings$nDaysAhead  = as.integer(120)

# 
# sg$read.forecasts(forecast_fn = data.path %+% 'pilotForecasts_2015.csv', forerror_fn = data.path %+% 'pilotErrors_2015.csv')
# sg$read.forecasts(forecast_fn = data.path %+% 'pilotForecasts_2016.csv', forerror_fn = data.path %+% 'pilotErrors_2016.csv')

sg$fill.atms()
sg$run.optimal(atms = atmids, start = start, end = end, show = F, forecast_demand = F, update_forecast = F, flexorder = T)
sg$gen.report()
RPT    = sg$report
atmids = rownames(RPT)

a.1 = atmids[RPT$FILL.RATE.BASE == 1]
a.2 = atmids %-% a.1
sg$tune.atms(atms = a.2, seg = 1.0, base = 10000)
sg$run.optimal(atms = a.2, start = start, end = end, show = F, forecast_demand = F, update_forecast = F)
sg$gen.report(base = 2000)
RPT = sg$report
atmids = rownames(RPT)

sg$save.report(path = 'report')
sg$save.atms(path = 'report')

# for (i in names(sg$stores)){
#   a = sg[i]$data[, 'forec', drop = F]
#   e = sg[i]$data[, 'fserr', drop = F]/sg$settings$serr.gain
#   names(a) <- i
#   names(e) <- i
#   sg$pred$feed(a)
#   sg$error$feed(e)
# }
# 
# saveRDS(sg$pred, 'preds_2015.rds')
# saveRDS(sg$error, 'errors_2015.rds')

sg$save.settings(data.path %+% 'pilotSettingsOptimal_2015.csv')

sum(RPT$TOT.COST)
365*(19.0 - sum(RPT$FILL.RATE.ZERO))
# =IF(AND(H2="NA",K2>0),"***","")

'Optimal_Base0K_SEG80_V1_NEW'
### gensg.R --------------------
# Header
# Filename:       gensg.R
# Description:    This module creates the ATM group and makes it ready for being visualized in a dashboard
# Author:         Nima Ramezani Taghiabadi
# Email:          nima.ramezani@cba.com.au
# Start Date:     18 May 2016
# Last Revision:  30 September 2016
# Version:        1.2
# 
# Version History:
# Version     Date                  Action
# _______________________________________________________________________
# 1.0         18 May  2016          Initail version
# 1.1         15 July 2016          Extends all atms and saves the atm group as .rds file
# 1.2         30 September 2016     Reads forecasts and forecast errors from a .csv file

# Requirements:
library(timeDate)
library(niragen)
library(nirats)
library(nira.storeman)
library(nira.atmopt)

source('script/cba.tools.R')

data.path = '\\\\flsy04/G_TS_SY$/CDO_MTK_SMT/Business Performance Reporting/Tableau Dashboards/VCC/PS/Cash and ATM/Off Premise ATM Cash Rebanks/Opportunity Sizing Presentation/National/Optimization Model/Adelaide/auxdata/'

data.path = 'data/'


ydy = Sys.Date() - 1
# ydy = Sys.Date() - 100

# Test for parallel run for 20 ATMs in Adelaide:
atmids = c(
  '200492', '201495', '202198', '210795', '211192', '212194', '213396', '213399', '218189', '218193',
  '220297', '222393', '226592', '226593', '228398', '228795', '229392', '229598', '230196', '231496',
  '260899', '261298', '266897', '273599', '276199', '301495', '311194', '311397', '312599', '313698',
  '314399', '314498', '317297', '317999', '318297', '323499', '323698', '324095', '324599', '325393',
  '346494', '353993', '358196', '361997', '399399', '400080', '400082', '400097', '410599', '411198',
  '411299', '411798', '412399', '412798', '413097', '413397', '414594', '414891', '414997', '416891',
  '500089', '500090', '500093', '512295', '512296', '513794', '513797', '513997', '514596', '514898',
  '515095', '515098', '515695', '515791', '515792', '516794', '517598', '518998', '550599', '551295',
  '600096', '600194', '600399', '601397', '601398', '601699', '601798', '605898', '610098', '611299',
  '611585', '611589', '611798', '612497', '612895', '613099', '613195', '615987', '616297', '616598')

atmids = c('200492', '220297',  '260899',  '314399',  '346494',  '411299',  '500089',  '515095',  '600096',  '611585')

atmids = c('411299',  '500089')

raw = readATMData(atmids, ratecard_fn = data.path %+% 'ratecard.csv', settings_fn = data.path %+% 'pilot2SettingsCurrent_2015.csv', endDate = ydy)

# Corrections due to poor data quality in the profile table:
raw$profile$Cannisters[raw$profile$Cannisters      == '4 Canister (1-$20 & 3-$50) 374k'] <- '4 Canister (1-$20 & 3-$50)'
raw$profile$MaximumCapacity[raw$profile$MaximumCapacity == 340000] <- 374000

# create an ATM group object:
sg  = as.ATMGroup(raw, time_zone = "GMT")

sg$extend(N = 170, extend_stores = F)

# Read Calendar Roster from a cal-roster file:
sg$settings$read.roster(data.path %+% 'calrostersCurrent.csv', in_roster_fee = sg$spec$Order.Fee.InRoster, off_roster_fee = sg$spec$Order.Fee.OffRoster, off_roster_weight = 5000.0, in_roster_weight = sg$spec$Order.Fee.InRoster)
# sg$read.forecasts(forecast_fn = data.path %+% 'pilot2Forecasts_2016.csv', forerror_fn = data.path %+% 'pilot2Errors_2016.csv')


# Tune the model with settings:
sg$settings$base.stock = 10000
sg$settings$es.penalty = 20000
sg$settings$top.up     = 2000
sg$settings$hc.rate    = 0.0176/365
sg$settings$serr.gain  = 0.7
sg$settings$lead.time  = as.integer(2)
sg$settings$nDaysAhead = as.integer(200)

sg$fill.atms(extract_all_data = T)

sg$extend.stores(N = 170, forecast_demand = F)

sg$goto(ydy)

saveRDS(sg, data.path %+% 'dataset.rds')


# Now the store group is ready for visualization:

### gomap.js --------------------
// When locator icon in datatable is clicked, go to that spot on the map
$(document).on("click", ".go-map", function(e) {
  e.preventDefault();
  Shiny.onInputChange("goto", {
    id: $(this).data("id"),
    date: $(this).data("date"),
    ord100: $(this).data("ord100"),
    ord50: $(this).data("ord50"),
    ord20: $(this).data("ord20"),
    piaz: Math.random()
  });
});



### newOptimalRosterPlanner.R --------------------
library(timeDate)
source('../../libraries/developing_packages/niragen.R')

source('../../libraries/developing_packages/deviset.R')
source('../../libraries/developing_packages/time.series.R')
# nira.storeman:
source('../../libraries/developing_packages/inv.tools.R')
source('../../libraries/developing_packages/opt.rost.plan.R')
source('../../libraries/developing_packages/virtual.store.R')
source('../../libraries/developing_packages/store.group.R')
# nira.atmopt:
source('../../libraries/developing_packages/atm.tools.R')
source('../../libraries/developing_packages/virtual.atm.R')
source('../../libraries/developing_packages/atm.group.R')
source('../../libraries/developing_packages/cba.tools.R')

source('C:/Nima/R/projects/cba/cba.atm.optimization (Developing)/script/optRoster.R')

library(pipeR)
path      = '\\\\flsy04/G_TS_SY$/CDO_MTK_SMT/Business Performance Reporting/Tableau Dashboards/VCC/PS/Cash and ATM/Off Premise ATM Cash Rebanks/Opportunity Sizing Presentation/National/Optimization Model/Adelaide/'
data.path = '\\\\flsy04/G_TS_SY$/CDO_MTK_SMT/Business Performance Reporting/Tableau Dashboards/VCC/PS/Cash and ATM/Off Premise ATM Cash Rebanks/Opportunity Sizing Presentation/National/Optimization Model/Adelaide/auxdata/'

calroster_fn = data.path %+% 'calrostersCurrent.csv'
feasibles_fn = data.path %+% 'feasibility.csv'

# atmids = readRDS('../cba.atm.optimization (Ver 2.0)/correctATMs.csv')
rejected = c('218189', '202198', '210795', '411299', '412399', '500090', '500093', '514596', '313698',  '601798')
awe      = c('400080', '500089', '317297', '601397')

test   = c('226592','228398','413097','605898','600194')
atmids = test

raw  = readATMData(atmids, ratecard_fn = data.path %+% 'ratecard.csv', settings_fn = data.path %+% 'pilot2SettingsCurrent_2016.csv')
raw$profile$MaximumCapacity[raw$profile$MaximumCapacity == 340000] <- 374000
raw$profile$Cannisters[raw$profile$Cannisters == '4 Canister (1-$20 & 3-$50) 374k'] <- '4 Canister (1-$20 & 3-$50)'

sg   = as.ATMGroup(raw, time_zone = "Sydney")

sg$settings$base.stock = 10000
sg$settings$hc.rate    = 0.0176/365
sg$settings$es.penalty = 20000
sg$settings$top.up     = 0
sg$settings$lead.time  = as.integer(2)
sg$settings$serr.gain  = 0.7

start = '2015-10-01'
end   = '2016-10-01'

# sg$read.forecasts(forecast_fn = data.path %+% 'pilot2Forecasts_2016.csv', forerror_fn = data.path %+% 'pilot2Errors_2016.csv')

RSTR  = read.csv(calroster_fn, as.is = T, row.names = 1, check.names = F)
FEAS  = read.csv(feasibles_fn, as.is = T, row.names = 1)
tt    = char2Time(rownames(RSTR))
tc    = time2Char(tt)
rownames(RSTR) <- tc

minCost = rep(Inf, sg$N.store)
minFreq = rep(0, sg$N.store)

sg$fill.atms(extract_all_data = T)
optRost = data.frame()

names(minCost) = names(sg$stores)
names(minFreq) = names(sg$stores)

for (i in names(sg$stores)){
  rosterDays = decodeDD(scr = c(), s = as.character(sg$spec[i, 'DeliveryDays']))
  RSTR$FortDay = fortday(tt)
  holidays  = tc[is.na(RSTR[, i])]
  flexidays = tc[which((RSTR[, i] == 1) & (RSTR$FortDay %in% rosterDays))]
  for (f in 1:7){
    if (f == 7){
      fRost = c(F,F,F,F,F, NA, NA, F,F,F,F,F, NA, NA)
      names(fRost) = fdlabel
      fRost[rosterDays] <- TRUE
    } else {
      fRost = sg$stores[[i]] %>>% 
        optimalRoster.future(start = start, end = end, freq = f, 
                             feasibleDays = as.logical(FEAS[i,]) 
        )  
    }
    
    sg$stores[[i]] = sg$stores[[i]] %>>% applyFortRoster(start = start, end = end, fortRoster = fRost,
                                                         holidays = c(), flexidays = c(), 
                                                         standardFee = sg$spec[i, 'Order.Fee.InRoster'], specialFee = sg$spec[i, 'Order.Fee.OffRoster'],
                                                         standardWeight = sg$spec[i, 'Order.Fee.InRoster'], specialWeight = 10*sg$spec[i, 'Order.Fee.OffRoster']
    )
    
    sg$stores[[i]]$goto(start)
    sg$stores[[i]]$reset()
    
    sg$stores[[i]]$data$forec <- sg$stores[[i]]$data$Demand.Adj
    sg$stores[[i]]$data$fserr <- 0.7*sd(sg$stores[[i]]$data$Demand.Adj, na.rm = T)
    
    sg$stores[[i]]$jump.optimal(until = end, fixed_roster = TRUE, show = F, update_forecast = F)
    
    figs  = c(ATM.ID  = 'ATM ID' , Date = 'Delivery Date', Week.Day = 'Week Day',
              Demand  = 'Demand' , Balance = 'Balance', 
              Roster  = 'Roster', Order.Fee = 'Order Fee', Order.Date = 'Order Date', 
              Order   = 'Order', Rebank  = 'Rebank')    
    
    TORDS = sg$stores[[i]]$tords(figures = figs)
    
    nOOC = sum((TORDS$Balance < 1) | ((TORDS$Rebank < 1) & (TORDS$Order > 0)))
    nSPC = sum(!TORDS$Roster & (TORDS$Order > 0))
    nSKP = sum(TORDS$Roster & (TORDS$Order < 1), na.rm = T)
    Cost = sg$stores[[i]]$current('Total.Cost') + 200*nSKP + 100*nSPC
    
    cat('ATM.No: ',i, '| Frequency: ', f, '| Out of Cash: ', nOOC, '| Specials: ', nSPC, '| Skips: ', nSKP, '| Actual Cost: ', sg$stores[[i]]$current('Total.Cost'), '| Points: ', Cost, '\n')
    write.csv(TORDS, paste0('report/', i, '_f', f,'.csv'))
    
    if (Cost < minCost[i]) {
      minCost[i] = Cost
      minFreq[i] = f
      minfRost   = fRost
    } 
  }
  rwnms   = rownames(optRost)   
  optRost = rbind(optRost, minfRost)
  rownames(optRost) <- c(rwnms, i)
  cat('\n')
}
colnames(optRost) <- fdlabel

write.csv(optRost, data.path %+% 'pilot2OptimalRoster_2016.csv')

# optRost = read.csv(data.path %+% 'pilot2OptimalRoster_2016.csv', row.names = 1, as.is = T)
calRoster = RSTR

for (i in names(sg$stores)){
  holidays  = tc[is.na(RSTR[, i])]
  flexidays = tc[which((RSTR[, i] == 1) & (RSTR$FortDay %in% rosterDays))]
  fRost     = as.logical(optRost[i,])
  names(fRost) <- fdlabel
  sg$stores[[i]] = sg$stores[[i]] %>>% applyFortRoster(start = start, end = end, fortRoster = fRost,
                                                       holidays = c(), flexidays = c(), 
                                                       standardFee = sg$spec[i, 'Order.Fee.InRoster'], specialFee = sg$spec[i, 'Order.Fee.OffRoster'],
                                                       standardWeight = sg$spec[i, 'Order.Fee.InRoster'], specialWeight = 10*sg$spec[i, 'Order.Fee.OffRoster']
  )
  
  peri = sg$stores[[i]]$time.number(start):sg$stores[[i]]$time.number(end) - 1
  tc = rownames(RSTR) %^% names(sg$stores[[i]]$settings$order.roster)[peri]
  calRoster[tc ,i] = sg$stores[[i]]$settings$order.roster[tc]
}

write.csv(calRoster, data.path %+% 'calrostersOptimal.csv')


# Generate Flexible Roster respecting holidays:
fRost = c(T,T,T,T,T, NA, NA, T, T, T, T, T, NA, NA)
names(fRost) <- fdlabel
calRoster = RSTR

for (i in names(sg$stores)){
  holidays  = tc[is.na(RSTR[, i])]
  sg$stores[[i]] = sg$stores[[i]] %>>% applyFortRoster(start = start, end = end, fortRoster = fRost,
                                                       holidays = holidays, flexidays = c(), 
                                                       standardFee = sg$spec[i, 'Order.Fee.InRoster'], specialFee = sg$spec[i, 'Order.Fee.OffRoster'],
                                                       standardWeight = sg$spec[i, 'Order.Fee.InRoster'], specialWeight = 10*sg$spec[i, 'Order.Fee.OffRoster']
  )
  
  peri = sg$stores[[i]]$time.number(start):sg$stores[[i]]$time.number(end) - 1
  tc = rownames(RSTR) %^% names(sg$stores[[i]]$settings$order.roster)[peri]
  calRoster[tc ,i] = sg$stores[[i]]$settings$order.roster[tc]
}

write.csv(calRoster, data.path %+% 'calrostersFlexible.csv')

### optRoster.R --------------------

optimalRoster.future = function(vs, start, end, freq, feasibleDays = NULL){
  peri = vs$time.number(start):vs$time.number(end)
  feasibleDays = verify(feasibleDays, 'logical', lengths = 14, default = c(1,1,1,1,1,NA,NA,1,1,1,1,1,NA,NA))
  names(feasibleDays) <- fdlabel
  vs$goto(start)
  DF = vs$aggregate.seasonal(period = peri, figures = 'Demand.Adj', func = high.pass.mean, seasonality = 'dof')
  from  = '04-Jan-2010'  # It is a Monday.1
  until = '17-Jan-2010'  # It is a Sunday.2
  ts    = timeSequence(from = from, to = until, by = 'day')
  u     = distribute.seasonality(ts, season.values = DF[,'Demand.Adj', drop = F], seasonality = 'dof')  
  r     = as.logical(opt.roster(demands = u, freq = freq, q = vs$settings$capacity, fr = feasibleDays))
  names(r) = fdlabel
  # rosterDays = fdlabel[which(r)]
  return(r)
}


optimalRoster = function(vs, start, end, freq, feasibleDays = NULL){
  peri = vs$time.number(start):vs$time.number(end)
  feasibleDays = verify(feasibleDays, 'logical', lengths = 14, default = c(1,1,1,1,1,NA,NA,1,1,1,1,1,NA,NA))
  names(feasibleDays) <- fdlabel
  vs$goto(start)
  vs$settings$nDaysAhead = as.integer(366)
  if(!is.clean(vs$data$forec[peri])){vs$updateDemandForecast()}
  DF = vs$aggregate.seasonal(period = peri, figures = 'forec', func = high.pass.mean, seasonality = 'dof')
  from  = '04-Jan-2010'  # It is a Monday.1
  until = '17-Jan-2010'  # It is a Sunday.2
  ts    = timeSequence(from = from, to = until, by = 'day')
  u     = distribute.seasonality(ts, season.values = DF[,'forec', drop = F], seasonality = 'dof')  
  r     = as.logical(opt.roster(demands = u, freq = freq, q = vs$settings$capacity, fr = feasibleDays))
  names(r) = fdlabel
  # rosterDays = fdlabel[which(r)]
  return(r)
}

applyFortRoster = function(vs, start, end, fortRoster, holidays, flexidays, standardFee = 132.9, specialFee = 160.1, standardWeight = 132.9, specialWeight = 1601){
  # Apply the roster:
  vs$settings$apply.roster.fortnightly(vs$time, start = vs$time.number(start), end = vs$time.number(end), f_rost = fortRoster, in_roster_fee = standardFee, off_roster_fee = specialFee, in_roster_weight = standardWeight, off_roster_weight = specialWeight)
  # Apply Holidays:
  holidays = holidays %^% names(vs$settings$order.roster)
  vs$settings$order.roster[holidays] = NA 
  vs$settings$order.fee[holidays]    = NA 
  vs$settings$order.weight[holidays] = NA
  # Apply Flexidays:
  flexidays = flexidays %^% names(vs$settings$order.roster)
  vs$settings$order.roster[flexidays] = TRUE 
  vs$settings$order.fee[flexidays]    = standardFee 
  vs$settings$order.weight[flexidays] = standardWeight
  
  return(vs)
}



### pilot_v2.R --------------------
# niragen:
source('C:/Nima/R/projects/cba/ATM.opt.dashboard/libraries/niragen.R')
source('C:/Nima/R/projects/cba/ATM.opt.dashboard/libraries/linalg.R')
# nira.timser:
source('C:/Nima/R/projects/cba/ATM.opt.dashboard/libraries/deviset.R')
source('C:/Nima/R/projects/cba/ATM.opt.dashboard/libraries/time.series.R')
# nira.storeman:
source('C:/Nima/R/projects/cba/ATM.opt.dashboard/libraries/inv.tools.R')
source('C:/Nima/R/projects/cba/ATM.opt.dashboard/libraries/opt.rost.plan.R')
source('C:/Nima/R/projects/cba/ATM.opt.dashboard/libraries/virtual.store.R')
source('C:/Nima/R/projects/cba/ATM.opt.dashboard/libraries/store.group.R')
# nira.atmopt:
source('C:/Nima/R/projects/cba/ATM.opt.dashboard/libraries/atm.tools.R')
source('C:/Nima/R/projects/cba/ATM.opt.dashboard/libraries/virtual.atm.R')
source('C:/Nima/R/projects/cba/ATM.opt.dashboard/libraries/atm.group.R')
source('C:/Nima/R/projects/cba/ATM.opt.dashboard/libraries/cba.tools.R')

path = 'M:/CDO_MTK_SMT/Business Performance Reporting/Tableau Dashboards/VCC/PS/Cash and ATM/Off Premise ATM Cash Rebanks/Opportunity Sizing Presentation/National/Optimization Model/Adelaide/'
data.path = 'M:/CDO_MTK_SMT/Business Performance Reporting/Tableau Dashboards/VCC/PS/Cash and ATM/Off Premise ATM Cash Rebanks/Opportunity Sizing Presentation/National/Optimization Model/Adelaide/auxdata/'

# Test for parallel run for 20 ATMs in Adelaide:
atmids = c('500090', '500093', '500491', '501198'  , '511299', '512295', 
           '512296', '513794', '513797', '514596' , '514898', '515095', 
           '515098', '515695', '515791', '516794'  , '517598', '519098', 
           '550298', '550599')

raw = read.atm.data.raw(atmids, ratecard_fn     = data.path %+% 'ratecard.csv', ipo_fn = NULL, 
                        forecast_fn     = data.path %+% 'SAS.pred.csv',
                        forecast_err_fn = data.path %+% 'SAS.error.csv',
)

# create an ATM group object:
sg  = to.atm.group(raw, time_zone = "GMT")

sg$extend(N = 30)

# Read Calendar Roster from the cal-roster file:
sg$settings$read.roster(data.path %+% 'calrosters.csv', in_roster_fee = sg$spec$Order.Fee.InRoster, off_roster_fee = sg$spec$Order.Fee.OffRoster, off_roster_weight = 5000.0, in_roster_weight = sg$spec$Order.Fee.InRoster)

sg$settings$base.stock = 10000
sg$settings$es.penalty = 50000
sg$settings$top.up     = 2000
sg$settings$lead.time  = as.integer(1)
sg$settings$serr.gain  = 0.5

sg$fill.atms()
# sg$extend.stores()
# sg$run.optimal(start = today)

# returns the next order information (how many days left? total order until the next order, if a scheduled order is missed in between)
apply.next.order.info = function(x, i){
  N = nrow(x)
  a = c(flag = NA, TD20 = NA, TD50 = NA, TD100 = NA, Tdemand = NA, Ndys = NA)
  
  if (x$order[i] > 0){
    w = which(!is.na(x$Roster[sequence(i - 1)]))
    if (length(w) == 0){x[i, 'Order.Date'] = 'SUBMITTED'} else {x[i, 'Order.Date'] = as.character(x$time[w[length(w)]])}
  }
  
  if (i < N){
    nordays = which(x$order[(i + 1):N] > 0)
    if (length(nordays) == 0){return(x)} 
    norday = i + nordays[1]
    
    TD20  = roundto.multiple(0.5*x$D20[i]  + 0.5*x$D20[norday], N = 20)
    TD50  = roundto.multiple(0.5*x$D50[i]  + 0.5*x$D50[norday], N = 50)
    TD100 = roundto.multiple(0.5*x$D100[i] + 0.5*x$D100[norday], N = 100)
    if (norday >= i + 2){
      flag  = sum(x$Roster[(i + 1):(norday - 1)], na.rm = T) > 0
      TD20  = TD20  + sum(x$D20[(i + 1):(norday - 1)])
      TD50  = TD50  + sum(x$D50[(i + 1):(norday - 1)])
      TD100 = TD100 + sum(x$D100[(i + 1):(norday - 1)])
    } else {flag = 0}
    a = c(flag = flag, TD20 = TD20, TD50 = TD50, TD100 = TD100, Tdemand = TD20 + TD50 + TD100, Ndys = norday - i)
  }
  for (nfld in names(a)){x[i, nfld] <- a[nfld]}
  return(x)
}

for (i in sequence(sg$N.store)){
  atmid = rownames(sg$spec)[i]
  cat('\n ATM ', atmid, ' Started ...')
  xi = sg$future(atmid, N = 30, apply_vs_settings = T)
  
  for (k in sequence(nrow(xi))){xi = apply.next.order.info(xi, k)}
  
  if (i == 1){x = xi} else {x = rbind(x, xi)}
  cat('Done !', ' \n')
}

x$DOW <- paste(x$DOW, format(x$time, format = '%d/%m'))
x = x[,c('time', 'ATM.ID', 'DOW', 'D100', 'D50','D20', 'demand', 'B100', 'B50', 'B20', 'balance',
         'Roster','Order.Fee', 'O100', 'O50', 'O20', 'order', 'Order.Date', 
         'R100', 'R50', 'R20', 'rebank', 'TD100', 'TD50', 'TD20', 'Tdemand', 'Ndys', 'flag')]

surcharged = x$order > 340000
x$Order.Fee[surcharged] = x$Order.Fee[surcharged] + 38

write.csv(x, path %+% as.character(as.Date(timeDate(FinCenter = "Sydney"))) %+% '_V2' %+% '.csv', row.names = F)

# write.csv(raw$transactions, paste0(path, 'transactions.csv'), row.names = T)

# sg$save.report()
# saveRDS(sg, path %+% 'dataset.rds')

### pilot_dash.R --------------------
figs = c('ATM.ID', 'Date', 'Week.Day', 'Roster', 'Order.Fee', 
         'Order.Date', 'Order', 'O100', 'O50', 'O20', 'Rebank', 'R100', 'R50', 'R20', 'Tdemand', 'TD100', 'TD50', 'TD20', 'Ndys', 'flag', 'Submitted')

# niragen:
source('C:/Nima/R/projects/cba/ATM.opt.dashboard/libraries/niragen.R')
source('C:/Nima/R/projects/cba/ATM.opt.dashboard/libraries/linalg.R')
# nira.timser:
source('C:/Nima/R/projects/cba/ATM.opt.dashboard/libraries/deviset.R')
source('C:/Nima/R/projects/cba/ATM.opt.dashboard/libraries/time.series.R')
# nira.storeman:
source('C:/Nima/R/projects/cba/ATM.opt.dashboard/libraries/inv.tools.R')
source('C:/Nima/R/projects/cba/ATM.opt.dashboard/libraries/opt.rost.plan.R')
source('C:/Nima/R/projects/cba/ATM.opt.dashboard/libraries/virtual.store.R')
source('C:/Nima/R/projects/cba/ATM.opt.dashboard/libraries/store.group.R')
# nira.atmopt:
source('C:/Nima/R/projects/cba/ATM.opt.dashboard/libraries/atm.tools.R')
source('C:/Nima/R/projects/cba/ATM.opt.dashboard/libraries/virtual.atm.R')
source('C:/Nima/R/projects/cba/ATM.opt.dashboard/libraries/atm.group.R')
source('C:/Nima/R/projects/cba/ATM.opt.dashboard/libraries/cba.tools.R')

library(pipeR)
path = 'M:/CDO_MTK_SMT/Business Performance Reporting/Tableau Dashboards/VCC/PS/Cash and ATM/Off Premise ATM Cash Rebanks/Opportunity Sizing Presentation/National/Optimization Model/Adelaide/'
data.path = 'M:/CDO_MTK_SMT/Business Performance Reporting/Tableau Dashboards/VCC/PS/Cash and ATM/Off Premise ATM Cash Rebanks/Opportunity Sizing Presentation/National/Optimization Model/Adelaide/auxdata/'

path      = ''
data.path = 'data/'

ydy = yesterday()
ydy = as.Date('2016-09-02')

sg = readRDS(path %+% 'dataset.rds') 
sg <- updateATMGroup(atmg = sg, atms = names(sg$stores), startDate = sg$demand$now(), endDate = ydy) %>>% 
  clearFutureForecasts()

sg$jumptoLastSubmittedOrder()
sg$jump.optimal(until = ydy + 120, forecast_demand = T, fixed_roster = T)
sg$goto(ydy)

sg$tords.update(atmids = names(sg$stores), start = ydy + 1,  end = ydy + 90, figures = figs)
saveRDS(sg, path %+% 'dataset.rds')

### update_calrosters.R --------------------
# Once a year, replenishment roster must be updated for the ATMs.
# This program plans the optimum roster for all ATMs and consolidates them into one cal-roster 
# A file containing feasibile fortnight days is required.

# Where is the file containing feasible roster days?
path      = '\\\\flsy04/G_TS_SY$/CDO_MTK_SMT/Business Performance Reporting/Tableau Dashboards/VCC/PS/Cash and ATM/Off Premise ATM Cash Rebanks/Opportunity Sizing Presentation/National/Optimization Model/Adelaide/'
data.path = '\\\\flsy04/G_TS_SY$/CDO_MTK_SMT/Business Performance Reporting/Tableau Dashboards/VCC/PS/Cash and ATM/Off Premise ATM Cash Rebanks/Opportunity Sizing Presentation/National/Optimization Model/Adelaide/auxdata/'

# niragen:
source('../../libraries/developing_packages/niragen.R')
source('../../libraries/developing_packages/linalg.R')
# nira.timser:
source('../../libraries/developing_packages/deviset.R')
source('../../libraries/developing_packages/time.series.R')
# nira.storeman:
source('../../libraries/developing_packages/inv.tools.R')
source('../../libraries/developing_packages/opt.rost.plan.R')
source('../../libraries/developing_packages/virtual.store.R')
source('../../libraries/developing_packages/store.group.R')
# nira.atmopt:
source('../../libraries/developing_packages/atm.tools.R')
source('../../libraries/developing_packages/virtual.atm.R')
source('../../libraries/developing_packages/atm.group.R')
source('../../libraries/developing_packages/cba.tools.R')

frost_fn  = data.path %+% 'feasibility.csv'
ratec_fn  = data.path %+% 'ratecard.csv'
outpt_fn  = data.path %+% 'calrosters.csv'

state.label = list(N = 'NSW', S = 'SA', Q = 'QLD', W = 'WA', T = 'TAS', V = 'VIC')


depots = c("WAY" , "WAA" , "QUM" , "QAD" , "NAN" , "NAS" , "VAP" , "SAS" , "VAS" , "WAT" , "SAD" , "TAH" , "QUD" , "NAW" , "TAL" , 
           "QUG" , "SAA" , "VEB" , "TAV" , "NAZ" , "VAB" , "QAT" , "QUR" , "QUI" , "NUW" , "WAK" , "VAL" , "NUK" , "VAO" , "QUS" , 
           "SAY" , "VAM" , "NAT" , "QAI" , "NAG" , "NAP" , "NUB" , "SUG" , "VEP")

# depots = c("WAY")

today = timeDate(FinCenter = "Sydney")

# Apply holidays

do = function(depot, start, end, update){
  state  = state.label[[substr(depot,1,1)]]
  fn     = data.path %+% 'holidays/' %+% state %+% '.csv'
  hld    = read.csv(fn)
  tt     = as.character(char2Date(hld$Date))
  genCalRstr(depot, startDate = start, endDate = end, holidays = tt, inflation_gain = 1.0, 
             frost_fn  = frost_fn, ratecard_fn = ratec_fn, 
             output_fn = data.path %+% 'calrosters/' %+% depot %+% '.csv', update = update)
}

done = c()
for (depot in depots) {
  cat('Doing depot: ', depot, ' ... ')
  do(depot, start = '2014-06-30', end = '2017-06-30', update = F)
  cat('Done: \n')
  done = c(done, depot)
}

for (depot in depots) {do(depot, start = '2015-06-30', end = '2016-06-30', update = T)}
for (depot in depots) {do(depot, start = '2016-06-30', end = '2017-06-30', update = T)}

# for (depot in depots) {do(depot, start = '2015-07-01', end = today, update = T)}


NN = 0
clrstr = data.frame()
for (depot in depots){
  CR   = read.csv(data.path %+% 'calrosters/' %+% depot %+% '.csv', as.is = T, row.names = 1, check.names = F)
  NN = NN + ncol(CR)
  cat(ncol(CR),' + ')
  tc   = rownames(CR)
  atms = colnames(CR)  
  for (atm in atms){clrstr[tc, atm] <- CR[tc, atm]}
}
cat(' = ', NN)

#x = colSums(clrstr, na.rm = T)
#dim(clrstr[, x > 0])

write.csv(clrstr, outpt_fn)




### styles.css --------------------
# input[type="number"] {
#   max-width: 80%;
# }
# 
# div.outer {
#   position: fixed;
#   top: 41px;
#   left: 0;
#   right: 0;
#   bottom: 0;
#   overflow: hidden;
#   padding: 0;
# }
# 
# /* Customize fonts */
#   body, label, input, button, select { 
#     font-family: 'Helvetica Neue', Helvetica;
#     font-weight: 200;
#   }
# h1, h2, h3, h4 { font-weight: 400; }
# 
# #controls {
# /* Appearance */
#   background-color: white;
# padding: 0 20px 20px 20px;
# cursor: move;
# /* Fade out while not hovering */
#   opacity: 0.65;
# zoom: 0.9;
# transition: opacity 500ms 1s;
# }
# #controls:hover {
# /* Fade in while hovering */
#   opacity: 0.95;
# transition-delay: 0;
# }
# 
# /* Position and style citation */
#   #cite {
#   position: absolute;
# bottom: 10px;
# left: 10px;
# font-size: 12px;
# }
# 
# /* If not using map tiles, show a white background */
#   .leaflet-container {
#     background-color: white !important;
#   }
