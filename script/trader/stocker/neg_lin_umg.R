# Negative Linear (Milking) Strategy with UMG.AX:

library(magrittr)
library(dplyr)
library(trader)

load("script/trader/stocker/data/dat_raw_historical_until_15_01_2021.RData")

selected_ticker = "UMG.AX"
# selected_ticker = "ING.AX"

dat_raw %>% 
  filter(ticker == selected_ticker) %>% 
  rename(open = price.open, high = price.high, low = price.low, close = price.close, time = ref.date) %>% 
  mutate(time = as.POSIXct(time)) %>% 
  select(time, open, low, high, close, volume) -> dat_i


vt = VIRTUAL.TRADER(data = dat_i)
vt$spread = 0

pm = default.parameters("neg_lin")
pm$tp.pips  = 2000
pm$gap.pips = 500
pm$pend_man = T
pm$tp_man = T
pm$n.above = 10
pm$n.below = 10
pm$lot = 0.01
# This means 1000 shares each time
# equity/profit is given in dollars
pm$hyper_sl = 1000
pm$hyper_tp = 2000

################## test #####################
# vt$take.buy()
# vt$jump(20)
# vt$position
# vt$current.price


# Default 0.1 lot = 10,000 shares, then $1.0 increase in price gives you $10,000 profit
# with 0.1 lot 1 pip increase = 1$ profit (buy position)
# 100 pips = 1 cent of change in price
# profit in pips = profit (in dollars) x 0.1/lots
#######################################
# debug(neg_lin)
vt$current.time
neg_lin(vt, pm = pm)

vt$current.time
vt$equity()
vt$position %>% View
