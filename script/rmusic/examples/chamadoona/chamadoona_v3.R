library(magrittr)
library(dplyr)
library(gm)

source("script/rmusic/tools/rm_tools.R")
source("script/rmusic/tools/mpr_tools.R")
source("script/rmusic/tools/tabr_tools.R")
source("script/rmusic/tools/gm_tools.R")

read.csv('script/rmusic/examples/chamadoona/chamadoona_v2.csv') -> mel


### In this file, I am generating a transposed version of the song by extracting 
#  functions and applying them on a different scale/mode/start:

nonrests = which(mel$note != 'r')

note_ocvtave2function(notes = mel$note[nonrests], octaves = mel$octave[nonrests], start = 'g') -> song_function

# Now take it to a different mode

function2note_octave(song_function, start = 'c', mode = 3, starting_octave = 3) -> noct

mel$note[nonrests] <- noct$note
mel$octave[nonrests] <- noct$octave

mel %>% rmd2gm(key = "C") -> song_gm
song_gm %>% show()
