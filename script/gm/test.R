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

update_rythm = function(rtm){
  posna = sum(is.na(rtm$pos))
  lenna = sum(is.na(rtm$len))
  for(i in which(is.na(rtm$pos))){
    if(i < N){
      if(!is.na(rtm$len[i]) & !is.na(rtm$pos[i + 1])){rtm$pos[i] = rtm$pos[i + 1] - rtm$len[i]}
    }
    if(i > 1){
      if(is.na(rtm$pos[i]) & !is.na(rtm$len[i-1]) & !is.na(rtm$pos[i - 1])){rtm$pos[i] = rtm$pos[i - 1] + rtm$len[i - 1]}
    }
  }
  
  for(i in which(is.na(rtm$len))){
    if(i < N){
      if(!is.na(rtm$pos[i]) & !is.na(rtm$pos[i + 1])){rtm$len[i] = rtm$pos[i + 1] - rtm$pos[i]}
    }
    if(i > 1){
      if(is.na(rtm$len[i]) &!is.na(rtm$pos[i]) & !is.na(rtm$pos[i - 1])){rtm$len[i] = rtm$pos[i] - rtm$pos[i - 1]}
    }
  }
  
  for(i in which(items == '.')){
    if((i < N) & (i > 1)){
      rtm$len[i - 1] <- NA
      k = i
      while(items[k] == '.'){k = k + 1}
      if(k <= N){
        if(!is.na(rtm$pos[k]) & !is.na(rtm$pos[i-1])){rtm$len[i-1] = rtm$pos[k] - rtm$pos[i-1]}
      }
    }
  }

  rtm$changed = (sum(is.na(rtm$pos)) < posna) | (sum(is.na(rtm$len)) < lenna)
  
  return(rtm)
}


notes = rep('CDEFGAB', 4) %>% strsplit('') %>% unlist
names(notes) <- names(patt)
octaves = 1:4 %>% sapply(rep, 7) %>% as.numeric
names(octaves) <- names(patt)

m8 = pitches %>% measure(7) %>% strsplit('') %>% unlist
n8 = notes[m8]
o8 = octaves[m8]

paste0(n8, o8 + 2)
#######

r = '14'
# loc = list()
# for(i in 1:8){
#   loc[[i]] = stringr::str_locate(r, as.character(i)) %>% as.integer
# }


loc = c()
for(i in 1:8){
   loc[i] = stringr::str_locate(r, as.character(i)) %>% as.integer %>% {.[1]}
}

zarbs = as.character(1:8)

items = r %>% strsplit('') %>% unlist; ilag = c(items[-1], '5')
N = length(items)

res = list(pos = rep(NA, N), len = rep(NA, N), changed = T)
names(res$pos) <- items
names(res$len) <- items

# step 1: assign position for sarzarbs:
# zheads = which(items %in% zarbs)
# pos[zheads] = items[zheads] %>% as.numeric; poslag = c(pos[-1], 5)

cnt = 0
for(i in sequence(N)){
  if(items[i] %in% zarbs){
    cnt = cnt + 1
    res$pos[i] <- items[i] %>% as.numeric
  } else if (items[i] == '.'){
    cnt = cnt + 1
    res$pos[i] <- cnt
  }
}


# for(i in which(items == ".")){
#   w = which(loc < i)
#   if(length(w) > 0){
#     pos[i] = w %>% max %>% {.+1}
#   } else {
#     pos[i] = cnt
#   }
# }

# step 2: update lengths and determine from origin:
res %<>% update_rythm

for(i in which(is.na(res$len))){
  if(i < N){
    if((items[i] == 'v') & (items[i + 1] %in% zarbs)){res$len[i] <- 0.5}
    if((items[i] %in% c(zarbs, 'v')) & ((items[i + 1] == 'o'))){res$len[i] <- 0.25}
    if((items[i] == 'o') & (items[i + 1] %in% c(zarbs, 'v'))){res$len[i] <- 0.25}
  } else {
    lng = c(rep(1,8), 0.5, 0.25)
    names(lng) <- c(zarbs, 'v', 'o')
    len[i] = lng[items[i]]
  }
}
res$changed = T

# step 3: update pos & len from each other:
while(res$changed & (sum(is.na(res$pos)) > 0) & (sum(is.na(res$len)) > 0)){res %<>% update_rythm}

# len[(items == 'v') & ((ilag %in% zarbs))] <- 0.5
# len[(items %in% c(zarbs, 'v')) & ((ilag == 'o'))] <- 0.25
# len[(items == 'o') & ((ilag %in% zarbs) | (ilag == 'v'))] <- 0.25
# names(len) <- items

########## 

z = 1 
between = substr(r, loc[[z]][2]+1, loc[[z+1]][1]-1)


# Melody

pitches = '2c3CEEDDCCDCa4bc5bDDCCbbCbg6af7EGGGGEEFEC8DEDb9CgED10DCbCfgf11FAAGGFFGFD12Ef'

pitches %>% paste0(13, measure(., 8) %>% pitch_shift(2)) 

pitches %>% measure(11) %>% pitch_shift(10)

rythms = c('', '4', '1.o3ovo4ovo', '14','1...ovo', '1444', '1.vo3678', '1..v4v', '124v5678')
  
### Chord:



