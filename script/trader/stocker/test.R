library(magrittr)
library(dplyr)
library(trader)

load("~/Documents/software/R/projects/stocker/data/dat_raw_historical_until_15_01_2021.RData")

selected_ticker = "CBA.AX"

dat_raw %>% 
  filter(ticker == selected_ticker) %>% 
  rename(open = price.open, high = price.high, low = price.low, close = price.close, time = ref.date) %>% 
  mutate(time = as.POSIXct(time)) %>% 
  select(time, open, low, high, close, volume) -> dat_i

  
vt = VIRTUAL.TRADER(data = dat_i)
vt$spread = 0

pm = default.parameters("neg_lin")
pm$tp.pips  = 25000
pm$gap.pips = 20000
pm$pend_man = T
pm$tp_man = T
pm$n.above = 10
pm$n.below = 10
pm$lot = 100/100000
# This means 100 shares each time
# equity/profit is given in cents
pm$hyper_sl = 1000
pm$hyper_tp = 1000

########
# What time are we currently at?
vt$current.time

# Let's go to some time in 2011 and start trading:
vt$jump(3000)
vt$current.time

# What's the stock price right now?
vt$current.price

# View price chart: 
# todo

# let's buy 100 shares (It requires $ 100*vt$current.price)
vt$take.buy(lot = pm$lot)

# wait a week and see what happens:
vt$jump(7)
vt$current.time
vt$current.price

# Have a look at your position:
vt$position
# Our profit in dollars:
vt$equity()/100


# debug(neg_lin)
# neg_lin(vt, pm = pm)

