library(magrittr)
library(dplyr)
library(gm)

#### For gm:

read.csv('script/gm/data/chamadoona_v2.csv') -> mel
# mel %>% write.csv('script/gm/data/chamadoona.csv', row.names = F)

View(mel)

is_issue = mel %>% group_by(measure) %>% summarise(sumdur = sum(duration)) %>% 
  pull(sumdur) %>% {.!=8} %>% sum %>% as.logical
is_issue = is_issue & (is.na(mel$octave[mel$note != 'r']) %>% sum)

mel %<>% filter(duration > 0)
mel$pitch = mel$note %>% stringr::str_replace(pattern = '_', replacement = '-') %>% 
  toupper %>% paste0(mel$octave)
mel$pitch[mel$note == 'r'] <- NA

melody = Line(pitches = mel$pitch %>% as.list, durations = (mel$duration/2) %>% as.list, name = 'Melody')

m = Music() + Meter(4,4) + Key(-2) + melody + Clef('G', to = "Melody")

show(m)
show(m, 'audio')

m %>% export(dir_path = 'script/gm/data', file_name = 'chamadoona', formats = 'mid')
