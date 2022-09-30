
# This function modifies the transactions file from cba format into the standard format
cba.to_standard = function(transactions){
  transactions %<>% 
    mutate(
      desc = description %>% tolower %>% gsub(pattern = "\\s", replacement = ""),
      eventTime = as.Date(NA), category = NA, merchant = NA) 
  
  ind_y = which(nchar(transactions$date) <= 8)
  ind_Y = which(nchar(transactions$date) > 8)
  assert(length(ind_Y) + length(ind_y) == nrow(transactions))
  transactions$eventTime[ind_y] <- as.Date(transactions$date[ind_y], format = '%d/%m/%y')
  transactions$eventTime[ind_Y] <- as.Date(transactions$date[ind_Y], format = '%d/%m/%Y')
  
  transactions %>% 
    distinct(eventTime, desc, value, source, .keep_all = T)
}

# This function assigns a category and a sub-category to each transaction
# in the given `transactions` table based on the given config.
categorise_transactions = function(transactions, config){
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
  
  transactions %>% select(eventTime, description, category, subcategory = merchant, source, value)
}

cba.read_transactions = function(filenames){
  transactions = NULL
  for (fn in filenames){
    path = "%s/%s" %>% sprintf('data', fn) %>% 
      read.csv(header = F, as.is = T) -> D
    if (ncol(D) == 4){
      D = D[,c(1:3)]
    }
    colnames(D) = c('date', 'value', 'description')
    if(fn %in% c('el_cr.csv',
                 'el_sa.csv')){D$source = 'E'} else {D$source = 'N'}
    transactions %<>% rbind(D)  
  }
  return(transactions)
}