### examples.R ----------------------------------
library(gener)
library(dplyr)
library(htmlwidgets)
library(rCharts)

source('../../packages/master/viser-master/R/visgen.R')
source('../../packages/master/viser-master/R/jscripts.R')
source('../../packages/master/viser-master/R/rCharts.R')
source('../../packages/master/viser-master/R/dimple.R')
source('../../packages/master/viser-master/R/candela.R')
source('../../packages/master/viser-master/R/plotly.R')
source('../../packages/master/viser-master/R/billboarder.R')
source('../../packages/master/viser-master/R/coffeewheel.R')
source('../../packages/master/viser-master/R/morrisjs.R')
source('../../packages/master/viser-master/R/nvd3.R')
source('../../packages/master/viser-master/R/amCharts.R')

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
## viser Translation:
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

# viser translation:

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

# viser translation:
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

# viser translation:

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

source('C:/Nicolas/R/projects/libraries/developing_packages/gener.R')
source('C:/Nicolas/R/projects/libraries/developing_packages/visgen.R')
source('C:/Nicolas/R/projects/libraries/developing_packages/rCharts.R')

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
# This module translates rCharts plots in the pdf documentation in viser language:
# https://media.readthedocs.org/pdf/rcharts/latest/rcharts.pdf

library(dplyr)
library(htmlwidgets)
library(rCharts)

data.path = 'C:/Nicolas/R/projects/tutorial/htmlwidget/data/'
source('../../packages/master/viser-master/R/visgen.R')
source('../../packages/master/viser-master/R/rCharts.R')
source('../../packages/master/viser-master/R/nvd3.R')

source('../../packages/master/viser-master/R/dygraphs.R')
source('../../packages/master/viser-master/R/plotly.R')


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
# This module translates rCharts plots in the pdf documentation in viser language:
# https://media.readthedocs.org/pdf/rcharts/latest/rcharts.pdf

library(dplyr)
library(htmlwidgets)
library(rCharts)

data.path = 'C:/Nicolas/R/projects/tutorial/htmlwidget/data/'
source('C:/Nicolas/R/projects/libraries/developing_packages/gener.R')

source('C:/Nicolas/R/projects/libraries/developing_packages/visgen.R')
source('C:/Nicolas/R/projects/libraries/developing_packages/rCharts.R')
source('C:/Nicolas/R/projects/libraries/developing_packages/nvd3.R')

source('C:/Nicolas/R/projects/libraries/developing_packages/dygraphs.R')
source('C:/Nicolas/R/projects/libraries/developing_packages/plotly.R')


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
