### examples.R ------------------------
library(htmlwidgets)
library(dygraphs)
library(shiny)
library(dplyr)

source('C:/Nima/R/projects/libraries/developing_packages/niragen.R')
source('C:/Nima/R/projects/libraries/developing_packages/linalg.R')
source('C:/Nima/R/projects/libraries/developing_packages/visgen.R')
source('C:/Nima/R/projects/libraries/developing_packages/dygraphs.R')


df = data.frame(Name = LETTERS, age = sin(0.5*(11 + 1:26)), score =  3.2 + 0.1*(26:1))
dygraphs.combo(df, x = 'Name', y = list('age', 'score'), shape = list('bar', NULL)) %>% dyRangeSelector

bubbles.bubble(df, size = 'score', label = 'Name', color = 'age')

plotly.combo(df, x = 'Name', y = list('age', 'score'), shape = list('bar', 'line'))

######################################################################################
library(quantmod)
getSymbols(c("MSFT", "HPQ"), from = "2014-06-01", auto.assign=TRUE)
## [1] "MSFT" "HPQ"
stocks <- cbind(MSFT[,2:4], HPQ[,2:4])
dygraph(stocks, main = "Microsoft and HP Share Prices") %>% 
  dySeries(c("MSFT.Low", "MSFT.Close", "MSFT.High"), label = "MSFT", axis = "y2", color = 'red', plotter = plotter[['bar']]) %>%
  dySeries(c("HPQ.Low", "HPQ.Close", "HPQ.High"), label = "HPQ", color = 'green', plotter = plotter[['bar']]) %>% dyRangeSelector

# Translation:
stocks = cbind(MSFT[,2:4], HPQ[,2:4])  %>% as.data.frame
stocks %>% mutate(time = rownames(stocks)) %>%
  dygraphs.combo(x = 'time', y = list(MSFT = 'MSFT.Close', HPQ = 'HPQ.Close'), color = list('magenta', NULL), shape = list('dashDotLine','bar'), ySide = list('left', 'right'), size = 5)

stocks %>% mutate(time = rownames(stocks)) %>%
  plotly.combo(x = 'time', y = list(MSFT = 'MSFT.Close', HPQ = 'HPQ.Close'), color = list('magenta', NULL), shape = list('line','bar'))

######################################################################################

