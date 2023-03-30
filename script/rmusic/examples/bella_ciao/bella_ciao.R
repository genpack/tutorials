library(magrittr)
library(dplyr)
library(gm)

source("script/rmusic/tools/rm_tools.R")
source("script/rmusic/tools/mpr_tools.R")
source("script/rmusic/tools/tabr_tools.R")
source("script/rmusic/tools/gm_tools.R")

read.csv('script/rmusic/examples/bella_ciao/bella_ciao.csv') -> mel


### In this file, I am generating a transposed version of the song by 
# converting notes and octaves to semitones, shifting semitones and converting them back to notes and octaves
nonrests = which(mel$note != 'r')

semitones = semitone(notes = mel$note[nonrests], octaves = mel$octave[nonrests])

semitones %>% semitone2note(sharps = 'f') %>% identical(mel$note[nonrests])
semitones %>% semitone2octave() %>% identical(mel$octave[nonrests])

# mel$note[nonrests] = semitones %>% shift_semitone(2) %>% semitone2note(sharps = 'g') # transpose to Am
mel$note[nonrests] = semitones %>% shift_semitone(5) %>% semitone2note() # transpose to Cm
mel$octave[nonrests] = semitones %>% shift_semitone(5) %>% semitone2octave()


mel %>% rmd2gm(key = "Cm", clef = list(melodie = 'G', accord = 'F')) -> song_gm
song_gm %>% show()
song_gm %>% export(dir_path = 'script/rmusic/examples/bella_ciao', file_name = 'bella_ciao_Cm', formats = 'mid')
song_gm %>% export(dir_path = 'script/rmusic/examples/bella_ciao', file_name = 'bella_ciao_Cm', formats = 'pdf')
