# gm_tools


## todo: add more arguments and customise defaults like Meter, key, Clef, ...
## todo: merge rows for gm to create ties

GMKEY = c(0, -5, 2, -3, 4, -1, -6, 1, -4, 3, -2, 5, -3, 4, -1, -6, 1, -4, 3, -2, 5, 0, -5, 2)
names(GMKEY) = names(KEY2MODE)[1:24]


rmd2gm = function(rmd, key = "Am", clef = 'G', meter = c(4,4), unit = 1/8){
  gmkey = GMKEY[key]    
  rmd %<>% filter(duration > 0)
  rmd$pitch = rmd$note %>% note_octave2pitch(rmd$octave) %>% 
    stringr::str_replace_all(pattern = '_', replacement = '-') %>% 
    toupper
  rmd$pitch[rmd$note == 'r'] <- NA

  if(is.null(rmd$track)){rmd$track = 'melody'}
  tracks = unique(rmd$track)  
  
  if(inherits(clef, 'character') | is.null(clef)){
    clef = rutils::verify(clef, 'character', domain = c('G', 'F', "C"), default = 'G')
    clef = rep(clef, length(tracks)) %>% as.list
    names(clef) <- tracks
  }
  
  clef = rutils::verify(clef, 'list', names_domain = tracks)

  rmd$durchar = tabr::ticks_to_duration(rmd$duration*unit*1920) %>% 
    gsub(pattern = "4", replacement = 'q')
  
  w1 = rmd$durchar %>% length %>% sequence %>% setdiff(grep(rmd$durchar, pattern = '16'))
  rmd$durchar[w1] %<>% gsub(pattern = "1", replacement = 'w')
  w2 = rmd$durchar %>% length %>% sequence %>% setdiff(grep(rmd$durchar, pattern = '32'))
  rmd$durchar[w2] %<>% gsub(pattern = "2", replacement = 'h')
  rmd$durchar[rmd$durchar == 't8'] <- 'q/3'
  m = Music() + Meter(meter[1], meter[2]) + Key(gmkey)
  for(tr in tracks){
    dft = rmd %>% dplyr::filter(track == tr)
    m = m + Line(pitches = dft$pitch %>% stringr::str_remove_all("[()]") %>% strsplit(":"), 
                 durations = dft$durchar %>% as.list,
                 name = tr) + Clef(clef[[tr]], to = tr)
  }
  return(m)  
}