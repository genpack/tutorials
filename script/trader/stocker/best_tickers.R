library(magrittr)
library(rutils)
library(dplyr)
library(trader)

load("~/Documents/software/R/projects/stocker/dat_raw_historical_until_15_01_2021.RData")

# Wich ticker is best for neg_lin strategy?
tickers = dat_raw %>% pull(ticker) %>% unique %>% sample(100)
dat_raw %>% 
  # filter(ticker %in% tickers) %>% 
  mutate(lag = price.adjusted) %>% 
  group_by(ticker) %>% 
  do({column.shift.down(.,col = 'lag')}) %>% 
  mutate(delta = price.adjusted - lag) %>% 
  summarise(maximum = max(price.adjusted), 
            minimum = min(price.adjusted),
            delta   = mean(abs(delta)),
            cnt     = length(price.adjusted),
            volume = median(volume)) %>% 
  mutate(volrate = 100*delta/(maximum - minimum),
         turnover = volume*(maximum + minimum)/2) -> bt

dat_raw %>% filter(ticker == 'KKC.AX') %>% pull(price.adjusted) %>% plot()
