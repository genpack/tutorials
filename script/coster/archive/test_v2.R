library(readr)
library(magrittr)
library(dplyr)
library(rutils)

setwd("script/coster")

source("coster_tools.R")

# Read Config:
config = yaml::read_yaml('configs/universal.yml')


files = c(
  'creditcard.csv',
  'smartaccess.csv',
  'creditcard_4Aug2020_4Aug2022.csv',
  'smartaccess_5Aug2020_4Aug2022.csv')


cba.read_transactions(files) %>% 
  cba.to_standard %>% 
  categorise_transactions(config) -> transactions


##########
View(transactions)

View(transactions %>% group_by(category, subcategory) %>% summarise(Total = sum(value)))

days = transactions$eventTime %>% range %>% as.Date %>% {.[2] - .[1]}

View(transactions %>% group_by(category) %>% 
       summarise(Total_Out  = sum(ifelse(value < 0, - value, 0)), 
                 Total_In   = sum(ifelse(value > 0, value, 0)))
)

View(transactions %>% group_by(category, subcategory) %>% 
       summarise(Total_Out  = sum(ifelse(value < 0, - value, 0)), 
                 Total_In   = sum(ifelse(value > 0, value, 0)))
     )

transactions %>% 
  mutate(Month = eventTime %>% substr(1,7)) %>% 
  group_by(Month, category, subcategory) %>% 
       summarise(Total_Out  = sum(ifelse(value < 0, - value, 0)), 
                 Total_In   = sum(ifelse(value > 0, value, 0)),
                 Total = sum(value)) %>% rpivotTable::rpivotTable()


exclude = c('Proximity', 'Income', 'CreditCardRepayment', 'Transfer', 'null')

transactions %>% 
  filter(eventTime >= '2021-04-01', !(category %in% exclude)) %>% 
  mutate(Month = eventTime %>% substr(1,7)) %>% 
  group_by(category, subcategory) %>% 
  summarise(Total_Out  = sum(ifelse(value < 0, - value, 0)), 
            Total_In   = sum(ifelse(value > 0, value, 0)),
            Total = sum(value), Average = sum(value)/16) %>% pull(Average) %>% sum

  

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

