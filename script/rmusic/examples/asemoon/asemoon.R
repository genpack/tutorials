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

destination_path = 'script/rmusic/examples/asemoon/asemoon.xlsx'
source_path      = "Documents/songs/unknown_composer/asemoon/asemoon.xlsx"

# od$list_items()
od$download_file(source_path, dest = destination_path, overwrite = T)

mpr <- read_excel(destination_path, sheet = 'smelody')

tracks = list(
  piano_left  = list(starting_octave = 2), 
  piano_right = list(),
  voice = list(chord = 'chord', lyrics = 'lyrics'),
  tar = list()
)

for(tr in names(tracks)){
  mpr[[tr]] %<>% {.[(. == '_')|(.=='')|is.na(.)]<-'__';.}
}  

mpr %>% mpr.add_tracks_from_smelody(tracks, key = 'Gm', meter = 3/4, sharps = 'f') %>% 
  mpr2rmd(tracks) -> song

# song %>% filter(track %in% c('piano_left', 'piano_right')) %>% 
#   rmd2gm(key = "Gm", unit = 1/8, clef = list(piano_left = 'F', piano_right = 'G'), meter = c(6,8)) -> song_piano_gm
# 
# song_piano_gm %>% show()
# song_piano_gm %>% export(dir_path = 'script/rmusic/examples/asemoon', file_name = 'piano_Cm', formats = 'mid')
# 
# # song_tarvoice_gm %>% show()
# song_tarvoice_gm %>% export(dir_path = 'script/rmusic/examples/asemoon', file_name = 'tarvoice_Cm', formats = 'mid')
# 
# 
# ######
# song %>% filter(track == 'piano_right') %>% rmd2tabr(key = "Cm", unit = 1/8, time = "3/4") -> song_piano_right_tabr
# 
# song %>% filter(track == 'voice') %>% {.[is.na(.)]<-"";.} %>% 
#   rmd2tabr(key = "Cm", unit = 1/8, time = "3/4") -> song_voice_tabr
# 
# song %>% filter(track == 'tar')   %>% {.[is.na(.)]<-"";.} %>% 
#   rmd2tabr(key = "Cm", unit = 1/8, time = "3/4") -> song_tar_tabr
# 
# song_voice_tabr %>% tabr::render_music(
#   file = 'script/rmusic/examples/atashe_del/voice_Cm.pdf',
#   header = list(
#     title = "آتش دل",
#     subtitle = "برازنده عبدالحسین شاهکار",
#     # composer = "Composer: Abdolhossein Barazandeh",
#     album = "Cozy Nava",
#     arranger = "تنظیم: نیما رمضانی",
#     instrument = "Note sheet for singer",
#     meter = "3/4",
#     # opus = "opus hastam",
#     copyright = "Cozy-Nava Band.",
#     # poet = "Poet: Hassan Sadr Salek",
#     tagline = "کوزی نوا"
#   )
# )
# 
# 
# song_tar_tabr %>% tabr::render_music(
#   file = 'script/rmusic/examples/atashe_del/tar_Cm.pdf',
#   header = list(
#     title = "آتش دل",
#     subtitle = "برازنده عبدالحسین شاهکار",
#     # composer = "Composer: Abdolhossein Barazandeh",
#     album = "Cozy Nava",
#     arranger = "تنظیم: نیما رمضانی",
#     instrument = "Note sheet for tar",
#     meter = "3/4",
#     copyright = "Cozy-Nava Band.",
#     tagline = "کوزی نوا"
#   )
# )
# 
# 
# 
# 
# song_piano_right_tabr %>% tabr::render_music(
#   file = 'script/rmusic/examples/atashe_del/piano_right_Cm.pdf',
#   header = list(
#     title = "آتش دل",
#     subtitle = "برازنده عبدالحسین شاهکار",
#     # composer = "Composer: Abdolhossein Barazandeh",
#     album = "Cozy Nava",
#     arranger = "تنظیم: نیما رمضانی",
#     instrument = "Note sheet for Piano right",
#     meter = "3/4",
#     # opus = "opus hastam",
#     copyright = "Cozy-Nava Band.",
#     # poet = "Poet: Hassan Sadr Salek",
#     tagline = "کوزی نوا"
#   )
# )

