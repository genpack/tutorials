library(magrittr)
library(dplyr)

# callFreq unit is average calls per week
loanStart = as.POSIXct('2010-07-1') + rnorm(N, mean = 10000, sd = 10000)
loanEnd   = loanStart + rexp(N, rate = 0.00000001)
customers = data.frame(caseID  = 1:N, 
           lvrFreq   = rnorm(N, mean = 40, sd = 3) %>% as.integer,
           transFreq = rnorm(N, mean = 10, sd = 1) %>% as.integer,
           rateFreq = rnorm(N, mean = 0.5),
           callFreq = rexp(N, rate = 0.1) %>% as.integer,
           start    = loanStart,
           end      = loanEnd
           )

customers$callFreq[cases$callFreq == 0] <- 0.000001


# Generates eventlog for a single type

genEventLogSingle = function(cases, eventType = 'call'){
  el = data.frame(eventID = character(), caseID = character(), eventType = character(), eventTime = emptime, variable = character(), value = numeric())
  coln = eventType %>% paste0('Freq')
  for (i in cases %>% nrow %>% sequence){
    maxNumEvents  = (2*difftime(cases$end[i], cases$start[i], units = 'weeks')*cases[i, coln]) %>% as.numeric %>% as.integer
    eventTime = cases$start[i] + rexp(maxNumEvents, rate = cases[i, coln]/(3600*24*7)) %>% cumsum
    eventTime = eventTime[eventTime < cases$end[i]]
    N = length(eventTime)
    if(N > 0){
      el %<>% rbind(
        data.frame(eventID   =  'EVNT' %>% paste(cases$caseID[i], sequence(N), sep = '.'),
                   caseID    = cases$caseID[i],
                   eventType = eventType,
                   eventTime = eventTime,
                   variable  = 'occurance',
                   value     = 1)
      )  
    }
  }
  return(el)
}

# Example:
EL = genEventLogSingle(customers)

genEventLog = function(cases, eventTypes){
  for (tp in eventTypes){
    EL %<>% genEventLogSingle(cases, eventType = tp)
  }
}

EL = genEventLog(cases, )

