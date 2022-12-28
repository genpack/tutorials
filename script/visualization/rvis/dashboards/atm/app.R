library(rutils)

valid.figures = c('Fig1', 'Fig2')

tdy = Sys.Date()

ydy = tdy - 1
tmr = tdy + 1

val = reactiveValues()

I = list()

val      = reactiveValues()
val$ord     = 0
val$tableTrigger  = T
val$nxtSrvTrigger = T

figs  = c(ATM.ID  = 'ATM_ID' , Date = 'Delivery_Date', Week.Day = 'Week_Day',
          Demand  = 'Demand' , Balance = 'Balance', 
          Roster  = 'Roster', Order.Fee = 'Order_Fee', Order.Date = 'Order_Date', 
          Order   = 'Order', Rebank  = 'Rebank', O100 = 'Order_100', O50 = 'Order_50', O20 = 'Order_20')    

# Dummy data
sg = list(
  stores = list(
    ATM_1 = list(),
    ATM_2 = list(),
    ATM_3 = list()
  ),
  TORDS = data.frame(ATM_ID = c('ATM01', 'ATM02', 'ATM03'),
                     Balance = c(100000, 200000, 300000),
                     Delivery_Date = c(tdy - 10, tdy - 20, tdy - 30),
                     Order_Date = c(tdy + 10, tdy + 20, tdy + 30),
                     Week_Day = c(T, T, T),
                     Roster = c(T, T, T),
                     Order_Fee = c(1,2,3)*1000,
                     Order = c(10, 20, 30),
                     Order_100 = c(100,200,300),
                     Order_50  = c(50,100,150),
                     Order_20  = c(20, 40, 60)),
  selected = 'ATM01'
)

getTordsRowNumber = function(TBL, day, id){
  which((TBL[, figs['ATM.ID']] == id) & (TBL[, figs['Date']] == day))[1]
}

