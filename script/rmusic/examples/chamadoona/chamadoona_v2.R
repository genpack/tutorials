library(magrittr)
library(dplyr)
library(gm)

source("script/rmusic/tools/rm_tools.R")
source("script/rmusic/tools/mpr_tools.R")
source("script/rmusic/tools/tabr_tools.R")
source("script/rmusic/tools/gm_tools.R")

read.csv('script/rmusic/examples/chamadoona/chamadoona_v2.csv') -> mel


## Make a GM music object:
## 
########################################################
m = mel %>% rmd2gm(key = "Gm", clef = "G", unit = 1/8)

show(m)
show(m, 'audio')


m %>% export(dir_path = 'script/gm/data', file_name = 'chamadoona', formats = 'mid')


## Make a tabr music object:
## 
########################################################
mel %>% rmd2tabr(key = "Gm") -> song_tabr

song_tabr %>% render_music(file = 'script/tabr/data/chamadoona_tabr.pdf')


## Convert to MPR:
## 
########################################################
mel %>% rmd2mpr() -> song
View(song)

# song$chord_function = '13535353_00000000'
# song$chord_rythm = '11111111_11111111'
pick = c(1:4, 7:10) %>% sample(size = 112, replace = T)
song$chord_function = chord_forms_learned$chord_function[pick]
song$chord_rythm    = chord_forms_learned$chord_rythm[pick]

chord_song = song %>% 
  mpr.add_cpitch_from_function(output = 'chord_cpitch', func = 'chord_function', key = 'Melody_chord', starting_octave = 2) %>% 
  mpr.add_duration(cpitch = 'chord_cpitch', rythm = 'chord_rythm', output = 'chord_duration')

chord_song %<>% mpr2rmd(pitch = 'chord_cpitch', duration = 'chord_duration', track = 'Chord', channel = 1)
chord_song$note[is.na(chord_song$note)] <- 'r'
chord_song$duration[is.na(chord_song$duration)] <- 8

mel %>% bind_rows(
  chord_song %>% select(note, duration, octave, measure, track)  
) -> melchord

melchord %>% rmd2gm(key = "Gm", clef = list(Melody = 'G', Chord = 'F'), unit = 1/8) -> song_gm
song_gm %>% show()
song_gm %>% export(dir_path = 'script/rmusic/examples/chamadoona', file_name = 'chamadoona_wc', formats = 'mid')
