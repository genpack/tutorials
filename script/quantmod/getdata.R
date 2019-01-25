quantmod::getFX('EUR/USD')


curs = c('EUR', 'GBP', 'AUD', 'NZD', 'CHF', 'JPY')


from = Sys.Date() - 19*365
quantmod::getFX(c('EUR/USD', 'AUD/USD', 'GBP/USD', 'USD/JPY', 'NZD/USD', 'USD/CHF'), from = from)

# get a series of currency-pairs as a data.frame
library(gener)
library(magrittr)
library(dplyr)

data = EURUSD %>% as.data.frame %>% rownames2Column("Date") %>% mutate(EUR.USD = 10000.0*EUR.USD) %>% 
  left_join(AUDUSD %>% as.data.frame %>% rownames2Column("Date") %>% mutate(AUD.USD = 10000.0*AUD.USD), by = 'Date') %>% 
  left_join(GBPUSD %>% as.data.frame %>% rownames2Column("Date") %>% mutate(GBP.USD = 10000.0*GBP.USD), by = 'Date') %>% 
  left_join(NZDUSD %>% as.data.frame %>% rownames2Column("Date") %>% mutate(NZD.USD = 10000.0*NZD.USD), by = 'Date') %>% 
  left_join(USDCHF %>% as.data.frame %>% rownames2Column("Date") %>% mutate(CHF.USD = 10000.0/USD.CHF) %>% select(Date, CHF.USD), by = 'Date') %>% 
  left_join(USDJPY %>% as.data.frame %>% rownames2Column("Date") %>% mutate(JPY.USD = 1000000.0/USD.JPY) %>% select(Date, JPY.USD), by = 'Date')

data %>% write.csv('~/Documents/data/forex/six_currencies.csv', row.names = F)

data %>%   
  left_join(data %>% gener::column.shift.down(curs  %>% paste('USD', sep = '.'), k = 1) %>% {names(.) <- c('Date', curs %>% paste('USD', 'L1', sep = '.'));.}, by = 'Date') %>% 
  left_join(data %>% gener::column.shift.down(curs  %>% paste('USD', sep = '.'), k = 2) %>% {names(.) <- c('Date', curs %>% paste('USD', 'L2', sep = '.'));.}, by = 'Date') %>% 
  left_join(data %>% gener::column.shift.down(curs  %>% paste('USD', sep = '.'), k = 7) %>% {names(.) <- c('Date', curs %>% paste('USD', 'L7', sep = '.'));.}, by = 'Date') %>% na.omit %>% head
  