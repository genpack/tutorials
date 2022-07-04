# mustools.R
zarbs = as.character(1:8)

measure = function(pitch, mn){
  mn %<>% as.integer
  start = stringr::str_locate(pitch, as.character(mn)) %>% as.integer %>% {.[2]} + 1
  end   = stringr::str_locate(pitch, as.character(mn+1)) %>% as.integer %>% {.[1]} - 1
  if(is.na(end)){end = nchar(pitch)}
  out   = substr(pitch, start, end)
  if(length(grep(out, pattern = "[0-9]")) == 0){return(out)}
  return("")
}

pitch_shift = function(pitch, shift = 1){
  patn = 'ormtslicdefgabCDEFGABORMTSLI' %>% strsplit('') %>% unlist
  patt  = patn %>% length %>% sequence
  names(patt) = patn
  
  notes[patt[gsub(pitch, pattern = "[0-9]", replacement = '') %>% strsplit('') %>% unlist] + shift] %>% 
    {.[is.na(.)]<-'-';.} %>% paste(collapse = "")
}

update_rythm_1 = function(rtm){
  N     = length(rtm$items)
  posna = sum(is.na(rtm$pos))
  lenna = sum(is.na(rtm$len))
  for(i in which(is.na(rtm$pos))){
    if(i < N){
      if(!is.na(rtm$len[i]) & !is.na(rtm$pos[i + 1])){rtm$pos[i] = rtm$pos[i + 1] - rtm$len[i]}
    } else {
      if(!is.na(rtm$len[i])){rtm$pos[i] = max(rtm$pos, na.rm = T) + 1 - rtm$len[i]}
    }
    if(i > 1){
      if(is.na(rtm$pos[i]) & !is.na(rtm$len[i-1]) & !is.na(rtm$pos[i - 1])){rtm$pos[i] = rtm$pos[i - 1] + rtm$len[i - 1]}
    }
  }
  
  for(i in which(is.na(rtm$len))){
    if(i < N){
      k = i + 1
      while((rtm$items[k] == '.') & (k < N)){k = k + 1}
      if(!is.na(rtm$pos[k]) & !is.na(rtm$pos[i])){rtm$len[i] = rtm$pos[k] - rtm$pos[i]}
      
      # if(!is.na(rtm$pos[i]) & !is.na(rtm$pos[i + 1]) & (rtm$items[i + 1] != '.')){rtm$len[i] = rtm$pos[i + 1] - rtm$pos[i]}
    } else {
      if(i > 1){
        if(rtm$items[i] == '-'){
          rtm$len[i] = max(rtm$pos, na.rm = T) - rtm$pos[i - 1] + 1
        }
      }
    }
  }
  
  # for(i in which(rtm$items == '.')){
  #   if((i < N) & (i > 1)){
  #     rtm$len[i - 1] <- NA
  #     k = i
  #     while((rtm$items[k] == '.') & (k < N)){k = k + 1}
  #     if(!is.na(rtm$pos[k]) & !is.na(rtm$pos[i-1])){rtm$len[i-1] = rtm$pos[k] - rtm$pos[i-1]}
  #     # if(!is.na(rtm$len[i + 1] & !is.na(rtm$len[i]))){rtm$len[i] <- rtm$len[i + 1]}
  #   }
  # }
  
  rtm$changed = (sum(is.na(rtm$pos)) < posna) | (sum(is.na(rtm$len)) < lenna)
  
  return(rtm)
}

update_rythm_2 = function(rtm){
  N     = length(rtm$items)
  posna = sum(is.na(rtm$pos))
  lenna = sum(is.na(rtm$len))
  lng   = c(rep(1,8), 0.5, 0.25)
  names(lng) <- c(zarbs, 'v', 'o')
  
  # step 2: determine lengths from origin:
  for(i in which(is.na(rtm$len))){
    if(i < N){
      if((rtm$items[i] == 'v') & (rtm$items[i + 1] %in% zarbs)){rtm$len[i] <- 0.5}
      if((rtm$items[i] %in% zarbs) & ((rtm$items[i + 1] == 'v'))){rtm$len[i] <- 0.5}
      if((rtm$items[i] %in% c(zarbs, 'v')) & ((rtm$items[i + 1] == 'o'))){rtm$len[i] <- 0.25}
      if((rtm$items[i] %in% zarbs) & ((rtm$items[i + 1] %in% zarbs))){rtm$len[i] <- as.numeric(rtm$items[i + 1]) - as.numeric(rtm$items[i])}
      if((rtm$items[i] == 'o') & (rtm$items[i + 1] %in% c(zarbs, 'v'))){rtm$len[i] <- 0.25}
      if((rtm$items[i] == 'o') & (rtm$items[i + 1] == 'o')){rtm$len[i] <- 0.5}
      
      # silents
      if(rtm$items[i] == '-'){
        if(i > 1){
          if((rtm$items[i-1] %in% c(zarbs, '.')) & (rtm$items[i+1] == 'v')){rtm$len[i] <- 0.25}
          if((rtm$items[i-1] %in% c(zarbs, '.')) & (rtm$items[i+1] == 'o')){rtm$len[i] <- 0.75}
          if((rtm$items[i-1] %in% zarbs) & (rtm$items[i+1] %in% zarbs)){
            a = as.numeric(rtm$items[i-1]); b = as.numeric(rtm$items[i + 1])
            if(b == a + 1){
              rtm$len[i] <- 0.5
            } else 
              rtm$len[i] <- b - a - 1}
          if((rtm$items[i-1] == 'v') & (rtm$items[i+1] %in% c(zarbs, '.'))){rtm$len[i] <- 0.25}
          if((rtm$items[i-1] == 'o') & (rtm$items[i+1] %in% c(zarbs, '.'))){rtm$len[i] <- 0.75}
        } else {
          # i = 1
        }
      }
      
    } else {
      rtm$len[i] = lng[rtm$items[i]]
    }
  }
  
  rtm$changed = (sum(is.na(rtm$pos)) < posna) | (sum(is.na(rtm$len)) < lenna)
  
  return(rtm)
}


as.rythm = function(r){
  
  loc = c()
  for(i in 1:8){
    loc[i] = stringr::str_locate(r, as.character(i)) %>% as.integer %>% {.[1]}
  }
  
  zarbs = as.character(1:8)
  
  res = list(items = r %>% strsplit('') %>% unlist)
  N = length(res$items)
  
  res$pos = rep(NA, N); res$len = rep(NA, N); res$changed = T
  names(res$pos) <- res$items
  names(res$len) <- res$items
  
  # step 1: assign position for sarzarbs:
  cnt = 0
  for(i in sequence(N)){
    if(res$items[i] %in% zarbs){
      cnt = cnt + 1
      res$pos[i] <- res$items[i] %>% as.numeric
    } else if (res$items[i] == '.'){
      cnt = cnt + 1
      res$pos[i] <- cnt
    }
  }
  
  res <- res %>% update_rythm_2
  while(res$changed & ((sum(is.na(res$pos)) > 0) | (sum(is.na(res$len)) > 0))){res %<>% update_rythm_1}

  # res$changed = T
  # res <- res %>% update_rythm_2
  # while(res$changed & ((sum(is.na(res$pos)) > 0) | (sum(is.na(res$len)) > 0))){res %<>% update_rythm_1}
  
  return(res) 
}
