# Write your own strategy:

# Each strategy requires three functions:
# <strategt_name>.start(vt, pm)
# <strategt_name>.decide(vt, pm, ...)
# <strategt_name>(vt, pm)

RedLine = Strategy()

redline_buy.start <- function(vt, pm){
  vt$take.buy(lot = pm$lot, label = "RLB")
}
redline_buy.decide <- function(vt, pm, base){
  if ((vt$current.price > base) & (vt$position.balance() < 0)){
    vt$close.all(labels = "RLB")
    vt$take.buy(lot = pm$lot, label = "RLB")
  }
  
  if ((vt$current.price < base) & (vt$position.balance() > 0)){
    vt$close.all(labels = "RLB")
  }
  
  # pull the base price down as price goes down:
  if (vt$current.price < base - pm$trailing_base.pips){
    base = pm$trailing_base.pips + vt$current.price
  }
}

# red_line is the same as redline_buy
redline_buy <- function(vt, pm = default.parameters("redline_buy")){
  if (is.na(pm$expiry_tn)){pm$expiry_tn = vt$number.of.intervals}
  if (!is.na(pm$max_dur)){pm$expiry_tn = min(vt$number.of.intervals, vt$current.time.number+pm$max_dur)}
  # assert(check.parameters(vt, pm, "redline_buy"), "Error from redline_buy: invalid parameters")
  
  redline_buy.start(vt, pm)
  base_line = vt$current.price - 10*vt$pip
  
  while (permit(vt, pm)){
    redline_buy.decide(vt, pm, base_line)
    vt$jump()
  }
}


