
###### BUILD SNOTE MAPPER #############################################
build_snote_mapper = function(key = "C", start = 2){
  
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
  
  map2octave = c(rep(start,7), rep(start+1,7), rep(start+2,7), rep(start+3,7))
  
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

# start: which octave number does the first snotes "ormtdli" start from?
# key: which key signature are you using?
snote2note_octave = function(snote, key = 'C', start = 2){
  mapper = build_snote_mapper(key = key)
  snotes = snote %>% strsplit('') %>% unlist
  plus   = which(snotes == '+') - 1
  nega   = which(snotes == '-') - 1
  notes  = mapper$map2note[snotes]
  if(length(plus) > 0){notes[plus] %<>% shift_note(1)}
  if(length(nega) > 0){notes[nega] %<>% shift_note(-1)}
  return(list(
    octaves = mapper$map2octave[snotes] %>% na.omit(),
    notes   = notes[!is.na(notes)]
  ))
}

snote2cpitch = function(...){
  res = snote2note_octave(...)
  return(paste0(res$notes, res$octaves))
}
