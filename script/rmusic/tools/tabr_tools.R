# tabr_tools
note_smallest_multiplier = function(v){
  all_integers = function(v, multiplier = 1){
    rutils::equal(multiplier*v, as.integer(multiplier*v), tolerance = 0.000001) %>% {sum(!.) == 0}
  }
  u = 1
  if(!all_integers(v, 256)){
    u = 3
    v = u*v
  }
  rutils::assert(all_integers(v, 256), "todo: write something!")
  
  while (!all_integers(v)){
    u = u*2
    v = u*v
  }
  return(u)
}


# Convert a rmusic data.frame into a tabr music object:
rmd2tabr = function(rmd, unit = 1/8, key = "C", ...){
  # rutils::assert(is_rmd(rmd, unit = unit), "measures do not have equal duration!")
  
  rmd$octave[rmd$note == 'r'] <- ''

  # has3 = which(!rutils::equal(256*rmd$duration, as.integer(256*rmd$duration), tolerance = 0.000001))
  # rmd$duration[has3] = 3*rmd$duration[has3]
  # 
  # cf = note_smallest_multiplier(rmd$duration)
  # rmd$duration = cf*rmd$duration
  # 
  # rmd$durint = 8.0*cf/rmd$duration
  # rmd$durchr = as.character(rmd$durint)
  # w = which(rmd$durint != as.integer(rmd$durint))
  # 
  # # rmd[w,]
  # for (i in w){
  #  breaks = rutils::breaksum_p2(rmd$duration[i]) %>% rev
  #  suffix = rep('.', length(breaks) - 1) %>% paste(collapse = '')
  #  rmd$durchr[i] = as.integer(cf*8/breaks[1]) %>% paste0(suffix)
  # }
  # 
  # rmd$durchr[has3] = paste0('t', rmd$durchr[has3])
  
  durchar = tabr::ticks_to_duration(rmd$duration*unit*1920)
  
  # Apply tags:
  if(!is.null(rmd$tags)){
    # Apply tie tags:
    rmd$note[grep(x = rmd$tags, pattern = 'tie')] %<>% paste0('~') 
  }

  # Apply lyrics:
  if(!is.null(rmd$lyrics)){
    lyrics = tabr::as_lyrics(rmd$lyrics)
  } else {lyrics = NA}
  
  note_octave2pitch(rmd$note, rmd$octave) %>% 
    stringr::str_replace_all(pattern = "[():]", replacement = "") -> pitches
  tabr::as_music(notes = pitches,
           info  = durchar, lyrics = lyrics, 
           labels = rmd$chord, 
           key = key %>% gsub(pattern = "b", replacement = '_') %>% tolower, 
           ...)         
}
