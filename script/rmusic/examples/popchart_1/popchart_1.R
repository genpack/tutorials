library(tuneR)
library(tabr)
library(magrittr)
library(dplyr)
library(gm)

source("script/rmusic/tools/rm_tools.R")
source("script/rmusic/tools/mpr_tools.R")
source("script/rmusic/tools/tabr_tools.R")
source("script/rmusic/tools/gm_tools.R")


mid = read_midi("script/rmusic/examples/popchart_1/POPCHORT1_MS.mid")

mid %>% midi2rmd() -> rmd

View(rmd)



rmd %>% rmd2mpr()
