
# Header
# Filename:     eval_strategy.R
# Description:  We test the performance of a strategy on stock market
# Author:       Nima Ramezani Taghiabadi
# Email :       N.RamezaniTaghiabadi@uws.edu.au
# Start Date:   23 March 2021
# Last change:  23 March 2021
# Version:      0.0.0

# source("init.R")
# 
# lib.set = c()
# lib.set = c(lib.set, paste(packages.path, "nima", "artificial_intelligence", "business_intelligence", "trading", "strategy_tester.R", sep = "/"))
# for (lib in lib.set){source(lib)}
library(magrittr)
library(dplyr)
library(rutils)
library(trader)

security = "ING.AX"

dat_raw %>% 
  filter(ticker == security) %>% 
  rename(open = price.open, high = price.high, low = price.low, close = price.close, time = ref.date) %>% 
  mutate(time = as.POSIXct(time)) %>% 
  select(time, open, low, high, close, volume) -> dat_i


vt = VIRTUAL.TRADER(data = dat_i)
vt$spread = 0

##########################################################
pm_min = default.parameters('neg_lin_man') %>% 
  list.edit(lot = 0.01, hyper_sl = 1000, hyper_tp = 1000, tp.pips = 1000, gap.pips = 1000)
pm_max = pm_min %>% 
  list.edit(hyper_sl = 2000, hyper_tp = 2000, tp.pips = 2000, gap.pips = 2000)


D1 = generate.desired.test.data.frame(100, 1, time_num_min = 1, time_num_max = 1000, 
                                      parameters_min=pm_min, parameters_max=pm_max, 
                                      time.first = TRUE, replacement = FALSE)

R1  = evaluate.strategy(vt, "neg_lin_man", desired_test_table = D1)


R1 %<>% 
  filter(!is.na(success)) %>% 
  mutate(invest = max_lot*100000*4.5) %>% 
  mutate(annual_percentage = 100*365*(equity - num_pos*20)/(invest*duration))

######################
default.parameters('prc_wll_lve')
