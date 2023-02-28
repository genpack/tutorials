library(magrittr)
library(dplyr)
library(tabr)
source('script/tabr/tabr_tools.R')

read.csv('script/gm/data/chamadoona_v2.csv') -> mel


mel %>% musicaidf2tabr(key = "gm") %>% render_music(file = 'script/tabr/data/chamadoona.pdf')



