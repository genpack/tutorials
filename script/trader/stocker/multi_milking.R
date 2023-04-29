# Mixed Milking on 10 Stocks
ticker_summary = dat_raw %>% stock_behaviour_summary
best_tickers = ticker_summary %>% 
  arrange(desc(volrate)) %>% filter(turnover > 2000000) %>% 
  filter(mindate < '2019-01-01') %>% 
  head(5)

run_milking_simulation = function(dat_raw, best_tickers){
  vt = list()
  el = NULL
  for(i in sequence(nrow(best_tickers))){
    tick = best_tickers$ticker[i]
    dat_raw %>% 
      filter(ticker == tick) %>% 
      rename(open = price.open, high = price.high, low = price.low, close = price.close, time = ref.date) %>% 
      mutate(time = as.POSIXct(time)) %>% 
      select(time, open, low, high, close, volume) -> dat_i
    
    vt[[tick]] = VIRTUAL.TRADER(data = dat_i)
    vt[[tick]]$spread = 0
    tn = which(as.Date(vt[[tick]]$data$time) == as.Date('2019-01-02'))
    vt[[tick]]$goto(tn)
    
    pm = list(lot = 0.01, label = "MLK", min_gap = 10000*best_tickers$delta[i], expiry_tn = 365, hyper_ts = F)
    
    milking(vt[[tick]], pm = pm)
    
    vt[[tick]]$history %>% mutate(eventID = paste(tick, sequence(nrow(.)), sep = '-'), eventType = 'AccountUpdate', caseID = tick) -> base
    
    base %>% mutate(attribute = 'lot') %>% 
      select(eventID, caseID, eventType, eventTime = time, attribute, value = lots) %>% rbind(el) -> el
    
    base %>% mutate(attribute = 'equity') %>% 
      select(eventID, caseID, eventType, eventTime = time, attribute, value = equity) %>% rbind(el) -> el

    base %>% mutate(attribute = 'invest') %>% 
      select(eventID, caseID, eventType, eventTime = time, attribute, value = invest) %>% rbind(el) -> el

    base %>% mutate(attribute = 'balance') %>% 
      select(eventID, caseID, eventType, eventTime = time, attribute, value = balance) %>% rbind(el) -> el
  }
  return(el)
}

run_milking_simulation(dat_raw, best_tickers) -> el


el %>% generate_dynamic_features_pack(period = 'day', sequential = T, attr_funs = 'last') -> dfg

