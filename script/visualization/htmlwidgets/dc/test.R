

###### Package dc ==================================
### test.R ------------------------
library(dcr)
library(magrittr)
library(niragen)



dfx = data.frame(Name     = c('Mr A', 'Mr B', 'Mr C', 'Mr A', 'Mr B', 'Mr B', 'Mr C'),
                 Spent    = c(40 , 10 , 40 , 70 , 20 , 50 , 30),
                 SpentCat = c('Forty' , 'Ten' , 'Forty' , 'Seventy' , 'Twenty' , 'Fifty' , 'thirdy'),
                 Year     = c('2000-11'  , '2000-11'  , '2000-11'  , '2000-12'  , '2000-12'  , '2000-13'  , '2000-13'))


dfx %>% dc.bar(x = 'Year')
dfx %>% dcr::dcr(type = 'pie', label = 'SpentCat', theta = 'Spent', config = list(pie.innerRadius = 50))
dfx %>% dcr::dcr(type = 'bar', y = 'SpentCat')

I = list()

####################
M = read.csv('data/morley.csv')
M %>% dcr::dcr(type = 'box', x = 'Expt', y = 'Speed')
M %>% dcr::dcr(type = 'scatterLine', x = 'Run', y = 'Speed', group = 'Expt', config = list(barMode = 'stack', xnum = F, xAxis.min = 0, xAxis.max = 20))
M %>% dc.scatter(x = 'Run', y = 'Speed', group = 'Expt', shape = 'line', config = list(legend.enabled = T))
M %>% dc.scatter(type = 'scatter', x = 'Run', y = 'Speed', group = 'Expt')

####################
cat = read.csv('data/cat.csv')
cat %>% dcr::dcr(type = 'sunburst')

####################

ndx = read.csv('C:/Nima/RCode/projects/tutorials/data/ndx.csv')
ndx %<>% dplyr::mutate(Year = date %>% as.character %>% as.Date(format = '%m/%d/%Y') %>% format('%Y')) %>% 
  dplyr::mutate(Month = date %>% strptime(format = "%m/%d/%Y") %>% as.Date %>% cut(breaks = 'month') %>% as.Date) %>% 
  dplyr::mutate(absGain = close - open) %>% dplyr::mutate(fluctuation = abs(absGain), sindex = 0.5*(open + close)) %>% 
  dplyr::mutate(percentageGain = (absGain / sindex) * 100)  

ndx %>% dcr::dcr(type = 'bubble', key = 'Year', label = 'Year', x = 'absGain', y = 'percentageGain', size = 'fluctuation', config = list(size.min = 0, size.max = 100000, xAxis.padding = 500, yAxis.padding = 10, tooltip = c(Index = 'percentageGain', Fluctuation = 'fluctuation')))

ndx %>% dcr::dcr(type = 'area', x = 'Month')


ndx %>% dcr::dcr(type = 'sample', key = 'Year')