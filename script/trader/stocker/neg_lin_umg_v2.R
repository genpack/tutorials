# Negative Linear Strategy with UMG.AX:

library(magrittr)
library(dplyr)
library(trader)
library(rutils)

load("~/Documents/software/R/projects/tutorials/script/trader/stocker/data/dat_raw_historical_until_15_01_2021.RData")

selected_ticker = "UMG.AX"
selected_ticker = "ING.AX"

dat_raw %>% 
  filter(ticker == selected_ticker) %>% 
  rename(open = price.open, high = price.high, low = price.low, close = price.close, time = ref.date) %>% 
  mutate(time = as.POSIXct(time)) %>% 
  select(time, open, low, high, close, volume) -> dat_i

#################

vt = VIRTUAL.TRADER(data = dat_i)
vt$spread = 0

s = MILK(tp.pips = 2000, gap.pips = 1000, pend_man = T, tp_man = T, n.above = 10, n.below = 10, lot = 0.01, hyper_sl = 10000, hyper_tp = 20000)

# lot = 0.01 means 1000 shares each time

vt$current.time
s$run(vt)

vt$current.time
vt$equity()
vt$position %>% View

#################
vt = VIRTUAL.TRADER(data = dat_i)
vt$spread = 0

s = REDLINE(lot = 0.01, hyper_sl = 1000, hyper_tp = 2000)
vt$current.time
s$run(vt)

vt$current.time
vt$equity()
vt$position %>% View

