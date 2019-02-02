
### pie.R -------------------------
library(magrittr)
library(dplyr)
library(plotly)
library(highcharter)
library(reshape2)

source('../../packages/master/niravis-master/R/visgen.R')
source('../../packages/master/niravis-master/R/plotly.R')
source('../../packages/master/niravis-master/R/c3.R')
source('../../packages/master/niravis-master/R/candela.R')
source('../../packages/master/niravis-master/R/dimple.R')
source('../../packages/master/niravis-master/R/dygraphs.R')
source('../../packages/master/niravis-master/R/highcharter.R')
source('../../packages/master/niravis-master/R/nvd3.R')
source('../../packages/master/niravis-master/R/pivot.R')
source('../../packages/master/niravis-master/R/billboarder.R')
source('../../packages/master/niravis-master/R/rAmCharts.R')

source('../../packages/master/niravis-master/R/googleVis.R')

source('../../packages/master/niravis-master/R/niraPlot.R')
source('../../packages/master/niravis-master/R/jscripts.R')

### Simple dataset:
tbl = USPersonalExpenditure

# Translation:
niraPlot(obj = tbl, x = 'Animals', y = list('', 'LA_Zoo', 'NY_Zoo', 'DR_Zoo'), plotter = 'plotly', type = 'bar', config = list(yAxis.label = 'Count'))

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
