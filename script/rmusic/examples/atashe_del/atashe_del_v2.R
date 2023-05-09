library(magrittr)
library(dplyr)
library(rutils)
library(gm)

source("script/rmusic/tools/snote_tools.R")
source("script/rmusic/tools/rm_tools.R")
source("script/rmusic/tools/mpr_tools.R")
source("script/rmusic/tools/tabr_tools.R")
source("script/rmusic/tools/gm_tools.R")

library(readxl)
library(Microsoft365R)

od <- get_personal_onedrive()

destination_path = 'script/rmusic/examples/atashe_del/atashe_del.xlsx'
source_path      = "Documents/songs/unknown_composer/atashe_del/atashe_del.xlsx"

# od$list_items()
od$download_file(source_path, dest = destination_path, overwrite = T)

mpr <- read_excel(destination_path, sheet = 'smelody')


tracks = c('piano_left', 'piano_right', 'voice', 'tar')

# correction only for atashe del
for(tr in tracks){
  mpr[[tr]] %<>% {.[(. == '_')|(.=='')|is.na(.)]<-'__';.}
}  
lambda = function(dot){
  data.frame(chord = paste(dot$chord %>% stringr::str_remove_all(" ") %>% {.[.!=""]} %>% na.omit, collapse = '/'),
             lyrics = paste(dot$lyrics %>% na.omit, collapse = " ")) -> out
  for(tr in tracks){
    split = dot[[tr]] %>% strsplit('_')
    split %>% list.pull(1) %>% paste(collapse = '') %>% 
      paste(split %>% list.pull(2) %>% paste(collapse = ''), sep = '_') -> out[[tr]]
  }
  return(out)
}
mpr %<>% group_by(measure) %>% do({lambda(.)}) %>% ungroup %>% arrange(measure)


for(tr in tracks){
  mpr[[tr]] %<>% {.[(. == '_')|(.=='')|is.na(.)]<-'__';.}
  res = mpr[[tr]] %>% smelody2pitch_rythm(
    starting_octave = chif(tr == 'piano_left', 1, 3),
    key = "Cm")
  
  mpr[[paste(tr, 'pitch', sep = '_')]] <- res$pitch
  mpr[[paste(tr, 'rythm', sep = '_')]] <- res$rythm
  
  mpr %<>% mpr.add_duration(
    cpitch = paste(tr, 'pitch', sep = '_'), 
    rythm  = paste(tr, 'rythm', sep = '_'),  
    output = paste(tr, 'duration', sep = '_'), meter = 3/4)
}

## Convert mpr to rmusic standard dataframe:
song = NULL
tracks_with_lyrics = 'voice'
tracks_with_chord  = c('piano_right', 'piano_left', 'voice')
for(tr in tracks){
  mpr %>% mpr2rmd(
    pitch    = paste(tr, 'pitch', sep = '_'),
    duration = paste(tr, 'duration', sep = '_'),
    lyrics   = rutils::chif(tr %in% tracks_with_lyrics, 'lyrics', NULL),
    chord    = rutils::chif(tr %in% tracks_with_chord, 'chord', NULL), track = tr) %>% bind_rows(song) -> song
}

mpr %>% mpr2rmd(pitch = 'piano_left_pitch', duration = 'piano_left_duration', chord = 'chord', track = 'piano_left') -> song_piano_left
mpr %>% mpr2rmd(pitch = 'piano_right_pitch', duration = 'piano_right_duration', chord = 'chord', track = 'piano_right') -> song_piano_right

mpr %>% mpr2rmd(pitch = 'voice_pitch', duration = 'voice_duration', chord = 'chord', track = 'voice', lyrics = 'lyrics') -> song_voice
mpr %>% mpr2rmd(pitch = 'tar_pitch', duration = 'tar_duration', chord = 'chord', track = 'tar') -> song_tar

# song_piano %>% rbind(song_tar) %>% rbind(song_voice) %>% 
#   rmd2gm(key = "Cm", meter = c(3,4)) -> song
# show(song)

song %>% filter(track %in% c('piano_left', 'piano_right')) %>% 
  rmd2gm(key = "Cm", unit = 1/8, clef = list(piano_left = 'F', piano_right = 'G'), meter = c(3,4)) -> song_piano_gm

song %>% filter(track %in% c('tar', 'voice')) %>% 
  rmd2gm(key = "Cm", unit = 1/8, clef = 'G', meter = c(3,4)) -> song_tarvoice_gm


song_piano_gm %>% show()
song_piano_gm %>% export(dir_path = 'script/rmusic/examples/atashe_del', file_name = 'piano_Cm', formats = 'mid')

# song_tarvoice_gm %>% show()
song_tarvoice_gm %>% export(dir_path = 'script/rmusic/examples/atashe_del', file_name = 'tarvoice_Cm', formats = 'mid')


######
song %>% filter(track == 'piano_right') %>% rmd2tabr(key = "Cm", unit = 1/8, time = "3/4") -> song_piano_right_tabr

song %>% filter(track == 'voice') %>% {.[is.na(.)]<-"";.} %>% 
  rmd2tabr(key = "Cm", unit = 1/8, time = "3/4") -> song_voice_tabr

song %>% filter(track == 'tar')   %>% {.[is.na(.)]<-"";.} %>% 
  rmd2tabr(key = "Cm", unit = 1/8, time = "3/4") -> song_tar_tabr

song_voice_tabr %>% tabr::render_music(
  file = 'script/rmusic/examples/atashe_del/voice_Cm.pdf',
  header = list(
    title = "آتش دل",
    subtitle = "برازنده عبدالحسین شاهکار",
    # composer = "Composer: Abdolhossein Barazandeh",
    album = "Cozy Nava",
    arranger = "تنظیم: نیما رمضانی",
    instrument = "Note sheet for singer",
    meter = "3/4",
    # opus = "opus hastam",
    copyright = "Cozy-Nava Band.",
    # poet = "Poet: Hassan Sadr Salek",
    tagline = "کوزی نوا"
  )
)


song_tar_tabr %>% tabr::render_music(
  file = 'script/rmusic/examples/atashe_del/tar_Cm.pdf',
  header = list(
    title = "آتش دل",
    subtitle = "برازنده عبدالحسین شاهکار",
    # composer = "Composer: Abdolhossein Barazandeh",
    album = "Cozy Nava",
    arranger = "تنظیم: نیما رمضانی",
    instrument = "Note sheet for tar",
    meter = "3/4",
    copyright = "Cozy-Nava Band.",
    tagline = "کوزی نوا"
  )
)




song_piano_right_tabr %>% tabr::render_music(
  file = 'script/rmusic/examples/atashe_del/piano_right_Cm.pdf',
  header = list(
    title = "آتش دل",
    subtitle = "برازنده عبدالحسین شاهکار",
    # composer = "Composer: Abdolhossein Barazandeh",
    album = "Cozy Nava",
    arranger = "تنظیم: نیما رمضانی",
    instrument = "Note sheet for Piano right",
    meter = "3/4",
    # opus = "opus hastam",
    copyright = "Cozy-Nava Band.",
    # poet = "Poet: Hassan Sadr Salek",
    tagline = "کوزی نوا"
  )
)