lg = h3("BI&A", span("Off Premise ATM Replenishment Optimization", style = "font-weight: 100"),
        style = "font-family: 'Source Sans Pro'; size: 10;
        color: 'red'; text-align: center; 
        background-image: url('C:/Nicolas/R/projects/abc/ATM.opt.dashboard/images/GO_Logo.png');
        padding: 12px")

# needs data
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
cloth.latbal   = list(type = 'infoBox', icon = 'money-bill-1' , subtitle = 'On ' %++% rutils::prettyDate(ydy), weight = 12, fill = T, color = 'yellow')
cloth.latuse   = list(type = 'infoBox', icon = 'credit-card'   , subtitle = 'On ' %++% rutils::prettyDate(ydy), weight = 12, fill = T, color = 'yellow')
cloth.dysnxt   = list(type = 'valueBox', icon = 'calendar', subtitle = 'On ' %++% rutils::prettyDate(ydy), weight = 12, fill = T, color = 'yellow')
cloth.usenxt   = list(type = 'valueBox', icon = 'credit-card', subtitle = 'On ' %++% rutils::prettyDate(ydy), weight = 12, fill = T, color = 'yellow')
colCloth       = list(type = 'column', weight = 3, offset = 0, align = 'center')
mapFrame       = list(type = 'wellPanel')

# Main Boxes:

I$main      = list(type = 'dashboardPage', title = 'BI&A ATM Optimization Toolbox', layout.head = c() ,layout.body = 'page', layout.side = c(), header.title = 'Cash Manager')
I$page      = list(type = 'fluidPage', 
                   layout = list('jsheader', list('CPLeft', 'metricBox'), list('mapBox',  'histBox'), 'tabBox'))

I$metricBox = list(type = 'fluidPage'    , layout = list(list('curUse', 'curBal', 'lstSrv', 'nxtSrv'), list('nDaysUNS', 'usageUNS', 'nextReb', 'available'), 'line', list('address', 'capacity', 'delStat')), weight = 8)
I$histBox   = list(type = 'box'          , title = 'History Plot', layout = 'histPanel', collapsible = T, collapsed = T, solidHeader = T, status = 'primary')
I$histPanel = list(type = 'fluidPage'    , title = '', layout = list(list('histYear', 'histPer', 'histFig'), 'histPlot'))0
I$histFig   = list(type = 'selectInput'  , title = 'Plot Figure', choices = valid.figures            , selected = 'Demand'  , multiple = F)
I$histYear  = list(type = 'checkboxGroupInput', title = 'Year'  , choices = as.character(2013:2016)  , selected = '2016'    , inline = T)
I$histPer   = list(type = 'radioButtons', title = 'Period'  , choices = c('Daily', 'Weekly', 'Monthly')  , selected = 'Weekly', inline = T)

#I$seasBox   = list(type = 'box'          , title = 'Seasonality', layout = 'seasPanel', collapsible = T, collapsed = T, solidHeader = T, status = 'primary')
#I$seasPanel = list(type = 'fluidPage'    , title = '', layout = list(list('seasYear', 'seasFigs', 'seasType'), 'seasPlot'))
#I$seasYear  = list(type = 'radioButton'  , title = 'Year'  , choices = c(as.character(2013:2016),'All History', 'Future'), selected = '2016', inline = T)
#I$seasFigs  = list(type = 'selectInput'  , title = 'Figures', choices = valid.figures,  selected = 'Demand', multiple = T)
#I$seasType  = list(type = 'radioButton'  , title = 'Seasonality', choices = c("Day of Week" = "dow", "Month of Year" = "moy"),  selected = 'dow', inline = T)

I$mapBox   = list(type = 'box'            , title = 'Map', layout = 'mapPanel', collapsible = T, collapsed = T, solidHeader = T, status = 'primary')
I$mapPanel = list(type = 'fluidPage'      , title = '', layout = list(list('reset.atms', 'zoom'), 'map'))
I$reset.atms = list(type = 'actionButton' , title = 'Show All ATMs', service = "val$mapsel = names(sg$stores)")
I$zoom      = list(type = 'actionButton'  , title = 'Zoom on Selected ATM', service = "val$mapsel = input$atmid")

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

# Why title can not be a shinytag? You may need to remove class check in verify or add shinytag to the list of accepted classes
I$ord20  = list(type = 'numericInput', title = 'Order $20:' , min = 0 , max = 60000, step = 20, value = val.ord20, width = '100%', weight = 4)
I$ord50  = list(type = 'numericInput', title = 'Order $50:' , min = 0 , max = 300000, step = 50, value = val.ord50, width = '100%', weight = 4)
I$ord100 = list(type = 'numericInput', title = 'Order $100:', min = 0 , max = 200000, step = 100, value = val.ord100, width = '100%', weight = 4)

I$ordate = list(type = 'dateInput', value = tdy + 1, min = tdy, max = tdy + 30, title = 'Order Delivery Date:', weight = 8)
I$atmid  = list(type = 'selectInput', title = 'ATM ID:', choices = rownames(sg$spec), selected = sg$selected, weight = 4)

O$curTotal    = list(type = 'htmlOutput', title = "Total Order")

O$line        = list(type = 'static', object = hr())
# O$line        = list(type = 'static', object = img(src='C:/Nicolas/R/projects/abc/ATM.opt.dashboard/images/GO_Line.png', align = "right"))
# O$logo        = list(type = 'static', object = img(src='C:/Nicolas/R/projects/abc/ATM.opt.dashboard/images/GO_Logo.png', align = "left"))
O$logo        = list(type = 'static', object = lg)

I$all.atms    = list(type = 'actionButton' , title = 'Include All ATMs', width = '100%', icon = icon('bullseye', 'fa-2x'), service = "val$tabsel = names(sg$stores)")
I$all.days    = list(type = 'actionButton' , title = 'Include All Days', width = '100%', icon = icon('calendar', 'fa-2x'), service = "val$tabday = unique(sg$TORDS[, figs['Date']])")
I$filter.atm  = list(type = 'actionButton' , title = 'Filter Selected ATM', width = '100%', icon = icon('filter', 'fa-2x'), service = "val$tabsel = input$atmid")
I$filter.day  = list(type = 'actionButton' , title = 'Filter Selected Date', width = '100%', icon = icon('calendar-check-o', 'fa-2x', verify_fa = F), service = "val$tabday = input$ordate")
#I$submitSel = list(type = 'actionButton' , title = h4('Submit Selected Orders'), width = '100%', icon = icon('trash-o', 'fa-2x'))
#I$clearSel  = list(type = 'actionButton' , title = h4('Clear  Selected Orders'), width = '100%', icon = icon('send', 'fa-2x'))
I$submit    = list(type = 'actionButton' , title = 'Submit Order', width = '100%')
I$clear     = list(type = 'actionButton' , title = 'Clear Order', width = '100%')
I$saveModel = list(type = 'actionButton' , title = 'Save Model', width = '100%', icon = icon('save', 'fa-2x', verify_fa = F))
I$saveOrder = list(type = 'actionButton' , title = 'Save Orders', width = '100%', icon = icon('save', 'fa-2x', verify_fa = F))


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



# 
# 
# # Input Service Functions:
# 
# I[['submit']]$service <- paste(
#   "sg$goto(ydy)",
#   "sg[input$atmid]$change.order(date = input$ordate, order_date = tdy, ord20 = input$ord20, ord50 = input$ord50, ord100 = input$ord100)",
#   "sg[input$atmid]$jumptoLastSubmittedOrder()",
#   "sg[input$atmid]$jump.optimal(until = tdy + 40, forecast_demand = F, fixed_roster = T, show = F)",
#   "sg[input$atmid]$goto(ydy)",
#   "sg$tords.update(atmids = input$atmid, start = tdy,  end = tdy + 30, figures = figs)",
#   "val$tableTrigger  = T",
#   "val$nxtSrvTrigger = T",
#   sep = "\n")
# 
# I[['clear']]$service <- paste(
#   "sg$goto(ydy)",
#   "sg[input$atmid]$change.order(date = input$ordate, ord20 = 0, ord50 = 0, ord100 = 0, submit = F)",
#   "sg[input$atmid]$jumptoLastSubmittedOrder()",
#   "sg[input$atmid]$jump.optimal(until = tdy + 40, forecast_demand = F, fixed_roster = T, show = F)",
#   "sg[input$atmid]$goto(ydy)",
#   "sg$tords.update(atmids = input$atmid, start = tdy,  end = tdy + 30, figures = figs)",
#   "val$tableTrigger  = T",
#   "val$nxtSrvTrigger = T",
#   sep = "\n")
# 
# I[['saveOrder']]$service <- "write.csv(sg$TORDS, path %+% as.character(tdy) %+% '.csv')"
# I[['saveModel']]$service <- "saveRDS(sg, data.path %+% 'dataset.rds')"
# 
# # I[['atmid']]$service <- paste(
# #   "val$tabsel = input$atmid",
# #   "val$tabday = unique(sg$TORDS[,figs['Date']])",
# #   sep = "\n")
# # 
# # I[['ordate']]$service <- paste(
# #   "val$tabsel = val$tabsel = names(sg$stores)",
# #   "val$tabday = val$tabday = input$ordate",
# #   sep = "\n")
# 
# # Output Service Functions:
# 
# O[['map']]$service       = "leaflet.map.plot(sg, tiles = T)"
# O[['profile']]$service   = paste(
#   "if (is.null(val$tableTrigger)){val$tableTrigger = T}",
#   "if (is.null(val$tabsel)){val$tabsel <- names(sg$stores)}",
#   "if (is.null(val$tabday)){val$tabday <- tdy + 1}",
#   "if (val$tableTrigger){val$tableTrigger = F}",
#   "w = (sg$TORDS[,figs['Order']] > 0) & (sg$TORDS[, figs['Date']] %in% val$tabday) & (sg$TORDS[,figs['ATM.ID']] %in% val$tabsel)",
#   "DT.Table.plot(sg$TORDS[w,], links = tableLinks, session = session, options = tableOptions, rownames = T) %>%", 
#   "DT::formatStyle('Submitted', target = 'row', fontWeight = DT::styleEqual(c(0, 1), c('normal', 'bold')), color = DT::styleEqual(c(0, 1), c('gray', 'black')))", 
#   sep = "\n")

 
O[['jsheader']]$object    = tags$head(includeCSS('styles.css'), includeScript('gomap.js'))

# O[['histPlot']]$service  = "sg$stores[[input$atmid]]$plot.timeBreak.yoy(years = input$histYear, x.axis = yoyxaxis[input$histPer],figure = input$histFig, main = paste0('ATM No. ', input$atmid, ' (', input$histFig, ')'))"

# O[['curTotal']]$service      = "h3('Total Order: $' %+% prettyNum(val$ord, scientific = F, big.mark = ','))"
# 
# O[['curUse']]$service = "'$ ' %+% prettyNum(sg[input$atmid]$current('Demand'), scientific = F, big.mark = ',')"
# O[['curBal']]$service = "'$ ' %+% prettyNum(sg[input$atmid]$current('Balance'), scientific = F, big.mark = ',')"
# O[['lstSrv']]$service = paste(
#   "tn = sg[input$atmid]$last.order(global = F, submitted_only = T)",
#   "ov = '$ ' %+% prettyNum(sg[input$atmid]$data$Order[tn], scientific = F, big.mark = ',')",
#   "od = 'On ' %+% rutils::prettyDate(sg[input$atmid]$time[tn])",
#   "infoBox('Last Service', value = ov, icon = icon('truck'), subtitle = od)",
#   sep = "\n")
# 
# O[['nxtSrv']]$service = paste(
#   "if (is.null(val$nxtSrvTrigger)){val$nxtSrvTrigger = T}",
#   "if (val$nxtSrvTrigger){val$nxtSrvTrigger = F}",
#   "tn = sg[input$atmid]$next.order(submitted_only = F)",
#   "ov = '$ ' %+% prettyNum(sg[input$atmid]$data$Order[tn], scientific = F, big.mark = ',')",
#   "od = 'On ' %+% rutils::prettyDate(sg[input$atmid]$time[tn])",
#   "infoBox('Next Service', value = ov, icon = icon('truck'), subtitle = od)",
#   sep = "\n")
# 
# O[['available']]$service = "valueBox(subtitle = 'Availability on ' %+% rutils::prettyDate(sg[input$atmid]$now()), value = format(100*sg[input$atmid]$current('Availability'), digits = 3) %+% ' %', icon = icon('hand-grab-o'))"
# O[['nDaysUNS']]$service  = "sg[input$atmid]$next.order(submitted_only = F) - sg[input$atmid]$ctn"
# 
# # O[['usageUNS']]$service = "paste('$', prettyNum(sg$TORDS[(sg$TORDS[, figs['Date']] == tdy) & (sg$TORDS[, figs['ATM.ID']] == input$atmid), figs['TD']], scientific = F, big.mark = ','))"
# O[['usageUNS']]$service = paste(
#   "tn = sg[input$atmid]$next.order(submitted_only = F)",
#   "rv = sg[input$atmid]$current('Balance') - sg[input$atmid]$data$Rebank[tn]",
#   "paste('$', prettyNum(rv , scientific = F, big.mark = ','))",
#   sep = "\n")
# 
# O[['nextReb']]$service = paste(
#   "if (is.null(val$nxtSrvTrigger)){val$nxtSrvTrigger = T}",
#   "if (val$nxtSrvTrigger){val$nxtSrvTrigger = F}",
#   "tn = sg[input$atmid]$next.order(submitted_only = F)",
#   "rv = '$ ' %+% prettyNum(sg[input$atmid]$data$Rebank[tn], scientific = F, big.mark = ',')",
#   "od = 'On ' %+% rutils::prettyDate(sg[input$atmid]$time[tn])",
#   "valueBox(value = rv, icon = icon('rotate-left'), subtitle = 'Estimated Rebank in the Next Service')",
#   sep = "\n")
# 

# O[['address']]$service  = "valueBox(value = sg$spec[input$atmid, 'Name'], icon = icon('map-marker'), subtitle = 'Address: ' %+% sg$spec[input$atmid, 'Address.1'], color = 'olive')"
# O[['capacity']]$service = "valueBox(subtitle = 'Capacity', value = prettyNum(sg$spec[input$atmid, 'Capacity'], scientific = F, big.mark = ','), icon = icon('battery-full'), color = 'olive')"
# O[['delStat']]$service  = "valueBox(subtitle = 'Roster Delivery Dates', value = sg$spec[input$atmid, 'DeliveryDays'], icon = icon('calendar', lib = 'glyphicon'), color = 'olive')"


# Observers:

OB = character()

OB[1] <- "updateSelectInput(session, 'atmid', selected = input$map_marker_click$id)"
# OB[2] <- paste("if (is.null(val$mapsel)){val$mapsel <- rownames(sg$spec)}",
#                "isolate({leafletProxy('map') %>% leaflet.map.Zoom(lat = sg$spec[val$mapsel, 'Latitude'], long = sg$spec[val$mapsel, 'Longitude'])})",
#                sep = "\n")
# 
# OB[3] <- paste(
#   "a = is.null(input$goto)",
#   "updateNumericInput(session, 'ord100', value = sg$TORDS[getTordsRowNumber(sg$TORDS, day = input$ordate, id = input$atmid), figs['O100']])",
#   "updateNumericInput(session, 'ord50' , value = sg$TORDS[getTordsRowNumber(sg$TORDS, day = input$ordate, id = input$atmid), figs['O50']])",
#   "updateNumericInput(session, 'ord20' , value = sg$TORDS[getTordsRowNumber(sg$TORDS, day = input$ordate, id = input$atmid), figs['O20']])",
#   
#   sep = "\n")
# 
# # map.zoom('map', lat = sg$spec[input$goto$id, 'Latitude'], long = sg$spec[input$goto$id, 'Longitude'], dist = 0.01)
# 
# OB[4] <- paste(
#   "if (is.null(input$goto)) {return()}",
#   "updateSelectInput(session, 'atmid', selected = input$goto$id)",
#   "updateDateInput(session, 'ordate', value = input$goto$date)",
#   sep = "\n")
# 
# OB[5] <- "val$ord = input$ord100 + input$ord50 + input$ord20"
# 

dash = new('DASHBOARD', items = c(I, O), king.layout = list('main'), observers = OB)

ui     <- dash$dashboard.ui()
server <- dash$dashboard.server()

shinyApp(ui, server)
