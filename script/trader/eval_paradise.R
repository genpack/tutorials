
# Header
# Filename:     eval_paradise.R
# Description:  We test the performance of strategy Paradise
# Author:       Nima Ramezani Taghiabadi
# Email :       N.RamezaniTaghiabadi@uws.edu.au
# Start Date:   03 November 2014
# Last change:  03 November 2014
# Version:      1.0

# source("init.R")
# 
# lib.set = c()
# lib.set = c(lib.set, paste(packages.path, "nima", "artificial_intelligence", "business_intelligence", "trading", "strategy_tester.R", sep = "/"))
# for (lib in lib.set){source(lib)}
source('C:/Users/nima_/Dropbox/software/R/packages/master/nirasoft/trader/R/genlib.R')
source('C:/Users/nima_/Dropbox/software/R/packages/master/nirasoft/trader/R/virtual_trader.R')
source('C:/Users/nima_/Dropbox/software/R/packages/master/nirasoft/trader/R/strategies.R')
source('C:/Users/nima_/Dropbox/software/R/packages/master/nirasoft/trader/R/strategy_tester.R')

security = "EURUSD" 


pm_min = list(hyper_tp=100, hyper_sl=200, hyper_ts = FALSE, expiry_tn = NA, max_dur = NA, lot.fwd = 0.01, lot.inv=0.1, tp = 3.0, gap_fwd = 5.0, gap_inv.pips = 50, max_fwd=10)
pm_max = pm_min

from  = "2000.01.01 00:00"
until = "2014.04.01 00:00"
prd   = "D"


r1 = c(1,3000) #time range 1
r2 = c(2000, 3500) #time range 2

# Look at This:

rates_1 = list()
rates_2 = list()
htps   = c()
hsls   = c()

htp0 = 5*pm_min$hyper_tp
hsl0 = 5*pm_min$hyper_sl
ktp  = pm_min$hyper_tp
ksl  = pm_min$hyper_sl

N = 100
for (i in sequence(10)){
  htp = htp0 + ktp*(i-5)
  for (j in sequence(10)){
    hsl = hsl0 + ksl*(j-5)
    pm_min$hyper_tp = htp
    pm_min$hyper_sl = hsl
    pm_max = pm_min
    D1 = generate.desired.test.data.frame(N, 1, time_num_min = r1[1], time_num_max = r1[2], parameters_min=pm_min, parameters_max=pm_max, time.first = TRUE, replacement = FALSE)
    D2 = generate.desired.test.data.frame(N, 1, time_num_min = r2[1], time_num_max = r2[2], parameters_min=pm_min, parameters_max=pm_max, time.first = TRUE, replacement = FALSE)
    
    vt  = prepare.environment(currency_pair = security, from_date = from, until_date = until, period = prd)

    R1  = evaluate.strategy(vt, "paradise", desired_test_table = D1)
    R2  = evaluate.strategy(vt, "paradise", desired_test_table = D2)

    s1 = summary(R1, period = prd)
    s2 = summary(R2, period = prd)
    
    rates_1 = rbind(rates_1, s1)
    rates_2 = rbind(rates_2, s2)
    
    htps = c(htps, htp)
    hsls = c(hsls, hsl)
  }
}  

RSLT1 = cbind(htps, hsls, rates_1)
RSLT2 = cbind(htps, hsls, rates_2)

 # RSLT = data.frame(TP = htps, SL = hsls, Pr.1 = probs_1, OddsR.1 = odrs_1, Duration.1 = durs_1, Ann.Rate.1 = rates_1, Pr.2 = probs_2, OddsR.2 = odrs_2, Duration.2 = durs_2, Ann.Rate.2 = rates_2)
