# This example shows how you can easily write notes for a song using snote and smelody functions.

source('script/rmus/snote_tools.R')
source('script/rmus/rmus_tools.R')

# Build melody until measure 22:
smelody = '2c3CEEDDCCDCa4bc5bDDCCbbCbg6af7EGGGGEEFEC8DEDb9CgED10DCbCfgf11FAAGGFFGFD12Ef19DfCDEDCb21CfabDCba'
smelody %<>% 
  paste0(13, smeasure(., 3) %>% snote_shift(2)) %>% 
  paste0(14, 'DbCb') %>% 
  paste0(15, smeasure(., 13) %>% snote_shift(3)) %>% 
  paste0(16, smeasure(., 8)  %>% snote_shift(3)) %>% 
  paste0(17, 'FbAG') %>% 
  paste0(18, 'GFEFfaCF') %>% 
  paste0(20, smeasure(., 19)) %>% 
  paste0(22, smeasure(., 21)) 
  

sequence(22) %>% 
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
song$rythm[19:22] <- '24112222_11111111'
song$rythm[c(9,17)] <- '9111_1111'


song %>% apply_rythms -> mpr

# todo for function apply_rythm: consider empty cpitch
mpr$pitch[1] <- "r"


mpr %>% mpr2rmusdf -> music_df

# todo for function snote2cpitch: consider bekkars and out of scale notes 
# specified with notation: + - in the snote
music_df$pitch[c(115, 123)] <- 'a4'
music_df$note[c(115, 123)] <- 'a'



View(music_df)
# Isn't this what you wanted?! :-)

###############################################################################

library(dplyr)

music_df %>% filter(note != 'r', measure == 7) %>% pull(pitch) %>% pitch2function(start = "f")
music_df %>% filter(measure == 16) %>% pull(pitch) -> pitch
music_df %>% filter(measure == 16) %>% pull(duration) -> duration
pitchDuration2rythm(pitch, duration)

music_df %>% 
  group_by(measure) %>% 
  do({data.frame(
    func = pitch2function(.$pitch, start = "f"),
    rythm = pitchDuration2rythm(.$pitch, .$duration))}) %>% View



