# el_generator_v3.R
# Changes to version 2:
# Added start and end time as arguments to event-log generator

library(magrittr)
library(dplyr)

N = 1000
emptime = Sys.time()[-1]
# callFreq unit is average calls annually
loanStart = as.POSIXct('2010-07-1') + rnorm(N, mean = 10000, sd = 10000)
loanEnd   = loanStart + rexp(N, rate = 0.00000001)
customers = data.frame(ID  = 1:N,
           lvrFreq   = 0.001 + rnorm(N, mean = 1, sd = 3),
           transFreq = 0.001 + rnorm(N, mean = 100, sd = 1),
           rateFreq = 0.001 + rnorm(N, mean = 0.5),
           callFreq = 0.001 + rexp(N, rate = 0.1),
           compFreq = 0.001 + rexp(N, rate = 5),
           printFreq = 0.001 + rexp(N, rate = 0.5),
           monthlyPayment = rnorm(N, mean = 2500, sd = 1200) %>% floor,
           start    = loanStart,
           end      = loanEnd
           )

# Generates eventlog for a single type
# cases: case profile table with features
# event: A configuration list for events to be generated
genEventLogSingle = function(cases, event, start, end){
  el = data.frame(eventID = character(), caseID = character(), eventType = character(), eventTime = emptime, variable = character(), value = numeric())
  for (i in cases %>% nrow %>% sequence){
    feat = cases[i,] %>% as.list
    flag = TRUE
    orig = max(start, cases$start[i])
    endt = min(end, cases$end[i])
    eventTime = emptime
    while (flag){
      eventTime %<>% c(orig + (do.call(event$IAT_generator, list(n = 1000, features = feat)) %>% cumsum))
      orig = max(eventTime, na.rm = T)
      flag = orig < endt
    }
    eventTime = eventTime[eventTime < endt]
    N = length(eventTime)
    if(N > 0){
      eid = do.call(event$ID_generator, list(n = N, features = feat))
      for (var in event$variables){
        el %<>% rbind(
          data.frame(eventID   = eid,
                     caseID    = cases$ID[i],
                     eventType = event$name,
                     eventTime = eventTime,
                     variable  = var$name,
                     value     = do.call(var$value_generator, list(n = N, features = feat))
          ))
      }
    }
  }
  return(el)
}

genEventLog = function(cases, eventTypes, start = NULL, end = NULL){
  EL = data.frame()
  for (tp in eventTypes){
    EL %<>% rbind(genEventLogSingle(cases, event = tp, start = start, end = end))
  }
  return(EL)
}

# rate = 1.0/meanIAT
# meanIAT = weekInSeconds/perWeekFreq
# rate = perWeekFreq/weekInSeconds
# rate = annualFreq/yearInSeconds
weekInSeconds  = 7*24*3600
yearInSeconds  = 52*weekInSeconds
monthInSeconds = yearInSeconds/12

###############
config = list(
  list(
    name = 'LVR Changed',
    # IAT: Inter-Arrival Time
    IAT_generator = function(n, features){return(rexp(n, rate = 1.0/yearInSeconds))},
    ID_generator = function(n, features){'LVRC' %>% paste(features$ID, sequence(n), sep = ".")},
    variables = list(
      list(
        name  = 'LVR',
        value_generator = function(n, features){rnorm(n, mean = 0.8, sd = 0.01)}
      )
    )
  ),

  list(
    name = 'Customer Complaint',
    # IAT: Inter-Arrival Time
    IAT_generator = function(n, features){return(rexp(n, rate = features$compFreq/yearInSeconds))},
    ID_generator = function(n, features){'CCMP' %>% paste(features$ID, sequence(n), sep = ".")},

    variables = list(
      list(
        name  = 'Theme',
        value_generator = function(n, features){sample(c('Service', 'Rate', 'Fee', 'Other'), size = n, replace = T)}
      )
    )
  ),

  list(
    name = 'Print Statement',
    # IAT: Inter-Arrival Time
    IAT_generator = function(n, features){return(rexp(n, rate = features$printFreq/weekInSeconds))},
    ID_generator = function(n, features){'PRNT' %>% paste(features$ID, sequence(n), sep = ".")},
    variables = list(
      list(
        name  = 'Occurance',
        value_generator = function(n, features){1}
      )
    )
  ),

  list(
    name = 'Call Received',
    IAT_generator = function(n, features){return(rexp(n, rate = features$callFreq/weekInSeconds))},
    ID_generator = function(n, features){'CALL' %>% paste(features$ID, sequence(n), sep = ".")},
    variables = list(
      list(
        name  = 'Occurance',
        value_generator = function(n, features){1}
      )
    )
  ),

  list(
    name = 'Payment Towards Loan',
    IAT_generator = function(n, features){return(rnorm(n, mean = 30*24*3600, sd = 10000)[- sample(1:n, size = 10)])},
    ID_generator = function(n, features){'PTLN' %>% paste(features$ID, sequence(n), sep = ".")},
    variables = list(
      list(
        name  = 'Amount',
        value_generator = function(n, features){features$monthlyPayment}
      )
    )
  )

)

# EL = genEventLog(customers, config)

EL = genEventLog(customers, config)

EL %>% write.csv('bigeventlog.csv')


