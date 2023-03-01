# This example shows how you can easily write notes for a song using snote and smelody functions.

source('script/rmus/snote_tools.R')
source('script/rmus/rmus_tools.R')

# Build melody until measure 18:
smelody = '2c3CEEDDCCDCa4bc5bDDCCbbCbg6af7EGGGGEEFEC8DEDb9CgED10DCbCfgf11FAAGGFFGFD12Ef'
smelody %<>% 
  paste0(13, smeasure(., 3) %>% snote_shift(2)) %>% 
  paste0(14, 'DbCb') %>% 
  paste0(15, smeasure(., 13) %>% snote_shift(3)) %>% 
  paste0(16, smeasure(., 8)  %>% snote_shift(3)) %>% 
  paste0(17, 'FbAG') %>% 
  paste0(18, 'GFEFfaCF')


sequence(18) %>% 
  sapply(function(i) smelody %>% 
           smeasure(i) %>% 
           snote2cpitch(key = 'Fm', start = 3)) -> cpitches

song = data.frame(
  cpitch = cpitches %>% lapply(paste, collapse = ";") %>% unlist,
  rythm = NA,
  pitch = NA,
  duration = NA,
  note = NA,
  octave = NA
)

song$rythm[1] <- '4_0'
song$rythm[2] <- '31_01'
song$rythm[c(3,5,7,11,13,15)] <- '7111111111_1111111111'
song$rythm[c(4,6,12)] <- '31_11'
song$rythm[c(8,16)] <- 'd3_1111'
song$rythm[10] <- '611c444_1111111'
song$rythm[14] <- '5111_111'
song$rythm[14] <- '611o_1111'


song %>% apply_rythms %>% View
  
# Isn't this what you wanted?! :-)