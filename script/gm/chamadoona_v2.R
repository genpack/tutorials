library(magrittr)
library(dplyr)
library(gm)

source("script/gm/gm_tools.R")
#### For gm:

read.csv('script/gm/data/chamadoona_v2.csv') -> mel

# verify mel

m = mel %>% musicaidf2gm()

show(m)
show(m, 'audio')

m %>% export(dir_path = 'script/gm/data', file_name = 'chamadoona', formats = 'mid')
