
# extracts the given measure number from a s_melody and returns a s_melody associated with the given measure number
# mn: measure number
# Examples:
# s_melody = '2c3CEEDDCCDCa4bc5bDDCCbbCbg6af7EGGGGEEFEC8DEDb9CgED10DCbCfgf11FAAGGFFGFD12Ef'
# s_measure(s_melody, 5)

s_measure = function(s_melody, mn){
  mn %<>% as.integer
  start = stringr::str_locate(s_melody, as.character(mn)) %>% as.integer %>% {.[2]} + 1
  end   = stringr::str_locate(s_melody, as.character(mn+1)) %>% as.integer %>% {.[1]} - 1
  if(is.na(end)){end = nchar(s_melody)}
  out   = substr(s_melody, start, end)
  if(length(grep(out, pattern = "[0-9]")) == 0){return(out)}
  return("")
}