

dataset = read.csv('~/Documents/data/forex/rba/rba_aud_2010_current.csv', as.is = T)

for( ft in colnames(dataset) %>% setdiff('Date')){
  dataset[, ft] %<>% as.numeric
}
dataset %<>% na.omit 
# dataset$Date %<>% as.Date


bagdelta = function(v) v[length(v)] - v[1]
bagbin   = function(v) mean(v > 0)

columns = colnames(dataset) %>% setdiff('Date')
actions = list(
  list(features = columns, fun = mean, win_sizes = c(12, 24), label = 'MA'),  # This makes moving averages
  list(features = columns, fun = bagdelta, win_sizes = c(1, 7, 14), label = 'D'),  # This makes deltas
  list(features = columns %>% paste('D1', sep = '.'), fun = first, win_sizes = c(1, 7, 14), label = 'L'),  # This makes lags on deltas
  list(features = columns %>% paste('D1', sep = '.'), fun = bagbin, win_sizes = c(0, 7, 14, 28), label = 'B')  # This makes binners on deltas
)


flst = add_features(actions = actions)


# Building 95 features:

labels = list(
  list(name = 'Y'    , aggregator = delta , reference = 'USD'     , win_size = 1),
  list(name = 'Y2'   , aggregator = last  , reference = 'USD.D1'  , win_size = 1)
)

dataset %>% MLMapper.historic(flst) %>% na.omit %>% MLMapper.labeler(labels) %>% na.omit %>% mutate(Y = 10000*Y, Y2 = Y2 > 0) %>% write.csv('~/Documents/data/forex/rba/dataset.csv', row.names = F)
