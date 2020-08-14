# rate = 1.0/meanIAT
# meanIAT = weekInSeconds/perWeekFreq
# rate = perWeekFreq/weekInSeconds
# rate = annualFreq/yearInSeconds
weekInSeconds  = 7*24*3600
yearInSeconds  = 52*weekInSeconds
monthInSeconds = yearInSeconds/12

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



# MLMpaaer.periodic converts an eventlog into a mix of multivariate time series.  Each caseID, will have a time series.
MLMapper.periodic = function(eventlog, features, period = c('hour', 'day', 'week', 'month', 'year'), start = NULL, end = NULL){
  period = match.arg(period)
  eventlog$eventTime %<>% as.POSIXct %>% lubridate::force_tz('GMT')
  if(!is.null(start)){start %<>% as.POSIXct %>% lubridate::force_tz('GMT'); eventlog %<>% filter(eventTime > start - 1)}
  if(!is.null(end))  {end   %<>% as.POSIXct %>% lubridate::force_tz('GMT'); eventlog %<>% filter(eventTime < end + 1)}

  eventlog %<>% mutate(periodStart = eventTime %>% lubridate::floor_date(period), selected = T)
  molten = data.frame()
  for (ft in features){
    if(!is.null(ft$eventTypes)){
      eventlog$selected = eventlog$eventType %in% ft$eventTypes
    } else eventlog$selected = TRUE

    if(!is.null(ft$variables)){
      eventlog$selected = eventlog$selected & (eventlog$variable %in% ft$variables)
    }
    eventlog %>% filter(selected) %>% group_by(caseID, periodStart) %>%
      summarise(aggrval = do.call(ft$aggregator, list(value))) %>%
      mutate(featureName = ft$name) -> mlt

    if(nrow(mlt) > 0){
      molten %<>% bind_rows(mlt)
    }
  }

  tt = data.frame(periodStart = seq(from = min(eventlog$periodStart), to = max(eventlog$periodStart), by = period))
  data.frame(caseID = unique(eventlog$caseID)) %>% group_by(caseID) %>% do({data.frame(caseID = .$caseID, periodStart = tt)}) %>%
    left_join(molten %>% reshape2::dcast(caseID + periodStart ~ featureName, sum, value.var = 'aggrval'), by = c('caseID', 'periodStart')) -> molten
  molten[is.na(molten)] <- 0
  names(molten)[2] <- 'time'
  return(molten)
}

