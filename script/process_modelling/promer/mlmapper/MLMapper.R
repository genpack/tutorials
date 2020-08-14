
library(magrittr)
library(dplyr)

# An example of featres list
features = list(
  list(name = 'totalCalls', aggregator = sum, eventTypes = 'Call Received', variables = 'Occurance'),
  list(name = 'totalDeclines', aggregator = length, eventTypes = 'Discount Request Approved', variables = 'Occurance'),
  list(name = 'maxLVR', aggregator = max, eventTypes = 'LVR Changed', variables = 'newRate'),
  list(name = 'minDesired', aggregator = min, eventTypes = 'Discount Request Lodged', variables = 'desiredRate'),
  list(name = 'rate', aggregator = last, eventTypes = 'Discount Request Lodged', variables = 'desiredRate')
)

# MLMpaaer.periodic converts an eventlog into a mix of multivariate time series.  Each caseID, will have a time series.
MLMapper.periodic = function(eventlog, features, period = c('hour', 'day', 'week', 'month', 'year'), start = NULL, end = NULL){
  period = match.arg(period)
  eventlog$eventTime %<>% as.POSIXct %>% lubridate::force_tz('GMT')
  if(!is.null(start)){start %<>% as.POSIXct %>% lubridate::force_tz('GMT'); eventlog %<>% filter(eventTime > start - 1)}
  if(!is.null(end))  {end   %<>% as.POSIXct %>% lubridate::force_tz('GMT'); eventlog %<>% filter(eventTime < end + 1)}

  EL %<>% mutate(periodStart = eventTime %>% lubridate::floor_date(period), selected = T)
  molten = data.frame()
  for (ft in features){
    if(!is.null(ft$eventTypes)){
      EL$selected = EL$eventType %in% ft$eventTypes
    }

    if(!is.null(ft$variables)){
      EL$selected = EL$selected & (EL$variable %in% ft$variables)
    }
    EL %>% filter(selected) %>% group_by(caseID, periodStart) %>%
      summarise(aggrval = do.call(ft$aggregator, list(value))) %>%
      mutate(featureName = ft$name) %>%
      bind_rows(molten) -> molten
  }

  tt = data.frame(periodStart = seq(from = min(EL$periodStart), to = max(EL$periodStart), by = 'day'))
  data.frame(caseID = unique(eventlog$caseID)) %>% group_by(caseID) %>% do({data.frame(caseID = .$caseID, periodStart = tt)}) %>%
    left_join(molten %>% reshape2::dcast(caseID + periodStart ~ featureName, sum, value.var = 'aggrval'), by = c('caseID', 'periodStart')) -> molten
  molten[is.na(molten)] <- 0
  names(molten)[2] <- 'time'
  return(molten)
}

EL = read.csv('eventlog.csv')
EL %>% MLMapper.periodic(features, period = 'day') %>% View
