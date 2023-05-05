# This example shows how you can easily write notes for a song using snote and smelody functions.
library(magrittr)

source('script/rmus/tools/snote_tools.R')
source('script/rmus/tools/rmus_tools.R')

## Build melody until measure 22:
########################################################
smelody = '2c3CEEDDCCDCa4bc5bDDCCbbCbg6af7EGGGGEEFEC8DEDb9CgED10DCbCfgf11FAAGGFFGFD12Ef19DfCDEDCb21CfabDCba'
smelody %<>% 
  paste0(13, smeasure(., 3) %>% snote_shift(2)) %>% 
  paste0(14, 'DbCb') %>% 
  paste0(15, smeasure(., 13) %>% snote_shift(3)) %>% 
  paste0(16, smeasure(., 8)  %>% snote_shift(3)) %>% 
  paste0(17, 'FbAG') %>% 
  paste0(18, 'GFEF') %>% 
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
  schord = NA,
  rchord = NA
)


## Rythms
########################################################
song$rythm[1] <- '4_0'
song$rythm[2] <- '31_01'
song$rythm[c(3,5,7,11,13,15)] <- '7111111111_1111111111'
song$rythm[c(4,6,12)] <- '31_11'
song$rythm[c(8,16)] <- 'd3_1111'
song$rythm[10] <- '611c444_1111111'
song$rythm[14] <- '5111_1111'
song$rythm[18] <- '611o_1111'
song$rythm[19:22] <- '24112222_11111111'
song$rythm[c(9,17)] <- '9111_1111'

song %<>% apply_rythms


## CHORD Melodies
########################################################
song$schord[c(1:3, 6)] = 'pcacacac'              # Fm
song$schord[4] = 'scgcgcgc'                      # C7/G
song$schord[5] = 'm+cgcgcgc'                     # C7/E
song$schord[c(7, 13, 21)] = 'l+fCfCfCf'          # F7/A
song$schord[c(8,11, 14, 19, 20)] = 'tfDfDfDf'    # Bbm
song$schord[9] = 'se+Ce+Ce+C'                    # C7/G
song$schord[10] = 'pea+cC'                       # F7

song$schord[12] = 'cfEfEfEf'                     # F7/C
song$schord[15] = 'tfD+fD+fD+f'                  # Bb7
song$schord[16] = 'ebGbGbeb'                     # Ebm
song$schord[17] = 'tfDftfD'                     # Bbm
song$schord[18] = 'pea+CFA+OP'                   # F7
song$schord[22] = 'pfCfCfCf'                     # F7

song$schord[1:22] %>% 
  sapply(snote2cpitch, key = 'Fm', start = 3) %>% 
  lapply(paste, collapse = ";") %>% unlist -> song$chord_cpitch

## CHORD Rythms
########################################################
song$rchord[c(1:8,11:16, 18:22)] = '11111111_11111111'      
song$rchord[c(9, 17)] = '1111112_1111111'               
song$rchord[10] = '11114_11111'               

song %>% select(chord_cpitch, rchord) %>% 
  rename(cpitch = chord_cpitch, rythm = rchord) %>% apply_rythms() %>% 
  select(chord_pitch = pitch, chord_duration = duration) %>% cbind(song) -> song


## Convert to standard music dataframe (SMD):
########################################################
# todo for function apply_rythm: consider empty cpitch
song$pitch[1] <- "r"


song %>% mpr2rmusdf -> music_df

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


