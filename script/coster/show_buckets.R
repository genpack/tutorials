# setwd("script/coster")
########################## View Transactions ################
library(readr)
library(magrittr)
library(dplyr)
library(rutils)

source("script/coster/coster_tools.R")

# Read Config:


# mc = yaml::read_yaml('script/coster/configs/mc_buckets.yml')
mc = yaml::read_yaml('script/coster/configs/master_config.yml')

config = yaml::read_yaml(mc$categories)


files = mc$inputs %>% paste('csv', sep = ".")
files = paste('script', 'coster', 'data', files, sep = "/")

cba.read_transactions(files) %>% 
  cba.to_standard %>% 
  categorise_transactions(config) %>% 
  filter(eventTime >= mc$from, 
         eventTime <= mc$until,
         !(category %in% mc$excluded_categories)) -> transactions


View(transactions)

##################### Save Transactions #################


path_output_transactions = paste('script', 'coster', 'report', mc$output$transactions, sep = "/")

transactions %>% write.csv(path_output_transactions %>% paste("csv", sep = "."), row.names = F)

##########

transactions %>% 
  group_by(category) %>% 
  summarise(Total_Out  = sum(ifelse(value < 0, - value, 0)), 
            Total_In   = sum(ifelse(value > 0, value, 0)),
            Total = sum(value)) -> bucket_balances

transactions %>% 
  group_by(category, subcategory) %>% 
  summarise(Total_Out  = sum(ifelse(value < 0, - value, 0)), 
            Total_In   = sum(ifelse(value > 0, value, 0)),
            Total = sum(value)) -> bucket_balances_sub

path_output_buckets = paste('script', 'coster', 'report', mc$output$buckets, sep = "/")

View(bucket_balances)
#View(bucket_balances_sub)

bucket_balances_sub %>% write.csv(path_output_buckets %>% paste('csv', sep = "."), row.names = F)

#  rpivotTable::rpivotTable()
  

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

