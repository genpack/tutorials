library(magrittr)
library(dplyr)
library(gm)


read.csv('data/chamadoona.csv') -> mel

View(mel)

is_issue = mel %>% group_by(measure) %>% summarise(sumdur = sum(duration)) %>% 
  pull(sumdur) %>% {.!=1} %>% sum %>% as.logical
is_issue = is_issue & (is.na(mel$octave[mel$note != 'r']) %>% sum)


mel$pitch = mel$note %>% stringr::str_replace(pattern = '_', replacement = '-') %>% 
  toupper %>% paste0(mel$octave)
mel$pitch[mel$note == 'r'] <- NA

melody = Line(pitches = mel$pitch %>% as.list, durations = mel$durint %>% as.list, name = 'Melody')

m = Music() + Meter(4,4) + Key(-2) + melody + Clef('G', to = "Melody")

show(m)
