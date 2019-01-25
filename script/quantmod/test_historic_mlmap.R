library(magrittr)
library(dplyr)


data = read.csv('~/Documents/data/forex/six_currencies.csv')

# An example of featres list
features = list(
  list(name = 'EUR.USD.MA24'    , aggregator = mean , reference = 'EUR.USD'     , win_size = 24),
  list(name = 'EUR.USD.MA12'    , aggregator = mean , reference = 'EUR.USD'     , win_size = 12),
  list(name = 'EUR.USD.D1'      , aggregator = delta, reference = 'EUR.USD'     , win_size = 1),
  list(name = 'EUR.USD.D1.L1'   , aggregator = first, reference = 'EUR.USD.D1'  , win_size = 1),
  list(name = 'EUR.USD.D1.L2'   , aggregator = first, reference = 'EUR.USD.D1'  , win_size = 2),
  list(name = 'EUR.USD.D1.L3'   , aggregator = first, reference = 'EUR.USD.D1'  , win_size = 3),
  list(name = 'EUR.USD.D1.L7'   , aggregator = first, reference = 'EUR.USD.D1'  , win_size = 7),
  list(name = 'EUR.USD.D1.L14'  , aggregator = first, reference = 'EUR.USD.D1'  , win_size = 14),
  list(name = 'EUR.USD.D1.MA14' , aggregator = mean , reference = 'EUR.USD.D1'  , win_size = 14),
  list(name = 'EUR.USD.D1.MA7'  , aggregator = mean , reference = 'EUR.USD.D1'  , win_size = 7),
  list(name = 'EUR.USD.D7'      , aggregator = delta, reference = 'EUR.USD'     , win_size = 7),
  list(name = 'EUR.USD.D7.L1'   , aggregator = first, reference = 'EUR.USD.D7'  , win_size = 1),
  list(name = 'EUR.USD.D7.L7'   , aggregator = first, reference = 'EUR.USD.D7'  , win_size = 7),
  list(name = 'EUR.USD.D7.L14'  , aggregator = first, reference = 'EUR.USD.D7'  , win_size = 14),
  list(name = 'EUR.USD.D14'     , aggregator = delta, reference = 'EUR.USD'     , win_size = 14),
  list(name = 'EUR.USD.D14.L1'  , aggregator = first, reference = 'EUR.USD.D14' , win_size = 1),
  list(name = 'EUR.USD.D14.L7'  , aggregator = first, reference = 'EUR.USD.D14' , win_size = 7),
  list(name = 'EUR.USD.D14.L14' , aggregator = first, reference = 'EUR.USD.D14' , win_size = 14),
  
  list(name = 'GBP.USD.MA24'    , aggregator = mean , reference = 'GBP.USD'     , win_size = 24),
  list(name = 'GBP.USD.MA12'    , aggregator = mean , reference = 'GBP.USD'     , win_size = 12),
  list(name = 'GBP.USD.D1'      , aggregator = delta, reference = 'GBP.USD'     , win_size = 1),
  list(name = 'GBP.USD.D1.L1'   , aggregator = first, reference = 'GBP.USD.D1'  , win_size = 1),
  list(name = 'GBP.USD.D1.L2'   , aggregator = first, reference = 'GBP.USD.D1'  , win_size = 2),
  list(name = 'GBP.USD.D1.L3'   , aggregator = first, reference = 'GBP.USD.D1'  , win_size = 3),
  list(name = 'GBP.USD.D1.L7'   , aggregator = first, reference = 'GBP.USD.D1'  , win_size = 7),
  list(name = 'GBP.USD.D1.L14'  , aggregator = first, reference = 'GBP.USD.D1'  , win_size = 14),
  list(name = 'GBP.USD.D1.MA14' , aggregator = mean , reference = 'GBP.USD.D1'  , win_size = 14),
  list(name = 'GBP.USD.D1.MA7'  , aggregator = mean , reference = 'GBP.USD.D1'  , win_size = 7),
  list(name = 'GBP.USD.D7'      , aggregator = delta, reference = 'GBP.USD'     , win_size = 7),
  list(name = 'GBP.USD.D7.L1'   , aggregator = first, reference = 'GBP.USD.D7'  , win_size = 1),
  list(name = 'GBP.USD.D7.L7'   , aggregator = first, reference = 'GBP.USD.D7'  , win_size = 7),
  list(name = 'GBP.USD.D7.L14'  , aggregator = first, reference = 'GBP.USD.D7'  , win_size = 14),
  list(name = 'GBP.USD.D14'     , aggregator = delta, reference = 'GBP.USD'     , win_size = 14),
  list(name = 'GBP.USD.D14.L1'  , aggregator = first, reference = 'GBP.USD.D14' , win_size = 1),
  list(name = 'GBP.USD.D14.L7'  , aggregator = first, reference = 'GBP.USD.D14' , win_size = 7),
  list(name = 'GBP.USD.D14.L14' , aggregator = first, reference = 'GBP.USD.D14' , win_size = 14)
)

labels = list(
  # list(name = 'Y'    , aggregator = delta , reference = 'EUR.USD'     , win_size = 1),
  list(name = 'Y2'   , aggregator = last  , reference = 'EUR.USD.D1'  , win_size = 1)
)

data %>% MLMapper.historic(features) %>% na.omit %>% MLMapper.labeler(labels) %>% na.omit %>% write.csv('~/Documents/data/forex/forexTrain.csv', row.names = F)


