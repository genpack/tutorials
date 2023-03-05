# This example shows how you can easily write notes for a song using snote and smelody functions.
library(magrittr)

source('script/rmus/tools/snote_tools.R')
source('script/rmus/tools/rmus_tools.R')

## Build melody until measure 22:
########################################################

song = data.frame(measure = 1:22, melody_snote = NA, melody_rythm = NA, chord_snote = NA, chord_rythm = NA)

song$melody_snote[1] = ''
song$melody_snote[2] = 'c'
song$melody_snote[3] = 'CEEDDCCDCa'
song$melody_snote[4] = 'bc'
song$melody_snote[5] = 'bDDCCbbCbg'
song$melody_snote[6] = 'af'
song$melody_snote[7] = 'EGGGGEEFEC'
song$melody_snote[8] = 'DEDb'
song$melody_snote[9] = 'CgED'
song$melody_snote[10] = 'DCbCfgf'
song$melody_snote[11] = 'FAAGGFFGFD'
song$melody_snote[12] = 'Ef'
song$melody_snote[14] = 'DbCb'
song$melody_snote[17] = 'FbAG'
song$melody_snote[18] = 'GFEF'
song$melody_snote[19] = 'DfCDEDCb'
song$melody_snote[21] = 'CfabDCba'

song$melody_snote[13] = song$melody_snote[3] %>% snote_shift(2)
song$melody_snote[15] = song$melody_snote[13] %>% snote_shift(3)
song$melody_snote[16] = song$melody_snote[8] %>% snote_shift(3)
song$melody_snote[20] = song$melody_snote[19]
song$melody_snote[22] = song$melody_snote[21]

## Rythms
########################################################
song$melody_rythm[1] <- '4_0'
song$melody_rythm[2] <- '31_01'
song$melody_rythm[c(3,5,7,11,13,15)] <- '7111111111_1111111111'
song$melody_rythm[c(4,6,12)] <- '31_11'
song$melody_rythm[c(8,16)] <- 'd3_1111'
song$melody_rythm[10] <- '611c444_1111111'
song$melody_rythm[14] <- '5111_1111'
song$melody_rythm[18] <- '611o_1111'
song$melody_rythm[19:22] <- '24112222_11111111'
song$melody_rythm[c(9,17)] <- '9111_1111'

## CHORD Melodies
########################################################
song$chord_snote[c(1:3, 6)] = 'tcacacac'              # Fm
song$chord_snote[4] = 'scgcgcgc'                      # C7/G
song$chord_snote[5] = 'm+cgcgcgc'                     # C7/E
song$chord_snote[c(7, 13, 21)] = 'l+fCfCfCf'          # F7/A
song$chord_snote[c(8,11, 14, 19, 20)] = 'ifDfDfDf'    # Bbm
song$chord_snote[9] = 'se+Ce+Ce+C'                    # C7/G
song$chord_snote[10] = 'tea+cC'                       # F7

song$chord_snote[12] = 'cfEfEfEf'                     # F7/C
song$chord_snote[15] = 'ifD+fD+fD+f'                  # Bb7
song$chord_snote[16] = 'ebGbGbeb'                     # Ebm
song$chord_snote[17] = 'ifDfifD'                      # Bbm
song$chord_snote[18] = 'tea+CFA+OT'                   # F7
song$chord_snote[22] = 'tfCfCfCf'                     # F7

## CHORD Rythms
########################################################
song$chord_rythm[c(1:8,11:16, 18:22)] = '11111111_11111111'      
song$chord_rythm[c(9, 17)] = '1111112_1111111'               
song$chord_rythm[10] = '11114_11111'            


song %>% mpr.add_cpitch_from_snote(
  snote = 'melody_snote', 
  octave = 3,
  key = "Fm",
  output = 'melody_cpitch') %>% 
  mpr.add_duration(
    cpitch = 'melody_cpitch',
    rythm = 'melody_rythm', 
    output = 'melody_duration') %>% 
  mpr.add_pitch(
    cpitch = 'melody_cpitch',
    rythm = 'melody_rythm', 
    output = 'melody_pitch') %>% 
  mpr.add_cpitch_from_snote(
    snote = 'chord_snote', 
    octave = 2, 
    key = "Fm",
    output = 'chord_cpitch') %>% 
  mpr.add_duration(
    cpitch = 'chord_cpitch',
    rythm = 'chord_rythm',
    output = 'chord_duration') %>% 
  mpr.add_pitch(
    cpitch = 'chord_cpitch',
    rythm = 'chord_rythm',
    output = 'chord_pitch') -> song

song %>%
  mpr.add_function(pitch = 'melody_pitch', output = 'melody_function', start = "f") %>% 
  mpr.add_cpitch_from_function(func = 'melody_function', start = "a") %>% View

song %>% mpr.add_function(pitch = 'chord_pitch', output = 'chord_function', start = "f") %>% View
