library(readr)
library(magrittr)
library(dplyr)
library(gener)

files = c('SmartAccess_FY2018-19.csv',
          'CreditCard_FY2018-19.csv',
          'SmartAccess_FY2019.csv',
          'CreditCard_FY2019.csv',
          'SmartAccess_FY2020.csv',
          'SmartAccess_FY2021_incomplete.csv',
          'CreditCard_FY2020.csv',
          'CreditCard_FY2021_incomplete.csv',
          'smartaccess.csv',
          'creditcard.csv')

#          'el_cr.csv',
#          'el_sa.csv')

transactions = NULL
for (fn in files){
  path = "%s/%s" %>% sprintf('Data', fn) %>% 
    read.csv(header = F, as.is = T) -> D
  if (ncol(D) == 4){
    D = D[,c(1:3)]
  }
  colnames(D) = c('date', 'value', 'description')
  if(fn %in% c('el_cr.csv',
               'el_sa.csv')){D$source = 'E'} else {D$source = 'N'}
  transactions %<>% rbind(D)  
}


transactions %<>% 
  mutate(
    desc = description %>% tolower %>% gsub(pattern = "\\s", replacement = ""),
    eventTime = as.Date(NA), category = NA, merchant = NA) 

ind_y = which(nchar(transactions$date) <= 8)
ind_Y = which(nchar(transactions$date) > 8)
assert(length(ind_Y) + length(ind_y) == nrow(transactions))
transactions$eventTime[ind_y] <- as.Date(transactions$date[ind_y], format = '%d/%m/%y')
transactions$eventTime[ind_Y] <- as.Date(transactions$date[ind_Y], format = '%d/%m/%Y')

transactions %<>% 
  distinct(eventTime, desc, value, source, .keep_all = T)

# Read Config:
config = yaml::read_yaml('config_2.yml')
for (cat in names(config)){
  for(mer in names(config[[cat]])){
    key = config[[cat]][[mer]]
    inds = c() 
    for(pat in tolower(key)){
      ind  = grep(transactions$desc , pattern = pat)
      inds = c(inds, ind)
    }
    inds = unique(inds) %^% which(is.na(transactions$category))
    transactions$category[inds] <- cat 
    transactions$merchant[inds] <- mer  
  }
}

transactions %<>% select(eventTime, description, category, subcategory = merchant, source, value)


# View(transactions %>% filter(is.na(category)))

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

