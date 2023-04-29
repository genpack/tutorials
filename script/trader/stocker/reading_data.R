library(BatchGetSymbols)
library(dplyr)
# set dates
first.date <- Sys.Date() - 100000
last.date <- Sys.Date()
freq.data <- 'daily'
# set tickers
tickers <- c('rio.ax')

l.out <- BatchGetSymbols(tickers = tickers, 
                         first.date = first.date,
                         last.date = last.date, 
                         freq.data = freq.data,
                         cache.folder = file.path("C:/Users/PeimanAsadi/Dropbox/personal_projects/stock_portfolio/data/"))

x1 <- readRDS("C:/Users/PeimanAsadi/Desktop/temp/wbcax_yahoo_1746-08-24_2020-06-08.rds")
x2 <- readRDS("C:/Users/PeimanAsadi/Desktop/temp/cbaax_yahoo_1746-08-24_2020-06-08.rds")

x <- inner_join(x1,x2,by="ref.date")