# currently, only works for daily
MLMapper.periodic.sparklyr = function(eventlog, features, period = 'day', start = NULL, end = NULL){
  period = match.arg(period)
  if(!is.null(start)){start %<>% as.POSIXct %>% lubridate::force_tz('GMT'); eventlog %<>% filter(eventTime > start - 1)}
  if(!is.null(end))  {end   %<>% as.POSIXct %>% lubridate::force_tz('GMT'); eventlog %<>% filter(eventTime < end + 1)}
  eventlog %<>% mutate(periodStart = as.Date(eventTime))
  molten = data.frame()
  for(ft in config$features){
    cat('Building PAF ', ft$name, '\n')
    if(!is.null(ft$eventTypes)){
      eventlog %<>% mutate(selected = eventType %in% ft$eventTypes)
    } else {
      eventlog %<>% mutate(selected = TRUE)
    }

    if(!is.null(ft$variables)){
      eventlog %<>% mutate(selected = selected & (variable %in% ft$variables))
    }

    switch(ft$aggregator,
           'mean' = {eventlog %>% filter(selected) %>% group_by(caseID, periodStart) %>% summarise(aggrval = AVG(value, na.rm = T)) %>% mutate(featureName = ft$name) %>% collect},
           'sum'  = {eventlog %>% filter(selected) %>% group_by(caseID, periodStart) %>% summarise(aggrval = SUM(value, na.rm = T)) %>% mutate(featureName = ft$name) %>% collect},
           'first' = {eventlog %>% filter(selected) %>% group_by(caseID, periodStart) %>% summarise(aggrval = first_value(value)) %>% mutate(featureName = ft$name) %>% collect},
           'last' = {eventlog %>% filter(selected) %>% group_by(caseID, periodStart) %>% summarise(aggrval = last_value(value)) %>% mutate(featureName = ft$name) %>% collect},
           'count'  = {eventlog %>% filter(selected) %>% group_by(caseID, periodStart) %>% summarise(aggrval = COUNT(value)) %>% mutate(featureName = ft$name) %>% collect},
           'max'  = {eventlog %>% filter(selected) %>% group_by(caseID, periodStart) %>% summarise(aggrval = MAX(value)) %>% mutate(featureName = ft$name) %>% collect},
           'sd'  = {eventlog %>% filter(selected) %>% group_by(caseID, periodStart) %>% summarise(aggrval = sd(value)) %>% mutate(featureName = ft$name) %>% collect},
           'min'  = {eventlog %>% filter(selected) %>% group_by(caseID, periodStart) %>% summarise(aggrval = MIN(value)) %>% mutate(featureName = ft$name) %>% collect}
    ) -> mlt

    if(nrow(mlt) > 0){
      molten %<>% bind_rows(mlt)
    }
  }

  tt = data.frame(periodStart = seq(from = min(molten$periodStart), to = max(molten$periodStart), by = 'day'))
  data.frame(caseID = unique(eventlog$caseID)) %>% group_by(caseID) %>% do({data.frame(caseID = .$caseID, periodStart = tt)}) %>%
    left_join(molten %>% reshape2::dcast(caseID + periodStart ~ featureName, sum, value.var = 'aggrval'), by = c('caseID', 'periodStart')) -> molten
  molten[is.na(molten)] <- 0
  names(molten)[2] <- 'time'
  return(molten)
}



vect.history = function(location, vector, win_size, fun, early_call = F){
  if(location < win_size){
    if(early_call){out = do.call(fun, args = list(v[sequence(location)]))} else {out = NA}
  } else {
    out = do.call(fun, args = list(vector[(location - win_size):location]))
  }
  return(out)
}

vect.future = function(location, vector, win_size, fun, late_call = F){
  N = length(vector)
  if(N - location < win_size){
    if(late_call){out = do.call(fun, args = list(v[location:N]))} else {out = NA}
  } else {
    out = do.call(fun, args = list(vector[location:(location + win_size)]))
  }
  return(out)
}

# Only for moving windows not growing
MLMapper.historic = function(periodic, features){
  drops = character()
  for (ft in features){
    if(is.null(ft$drop_reference)){ft$drop_reference = F}
    periodic %>% nrow %>% sequence %>% sapply(FUN = vect.history, vector = periodic[, ft$reference], win_size = ft$win_size, fun = ft$aggregator) -> periodic[, ft$name]
    if(ft$drop_reference){drops = c(drops, ft$reference)}
  }

  return(periodic[, colnames(periodic) %>% setdiff(drops)])
}

MLMapper.labeler = function(periodic, features){
  drops = character()
  for (ft in features){
    if(is.null(ft$drop_reference)){ft$drop_reference = F}
    periodic %>% nrow %>% sequence %>% sapply(FUN = vect.future, vector = periodic[, ft$reference], win_size = ft$win_size, fun = ft$aggregator) -> periodic[, ft$name]
    if(ft$drop_reference){drops = c(drops, ft$reference)}
  }
  return(periodic[, colnames(periodic) %>% setdiff(drops)])
}

# This function helps you build list of features to pass to argument features of MLMapper.historic and MLMapper.labeler:
add_features = function(flist = list(), actions){
  for (act in actions){
    for (ft in act$features){
      flist %<>% c(act$win_sizes %>% lapply(function(x) list(name = paste(ft, act$label, sep = '.') %>% paste0(x) , aggregator = act$fun, reference = ft, win_size = x)))
    }
  }
  return(flist)
}
