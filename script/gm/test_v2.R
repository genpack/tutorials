library(magrittr)
source('~/Documents/projects/tutorials/script/gm/mustools.R')

# Melody

pitches = '2c3CEEDDCCDCa4bc5bDDCCbbCbg6af7EGGGGEEFEC8DEDb9CgED10DCbCfgf11FAAGGFFGFD12Ef'
pitches %>% 
  paste0(13, measure(., 3) %>% pitch_shift(2)) %>% 
  paste0(14, 'DbCb') %>% 
  paste0(15, measure(., 13) %>% pitch_shift(3)) %>% 
  paste0(16, measure(., 8)  %>% pitch_shift(3)) %>% 
  paste0(17, 'FbAG') %>% 
  paste0(18, 'GFEFfaCF')
  
  


pitches %>% measure(11) %>% pitch_shift(-1)

rythms = c('', '4', '1.o3ovo4ovo', '14','1...ovo', '1444', '1.vo3678', '1..v4v', '124v5678', '1vo3')
  

rythms[6] %>% as.rythm()

### Chord:

as.rythm('1-34') 

"1-v" %>% as.rythm
"1-2" %>% as.rythm
"2-4" %>% as.rythm
"v-.v" %>% as.rythm
"-o234" %>% as.rythm
"-v23." %>% as.rythm

"1-vo23-" %>% as.rythm
  
