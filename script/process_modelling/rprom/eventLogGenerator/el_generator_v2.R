# el_generator_v2.R
# Changes to version 1:
# Defined config structure for generating customized event-log

library(magrittr)
library(dplyr)

emptime = Sys.time()[-1]
# callFreq unit is average calls per week
loanStart = as.POSIXct('2010-07-1') + rnorm(N, mean = 10000, sd = 10000)
loanEnd   = loanStart + rexp(N, rate = 0.00000001)
customers = data.frame(ID  = 1:N, 
           lvrFreq   = rnorm(N, mean = 40, sd = 3) %>% as.integer,
           transFreq = rnorm(N, mean = 10, sd = 1) %>% as.integer,
           rateFreq = rnorm(N, mean = 0.5),
           callFreq = rexp(N, rate = 0.1) %>% as.integer,
           start    = loanStart,
           end      = loanEnd
           )

# Generates eventlog for a single type
# cases: case profile table with features
# event: A configuration list for events to be generated
genEventLogSingle = function(cases, event){
  el = data.frame(eventID = character(), caseID = character(), eventType = character(), eventTime = emptime, variable = character(), value = numeric())
  for (i in cases %>% nrow %>% sequence){
    feat = cases[i,] %>% as.list
    flag = TRUE
    orig = cases$start[i]
    eventTime = emptime
    while (flag){
      eventTime %<>% c(orig + (do.call(event$IAT_generator, list(n = 1000, features = feat)) %>% cumsum))
      orig = max(eventTime)
      flag = orig < cases$end[i]
    }
    eventTime = eventTime[eventTime < cases$end[i]]
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

genEventLog = function(cases, eventTypes){
  EL = data.frame()
  for (tp in eventTypes){
    EL %<>% rbind(genEventLogSingle(cases, event = tp))
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
        name  = 'newRate',
        value_generator = function(n, features){rnorm(n, mean = 4.0, sd = 0.1)}
      )
    )),
  
  list(
    name = 'Discount Request Lodged',
    # IAT: Inter-Arrival Time
    IAT_generator = function(n, features){return(rexp(n, rate = 1.0/yearInSeconds))},
    ID_generator = function(n, features){'DCRL' %>% paste(features$ID, sequence(n), sep = ".")},
    
    variables = list(
      list(
        name  = 'desiredRate',
        value_generator = function(n, features){rnorm(n, mean = 4.0, sd = 0.1)}
      )
    )
  ),
  
  list(
    name = 'Discount Request Approved',
    # IAT: Inter-Arrival Time
    IAT_generator = function(n, features){return(rexp(n, rate = 1.0/weekInSeconds))},
    ID_generator = function(n, features){'DCRA' %>% paste(features$ID, sequence(n), sep = ".")},
    variables = list(
      list(
        name  = 'Occurance',
        value_generator = function(n, features){1}
      )
    )
  ),
  
  list(
    name = 'Call Received',
    IAT_generator = function(n, features){return(rexp(n, rate = 1.0/weekInSeconds))},
    ID_generator = function(n, features){'CALL' %>% paste(features$ID, sequence(n), sep = ".")},
    variables = list(
      list(
        name  = 'Occurance',
        value_generator = function(n, features){1}
      )
    ), 
    requires = character(),
    follows  = character()
  )
)

# EL = genEventLog(customers, config)


