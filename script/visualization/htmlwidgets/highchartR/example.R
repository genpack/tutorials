
###### Package highchartR ==================================
### examples.R -------------------------------
source('C:/Nima/R/packages/niravis/R/tools.R')
library(highchartR)

data = mtcars
x = 'wt'
y = 'mpg'
group = 'cyl'

h = highcharts(
  data = data,
  x = x,
  y = y,
  group = group,
  type = 'scatter'
)

plot.html(h)






library(data.table)
library(pipeR)
library(rlist)
library(quantmod)
library(dplyr)

symbols <- c("MSFT","C","AAPL")

symbols %>>%
  list.map(
    get(getSymbols(.))
  ) %>>%
  list.map(
    . %>>%
      as.data.frame %>>%
      mutate(
        name = .name,
        date = rownames(.)
      ) %>>%
      select(
        name,
        date,
        price = contains("close")
      ) %>>%
      data.table
  ) %>>%
  rbindlist ->
  data

highstocks(
  data = data,
  x = 'date',
  y = 'price',
  group = 'name'
)