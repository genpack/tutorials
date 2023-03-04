
###### BUILD SNOTE MAPPER #############################################
build_snote_mapper = function(key = "C", start = 2){

  all_snotes = 'ormtslicdefgabCDEFGABORMTSLI' %>% strsplit('') %>% unlist
  snote_mapper = 'cdefgabcdefgabcdefgabcdefgab' %>% 
    strsplit('') %>% unlist %>% {names(.)<-all_snotes;.}
  
  if(key %in% c("Dm", "F")){
    snote_mapper[strsplit('biBI', '') %>% unlist] %<>% paste0('_')
  }
  
  if(key %in% c("G", "Em")){
    snote_mapper[strsplit('gsGS','') %>% unlist] %<>% paste0('#')
  }
  
  if(key %in% c("Gm", "Bb")){
    snote_mapper[strsplit('beimBEIM','') %>% unlist] %<>% paste0('_')
  }
  
  if(key %in% c("D", "Bm")){
    snote_mapper[strsplit('ftcoFTCO','') %>% unlist] %<>% paste0('#')
  }
  
  if(key %in% c("Cm", "Eb")){
    snote_mapper[strsplit('meEMibBIlaAL','') %>% unlist] %<>% paste0('_')
  }

  if(key %in% c("A", "Gbm")){
    snote_mapper[strsplit('cfgotsCFGOTS','') %>% unlist] %<>% paste0('#')
  }
  
  if(key %in% c("Fm", "Ab")){
    snote_mapper[strsplit('meEMibBIlaALdrDR','') %>% unlist] %<>% paste0('_')
  }
  
  if(key %in% c("E", "Dbm")){
    snote_mapper[strsplit('cfgotsCFGOTSdrDR','') %>% unlist] %<>% paste0('#')
  }

  # 5 or more signatures have not been supported yet.
  
  snote_mapper %>% 
    paste0(c(rep(start,7), rep(start+1,7), rep(start+2,7), rep(start+3,7))) %>% 
    {names(.)<-all_snotes;.}
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
snote2cpitch = function(snote, key = 'C', start = 2){
  mapper = build_snote_mapper(key = key, start = start)
  return(mapper[snote %>% strsplit('') %>% unlist])
}