library(magrittr)

library(foreach)
library(doParallel)
library(BatchGetSymbols)
library(dplyr)
library(data.table)
library(readxl)
library(tidyverse)
library(zoo)
library(lubridate)

library(quantmod)
library(tidyquant)

#### Downloading data
setwd('script/trader/stocker/data/')
all_stocks <- readxl::read_excel("stock_list.xlsx")
all_stocks_codes <- paste(all_stocks$code,".AX",sep="")

f_names <- list.files("data_raw_current/", full.names = TRUE)
file.remove(f_names)

from_date <- Sys.Date()-90
to_date <- Sys.Date()+1
n <- length(all_stocks_codes)


parallel <- 0

if (parallel ==1){
  cores=detectCores()
  cl <- makeCluster(cores[1]-1)
  registerDoParallel(cl)
  all_res <- foreach(i=1:n, .packages=c("quantmod","tidyquant","tidyverse")) %dopar% {
    tickers <- all_stocks_codes[i]
    x <- tq_get(tickers,
                get  = "stock.prices",
                from = from_date,
                to   = to_date)
    f_name <- paste("data_raw_current/","x",i,".RData",sep="")
    save(x, file=f_name)
  }
  stopCluster(cl)
}


if (parallel == 0){
  for(i in 1:n){
    tickers<- all_stocks_codes[i]
    x <- try(tq_get(tickers,
                    get  = "stock.prices",
                    from = from_date,
                    to   = to_date), silent = TRUE)
    f_name <- paste("data_raw_current/","x",i,".RData",sep="")
    save(x, file=f_name)
    print(c(i,nrow(x)))
    
  }
}

###############################################################################
all_files <- list.files("data_raw_current/",full.names = TRUE)
all_dat_list <- list()
for(i in 1:length(all_files)){
  load(all_files[i])
  if(!is.null(nrow(x))){
    all_dat_list[[i]] <- x
  }
}

dat <- rbindlist(all_dat_list)
temp <- duplicated(dat)
ind <- which(temp==FALSE)

dat <- dat[ind,]
max_date <- max(dat$date)
dat <- dat %>% group_by(symbol,date) %>% arrange(-volume) %>% mutate(id_temp=row_number()) %>% filter(id_temp==1) %>% select(-id_temp)
dat %>% filter(date==max_date) %>% nrow()


dat <- dat %>% group_by(symbol) %>% arrange(date,.by_group = TRUE) %>%
  mutate(vol_dollar = volume * close) %>%
  mutate(ret_close = log(close/lag(close,1))) %>%
  mutate(ret_close_last_1_day = lag(ret_close,1)) %>%
  mutate(ret_open = log(open/lag(close,1))) %>%
  mutate(ret_close_high  = log(close/high))  %>%
  mutate(ret_open_next_1_day = lead(ret_open,1)) %>%
  mutate(ret_close_next_1_day = lead(ret_close,1)) %>%
  #mutate(ret_5_days  = log(close/lag(close,5))) %>%
  mutate(ret_close_open = log(close/open)) %>%
  mutate(ret_high = log(high/lag(close,1))) %>%
  mutate(ret_low = log(low/lag(close,1))) %>%
  mutate(ret_low_open = log(low/open)) %>%
  mutate(ret_close_low = log(close/low)) %>%
  mutate(ret_high_open = log(high/open)) %>%
  mutate(ret_high_low = log(high/low)) %>%
  mutate(ret_close_open  = log(close/open)) %>%
  mutate(vol_next_1_day = lead(vol_dollar,1)) %>%
  mutate(ret_open_last_1_day = lag(ret_open,1)) %>%
  mutate(vol_change = log(volume/lag(volume,1))) %>%
  mutate(ret_high_next_1_day = log(lead(high,1)/close)) %>%
  mutate(ret_low_next_1_day = log(lead(low,1)/close)) %>%
  mutate(ret_open_last_2_days = lag(ret_open,2)) %>%
  mutate(ret_close_last_2_day = lag(ret_close,2))




min_trade <- 500000
max_trade <- 2500000
temp <- dat %>% filter(vol_dollar > min_trade,vol_dollar < max_trade, ret_close< .15, ret_close>-.15,
                       open>.01, open<10) %>%
  group_by(date) %>%   arrange(ret_close_high) %>% mutate(id=row_number()) %>% filter(id<10)


mean(temp$ret_close_high,na.rm=TRUE)
mean(temp$ret_close,na.rm=TRUE)

mean(temp$ret_open_next_1_day,na.rm=TRUE)
mean(temp$ret_close_next_1_day,na.rm=TRUE)
mean(temp$ret_high_next_1_day,na.rm=TRUE)
mean(temp$ret_low_next_1_day,na.rm=TRUE)
quantile(temp$vol_next_1_day,seq(0,1,by=.1),na.rm=TRUE)
