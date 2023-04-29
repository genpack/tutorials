library(magrittr)
library(rutils)
library(dplyr)
library(trader)

load("script/trader/stocker/data/dat_raw_historical_until_15_01_2021.RData")

# delta is average candle length or volatility
# volatility rate is average candle length / peak to peak price variation or price range (maximum - minimum)
stock_behaviour_summary = function(dat_raw){
  dat_raw %>% 
    mutate(lag = price.adjusted) %>% 
    group_by(ticker) %>% 
    do({arrange(., ref.date) %>% column.shift.down(col = 'lag')}) %>% 
    mutate(delta = price.adjusted - lag) %>% 
    summarise(mindate = min(ref.date),
              maxdate = max(ref.date),
              maximum = max(price.adjusted), 
              minimum = min(price.adjusted),
              delta   = mean(abs(delta)),
              cnt     = length(price.adjusted),
              volume = median(volume)) %>% 
    mutate(volrate = 100*delta/(maximum - minimum),
           turnover = volume*(maximum + minimum)/2)
}

# dat_raw %>% 
#   stock_behaviour_summary %>% 
#   arrange(desc(volrate)) %>% filter(turnover > 2000000) %>% head(20) -> bt



# #dat_raw %>% filter(ticker == 'KKC.AX') %>% pull(price.adjusted) %>% plot()


