
### tsline.R ------------------------
library(D3plusR)
library(dplyr)
library(magrittr)

source('../../packages/master/niragen-master/R/niragen.R')
source('../../packages/master/niravis-master/R/visgen.R')
source('../../packages/master/niravis-master/R/d3plus.R')


data("bra_inflation")
# Date variables must have this format
bra_inflation$Date <- format(bra_inflation$Date, "%Y/%m/%d")
# dates to be passed in solo argument
date_filter <- bra_inflation$Date[bra_inflation$Date > "2013/01/01"]


d3plus(data = bra_inflation, id = "country",
       type = "rings",
       percent_var = "Rate",
       height = 400,
       width = "100%") %>% 
  d3plusX(value = "Date", grid = FALSE) %>% 
  d3plusY(value = "Rate") %>% 
  d3plusTime(value = "Date", solo = date_filter) %>% 
  d3plusTooltip(value = "Date") %>% 
  d3plusTitle("Brazilian Inflation (IPCA)")


# niravis translation:
cfg = list(
  title  = 'Brazilian Inflation (IPCA)',
  height = 400,
  width  = "100%",
  xAxis.min = as.Date("2013/01/01"),
  xAxis.grid.enabled = F,
  label.format = list('Rate' = 'percentage')
)

data("bra_inflation")
bra_inflation %>% d3plus.tsline.molten(x = 'Date', y = 'Rate', group = 'country', config = cfg)
bra_inflation %>% d3plus.tsbar.molten(x = 'Date', y = 'Rate', group = 'country', config = cfg)
bra_inflation %>% d3plus.tsarea.molten(x = 'Date', y = 'Rate', group = 'country', config = cfg)
