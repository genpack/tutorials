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

destination_path = 'script/rmusic/examples/piano_class/elementary.xlsx'
source_path      = "Documents/songs/unknown_composer/piano_class/elementary.xlsx"

# od$list_items()
od$download_file(source_path, dest = destination_path, overwrite = T)

mpr <- read_excel(destination_path, sheet = 'L4')

tracks = list(
  piano_left  = list(chord = 'chord', starting_octave = 2), 
  piano_right = list(chord = 'chord')
)

for(tr in names(tracks)){
  mpr[[tr]] %<>% {.[(. == '_')|(.=='')|is.na(.)]<-'__';.}
}  

mpr %>% mpr.add_tracks_from_smelody(tracks, key = 'C', meter = 4/4) %>% 
  mpr2rmd(tracks) -> song

######

song %>% filter(track %in% c('piano_left', 'piano_right')) %>% 
 rmd2gm(key = "C", unit = 1/8, clef = list(piano_left = 'F', piano_right = 'G'), meter = c(4,4)) -> song_piano_gm

song_piano_gm %>% show()

song_piano_gm %>% export(dir_path = 'script/rmusic/examples/piano_class', file_name = 'L4_piano_C', formats = 'pdf')

######

song %>% filter(track == 'piano_right') %>% {.[is.na(.)]<-"";.} %>%
  rmd2tabr(key = "C", unit = 1/8, time = "4/4", accidentals = NULL) -> song_piano_right_tabr


song_piano_right_tabr %>% tabr::render_music(
  file = 'script/rmusic/examples/piano_class/L4_piano_right_C.pdf',
  header = list(
    title = "Lesson 4",
    subtitle = "Right Hand Practice",
    arranger = "Nima Ramezani",
    meter = "4/4"
  )
)

song %>% filter(track == 'piano_left') %>% {.[is.na(.)]<-"";.} %>%
  rmd2tabr(key = "C", unit = 1/8, time = "4/4", accidentals = NULL) -> song_piano_left_tabr


song_piano_left_tabr %>% tabr::render_music(
  file = 'script/rmusic/examples/piano_class/L4_piano_left_C.pdf',
  header = list(
    title = "Lesson 4",
    subtitle = "Right Hand Practice",
    arranger = "Nima Ramezani",
    meter = "4/4"
  )
)


