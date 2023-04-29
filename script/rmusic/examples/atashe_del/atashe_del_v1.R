library(magrittr)
library(dplyr)
library(rutils)
library(gm)

source("script/rmusic/tools/snote_tools.R")
source("script/rmusic/tools/rm_tools.R")
source("script/rmusic/tools/mpr_tools.R")
source("script/rmusic/tools/tabr_tools.R")
source("script/rmusic/tools/gm_tools.R")

read.csv('script/rmusic/examples/atashe_del/atashe_del.csv') -> mpr


tracks = c('piano', 'voice', 'tar')
for(tr in tracks){
  mpr[[tr]] %<>% {.[(. == '_')|(.=='')|is.na(.)]<-'__';.}
  res = mpr[[tr]] %>% smelody2pitch_rythm(starting_octave = 3, key = "Cm")
  
  mpr[[paste(tr, 'pitch', sep = '_')]] <- res$pitch
  mpr[[paste(tr, 'rythm', sep = '_')]] <- res$rythm
}

mpr %<>% mpr.add_duration(cpitch = 'piano_pitch', rythm = 'piano_rythm', output = 'piano_duration', meter = 3/4)
mpr %<>% mpr.add_duration(cpitch = 'tar_pitch', rythm = 'tar_rythm', output = 'tar_duration', meter = 3/4)
mpr %<>% mpr.add_duration(cpitch = 'voice_pitch', rythm = 'voice_rythm', output = 'voice_duration', meter = 3/4)

mpr %<>% group_by(measure) %>% 
  summarise(chord = paste(chord, collapse = ' '),
            lyrics = paste(lyrics, collapse = " "),
            piano_pitch = paste(piano_pitch, collapse = ';'),
            piano_duration = paste(piano_duration, collapse = ';'),
            voice_pitch = paste(voice_pitch, collapse = ';'),
            voice_duration = paste(voice_duration, collapse = ';'),
            tar_pitch = paste(tar_pitch, collapse = ';'),
            tar_duration = paste(tar_duration, collapse = ';')) %>% 
  ungroup %>% arrange(measure)

mpr %>% mpr2rmd(pitch = 'piano_pitch', duration = 'piano_duration', chord = 'chord', track = 'piano') -> song_piano
mpr %>% mpr2rmd(pitch = 'voice_pitch', duration = 'voice_duration', chord = 'chord', track = 'voice') -> song_voice
mpr %>% mpr2rmd(pitch = 'tar_pitch', duration = 'tar_duration', chord = 'chord', track = 'tar') -> song_tar

song_piano %>% rbind(song_tar) %>% rbind(song_voice) %>% rmd2gm() -> song
  
