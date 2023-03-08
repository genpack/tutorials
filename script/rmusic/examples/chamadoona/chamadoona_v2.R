library(magrittr)
library(dplyr)
library(gm)

source("script/rmusic/tools/gm_tools.R")
source("script/rmusic/tools/rm_tools.R")

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

song$chord_function = '13513153_00011100'
song$chord_function = '13535353_00000000'
song$chord_rythm = '11111111_11111111'

song %>% mpr.add_cpitch_from_function(output = 'chord_cpitch', func = 'chord_function', key = 'Melody_chord') %>% View

