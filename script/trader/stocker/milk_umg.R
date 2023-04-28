# Negative Linear (Milking) Strategy with UMG.AX:

library(magrittr)
library(dplyr)
# library(trader)
source("~/Documents/packages/trader/R/virtual_trader.R")
source("~/Documents/packages/trader/R/strategy_tools.R")
source("~/Documents/projects/tutorials/script/trader/stocker/new_strategies.R")

load("script/trader/stocker/data/dat_raw_historical_until_15_01_2021.RData")

selected_ticker = "UMG.AX"

dat_raw %>% 
  filter(ticker == selected_ticker) %>% 
  rename(open = price.open, high = price.high, low = price.low, close = price.close, time = ref.date) %>% 
  mutate(time = as.POSIXct(time)) %>% 
  select(time, open, low, high, close, volume) -> dat_i


vt = VIRTUAL.TRADER(data = dat_i)
vt$spread = 0


# Default 0.1 lot = 10,000 shares, then $1.0 increase in price gives you $10,000 profit
# with 0.1 lot 1 pip increase = 1$ profit (buy position)
# 100 pips = 1 cent of change in price
# profit in pips = profit (in dollars) x 0.1/lots
#######################################
vt$current.time
vt$current.price

res = vt$jump(sample(1:1000, size = 1))
vt$current.time
vt$current.price
#######################################
pm = DEFAULT_PARAMETERS$MILKING %>% add_missing_parameters(vt)
pm$expiry_tn = vt$current.time.number + 365
  
#debug(milking)
milking(vt)
vt$current.time

investment = max(vt$history$lots)*mean(vt$position$price)*100000
return = vt$equity() - 10*nrow(vt$position)

return/investment
