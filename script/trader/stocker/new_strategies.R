
milking_settings = list(
  lot = 0.01,
  label = 'MLK',
  min_gap = 500
)

DEFAULT_PARAMETERS = list()
DEFAULT_PARAMETERS[["MILKING"]] = milking_settings
  
milking.start <- function(vt, pm){
  # take initial buy position:
  vt$take.buy(lot = pm$lot, label = pm$label)
}

add_missing_parameters = function(pm, vt){
  pm$hyper_ts <- rutils::verify(pm$hyper_ts, 'logical', domain = c(T,F), lengths = 1, default = F)
  pm$hyper_sl <- rutils::verify(pm$hyper_sl, 'numeric', lengths = 1, default = NA)
  pm$hyper_tp <- rutils::verify(pm$hyper_tp, 'numeric', lengths = 1, default = NA)
  pm$pm$expiry_tn <- rutils::verify(pm$expiry_tn, 'numeric', lengths = 1, default = NA)
  if (is.null(pm$expiry_tn)){pm$expiry_tn = vt$number.of.intervals}
  if (!is.null(pm$max_dur)){pm$expiry_tn = min(vt$number.of.intervals, vt$current.time.number + pm$max_dur)}
  
  return(pm)
}

milking.decide <-function(vt, pm, s){
  if(sum(vt$position$active) == 0){
    milking.start(vt, pm)
  } else if (length(vt$positive.positions()) > 0) {
    # if there is any positive position, close and take the milk
    vt$close(vt$positive.positions())
  } else {
    # if the last position is more than min_gap pips in loss, take another buy
    max_profit = vt$position %>% filter(active) %>% pull(profit) %>% max
    max_pips   = max_profit*0.1/pm$lot
    
    if(max_profit < 0){
      if(abs(max_pips) > pm$min_gap){
        vt$take.buy(lot = pm$lot, label = pm$label)
      }
    }
  }
}

milking <- function(vt, pm = DEFAULT_PARAMETERS[["MILKING"]]){
  pm %<>% add_missing_parameters(vt)
  # The strategy program starts here
  # assert(check.parameters(vt, pm, "MILK"), "Error from neg_lin: invalid parameters")
  
  milking.start(vt, pm)
  while (permit(vt, pm)){
    res   = vt$jump(1)
    milking.decide(vt, pm, res)
  }
}
