
###### BUILD SNOTE MAPPER #############################################
build_snote_mapper = function(key = "C", starting_octave = 2){
  
  all_snotes = 'ormtslicdefgabCDEFGABORMTSLI' %>% strsplit('') %>% unlist
  map2note = 'cdefgabcdefgabcdefgabcdefgab' %>% 
    strsplit('') %>% unlist %>% {names(.)<-all_snotes;.}
  
  if(key %in% c("Dm", "F")){
    map2note[strsplit('biBI', '') %>% unlist] %<>% paste0('_')
  }
  
  if(key %in% c("G", "Em")){
    map2note[strsplit('gsGS','') %>% unlist] %<>% paste0('#')
  }
  
  if(key %in% c("Gm", "Bb")){
    map2note[strsplit('beimBEIM','') %>% unlist] %<>% paste0('_')
  }
  
  if(key %in% c("D", "Bm")){
    map2note[strsplit('ftcoFTCO','') %>% unlist] %<>% paste0('#')
  }
  
  if(key %in% c("Cm", "Eb")){
    map2note[strsplit('meEMibBIlaAL','') %>% unlist] %<>% paste0('_')
  }
  
  if(key %in% c("A", "Gbm")){
    map2note[strsplit('cfgotsCFGOTS','') %>% unlist] %<>% paste0('#')
  }
  
  if(key %in% c("Fm", "Ab")){
    map2note[strsplit('meEMibBIlaALdrDR','') %>% unlist] %<>% paste0('_')
  }
  
  if(key %in% c("E", "Dbm")){
    map2note[strsplit('cfgotsCFGOTSdrDR','') %>% unlist] %<>% paste0('#')
  }
  
  map2octave = c(rep(starting_octave,7), rep(starting_octave+1,7), rep(starting_octave+2,7), rep(starting_octave+3,7))
  
  map2note %>% paste0(map2octave) -> map2pitch
  
  names(map2note) <- all_snotes 
  names(map2octave) <- all_snotes 
  names(map2pitch) <- all_snotes 
  
  
  # 5 or more signatures have not been supported yet.
  return(list(map2note = map2note, map2octave = map2octave, map2pitch = map2pitch)) 
}

###############################################################################


############################ Function smeasure ################################

# extracts the given measure number from a smelody and returns a smelody associated with the given measure number
# mn: measure number
# Examples:
# s_melody = '2c3CEEDDCCDCa4bc5bDDCCbbCbg6af7EGGGGEEFEC8DEDb9CgED10DCbCfgf11FAAGGFFGFD12Ef'
# s_measure(s_melody, 5)
smeasure = function(smelody, mn){
  mn %<>% as.integer
  start = stringr::str_locate(smelody, as.character(mn)) %>% as.integer %>% {.[2]} + 1
  end   = start + substr(smelody, start, nchar(smelody)) %>% stringr::str_locate("[0-9]") %>% as.integer %>% {.[1]} - 2
  if(is.na(end)){end = nchar(smelody)}
  out   = substr(smelody, start, end)
  if(length(grep(out, pattern = "[0-9]")) == 0){return(out)}
  return("")
}

###############################################################################

############################ Function snote_shift ################################

# shifts a snote by a given number of notes to the right or left. 
# If argument shift is positive, the notes are shifted to the right otherwise to the left
# Example:
# s_melody = '2c3CEEDDCCDCa4bc5bDDCCbbCbg6af7EGGGGEEFEC8DEDb9CgED10DCbCfgf11FAAGGFFGFD12Ef'
# s_melody %>% smeasure(5) %>% snote_shift(-3)
snote_shift = function(snote, shift = 1){
  patn   = 'ormtslicdefgabCDEFGABORMTSLI' %>% strsplit('') %>% unlist
  patt   = patn %>% length %>% sequence
  names(patt) = patn
  
  patn[patt[gsub(snote, pattern = "[0-9]", replacement = '') %>% strsplit('') %>% unlist] + shift] %>% 
    {.[is.na(.)]<-'-';.} %>% paste(collapse = "")
}

###############################################################################

# starting_octave: which octave number does the first snotes "ormtdli" start from?
# key: which key signature are you using?
snote2note_octave = function(snote, ...){
  
  aa = snote %>% strsplit("[()]") %>% unlist
  if(length(aa) > 1){
    notes = c()
    octaves = c()
    for(i in sequence(length(aa))){
      res = aa[i] %>% snote2note_octave(...)
      notes   = c(notes, res$notes)
      octaves = c(octaves, res$octaves)
    }
    return(list(notes = notes, octaves = octaves))
  }
  
  bb = snote %>% strsplit(":") %>% unlist
  if(length(bb) > 1){
    res = bb %>% paste(collapse = '') %>% snote2note_octave(...)
    res$notes %<>% paste(collapse = ':')
    res$notes = paste0('(', res$notes, ')')
    if (length(unique(res$octaves)) > 1){
      res$octaves %<>% paste(collapse = ':')
      res$octaves = paste0('(', res$octaves, ')')
    } else {
      res$octaves %<>% unique
    }
    return(res)
  }
    
  mapper = build_snote_mapper(...)
  snotes = snote %>% strsplit('') %>% unlist
  plus   = which(snotes == '+') - 1
  nega   = which(snotes == '-') - 1
  notes  = mapper$map2note[snotes]
  if(length(plus) > 0){notes[plus] %<>% shift_note(1)}
  if(length(nega) > 0){notes[nega] %<>% shift_note(-1)}
  return(list(
    octaves = mapper$map2octave[snotes] %>% na.omit() %>% unname,
    notes   = notes[!is.na(notes)] %>% unname
  ))
}

snote2cpitch = function(...){
  res = snote2note_octave(...)
  return(paste0(res$notes, res$octaves))
}

snote2rythm_suffix = function(snotes){
  if(length(snotes)>1){return(snotes %>% sapply(snote2rythm_suffix) %>% unlist)}
  if(snotes == ""){return("")}
  aa = snotes %>% strsplit("[()]") %>% unlist
  if(length(aa) == 1){
    bb = aa %>% strsplit("") %>% unlist
    rs = 1 - (bb == 'x')
    return(rs %>% paste(collapse = ""))
  } else {
    rs = ""
    for (i in sequence(length(aa))){
      if(RMUSMOD(i,2) == 0){rs = paste0(rs, 1)} else {rs = paste0(rs, aa[i] %>% snote2rythm_suffix)}
    }
    return(rs)
  }
}

smelody2pitch_rythm = function(smelodies, ...){
  out = list()
  splitted = smelodies %>% strsplit('_') %>% purrr::reduce(rbind)
  if(length(smelodies) == 1){splitted %<>% t}
  splitted %<>% as.data.frame %>% {names(.)<-c('snote', 'srythm');.}
  out$rythm = splitted$srythm %>% paste(splitted$snote %>% snote2rythm_suffix, sep = '_')
  out$rythm[out$rythm == "_"] <- "1_0"
  cpitch = splitted$snote %>% 
    # remove character x ?
    purrr::map(snote2cpitch, ...) %>% 
    lapply(paste, collapse = ";") %>% unlist
  out$pitch = cpitch %>% strsplit(";") %>% purrr::map2(.y = out$rythm, .f = cpitch2pitch) %>% 
    purrr::map(paste, collapse = ';') %>% unlist
  # out$pitch = cpitch %>% cpitch2pitch(rythm = out$rythm)
  return(out)
}
