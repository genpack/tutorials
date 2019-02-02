
### bar.R -------------------------
library(magrittr)
library(dplyr)
library(plotly)
library(highcharter)
library(reshape2)

source('C:/Nima/RCode/packages/master/niragen-master/R/niragen.R')
source('C:/Nima/RCode/packages/master/niravis-master/R/visgen.R')
source('C:/Nima/RCode/packages/master/niravis-master/R/plotly.R')
source('C:/Nima/RCode/packages/master/niravis-master/R/c3.R')
source('C:/Nima/RCode/packages/master/niravis-master/R/candela.R')
source('C:/Nima/RCode/packages/master/niravis-master/R/dimple.R')
source('C:/Nima/RCode/packages/master/niravis-master/R/dygraphs.R')
source('C:/Nima/RCode/packages/master/niravis-master/R/highcharter.R')
source('C:/Nima/RCode/packages/master/niravis-master/R/nvd3.R')
source('C:/Nima/RCode/packages/master/niravis-master/R/pivot.R')
source('C:/Nima/RCode/packages/master/niravis-master/R/billboarder.R')
source('C:/Nima/RCode/packages/master/niravis-master/R/rAmCharts.R')

source('C:/Nima/RCode/packages/master/niravis-master/R/googleVis.R')

source('C:/Nima/RCode/packages/master/niravis-master/R/niraPlot.R')
source('C:/Nima/RCode/packages/master/niravis-master/R/jscripts.R')

### Chart 1:
# This does not work!
Animals <- c("giraffes", "orangutans", "monkeys")
SF_Zoo <- c(20, 14, 23)
LA_Zoo <- c(12, 18, 29)
NY_Zoo <- c(15, 16, 21)
DR_Zoo <- c(13, 19, 7)
tbl <- data.frame(Animals, SF_Zoo, LA_Zoo, NY_Zoo, DR_Zoo)
# works in the fucking new version!

plot_ly(tbl, x = ~Animals, y = ~SF_Zoo, type = 'bar', name = 'SF Zoo') %>%
  add_trace(y = ~LA_Zoo, name = 'LA Zoo') %>%
  add_trace(y = ~NY_Zoo, name = 'NY Zoo') %>%
  add_trace(y = ~DR_Zoo, name = 'DR Zoo') %>%
  layout(yaxis = list(title = 'Count'), barmode = 'group')


# Translation:
niraPlot(obj = tbl, x = 'Animals', y = list('SF_Zoo', 'LA_Zoo', 'NY_Zoo', 'DR_Zoo'), plotter = 'plotly', type = 'bar', config = list(yAxis.label = 'Count'))

# Other plotters:
# C3:
niraPlot(obj = tbl, x = 'Animals', y = list('SF_Zoo', 'LA_Zoo', 'NY_Zoo', 'DR_Zoo'), plotter = 'c3', type = 'bar', config = list(yAxis.label = 'Count'))

# candela
cndl = tbl %>% melt(id.var = 'Animals') %>% nameColumns(list(Group = 'variable'), classes = list()) %>%
  candela.bar.molten(x = 'Animals', y = 'value', color = 'Group')
# candela does not show the chart in the viewer


# dimple:
niraPlot(tbl, x = 'Animals', y = list('SF_Zoo', 'LA_Zoo', 'NY_Zoo', 'DR_Zoo'), shape = 'bar', plotter = 'dimple', type = 'combo')
# todo: check how you can set yAxis label
# todo: check group barchart rather than stack
# todo: legend?!

# dygraphs:
niraPlot(tbl, x = 'Animals', y = list('SF_Zoo', 'LA_Zoo', 'NY_Zoo', 'DR_Zoo'), shape = 'bar', plotter = 'dygraphs', type = 'combo')

# highcharter:
niraPlot(tbl, x = 'Animals', y = list('SF_Zoo', 'LA_Zoo', 'NY_Zoo', 'DR_Zoo'), shape = 'bar', type = 'combo', plotter = 'highcharter')


# nvd3:
tbl %>% melt(id.var = 'Animals') %>% nameColumns(list(Group = 'variable'), classes = list()) %>%
  niraPlot(x = 'Animals', y = 'value', group = 'Group', shape = 'bar', type = 'bar.molten', plotter = 'nvd3')

# pivot
tbl %>% melt(id.var = 'Animals') %>% nameColumns(list(Group = 'variable'), classes = list()) %>%
  pivot(rows = 'Group', cols = 'Animals', aggregatorName = 'Sum', vals = 'value', rendererName = 'Bar Chart', )

# billboarder:
niraPlot(tbl, x = 'Animals', y = list('SF_Zoo', 'LA_Zoo', 'NY_Zoo', 'DR_Zoo'), plotter = 'billboarder', type = 'bar')
tbl %>% melt(id.var = 'Animals') %>% nameColumns(list(Group = 'variable'), classes = list()) %>%
  niraPlot(x = 'Animals', y = 'value', group = 'Group', shape = 'bar', type = 'bar.molten', plotter = 'billboarder')


# rAmCharts:
niraPlot(tbl, x = 'Animals', y = list('SF_Zoo', 'LA_Zoo', 'NY_Zoo', 'DR_Zoo'), type = 'bar', plotter = 'rAmCharts')


#r = rCharts.combo(tbl, x = 'Animals', y = list('SF_Zoo', 'LA_Zoo', 'NY_Zoo', 'DR_Zoo'), shape = 'bar')

# googleVis:
plot(googleVis.bar(tbl, x = 'Animals', y = list('SF_Zoo', 'LA_Zoo', 'NY_Zoo')))
# Does not show! Check it!


# plot(googleVis.gauge(tbl, theta = 'SF_Zoo', label = 'Animals'))
# plot(googleVis.gauge(tbl, theta = c('SF_Zoo', 'LA_Zoo', 'NY_Zoo')))
# plot(googleVis.gauge(tbl[2,], theta = c('SF_Zoo', 'LA_Zoo', 'NY_Zoo')))
