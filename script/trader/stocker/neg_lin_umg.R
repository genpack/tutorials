# Negative Linear Strategy with UMG.AX:

library(magrittr)
library(dplyr)
library(trader)

load("~/Documents/software/R/projects/stocker/data/dat_raw_historical_until_15_01_2021.RData")

selected_ticker = "UMG.AX"
selected_ticker = "ING.AX"

dat_raw %>% 
  filter(ticker == selected_ticker) %>% 
  rename(open = price.open, high = price.high, low = price.low, close = price.close, time = ref.date) %>% 
  mutate(time = as.POSIXct(time)) %>% 
  select(time, open, low, high, close, volume) -> dat_i


vt = VIRTUAL.TRADER(data = dat_i)
vt$spread = 0

pm = default.parameters("neg_lin")
pm$tp.pips  = 3000
pm$gap.pips = 1000
pm$pend_man = T
pm$tp_man = T
pm$n.above = 10
pm$n.below = 10
pm$lot = 0.01
# This means 10000 shares each time
# equity/profit is given in cents
pm$hyper_sl = 10000
pm$hyper_tp = 20000

################## test #####################
# vt$take.buy()
# vt$jump(2)
# vt$position
# vt$current.price
#######################################
# debug(neg_lin)
vt$current.time
neg_lin(vt, pm = pm)

vt$current.time
vt$equity()
vt$position %>% View
