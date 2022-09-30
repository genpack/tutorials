# setwd("script/coster")

library(readr)
library(magrittr)
library(dplyr)
library(rutils)


source("coster_tools.R")

# Read Config:
config = yaml::read_yaml('configs/buckets.yml')


files = c('cba_nbs_aug22.csv', 'cba_nbs_sep22.csv')

cba.read_transactions(files) %>% 
  cba.to_standard %>% 
  categorise_transactions(config) -> transactions


##########
View(transactions)

# transactions %>% 
#   filter(eventTime >= '2022-08-01') %>% 
#   group_by(category) %>% summarise(Total = sum(value)) %>% 
#   View
# 
# days = transactions$eventTime %>% range %>% as.Date %>% {.[2] - .[1]}
# 
# View(transactions %>% group_by(category) %>% 
#        summarise(Total_Out  = sum(ifelse(value < 0, - value, 0)), 
#                  Total_In   = sum(ifelse(value > 0, value, 0)),
#                  Total = sum(value))
# )


exclude = c('Expenses', 'Miscellaneous', 'CreditCard', 'Proximity')

transactions %>% 
  filter(eventTime >= '2022-08-01', !(category %in% exclude)) %>% 
  group_by(category) %>% 
  summarise(Total_Out  = sum(ifelse(value < 0, - value, 0)), 
            Total_In   = sum(ifelse(value > 0, value, 0)),
            Total = sum(value)) -> bucket_balances

  bucket_balances %>% View
#  rpivotTable::rpivotTable()
  bucket_balances %>% write.csv('bucket_balances.csv', row.names = F)
  

# for(st in paste0(' ', unique(suburbs$state))){
#   D[D$desc %>% grep(pattern = st), 'state'] <- st
#   D$desc %<>% gsub(pattern = st, replacement = '')
# }
# 
# for(sb in paste0(' ', suburbs %>% filter(state == 'NSW') %>% pull(suburb) %>% setdiff(c('WILSON', 'COLES')) %>% unique)){
#   D[D$desc %>% grep(pattern = sb), 'suburb'] <- sb
#   D$desc %<>% gsub(pattern = sb, replacement = '')
# }
# 
# D[D$desc %>% grep(pattern = 'AMEX'), 'amex'] <- 1
# D$desc %<>% gsub(pattern = 'AMEX', replacement = '')
# 
# D$desc %<>% gsub(pattern = 'PTY', replacement = '')
# D$desc %<>% gsub(pattern = 'LTD', replacement = '')
# 
# while(!is.empty(grep(D$desc, pattern = '  '))){
#   D$desc[grep(D$desc, pattern = '  ')]  %<>%  gsub(pattern = '  ', replacement = ' ')
# }
# 
# 
# D %>% group_by(desc) %>% summarise(value = sum(value), cnt = length(value)) %>% dim

